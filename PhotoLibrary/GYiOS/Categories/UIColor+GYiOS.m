//
//  UIColor+GYiOS.m
//  ResourceBox
//
//  Created by 龚宇 on 21/12/29.
//

#import "UIColor+GYiOS.h"

@implementation UIColor (iOS)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    if (![hexString isKindOfClass:[NSString class]] || [hexString length] == 0) {
        [[GYLogManager defaultManager] addDefaultLogWithFormat:@"颜色值出错: %@，返回透明", hexString];
        return [UIColor clearColor];
    }
    
    const char *s = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
    if (*s == '#') {
        ++s;
    }
    unsigned long long value = strtoll(s, nil, 16);
    int r, g, b, a;
    switch (strlen(s)) {
        case 2:
            // xx
            r = g = b = (int)value;
            a = 255;
            break;
        case 3:
            // RGB
            r = ((value & 0xf00) >> 8);
            g = ((value & 0x0f0) >> 4);
            b = ((value & 0x00f) >> 0);
            r = r * 16 + r;
            g = g * 16 + g;
            b = b * 16 + b;
            a = 255;
            break;
        case 6:
            // RRGGBB
            r = (value & 0xff0000) >> 16;
            g = (value & 0x00ff00) >>  8;
            b = (value & 0x0000ff) >>  0;
            a = 255;
            break;
        default:
            // AARRGGBB
            a = (value & 0xff000000) >> 24;
            r = (value & 0x00ff0000) >> 16;
            g = (value & 0x0000ff00) >>  8;
            b = (value & 0x000000ff) >>  0;
            break;
    }
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
}

@end
