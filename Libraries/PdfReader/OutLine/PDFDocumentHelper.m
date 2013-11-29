//
//  PDFDocumentHelper.m
//  PDFReader_Q2D
//
//  Created by Gu Lei on 10-4-3.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PDFDocumentHelper.h"
#import <CoreGraphics/CoreGraphics.h>


@implementation PDFDocumentHelper
@synthesize outlineCount, pages;

- (PDFDocumentHelper *)initWithFilePath: (NSString *) fileNameLocal
{
	self = [super init];
	
	if (self)
	{
		outlineCount = 0;
		pages = [[NSMutableArray alloc] init] ;
		[self createPDFDocument:fileNameLocal];
        
		[self updatePageCount];
		[self updateOutlines];
	}
	
	return self;
}

- (PDFDocumentHelper *)initWithDocument: (CGPDFDocumentRef) pdfDoc
{
	self = [super init];
	
	if (self)
	{
		outlineCount = 0;
		pages = [[NSMutableArray alloc] init];
        pdfDocument = pdfDoc;
        
		[self updatePageCount];
		[self updateOutlines];
        
       // NSLog(@"pageCnt : %d",[pages count]);
	}
    
    for (int i=0; i<[self.pages count]; i++)
    {
        OutlineItem * item = [pages objectAtIndex:i];
        NSLog(@"%d : %@", i, item.title);
    }
    
	
	return self;    
}

//- (void)outListGetPageList {
//    
//    
//    if ([pages count] <= 0) {
//        UIAlertView    *alertView = [[UIAlertView alloc] initWithTitle:@"알림!" message:@"파일이 삭제되었습니다." delegate:self cancelButtonTitle:@"확 인" otherButtonTitles:nil, nil];
//                    [alertView show];
//                    
//
//        
//        return;
//    }
//    
//}

//Add CJH

//table셀 선택 시
- (int)getPageNumberWithPageDic:(CGPDFDocumentRef)pdfDoc PageDic:(CGPDFDictionaryRef)pageDictionary
{
/*
    NSValue * val = [pagePointers objectAtIndex:0];
    CGPDFDictionaryRef pageDic = [val pointerValue];//1 page Dictionary 
    
//    NSLog(@"1 Page Dictionary : %@, pageDic");
    
    CGPDFDictionaryRef catalog =  CGPDFDocumentGetCatalog(pdfDoc);
    CGPDFDictionaryRef Outline_Dic;
    bool bRet = CGPDFDictionaryGetDictionary(catalog, "Outlines", &Outline_Dic);
    
    size_t count = CGPDFDictionaryGetCount(Outline_Dic); 
    NSLog(@"/Outline count = %d", count);//Dic 4
    // "/Outline" => "/Count"(Dic), "/First"(Dic), "/Last"(Dic), /Title(String)
        
    CGPDFDictionaryRef First_Dic;
    CGPDFDictionaryGetDictionary(Outline_Dic, "First", &First_Dic);  
    count = CGPDFDictionaryGetCount(First_Dic); 
    NSLog(@"/First count = %d", count);//5
    // "/First" - "/A"(Dic), "/Next"(Dic), "Parent"(Dic), "/SE"(Dic), /Title(String)
    
    CGPDFDictionaryRef A_Dic;
    CGPDFDictionaryGetDictionary(First_Dic, "A", &A_Dic);  
    count = CGPDFDictionaryGetCount(A_Dic); 
    NSLog(@"/A count = %d", count);//2
    // "/A" - "/D"(Array), "/S"(Name)  
    
    CGPDFArrayRef D_Array;
    CGPDFDictionaryGetArray(A_Dic, "D", &D_Array); 
    count = CGPDFArrayGetCount(D_Array); 
    NSLog(@"/D count = %d", count);//3
    
    CGPDFDictionaryRef Page_Dic;
    CGPDFArrayGetDictionary(D_Array, 0, &Page_Dic);  
    count = CGPDFDictionaryGetCount(Page_Dic); 
    NSLog(@"/Page count = %d", count);//12    
*/    
    
    int numberOfPages = CGPDFDocumentGetNumberOfPages(pdfDoc);
    pagePointers = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
    if (0 < numberOfPages) 
    {
        for (int i=1; i<=numberOfPages; i++) 
        {
            [pagePointers addObject:[NSValue valueWithPointer:CGPDFPageGetDictionary(CGPDFDocumentGetPage(pdfDoc, i))]];
        }
    }
    
    NSValue * pageVal = [NSValue valueWithPointer:pageDictionary];
    
    for (int i=0; i<[pagePointers count]; i++) 
    {
        NSValue * val = [pagePointers objectAtIndex:i];
        if([val isEqualToValue:pageVal])
        {
//            NSLog(@"%d page Same!!!!!", i+1);
            return i+1;//0 Array index => 1 Page index
        }
    }
    return 0;
}
//Add End    
- (int)getPDFPageCount
{
	return pageCount;

}

