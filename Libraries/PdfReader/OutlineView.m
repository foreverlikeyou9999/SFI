//
//  OutlineView.m
//  Reader
//
//  Created by 정후 조 on 11. 10. 7..
//  Copyright 2011 코롱베니트. All rights reserved.
//

#import "OutlineView.h"
#import "ReaderViewController.h"
#import "OutlineViewController.h"
#import "AppDelegate.h"
#import "Define.h"

@implementation UIView (OutlineViewController)
- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}
- (UIViewController *) firstAvailableUIViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}
@end

@implementation OutlineView

@synthesize _tableOutlineView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"outlineviewrect: %@", NSStringFromCGRect(frame));
        
        id appDelegate = [[UIApplication sharedApplication] delegate];
        [self loadFromPDFDocument:(CGPDFDocumentRef)[appDelegate getDocument]];
        _tableOutlineView = [[UITableView alloc] initWithFrame:frame];
        _tableOutlineView.delegate = self;
		_tableOutlineView.dataSource = self;
        _tableOutlineView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        
        [self addSubview:_tableOutlineView];
        [_tableOutlineView release];
        
    }
    return self;
}

//- (void)tableReloadviews:(CGRect)tableFrame
//{
//    NSLog(@"tablviewrect: %@", NSStringFromCGRect(tableFrame));
//    
//    _tableOutlineView.frame = tableFrame;
//        
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) loadFromFileName:(NSString*) fileName {
	PDFDocumentHelper* helper = [[PDFDocumentHelper alloc] initWithFilePath:fileName];
	root = [helper getOutlinesRoot];
	outlineCount = helper.outlineCount;

	outlineItems = [[NSMutableArray alloc] init];
	[self updateOutlines:root];
    [_tableOutlineView reloadData];
    
    [helper release];
}

-(void) loadFromPDFDocument:(CGPDFDocumentRef) PDFDocument
{
	_pdfhelper = [[PDFDocumentHelper alloc] initWithDocument:PDFDocument];
	root = [_pdfhelper getOutlinesRoot];
	outlineCount = _pdfhelper.outlineCount;
	outlineItems = [[NSMutableArray alloc] init];
	[self updateOutlines:root];
    [_tableOutlineView reloadData];
    
}

-(void) updateOutlines:(OutlineItem*) outlineItem {
	[outlineItems addObject:outlineItem];
	for (int i = 0; i < [outlineItem.children count]; i++) {
		[self updateOutlines:(OutlineItem*)[outlineItem.children objectAtIndex:i]];
	}
}


#pragma mark -
#pragma mark UITableViewDataSource

//테이블내에 몇개의 그룹(Section)이 존재하는가?
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//특정 그룹(Section)에 몇개의 셀(Row)가 존재하는가?
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"outlineCount: %d", outlineCount);
    return outlineCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
	OutlineItem* item = [outlineItems objectAtIndex:indexPath.row];
    NSString* label = item.title;
	for (int i = 0; i < item.level; i++) {
        //        if(label == nil) 
        //        { NSLog(@"nil!"); label = @""; }
		label = [@"  " stringByAppendingString:label];
	}
    cell.textLabel.text = label;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    //    NSLog(@"didSelectRowAtIndexPath => %d", indexPath.row);//1 index
    int idx = indexPath.row-1;//Zero base index
    
	OutlineItem * item = [_pdfhelper.pages objectAtIndex:idx];
    
//    CGPDFDocumentRef * selectedPageDic = [item.pageVal pointerValue];
    CGPDFDictionaryRef selectedPageDic = [item.pageVal pointerValue];
    
    AppDelegate * appDelegate = (AppDelegate * )[[UIApplication sharedApplication] delegate];
    int numberPage = [_pdfhelper getPageNumberWithPageDic:[appDelegate getDocument] PageDic:selectedPageDic];
    
    NSLog(@"Selected Pages = %d", numberPage);
    OutlineViewController * myController = (OutlineViewController*)[self firstAvailableUIViewController];
    [myController showPage:numberPage];
}

- (void)dealloc
{
    [super dealloc];
}

@end
