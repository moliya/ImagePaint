//
//  DragDropView.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "DragDropView.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "PasteboardItem.h"

@interface DragDropView ()

@property (nonatomic, strong) NSView    *highlightView;

@end

@implementation DragDropView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self registerForDraggedTypes:@[NSPasteboardTypeFileURL, NSPasteboardTypeTIFF, NSPasteboardTypePNG, PasteboardTypeCustom]];
    
    [self addSubview:self.highlightView];
    self.highlightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.highlightView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.highlightView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.highlightView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.highlightView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
}

- (NSDictionary *)readingOptions {
    NSDictionary *options;
    if (@available(macOS 11.0, *)) {
        options = @{
            NSPasteboardURLReadingContentsConformToTypesKey: @[
                UTTypePNG.identifier,
                UTTypeJPEG.identifier,
                UTTypeTIFF.identifier,
                UTTypeBMP.identifier,
                UTTypeHEIF.identifier,
                UTTypeHEIC.identifier
            ]
        };
    } else {
        options = @{
            NSPasteboardURLReadingContentsConformToTypesKey: @[
                (__bridge  NSString *)kUTTypePNG,
                (__bridge  NSString *)kUTTypeJPEG,
                (__bridge  NSString *)kUTTypeJPEG2000,
                (__bridge  NSString *)kUTTypeTIFF,
                (__bridge  NSString *)kUTTypeBMP
            ]
        };
    }
    return options;
}

- (BOOL)checkAcceptForInfo:(id<NSDraggingInfo>)info {
    NSPasteboard *pasteboard = info.draggingPasteboard;
    if ([pasteboard canReadObjectForClasses:@[NSURL.class, PasteboardItem.class] options:[self readingOptions]]) {
        return YES;
    }
    for (NSPasteboardType type in pasteboard.types) {
        if ([type isEqualToString:NSPasteboardTypeTIFF] || [type isEqualToString:NSPasteboardTypePNG]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Drag And Drop
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    BOOL accept = [self checkAcceptForInfo:sender];

    self.highlightView.hidden = !accept;
    return accept ? NSDragOperationCopy : NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    BOOL accept = [self checkAcceptForInfo:sender];
    
    self.highlightView.hidden = !accept;
    return accept ? NSDragOperationCopy : NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = sender.draggingPasteboard;
    NSArray *list = [pasteboard readObjectsForClasses:@[NSURL.class, NSImage.class, PasteboardItem.class] options:[self readingOptions]];
    if (!list) {
        return NO;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (id item in list) {
        if ([item isKindOfClass:NSURL.class]) {
            [arr addObject:item];
        }
        if ([item isKindOfClass:NSString.class]) {
            [arr addObject:[NSURL fileURLWithPath:item]];
        }
        if ([item isKindOfClass:NSImage.class]) {
            [arr addObject:item];
        }
        if ([item isKindOfClass:PasteboardItem.class]) {
            [arr addObject:[(PasteboardItem *)item model]];
        }
    }
    if (self.changeHandler) {
        self.changeHandler(arr);
    }
    return YES;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
    self.highlightView.hidden = YES;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    self.highlightView.hidden = YES;
}

#pragma mark - Lazyloading
- (NSView *)highlightView {
    if (!_highlightView) {
        _highlightView = [[NSView alloc] init];
        _highlightView.wantsLayer = YES;
        _highlightView.layer.borderColor = NSColor.systemBlueColor.CGColor;
        _highlightView.layer.borderWidth = 4;
        _highlightView.layer.cornerRadius = 12;
        _highlightView.hidden = YES;
    }
    return _highlightView;
}

@end
