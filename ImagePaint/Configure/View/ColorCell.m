//
//  ColorCell.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "ColorCell.h"
#import "NSColor+Hex.h"

@interface ColorCell ()

@property (weak) IBOutlet NSColorWell *leftColorWell;
@property (weak) IBOutlet NSColorWell *rightColorWell;

@property (weak) IBOutlet NSTextField *indicatorView;

@property (weak) IBOutlet NSTextField *leftLabel;
@property (weak) IBOutlet NSTextField *rightLabel;

@end

@implementation ColorCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setModel:(ColorModel *)model {
    _model = model;
    
    if (model.fromColor.length == 0) {
        self.leftColorWell.color = NSColor.clearColor;
        self.leftLabel.stringValue = @"ClearColor";
    } else {
        self.leftColorWell.color = [NSColor colorWithHexString:model.fromColor];
        self.leftLabel.stringValue = model.fromColor;
    }
    if (model.toColor.length == 0) {
        self.rightColorWell.color = NSColor.clearColor;
        self.rightLabel.stringValue = @"ClearColor";
    } else {
        self.rightColorWell.color = [NSColor colorWithHexString:model.toColor];
        self.rightLabel.stringValue = model.toColor;
    }
}

- (void)updateSelectionStyle:(BOOL)selected {
    if (selected) {
        self.leftLabel.textColor = NSColor.whiteColor;
        self.rightLabel.textColor = NSColor.whiteColor;
        self.indicatorView.textColor = NSColor.whiteColor;
    } else {
        self.leftLabel.textColor = NSColor.textColor;
        self.rightLabel.textColor = NSColor.textColor;
        self.indicatorView.textColor = NSColor.systemGrayColor;
    }
}

- (IBAction)leftColorChanged:(id)sender {
    NSString *hex = self.leftColorWell.color.hexString;
    self.leftLabel.stringValue = hex;
    self.model.fromColor = hex;
}

- (IBAction)rightColorChanged:(id)sender {
    NSString *hex = self.rightColorWell.color.hexString;
    self.rightLabel.stringValue = hex;
    self.model.toColor = hex;
}

@end
