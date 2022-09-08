//
//  AddCell.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddCell : NSTableCellView

@property (nonatomic, copy) void (^addHandler)(void);

@end

NS_ASSUME_NONNULL_END
