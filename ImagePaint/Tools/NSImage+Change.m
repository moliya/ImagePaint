//
//  NSImage+Change.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "NSImage+Change.h"
#import <CoreImage/CoreImage.h>
#import "NSImage+Extension.h"

@implementation NSImage (Change)

- (NSImage *)changeFromColor:(NSColor *)color1 toColor:(NSColor *)color2 {
    return [self changeFromColor:color1 toColor:color2 withThreshold:10];
}

- (NSImage *)changeFromColor:(NSColor *)color1 toColor:(NSColor *)color2 withThreshold:(NSInteger)threshold {
    NSColor *inColor = [color1 colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    NSColor *outColor = [color2 colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    
    CIImage *inputImage = [[CIImage alloc] initWithData:[self TIFFRepresentation]];
    
    const unsigned int size = 64;
    
    size_t cubeDataSize = size * size * size * sizeof ( float ) * 4;
    float *cubeData = (float *) malloc ( cubeDataSize );
    float rgb[3];
    
    size_t offset = 0;
    for (int z = 0; z < size; z++)
    {
        rgb[2] = ((double) z) / size; // blue value
        for (int y = 0; y < size; y++)
        {
            rgb[1] = ((double) y) / size; // green value
            for (int x = 0; x < size; x++)
            {
                rgb[0] = ((double) x) / size; // red value
                
                if ([self testColor:rgb withColor:inColor threshold:threshold]) {
                    cubeData[offset]   = outColor.redComponent;
                    cubeData[offset+1] = outColor.greenComponent;
                    cubeData[offset+2] = outColor.blueComponent;
                    cubeData[offset+3] = outColor ? 1.0 : 0.0;
                    //                    NSLog (@"replaced: %f %f %f BY %f %f %f", rgb[0], rgb[1], rgb[2], outColor.redComponent, outColor.greenComponent, outColor.blueComponent);
                } else {
                    cubeData[offset]   = rgb[0];
                    cubeData[offset+1] = rgb[1];
                    cubeData[offset+2] = rgb[2];
                    cubeData[offset+3] = 1.0;
                }
                
                offset += 4;
            }
        }
    }
    
    NSData *data = [NSData dataWithBytesNoCopy:cubeData length:cubeDataSize freeWhenDone:YES];
    CIFilter *colorCube = [CIFilter filterWithName:@"CIColorCube"];
    [colorCube setValue:[NSNumber numberWithInt:size] forKey:@"inputCubeDimension"];
    [colorCube setValue:data forKey:@"inputCubeData"];
    [colorCube setValue:inputImage forKey:kCIInputImageKey];
    CIImage *outputImage = [colorCube outputImage];
    
    NSImage *resultImage = [[NSImage alloc] initWithSize:[outputImage extent].size];
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:outputImage];
    [resultImage addRepresentation:rep];
    
    return resultImage;
}

- (BOOL)testColor:(float[3])color1 withColor:(NSColor *)color2 threshold:(NSInteger)threshold {
    CGFloat offset = threshold / 100.0;
    CGFloat diff1 = fabs(color1[0] - color2.redComponent);
    CGFloat diff2 = fabs(color1[1] - color2.greenComponent);
    CGFloat diff3 = fabs(color1[2] - color2.blueComponent);
    
//    return (diff1 + diff2 + diff3) < offset;
    return diff1 < offset && diff2 < offset && diff3 < offset;
}

void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


- (NSImage *)roundCornersImageCornerRadius:(CGFloat)radius {
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, w, h);
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGImageRef cgImage = [[NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]] CGImage];
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), cgImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    NSImage *tmpImage = [[NSImage alloc] initWithCGImage:imageMasked size:self.size];
    NSData *imageData = [tmpImage TIFFRepresentation];
    NSImage *image = [[NSImage alloc] initWithData:imageData];
    
    return image;
}

- (NSData *)dataForFileType:(NSString *)type {
    NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:self.TIFFRepresentation];
    
    NSBitmapImageFileType imageType = NSBitmapImageFileTypeTIFF;
    if ([type isEqualToString:@"png"]) {
        imageType = NSBitmapImageFileTypePNG;
    }
    if ([type isEqualToString:@"jpg"] || [type isEqualToString:@"jpeg"]) {
        imageType = NSBitmapImageFileTypeJPEG;
    }
    if ([type isEqualToString:@"bmp"]) {
        imageType = NSBitmapImageFileTypeBMP;
    }
    NSData *data = [rep representationUsingType:imageType properties:@{}];
    
    return data;
}

@end