- (CGPDFDocumentRef)getPDFDocumentRef
{
	return pdfDocument;
}

- (CGPDFPageRef)getPDFPageRefByNumber: (int)pageNumber
{
	return CGPDFDocumentGetPage(pdfDocument, pageNumber);
}

- (OutlineItem *)getOutlinesRoot
{
	return outlinesRoot;
}

//private
- (void)createPDFDocument: (NSString *) _fileName
{
	fileName = [NSString stringWithFormat:@"%@", _fileName];
	CFStringRef path;
	CFURLRef url;
	filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"pdf"];
	path = CFStringCreateWithCString(NULL, [filePath UTF8String], kCFStringEncodingUTF8);
	url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, 0);
    NSLog(@"path %@", path);
    
	CFRelease(path);
	pdfDocument = CGPDFDocumentCreateWithURL(url);
    
//    int nCnt = CGPDFDocumentGetNumberOfPages(pdfDocument);
    
	CFRelease(url);
}

- (void)updatePageCount
{
	if (pdfDocument != nil)
	{
		pageCount = CGPDFDocumentGetNumberOfPages(pdfDocument);
        
        NSLog(@"pageCnt : %d",pageCount);

	}
	else
	{
		pageCount = 0;
	}
}

-(void) recursiveUpdatePages: (CGPDFDictionaryRef) pageDic
{
	const char* pchType;
	if(CGPDFDictionaryGetName(pageDic, "Type", &pchType)) {
		if (strcmp(pchType, "Pages") == 0) {
			int count;
			if(CGPDFDictionaryGetInteger(pageDic, "Count", (CGPDFInteger*)&count) && count > 0) {
				CGPDFArrayRef kidsArray;
				if(CGPDFDictionaryGetArray(pageDic, "Kids", &kidsArray)) {
					int kidsCount = CGPDFArrayGetCount(kidsArray);
					for (int i = 0; i < kidsCount; i++) {
						CGPDFDictionaryRef kidDic;
						if (CGPDFArrayGetDictionary(kidsArray, i, &kidDic)) {
							[self recursiveUpdatePages:kidDic];
						}
					}
				}
			}
		} else if (strcmp(pchType, "Page") == 0) {
            //Remove CJH
//			[pages addObject:pageDic];
		}
	}
}

- (void)updateOutlines
{
	//Catalog
	CGPDFDictionaryRef catalog;
	catalog = CGPDFDocumentGetCatalog(pdfDocument);
    
	// Pages Ref
	CGPDFDictionaryRef pagesDic;
	if(CGPDFDictionaryGetDictionary(catalog, "Pages", &pagesDic))
		[self recursiveUpdatePages: pagesDic];
	
	// Names & Dests
	CGPDFDictionaryRef names;
	if(CGPDFDictionaryGetDictionary(catalog, "Names", &names))
	{
		if(!CGPDFDictionaryGetDictionary(names, "Dests", &dests)) {
			// TODO exception
			exit(0);
		}
	}
	
	//Root of the outlines
	CGPDFDictionaryRef outlines;
	
	//Setup the outlines tree with iteration
	if (CGPDFDictionaryGetDictionary(catalog, "Outlines", &outlines))
	{
		CGPDFDictionaryRef first;
		if (CGPDFDictionaryGetDictionary(outlines, "First", &first))
		{
			outlinesRoot = [self recursiveUpdateOutlines:outlines parent:nil level:0];
			// set title, x, y of root
			outlinesRoot.title = fileName;
			outlinesRoot.x = 30;
			outlinesRoot.y = 790;
		}
		else
		{
             NSLog(@"목차 없음");
			outlinesRoot = nil;
		}
	}
	else
	{
        NSLog(@"목차 없음");
        //outline에 데이터 없을 때..
        outlinesRoot = nil;
       
	}
}

