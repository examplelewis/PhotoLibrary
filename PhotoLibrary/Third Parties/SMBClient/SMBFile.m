// -----------------------------------------------------------------------------
// This file is part of SMBClient.
// Copyright © 2016 Naxos Software Solutions GmbH.
//
// Author: Martin Schaefer <martin.schaefer@naxos-software.de>
//
// SMBClient is licensed under the GNU Lesser General Public License version 2.1
// or later
// -----------------------------------------------------------------------------
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
// -----------------------------------------------------------------------------

#import "SMBFile_Protected.h"
#import "SMBShare_Protected.h"
#import "SMBError.h"

#import "smb_file.h"

@interface SMBFile ()

@property (nonatomic) dispatch_queue_t serialQueue;
@property (nonatomic) smb_fd fileID;

@end

@implementation SMBFile

+ (instancetype)rootOfShare:(SMBShare *)share {
    SMBFile *root = [[self alloc] initWithPath:@"/" share:share];
    
    root.smbStat = [SMBStat statForRoot];
    
    return root;
}

+ (nullable instancetype)fileWithPath:(nonnull NSString *)path share:(nonnull SMBShare *)share {
    return [[self alloc] initWithPath:path share:share];
}

+ (nullable instancetype)fileWithPath:(nonnull NSString *)path relativeToFile:(nonnull SMBFile *)file {
    return [[self alloc] initWithPath:path relativeToFile:file];
}

- (instancetype)initWithPath:(NSString *)path share:(SMBShare *)share {
    self = [super init];
    if (self) {
        NSString *queueName = [NSString stringWithFormat:@"smb_file_queue_%@", path];

        _path = path;
        _share = share;
        _serialQueue = dispatch_queue_create(queueName.UTF8String, DISPATCH_QUEUE_SERIAL);

        if ([_path isEqualToString:@"/"]) {
            self.smbStat = [SMBStat statForRoot];
        } else {
            if (![_path hasPrefix:@"/"]) {
                _path = [@"/" stringByAppendingString:_path];
            }
            
            if ([_path hasSuffix:@"/"]) {
                _path = [_path substringToIndex:_path.length - 1];
            }
        }
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path relativeToFile:(SMBFile *)file {
    NSString *p = file.path;
    
    if (file.isDirectory) {
        p = [p stringByAppendingString:@"/"];
    }
    
    NSURL *url = [NSURL fileURLWithPath:p];
    NSString *absolutePath = [NSURL fileURLWithPath:path relativeToURL:url].path;
    
    return [self initWithPath:absolutePath share:file.share];
}

- (NSString *)description {
    if (_smbStat) {
        return [NSString stringWithFormat:@"%@ (%@)", _path, _smbStat.description];
    } else {
        return _path;
    }
}

#pragma mark - Public methods

- (SMBFile *)parent {
    SMBFile *parent = nil;
    NSString *path;
    
    if ([self.path isEqualToString:@"/"]) {
        path = nil;
    } else {
        path = [self.path stringByDeletingLastPathComponent];
    }
    
    if (path.length) {
        parent = [[SMBFile alloc] initWithPath:path share:self.share];
    }
    
    return parent;
}

- (void)open:(SMBFileMode)mode completion:(nullable void (^)(NSError *_Nullable))completion {

    dispatch_async(_serialQueue, ^{
    
        [self.share openFile:self.path mode:mode completion:^(SMBFile *file, smb_fd fileID, NSError *error) {
            if (error == nil) {
                self->_fileID = fileID;
                self->_smbStat = file.smbStat;
            }
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
        }];
    });
    
}

- (void)close:(nullable void (^)(NSError *_Nullable))completion {

    dispatch_async(_serialQueue, ^{

        if (self->_fileID == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([SMBError notOpenError]);
            });
        } else {
            [self.share closeFile:self->_fileID path:self.path completion:^(SMBFile *file, NSError * _Nullable error) {
                if (error == nil) {
                    self->_fileID = 0;
                    self->_smbStat = file.smbStat;
                }
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(error);
                    });
                }
            }];
            
        }
    });
}

