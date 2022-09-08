//
//  NSColor+Hex.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColor (Hex)

+ (NSColor *)colorWithHexString:(NSString *)hexString;

- (NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
