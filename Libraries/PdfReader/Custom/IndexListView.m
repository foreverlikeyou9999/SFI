//
//  IndexView.m
//  SalesForce
//
//  Created by 여성현 on 13. 8. 28..
//  Copyright (c) 2013년 BMBComs. All rights reserved.
//

#import "IndexListView.h"
#import "AppDelegate.h"

#define FIX_STATUS_BAR  20
#define FIX_TITLE_BAR   44

#define START_POS_X         0
#define START_POS_Y         (44-11)

#define INDEX_LIST_HEADER_HEIGHT  51

#define INDEX_LIST_WIDTH    195
#define INDEX_LIST_HEIGHT   (1024-START_POS_Y-INDEX_LIST_HEADER_HEIGHT-FIX_STATUS_BAR)

//#define INDEX_BTN_WIDTH     195
//#define INDEX_BTN_HEIGHT    51


@implementation IndexListView
@synthesize tableOutlineView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(START_POS_X, START_POS_Y, INDEX_LIST_WIDTH, INDEX_LIST_HEIGHT+INDEX_LIST_HEADER_HEIGHT)];
    if (self) {
        //[self setAlpha:0.9];
        // Initialization code
        isShow = false;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self loadFromPDFDocument:(CGPDFDocumentRef)[appDelegate getDocument]];
        
        // header
        UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, INDEX_LIST_WIDTH, INDEX_LIST_HEADER_HEIGHT)] ;
        [headerView setImage:[UIImage imageNamed:@"PDF_IndexListTitle"]];
        [self addSubview:headerView];
        
        // create view
        self.tableOutlineView = [[UITableView alloc] initWithFrame:CGRectMake(0, INDEX_LIST_HEADER_HEIGHT, INDEX_LIST_WIDTH, INDEX_LIST_HEIGHT)];
        [tableOutlineView setDelegate:self];
        [tableOutlineView setDataSource:self];
        [tableOutlineView setAlpha:0.8f];
        [tableOutlineView setBackgroundColor:RGBCOLOR(38, 38, 38)];
        [tableOutlineView setSeparatorColor:[UIColor darkGrayColor]];
        [self addSubview:tableOutlineView];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return outlineCount-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"IndexListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    // Configure the cell...
    //[cell.textLabel setText:[NSString stringWithFormat:@"%d", indexPath.row]];
    
    
    OutlineItem* item = [outlineItems objectAtIndex:indexPath.row+1];
    NSString* label = item.title;
	for (int i = 0; i < item.level; i++) {
        //        if(label == nil)
        //        { NSLog(@"nil!"); label = @""; }
		label = [@"  " stringByAppendingString:label];
	}
    cell.textLabel.text = label;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    NSLog(@"item %@",label); 
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    int idx = indexPath.row;//Zero base index
    
	OutlineItem * item = [_pdfhelper.pages objectAtIndex:idx];
    
    //    CGPDFDocumentRef * selectedPageDic = [item.pageVal pointerValue];
    CGPDFDictionaryRef selectedPageDic = [item.pageVal pointerValue];
    
    AppDelegate * appDelegate = (AppDelegate * )[[UIApplication sharedApplication] delegate];
    int numberPage = [_pdfhelper getPageNumberWithPageDic:[appDelegate getDocument] PageDic:selectedPageDic];
    
    NSLog(@"Selected Pages = %d", numberPage);
    [delegate indexListViewGoToPage: numberPage];
}


#pragma mark - private method

-(void) loadFromPDFDocument:(CGPDFDocumentRef) PDFDocument
{
	_pdfhelper = [[PDFDocumentHelper alloc] initWithDocument:PDFDocument];
	root = [_pdfhelper getOutlinesRoot];
	outlineCount = _pdfhelper.outlineCount;
	outlineItems = [[NSMutableArray alloc] init];
	[self updateOutlines:root];
    [tableOutlineView reloadData];
}

-(void) updateOutlines:(OutlineItem*) outlineItem {
    if (outlineItem == nil) {
        return;
    }
    
	[outlineItems addObject:outlineItem];
	for (int i = 0; i < [outlineItem.children count]; i++) {
		[self updateOutlines:(OutlineItem*)[outlineItem.children objectAtIndex:i]];
	}
}


- (void)hideBar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
	}
}

- (void)showBar
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
	if (self.hidden == YES)
	{
        
		[UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
	}
}
@end
