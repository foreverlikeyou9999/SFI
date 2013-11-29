//
//  PDFDocumentHelper.h
//  PDFReader_Q2D
//
//  Created by Gu Lei on 10-4-3.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OutlineItem.h"

@interface PDFDocumentHelper : NSObject<UIAlertViewDelegate>
{
	NSString *fileName;
	NSString *filePath;
	int pageCount;
	CGPDFDocumentRef pdfDocument;
	CGPDFDictionaryRef dests;
	NSMutableArray* pages;
	CGPDFPageRef page;
	OutlineItem *outlinesRoot;
	int outlineCount;
    
    NSMutableArray* pagePointers;
}
@property int outlineCount;
@property (retain, nonatomic) NSMutableArray* pages;
//@property (retain, nonatomic) NSString *filePath;
//@property int pageNumber;
//@property (retain, nonatomic) OutlinesItem *outlinesRoot;

- (PDFDocumentHelper *)initWithFilePath: (NSString *) filePath;
- (PDFDocumentHelper *)initWithDocument: (CGPDFDocumentRef) pdfDoc;

//PDF 총 페이지수를 리턴한다.
- (int)getPDFPageCount;
//PDFDocumentHelper로 오픈한 PDF Document(CGPDFDocumentRef)를 리턴한다.
- (CGPDFDocumentRef)getPDFDocumentRef;
//페이지에 해당하는 PDF page(CGPDFPageRef)를 리턴한다.
- (CGPDFPageRef)getPDFPageRefByNumber: (int)pageNumber;
- (OutlineItem *)getOutlinesRoot;

//PDF 파일의 Quartz PDF Document(CGPDFDocumentRef)를 생성한다.
- (void)createPDFDocument: (NSString *) fileName;
//PDF 총 페이지수를 업데이트 한다.
- (void)updatePageCount;
//목차 페이지 정보를 업데이트 한다.
- (void)updateOutlines;
-(void) recursiveUpdatePages: (CGPDFDictionaryRef) pageDic;
- (OutlineItem*)recursiveUpdateOutlines: (CGPDFDictionaryRef) outlineDic parent:(OutlineItem*) parentItem level:(NSUInteger) level;

- (int)getPageNumberWithPageDic:(CGPDFDocumentRef)pdfDoc PageDic:(CGPDFDictionaryRef)pageDictionary;


//- (void)outListGetPageList ;

@end
