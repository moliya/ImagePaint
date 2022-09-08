//
//  ImageView.m
//  ImagePaint
//
//  Created by carefree on 2022/9/6.
//

#import "ImageView.h"

@interface ImageView()

@property (nonatomic, strong) NSMutableArray    *items;

@end

@implementation ImageView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)event {
    if (self.mouseHandler) {
        self.mouseHandler(event, self);
    }
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    if (self.items.count > 0) {
        NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
        for (NSMenuItem *item in self.items) {
            [menu addItem:item];
        }
        return menu;
    }
    
    return nil;
}

- (void)addMenuItem:(NSMenuItem *)item {
    [self.items addObject:item];
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end
