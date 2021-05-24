//
//  PLUniversalManager.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/24.
//

#import "PLUniversalManager.h"

@implementation PLUniversalManager

#pragma mark - Lifecycle
+ (instancetype)defaultManager {
    static PLUniversalManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[PLUniversalManager alloc] init];
    });
    
    return defaultManager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _rowColumnSpacing = PLRowColumnSpacing;
        _columnsPerRow = PLColumnsPerRow;
    }
    
    return self;
}

#pragma mark - Getter
- (UIEdgeInsets)flowLayoutSectionInset {
    _flowLayoutSectionInset = UIEdgeInsetsMake(self.rowColumnSpacing, self.rowColumnSpacing, self.rowColumnSpacing, self.rowColumnSpacing);
    return _flowLayoutSectionInset;
}

#pragma mark - Setter
- (void)setColumnsPerRow:(NSInteger)columnsPerRow {
    if (_columnsPerRow == columnsPerRow) {
        return;
    }
    
    _columnsPerRow = columnsPerRow;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PLColumnPerRowSliderValueChanged object:nil];
}

@end