- (BOOL)isOpen {
    return _fileID > 0;
}

- (void)seek:(unsigned long long)offset absolute:(BOOL)absolute completion:(nullable void (^)(unsigned long long, NSError *_Nullable))completion {
    
    dispatch_async(_serialQueue, ^{
        
        NSError *error = nil;
        unsigned long long position = 0;

        if (self.share.server.smbSession) {
            if ([self isOpen]) {
                
                off_t pos = smb_fseek(self.share.server.smbSession, self->_fileID, offset, absolute ? SMB_SEEK_SET : SMB_SEEK_CUR);
                
                position = MAX(0L, pos);
                
                if (pos < 0L) {
                    error = [SMBError seekError];
                }
                
            } else {
                error = [SMBError notOpenError];
            }
        } else {
            error = [SMBError notConnectedError];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(position, error);
            });
        }

    });
}

- (void)read:(NSUInteger)bufferSize progress:(nullable BOOL (^)(unsigned long long, NSData *_Nullable, BOOL, NSError *_Nullable))progress {
    [self read:bufferSize maxBytes:0 progress:progress];
}

- (void)read:(NSUInteger)bufferSize maxBytes:(unsigned long long)maxBytes progress:(nullable BOOL (^)(unsigned long long, NSData *_Nullable, BOOL, NSError *_Nullable))progress {
    
    dispatch_async(_serialQueue, ^{
        
        NSError *error = nil;
        __block BOOL finished = NO;
        unsigned long long bytesReadTotal = 0;
        
        if (self.share.server.smbSession) {
            if ([self isOpen]) {
                
                char buf[bufferSize];
                
                if (progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BOOL readMore = progress(bytesReadTotal, nil, NO, error);
                        
                        if (!readMore) {
                            finished = YES;
                        }
                    });
                }
                
                while (!finished) {
                    
                    NSUInteger bytesToRead = maxBytes == 0 ? bufferSize : MIN(bufferSize, (NSUInteger)(maxBytes - bytesReadTotal));
                    long bytesRead = smb_fread(self.share.server.smbSession, self->_fileID, buf, bytesToRead);
                    
                    if (bytesRead < 0) {
                        finished = YES;
                        error = [SMBError readError];
                    } else if (bytesRead == 0) {
                        finished = YES;
                    } else {
                        bytesReadTotal += bytesRead;
                        
                        if (bytesReadTotal == maxBytes) {
                            finished = YES;
                        }
                        
                        if (progress) {
                            NSData *data = [NSData dataWithBytes:buf length:bytesRead];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                BOOL readMore = progress(bytesReadTotal, data, NO, error);
                                
                                if (!readMore) {
                                    finished = YES;
                                }
                            });
                        }
                    }
                }
            } else {
                finished = YES;
                error = [SMBError notOpenError];
            }
        } else {
            finished = YES;
            error = [SMBError notConnectedError];
        }
        
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(bytesReadTotal, nil, YES, error);
            });
        }
    });
}

- (void)write:(nonnull NSData *_Nullable (^)(unsigned long long))dataHandler progress:(nullable void (^)(unsigned long long, long, BOOL, NSError *_Nullable))progress {

    dispatch_async(_serialQueue, ^{
    
        NSError *error = nil;
        unsigned long long offset = 0;
        BOOL finished = NO;

        if (self.share.server.smbSession) {
            if ([self isOpen]) {
                
                NSData *data;
                
                if (progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progress(offset, 0, finished, error);
                    });
                }

                while (!finished) {

                    data = dataHandler(offset);
                    
                    if (data.length == 0) {
                        finished = YES;
                    } else {
                        long bytesToWrite = data.length;
                        long bytesWritten = smb_fwrite(self.share.server.smbSession, self->_fileID, (void *)data.bytes, bytesToWrite);
                        
                        offset += MAX(0, bytesWritten);
                        
                        if (bytesWritten != bytesToWrite) {
                            finished = YES;
                            error = [SMBError writeError];
                        } else {
                            if (progress) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    progress(offset, MAX(0, bytesWritten), finished, error);
                                });
                            }
                        }
                    }
                }
            } else {
                finished = YES;
                error = [SMBError notOpenError];
            }
        } else {
            finished = YES;
            error = [SMBError notConnectedError];
        }
        
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(offset, 0, finished, error);
            });
        }
    });
}

