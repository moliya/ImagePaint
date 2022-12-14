//
//  ConfigureController.m
//  ImagePaint
//
//  Created by carefree on 2022/9/5.
//

#import "ConfigureController.h"
#import "AddCell.h"
#import "ColorCell.h"

@interface ConfigureController ()<NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate>

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *rangField;
@property (weak) IBOutlet NSTextField *radiusField;

@property (nonatomic, strong) NSMutableArray *colorList;

@property (nonatomic, assign) NSInteger lastSelectedRow;

@end

@implementation ConfigureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    
    NSInteger threshold = [NSUserDefaults.standardUserDefaults integerForKey:@"ColorThreshold"];
    NSString *str = [NSString stringWithFormat:@"%zi", threshold];
    self.rangField.stringValue = str;
    
    CGFloat cornerRadius = [NSUserDefaults.standardUserDefaults floatForKey:@"ColorCornerRadius"];
    str = [NSString stringWithFormat:@"%.2f", cornerRadius];
    if ([str hasSuffix:@"0"] && [str containsString:@"."]) {
        str = [str substringToIndex:str.length - 1];
    }
    if ([str hasSuffix:@"0"] && [str containsString:@"."]) {
        str = [str substringToIndex:str.length - 1];
    }
    if ([str hasSuffix:@"."]) {
        str = [str substringToIndex:str.length - 1];
    }
    self.radiusField.stringValue = str;
    
    for (ColorModel *model in self.colors) {
        [self.colorList addObject:model];
    }
}

- (void)keyDown:(NSEvent *)event {
    if (event.keyCode == 51) {
        // 删除
        if (self.tableView.selectedRow >= 0 && self.tableView.selectedRow < self.colorList.count) {
            [self deleteCellAtIndex:self.tableView.selectedRow];
        }
    }
    if (event.keyCode == 36) {
        // 回车
        [self confirmAction:nil];
    }
}

- (void)addAction {
    [self.colorList addObject:[ColorModel new]];
    [self.tableView reloadData];
}

- (void)deleteCellAtIndex:(NSInteger)index {
    [self.colorList removeObjectAtIndex:index];
    [self.tableView reloadData];
}

- (IBAction)confirmAction:(id)sender {
    if (self.confirmHandler) {
        self.confirmHandler(self.colorList, self.rangField.stringValue.floatValue, self.radiusField.stringValue.floatValue);
    }
    [self.view.window close];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.colorList.count + 1;
}

#pragma mark - NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    __weak typeof(self) weakSelf = self;
    if (row >= self.colorList.count) {
        AddCell *cell = [tableView makeViewWithIdentifier:@"add" owner:self];
        cell.addHandler = ^{
            [weakSelf addAction];
        };
        return cell;
    }
    ColorCell *cell = [tableView makeViewWithIdentifier:@"cell" owner:self];
    cell.model = self.colorList[row];
    [cell updateSelectionStyle:NO];
    return cell;
}

- (void)tableViewSelectionIsChanging:(NSNotification *)notification {
    if (self.lastSelectedRow != self.tableView.selectedRow) {
        ColorCell *oldCell = [self.tableView viewAtColumn:0 row:self.lastSelectedRow makeIfNecessary:NO];
        [oldCell updateSelectionStyle:NO];
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if (tableView.selectedRow == row) {
        return YES;
    }
    if (row >= self.colorList.count) {
        return NO;
    }
    if (tableView.selectedRow >= 0) {
        ColorCell *oldCell = [tableView viewAtColumn:0 row:tableView.selectedRow makeIfNecessary:NO];
        [oldCell updateSelectionStyle:NO];
    }
    
    ColorCell *newCell = [tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    [newCell updateSelectionStyle:YES];
    self.lastSelectedRow = row;
    
    return YES;
}

#pragma mark - Lazyloading
- (NSMutableArray *)colorList {
    if (!_colorList) {
        _colorList = [NSMutableArray array];
    }
    return _colorList;
}

@end
