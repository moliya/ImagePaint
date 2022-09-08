//
//  ColorModel.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "ColorModel.h"

@implementation ColorModel

- (NSString *)fromColor {
    if (_fromColor) {
        return _fromColor;
    }
    return @"#000000";
}

@end
