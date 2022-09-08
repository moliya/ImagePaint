//
//  MainController.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "MainController.h"
#import <UserNotifications/UserNotifications.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "ConfigureController.h"
#import "DragDropView.h"
#import "ImageListView.h"
#import "NSImage+Change.h"
#import "ColorModel.h"
#import "SYFlatButton.h"
#import "ImageModel.h"
#import "NSImage+Extension.h"

@interface MainController ()

@property (weak) IBOutlet DragDropView  *dragableView;
@property (weak) IBOutlet ImageListView *originListView;
@property (weak) IBOutlet ImageListView *resultListView;
@property (weak) IBOutlet NSTextField   *tipLabel;

@property (nonatomic, strong) NSMutableArray<ColorModel *>  *configList;
@property (nonatomic, assign) CGFloat threshold;
@property (nonatomic, assign) CGFloat cornerRadius;

@end

@implementation MainController

#pragma mark - Private
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.threshold = [NSUserDefaults.standardUserDefaults floatForKey:@"ColorThreshold"];
    if (self.threshold <= 0) {
        self.threshold = 0.1;
    }
    
    self.cornerRadius = [NSUserDefaults.standardUserDefaults floatForKey:@"ColorCornerRadius"];
    
    NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"ColorItems"];
    if (items) {
        for (NSDictionary *dict in items) {
            ColorModel *model = [[ColorModel alloc] init];
            model.fromColor = [dict objectForKey:@"fromColor"];
            model.toColor = [dict objectForKey:@"toColor"];
            [self.configList addObject:model];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    self.dragableView.changeHandler = ^(NSArray * _Nonnull urls) {
        [weakSelf addOriginImagesWithUrls:urls];
    };
    
    self.originListView.deleteHandler = ^{
        weakSelf.tipLabel.hidden = weakSelf.originListView.images.count > 0;
    };
    self.resultListView.draggable = YES;
}

- (void)addOriginImagesWithUrls:(NSArray *)urls {
    NSMutableArray *images = [NSMutableArray array];
    for (id item in urls) {
        ImageModel *model = [[ImageModel alloc] init];
        
        if ([item isKindOfClass:NSURL.class]) {
            NSURL *url = item;
            model.name = url.lastPathComponent;
            model.fileType = url.pathExtension;
            model.data = [NSData dataWithContentsOfURL:url];
            if (!model.data) {
                continue;
            }
        } else if ([item isKindOfClass:NSImage.class]) {
            NSImage *image = item;
            model.name = [NSString stringWithFormat:@"%f.%@", NSDate.date.timeIntervalSince1970, image.fileExtension];
            model.fileType = image.fileExtension;
            model.data = image.TIFFRepresentation;
        } else if ([item isKindOfClass:ImageModel.class]) {
            model = item;
        }
        
        [images addObject:model];
    }
    NSMutableArray *list = [NSMutableArray array];
    if (self.originListView.images) {
        [list addObjectsFromArray:self.originListView.images];
    }
    [list addObjectsFromArray:images];
    self.originListView.images = list;
    self.tipLabel.hidden = list.count > 0;
    [self.originListView scrollToBottom];
}

- (IBAction)changeAction:(id)sender {
    [self startTransform:sender withThreshold:self.threshold];
}

- (void)startTransform:(SYFlatButton *)sender withThreshold:(CGFloat)threshold {
    sender.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *images = [NSMutableArray array];
        for (ImageModel *imageModel in self.originListView.images) {
            NSImage *image = [[NSImage alloc] initWithData:imageModel.data];
            if (!image) {
                continue;
            }
            NSData *data;
            for (ColorModel *model in self.configList) {
                image = [image changeFromColor:[NSColor colorWithHexString:model.fromColor] toColor:[NSColor colorWithHexString:model.toColor] withThreshold:threshold];
                if (self.cornerRadius > 0) {
                    image = [image roundCornersImageCornerRadius:self.cornerRadius];
                }
                data = [image dataForFileType:imageModel.fileType];
            }
            ImageModel *result = [[ImageModel alloc] init];
            result.data = data;
            result.name = imageModel.name;
            result.fileType = imageModel.fileType;
            [images addObject:result];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultListView.images = images;
            sender.enabled = YES;
        });
    });
}

