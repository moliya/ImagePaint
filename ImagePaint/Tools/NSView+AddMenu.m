//
//  NSView+AddMenu.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "NSView+AddMenu.h"
#import <objc/runtime.h>

@interface NSView (AddMenu)

@property (nonatomic, strong) NSMutableArray    *items;

@end

@implementation NSView (AddMenu)

- (NSMutableArray *)items {
    id obj = objc_getAssociatedObject(self, @selector(items));
    if (obj && [obj isKindOfClass:NSMutableArray.class]) {
        return obj;
    }
    NSMutableArray *arr = [NSMutableArray array];
    objc_setAssociatedObject(self, @selector(items), arr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return arr;
}

+ (void)load {
    method_exchangeImplementations(
                                   class_getInstanceMethod(self, @selector(custom_menuForEvent:)),
                                   class_getInstanceMethod(self, @selector(menuForEvent:))
                                   );
}

- (NSMenu *)custom_menuForEvent:(NSEvent *)event {
    if (self.items.count > 0) {
        NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
        for (NSMenuItem *item in self.items) {
            [menu addItem:item];
        }
        return menu;
    }
    
    return [self custom_menuForEvent:event];
}

- (void)addMenuItem:(NSMenuItem *)item {
    [self.items addObject:item];
}

@end
