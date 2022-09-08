//
//  ConfigureController.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigureController : NSViewController

@property (nonatomic, strong) NSArray   *colors;
@property (nonatomic, copy) void (^confirmHandler)(NSArray *colors, NSInteger threshold, CGFloat cornerRadius);

@end

NS_ASSUME_NONNULL_END
