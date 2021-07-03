//
//  PLContentView.m
//  PhotoLibrary
//
//  Created by 龚宇 on 2021/7/3.
//

#import "PLContentView.h"

@interface PLContentView ()

@property (nonatomic, copy) NSString *folderPath;

@end

@implementation PLContentView

@synthesize viewModel = _viewModel;

#pragma mark - Lifecycle
- (instancetype)initWithFolderPath:(NSString *)folderPath {
    self = [super init];
    if (self) {
        self.folderPath = folderPath.copy;
        
        
    }
    
    return self;
}

#pragma mark - Getter
- (PLContentViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[PLContentViewModel alloc] initWithFolderPath:self.folderPath];
    }
    
    return _viewModel;
}

@end
