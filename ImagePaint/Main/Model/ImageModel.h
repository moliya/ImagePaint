//
//  ImageModel.h
//  ImagePaint
//
//  Created by carefree on 2022/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageModel : NSObject

@property (nonatomic, strong) NSData    *data;
@property (nonatomic, copy) NSString    *name;
@property (nonatomic, copy) NSString    *fileType;

@end

NS_ASSUME_NONNULL_END
