//
//  AddCell.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "AddCell.h"
#import "SYFlatButton.h"

@interface AddCell ()

@property (weak) IBOutlet NSButton *addButton;

@end

@implementation AddCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)addAction:(id)sender {
    if (self.addHandler) {
        self.addHandler();
    }
}

@end
