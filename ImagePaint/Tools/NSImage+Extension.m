//
//  NSImage+Extension.m
//  ImagePaint
//
//  Created by carefree on 2022/9/6.
//

#import "NSImage+Extension.h"

@implementation NSImage (Extension)

- (NSString *)fileExtension {
    uint8_t c;
    [self.TIFFRepresentation getBytes:&c length:1];
    NSString *extension = @"";
    switch (c) {
        case 0xFF:
            extension = @"jpeg";
            break;
        case 0x89:
            extension = @"png";
        case 0x49:
        case 0x4D:
            extension = @"tiff";
        default:
            break;
    }
    return extension;
}

@end
