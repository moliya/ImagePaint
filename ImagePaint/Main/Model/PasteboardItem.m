//
//  PasteboardItem.m
//  ImagePaint
//
//  Created by carefree on 2022/9/7.
//

#import "PasteboardItem.h"

NSString *PasteboardTypeCustom = @"com.carefree.ImagePaint.Action";

@implementation PasteboardItem

- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[PasteboardTypeCustom];
}

- (nullable id)pasteboardPropertyListForType:(nonnull NSPasteboardType)type {
    if ([type isEqualToString:PasteboardTypeCustom]) {
        NSDictionary *dict = @{
            @"data": self.model.data,
            @"name": self.model.name ?: @"",
            @"fileType": self.model.fileType ?: @""
        };
        
        return dict;
    }
    return nil;
}

+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[PasteboardTypeCustom];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard {
    return NSPasteboardReadingAsPropertyList;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type {
    if ([type isEqualToString:PasteboardTypeCustom]) {
        if (!propertyList) {
            return nil;
        }
        if (![propertyList isKindOfClass:NSDictionary.class]) {
            return nil;
        }
        NSDictionary *dict = propertyList;
        ImageModel *model = [[ImageModel alloc] init];
        model.data = [dict objectForKey:@"data"];
        model.name = [dict objectForKey:@"name"];
        model.fileType = [dict objectForKey:@"fileType"];
        
        PasteboardItem *item = [[PasteboardItem alloc] init];
        item.model = model;
        return item;
    }
    return nil;
}

@end
