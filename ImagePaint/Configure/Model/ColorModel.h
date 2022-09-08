//
//  ColorModel.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorModel : NSObject

@property (nonatomic, copy) NSString    *fromColor;
@property (nonatomic, copy) NSString    *toColor;

@end

NS_ASSUME_NONNULL_END
