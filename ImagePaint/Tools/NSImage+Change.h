//
//  NSImage+Change.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Cocoa/Cocoa.h>
#import "NSColor+Hex.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (Change)

- (NSImage *)changeFromColor:(NSColor *)color1 toColor:(NSColor *)color2;

- (NSImage *)changeFromColor:(NSColor *)color1 toColor:(NSColor *)color2 withThreshold:(NSInteger)threshold;

- (NSImage *)roundCornersImageCornerRadius:(CGFloat)radius;

- (NSData *)dataForFileType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
