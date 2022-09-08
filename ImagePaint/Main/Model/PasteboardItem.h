//
//  PasteboardItem.h
//  ImagePaint
//
//  Created by carefree on 2022/9/7.
//

#import <Cocoa/Cocoa.h>
#import "ImageModel.h"

NS_ASSUME_NONNULL_BEGIN

APPKIT_EXTERN NSString *PasteboardTypeCustom;

@interface PasteboardItem : NSObject<NSPasteboardWriting, NSPasteboardReading>

@property (nonatomic, strong) ImageModel    *model;

@end

NS_ASSUME_NONNULL_END