- (void)saveImagesAtPath:(NSString *)path {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateStyle = NSDateFormatterShortStyle;
        fmt.timeStyle = NSDateFormatterMediumStyle;
        fmt.locale = NSLocale.systemLocale;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *newPath = [path stringByAppendingFormat:@"/ImagePaint %@", [fmt stringFromDate:NSDate.date]];
        
        NSError *error;
        BOOL ret = [fileManager createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!ret) {
            [self sendNotification:error.localizedDescription];
            return;
        }
        NSMutableSet *names = [NSMutableSet set];
        NSMutableArray *saveNames = [NSMutableArray array];
        for (ImageModel *model in self.resultListView.images) {
            NSString *fileName = model.name;
            if ([names containsObject:fileName]) {
                NSInteger count = 0;
                NSString *pureName = [fileName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", model.fileType] withString:@""];
                do {
                    count = count + 1;
                    fileName = [NSString stringWithFormat:@"%@(%zi).%@", pureName, count, model.fileType];
                } while ([names containsObject:fileName]);
            }
            
            [names addObject:fileName];
            [saveNames addObject:fileName];
        }
        NSInteger count = 0;
        for (NSInteger i = 0; i < self.resultListView.images.count; i ++) {
            ImageModel *model = self.resultListView.images[i];
            NSString *filename = saveNames[i];
            
            NSString *filePath = [newPath stringByAppendingFormat:@"/%@", filename];
            BOOL success = [fileManager createFileAtPath:filePath contents:model.data attributes:nil];
            if (success) {
                count = count + 1;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendNotification:[NSString stringWithFormat:@"%zi Exported!", count]];
            [NSWorkspace.sharedWorkspace openFile:newPath];
        });
    });
}

- (void)sendNotification:(NSString *)message {
    if (@available(macOS 10.14, *)) {
        UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!granted) {
                [self sendAlert:message];
                return;
            }
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = @"Prompt";
            content.body = message;
            content.sound = UNNotificationSound.defaultSound;
            
            NSString *identifier = [NSString stringWithFormat:@"NOTIFICATION%.0f", NSDate.date.timeIntervalSince1970];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:nil];
            
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    [self sendAlert:message];
                }
            }];
        }];
    } else {
        [self sendAlert:message];
    }
}

- (void)sendAlert:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleInformational;
        [alert addButtonWithTitle:@"OK"];
        alert.messageText = @"Prompt";
        alert.informativeText = message;
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    });
}

- (void)setThreshold:(CGFloat)threshold {
    _threshold = threshold;
    [NSUserDefaults.standardUserDefaults setFloat:threshold forKey:@"ColorThreshold"];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [NSUserDefaults.standardUserDefaults setFloat:cornerRadius forKey:@"ColorCornerRadius"];
}

#pragma mark - Public
- (void)importImages {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = YES;
    if (@available(macOS 11.0, *)) {
        panel.allowedContentTypes = @[
            UTTypePNG,
            UTTypeJPEG,
            UTTypeTIFF,
            UTTypeBMP,
            UTTypeHEIC,
            UTTypeHEIF
        ];
    } else {
        panel.allowedFileTypes = @[@"png", @"jpg", @"jpeg", @"tiff", @"bmp", @"heic", @"heif"];
    }
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    
    NSModalResponse resp = [panel runModal];
    if (resp == NSModalResponseOK) {
        [self addOriginImagesWithUrls:panel.URLs];
    }
}

- (void)clearImages {
    self.originListView.images = @[];
    self.resultListView.images = @[];
    self.tipLabel.hidden = NO;
}

- (void)configColors {
    ConfigureController *vc = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"config"];
    vc.colors = self.configList;
    vc.confirmHandler = ^(NSArray * _Nonnull colors, CGFloat threshold, CGFloat cornerRadius) {
        [self.configList removeAllObjects];
        [self.configList addObjectsFromArray:colors];
        NSMutableArray *arr = [NSMutableArray array];
        for (ColorModel *model in self.configList) {
            [arr addObject:@{
                @"fromColor": model.fromColor,
                @"toColor": model.toColor ?: @""
            }];
        }
        [NSUserDefaults.standardUserDefaults setObject:arr forKey:@"ColorItems"];
        self.threshold = threshold;
        self.cornerRadius = cornerRadius;
    };
    
    [self presentViewControllerAsModalWindow:vc];
}

- (void)exportImages {
    if (self.resultListView.images.count == 0) {
        [self sendNotification:@"no images"];
        return;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:NSApp.mainWindow completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK) {
            return;
        }
        [self saveImagesAtPath:panel.URL.path];
    }];
}

#pragma mark - Lazyloading
- (NSMutableArray<ColorModel *> *)configList {
    if (!_configList) {
        _configList = [NSMutableArray array];
    }
    return _configList;
}

@end
