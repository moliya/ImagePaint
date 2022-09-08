//
//  ImageListView.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "ImageListView.h"
#import "ImageView.h"
#import "PasteboardItem.h"

@interface FlippedClipView : NSClipView
@end

@implementation FlippedClipView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (BOOL)isFlipped {
    return YES;
}

@end

@interface ImageListView ()<NSDraggingSource>

@property (nonatomic, strong) NSScrollView  *scrollView;
@property (nonatomic, strong) FlippedClipView *clipView;
@property (nonatomic, strong) NSStackView   *stackView;

@end

@implementation ImageListView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    self.wantsLayer = YES;
    self.layer.cornerRadius = 12;
    
    [self addSubview:self.scrollView];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.scrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    self.scrollView.contentView = self.clipView;
    self.clipView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clipView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor].active = YES;
    [self.clipView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor].active = YES;
    [self.clipView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
    [self.clipView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor].active = YES;
    
    self.scrollView.documentView = self.stackView;
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clipView.leadingAnchor constraintEqualToAnchor:self.stackView.leadingAnchor].active = YES;
    [self.clipView.trailingAnchor constraintEqualToAnchor:self.stackView.trailingAnchor].active = YES;
    [self.clipView.topAnchor constraintEqualToAnchor:self.stackView.topAnchor].active = YES;
}

- (void)copyImage:(NSMenuItem *)sender {
    NSInteger index = sender.tag;
    NSImageView *imgView = self.stackView.arrangedSubviews[index];
    [NSPasteboard.generalPasteboard clearContents];
    [NSPasteboard.generalPasteboard writeObjects:@[imgView.image]];
}

- (void)deleteImage:(NSMenuItem *)sender {
    NSInteger index = sender.tag;
    NSImageView *imgView = self.stackView.arrangedSubviews[index];
    [imgView removeFromSuperview];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.images];
    [arr removeObjectAtIndex:index];
    self.images = arr;
    if (self.deleteHandler) {
        self.deleteHandler();
    }
}

- (void)scrollToBottom {
    [self.scrollView.documentView layoutSubtreeIfNeeded];
    CGFloat height = self.scrollView.documentView.bounds.size.height;
    CGFloat offset = height - self.scrollView.bounds.size.height;
    if (offset < 0) {
        offset = 0;
    }
    NSPoint point = NSMakePoint(0, offset);
    [self.scrollView.contentView scrollToPoint:point];
}

#pragma mark - Override
- (void)setImages:(NSArray<ImageModel *> *)images {
    _images = images;
    [self.stackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    __weak typeof(self) weakSelf = self;
    NSInteger index = 0;
    for (ImageModel *model in images) {
        NSImage *image = [[NSImage alloc] initWithData:model.data];
        ImageView *imgView = [[ImageView alloc] init];
        imgView.image = image;
        imgView.mouseHandler = ^(NSEvent * _Nonnull event, ImageView * _Nonnull targetView) {
            if (!weakSelf.draggable) {
                return;
            }
            PasteboardItem *pasteboard = [[PasteboardItem alloc] init];
            pasteboard.model = model;
            NSDraggingItem *dragging = [[NSDraggingItem alloc] initWithPasteboardWriter:pasteboard];
            dragging.draggingFrame = targetView.bounds;
            [dragging setImageComponentsProvider:^NSArray<NSDraggingImageComponent *> * _Nonnull{
                NSDraggingImageComponent *component = [NSDraggingImageComponent draggingImageComponentWithKey:NSDraggingImageComponentIconKey];
                component.frame = targetView.bounds;
                component.contents = targetView.image;
                
                return @[component];
            }];
            [targetView beginDraggingSessionWithItems:@[dragging] event:event source:weakSelf];
        };
        imgView.translatesAutoresizingMaskIntoConstraints = NO;
        [imgView.widthAnchor constraintEqualToConstant:100].active = YES;
        [imgView.heightAnchor constraintEqualToAnchor:imgView.widthAnchor multiplier:image.size.height / image.size.width].active = YES;
        
        NSMenuItem *copyItem = [[NSMenuItem alloc] initWithTitle:@"Copy(复制)" action:@selector(copyImage:) keyEquivalent:@""];
        copyItem.tag = index;
        NSMenuItem *deleteItem = [[NSMenuItem alloc] initWithTitle:@"Delete(删除)" action:@selector(deleteImage:) keyEquivalent:@""];
        deleteItem.tag = index;
        
        [imgView addMenuItem:copyItem];
        [imgView addMenuItem:deleteItem];
        [self.stackView addArrangedSubview:imgView];
        index = index + 1;
    }
}

#pragma mark - NSDraggingSource
- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationCopy;
}

#pragma mark - Lazyloading
- (NSScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[NSScrollView alloc] init];
    }
    return _scrollView;
}

- (FlippedClipView *)clipView {
    if (!_clipView) {
        _clipView = [[FlippedClipView alloc] init];
    }
    return _clipView;
}

- (NSStackView *)stackView {
    if (!_stackView) {
        _stackView = [[NSStackView alloc] init];
        _stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
        _stackView.alignment = NSLayoutAttributeCenterX;
        _stackView.spacing = 10;
    }
    return _stackView;
}

@end
