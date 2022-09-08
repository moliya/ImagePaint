//
//  DragDropView.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DragDropView : NSView

@property (nonatomic, copy) void (^changeHandler)(NSArray *urls);

@end

NS_ASSUME_NONNULL_END
