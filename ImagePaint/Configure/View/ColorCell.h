//
//  ColorCell.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Cocoa/Cocoa.h>
#import "ColorModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColorCell : NSTableCellView

@property (nonatomic, strong) ColorModel    *model;

- (void)updateSelectionStyle:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
