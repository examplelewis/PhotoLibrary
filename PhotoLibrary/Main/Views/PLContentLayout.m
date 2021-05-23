//
//  PLContentLayout.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import "PLContentLayout.h"

@interface PLContentLayout ()

@end

@implementation PLContentLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sectionInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        self.lineSpace = 10;
        self.itemHeight = 200;
    }
    
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
}

@end
