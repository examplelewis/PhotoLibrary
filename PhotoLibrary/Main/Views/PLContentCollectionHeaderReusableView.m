//
//  PLContentCollectionHeaderReusableView.m
//  PhotoLibrary
//
//  Created by 龚宇 on 21/05/23.
//

#import "PLContentCollectionHeaderReusableView.h"

@interface PLContentCollectionHeaderReusableView ()

@property (strong, nonatomic) IBOutlet UILabel *label;

@end

@implementation PLContentCollectionHeaderReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithHexString:@"#f0e9e9"];
}

#pragma mark - Setter
- (void)setHeader:(NSString *)header {
    _header = [header copy];
    
    self.label.text = header;
}

@end