- (void)listFiles:(nullable void (^)(NSArray<SMBFile *> *_Nullable, NSError *_Nullable))completion {
    [self listFilesUsingFilter:nil completion:completion];
}

- (void)listFilesUsingFilter:(nullable BOOL (^)(SMBFile *_Nonnull file))filter completion:(nullable void (^)(NSArray<SMBFile *> *_Nullable files, NSError *_Nullable error))completion {
    //if (_smbStat == nil || !self.exists) {
        [self updateStatus:^(NSError *error) {
            if (error) {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, error);
                    });
                }
            } else if (!self.hasStatus || !self.isDirectory) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, [SMBError notSuchFileOrDirectory]);
                });
            } else {
                [self.share listFiles:self.path filter:filter completion:completion];
            }
        }];
    //} else {
    //    [self.share listFiles:self.path filter:filter completion:completion];
    //}
}

- (void)updateStatus:(nullable void (^)(NSError *_Nullable))completion {
    [self.share getStatusOfFile:self.path completion:^(SMBStat * _Nullable smbStat, NSError * _Nullable error) {
        if (error == nil) {
            self->_smbStat = smbStat;
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

- (void)createDirectory:(nullable void (^)(NSError *_Nullable))completion {
    [self.share createDirectory:self.path completion:^(SMBFile * _Nullable file, NSError * _Nullable error) {
        if (error == nil) {
            self->_smbStat = file.smbStat;
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

- (void)createDirectories:(nullable void (^)(NSError *_Nullable))completion {
    [self.share createDirectories:self.path completion:^(SMBFile * _Nullable file, NSError * _Nullable error) {
        if (error == nil) {
            self->_smbStat = file.smbStat;
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

- (void)delete:(nullable void (^)(NSError *_Nullable))completion {
    [self.share deleteFile:self.path completion:^(NSError * _Nullable error) {
        if (error == nil) {
            self->_smbStat = [SMBStat statForNonExistingFile];
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

- (void)moveTo:(nonnull NSString *)path completion:(nullable void (^)(NSError *_Nullable))completion {
    SMBFile *f = [SMBFile fileWithPath:path relativeToFile:self];
    
    [self.share moveFile:self.path to:f.path completion:^(SMBFile *_Nullable newFile, NSError * _Nullable error) {
        if (error == nil) {
            self->_smbStat = newFile.smbStat;
            self->_path = newFile.path;
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    }];
}

#pragma mark - Overwritten getters and setters

- (NSString *)name {
    return _path.pathComponents.lastObject;
}

- (BOOL)exists {
    return self.smbStat.exists;
}

- (BOOL)isDirectory {
    return self.smbStat.isDirectory;
}

- (unsigned long long)size {
    return self.smbStat.size;
}

- (NSDate *)creationTime {
    return self.smbStat.creationTime;
}

- (NSDate *)modificationTime {
    return self.smbStat.modificationTime;
}

- (NSDate *)accessTime {
    return self.smbStat.accessTime;
}

- (NSDate *)writeTime {
    return self.smbStat.writeTime;
}

- (NSDate *)statusTime {
    return self.smbStat.statTime;
}

- (BOOL)hasStatus {
    return self.smbStat != nil;
}

@end