- (OutlineItem*)recursiveUpdateOutlines: (CGPDFDictionaryRef) outlineDic parent:(OutlineItem*) parentItem level:(NSUInteger) level;
{
	//update outline count
	outlineCount++;
	OutlineItem* item = [[[OutlineItem alloc] init] autorelease];
    
	// Level
	item.level = level;
    
    

    NSLog(@"outLine Count : %d",outlineCount);
	// Title
	CGPDFStringRef title;
	if(CGPDFDictionaryGetString(outlineDic, "Title", &title)) {
        //item.title = (NSString *)CGPDFStringCopyTextString(title);
        CFStringRef _res = CGPDFStringCopyTextString(title);
        item.title = [NSString stringWithString:( NSString *)_res];
        CFRelease(_res);
        
        //NSLog(@"Title : %@", item.title);
        
        //
        //size_t count = CGPDFDictionaryGetCount(outlineDic); 
        int64_t count = CGPDFDictionaryGetCount(outlineDic);
        
        NSLog(@"count : %d",(int)count);
        
        
        NSLog(@"(First/Next) Dic count = %d", (int)count);//5
        
        // "/First" - "/A"(Dic), "/Next"(Dic), "Parent"(Dic), "/SE"(Dic), /Title(String)
        
        CGPDFDictionaryRef A_Dic;
        CGPDFDictionaryGetDictionary(outlineDic, "A", &A_Dic);  
        count = CGPDFDictionaryGetCount(A_Dic); 
        NSLog(@"/A count = %d", (int)count);//2
        // "/A" - "/D"(Array), "/S"(Name)  
        
        CGPDFArrayRef D_Array;
        CGPDFDictionaryGetArray(A_Dic, "D", &D_Array); 
        count = CGPDFArrayGetCount(D_Array); 
        NSLog(@"/D count = %d", (int)count);//3
        
        CGPDFDictionaryRef Page_Dic;
        CGPDFArrayGetDictionary(D_Array, 0, &Page_Dic);  
        count = CGPDFDictionaryGetCount(Page_Dic); 
        NSLog(@"/Page count = %d", (int)count);//12   
        
        item.pageVal = [NSValue valueWithPointer:Page_Dic]; 
        
        [pages addObject:item];
	}
    
	if (parentItem != nil) {
		// Add to parent
		[parentItem.children addObject:item];
		// Next
		CGPDFDictionaryRef nextDic;
		if (CGPDFDictionaryGetDictionary(outlineDic, "Next", &nextDic)) {
			[self recursiveUpdateOutlines:nextDic parent:parentItem level: level];
		}
	}
    
	// First child
	CGPDFDictionaryRef firstDic;
	if (CGPDFDictionaryGetDictionary(outlineDic, "First", &firstDic)) {
        [self recursiveUpdateOutlines:firstDic parent:item level: level + 1];
	}
	// Dest
	CGPDFStringRef destString;
	if(CGPDFDictionaryGetString(outlineDic, "Dest", &destString)) {
		const char* pchDest = (const char *)CGPDFStringGetBytePtr(destString);
		CGPDFDictionaryRef destDic;
		if(CGPDFDictionaryGetDictionary(dests, pchDest, &destDic)) {
			NSLog(@"aa");
		}
		CGPDFArrayRef destArray;
		if (CGPDFDictionaryGetArray(dests, pchDest, &destArray)) {
			NSLog(@"bb");
		}
	} else {
		CGPDFDictionaryRef ADic;
		if (CGPDFDictionaryGetDictionary(outlineDic, "A", &ADic)) {
			const char* pchS;
			if (CGPDFDictionaryGetName(ADic, "S", &pchS)) {
				CGPDFArrayRef destArray;
				if (CGPDFDictionaryGetArray(ADic, "D", &destArray)) {
					int count = CGPDFArrayGetCount(destArray);
					switch (count) {
						case 5:
						{
							// dest page
							CGPDFDictionaryRef destPageDic;
							if (CGPDFArrayGetDictionary(destArray, 0, &destPageDic)) {
								int pageNumber = [self.pages indexOfObjectIdenticalTo:(id)destPageDic];
								item.page = pageNumber;
							}
							// x
							CGPDFInteger x;
							if (CGPDFArrayGetInteger(destArray, 2, &x)) {
								item.x = x;
							}
							// y
							CGPDFInteger y;
							if (CGPDFArrayGetInteger(destArray, 3, &y)) {
								item.y = y;
							}
							// z
						}
							break;
                            
						default:
							NSLog(@"default");
							break;
					}
				}
			}
		}
	}
	
	return item;
}

- (void)dealloc {
	[pages release];
	
    [super dealloc];
}

@end
