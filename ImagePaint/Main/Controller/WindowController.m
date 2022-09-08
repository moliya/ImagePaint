//
//  WindowController.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "WindowController.h"
#import "MainController.h"

@interface WindowController ()

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)addAction:(id)sender {
    MainController *vc = (MainController *)self.contentViewController;
    [vc importImages];
}

- (IBAction)clearAction:(id)sender {
    MainController *vc = (MainController *)self.contentViewController;
    [vc clearImages];
}

- (IBAction)configAction:(id)sender {
    MainController *vc = (MainController *)self.contentViewController;
    [vc configColors];
}

- (IBAction)exportAction:(id)sender {
    MainController *vc = (MainController *)self.contentViewController;
    [vc exportImages];
}

@end
