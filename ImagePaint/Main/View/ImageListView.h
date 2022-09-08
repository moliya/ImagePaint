//
//  ImageListView.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Cocoa/Cocoa.h>
#import "ImageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageListView : NSView

@property (nonatomic, strong) NSArray<ImageModel *>   *images;
@property (nonatomic, assign) BOOL      draggable;
@property (nonatomic, copy) void (^deleteHandler)(void);

- (void)scrollToBottom;

@end

NS_ASSUME_NONNULL_END
