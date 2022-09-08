//
//  MainController.h
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainController : NSViewController

- (void)addOriginImagesWithUrls:(NSArray *)urls;

- (void)importImages;

- (void)clearImages;

- (void)configColors;

- (void)exportImages;

@end

NS_ASSUME_NONNULL_END
