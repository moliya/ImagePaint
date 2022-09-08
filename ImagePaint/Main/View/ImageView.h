//
//  ImageView.h
//  ImagePaint
//
//  Created by carefree on 2022/9/6.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageView : NSImageView

@property (nonatomic, copy) void (^mouseHandler)(NSEvent *event, ImageView *targetView);

- (void)addMenuItem:(NSMenuItem *)item;

@end

NS_ASSUME_NONNULL_END
