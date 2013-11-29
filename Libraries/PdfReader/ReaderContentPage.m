//
//	ReaderContentPage.m
//	Reader v2.2.0
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011 Julius Oklamcak. All rights reserved.
//
//	This work is being made available under a Creative Commons Attribution license:
//		«http://creativecommons.org/licenses/by/3.0/»
//	You are free to use this work and any derivatives of this work in personal and/or
//	commercial products and projects as long as the above copyright is maintained and
//	the original author is attributed.
//

#import "ReaderContentPage.h"
#import "ReaderContentTile.h"
#import "CGPDFDocument.h"
#import "AppDelegate.h"

@implementation ReaderContentPage

//#pragma mark Properties

//@synthesize ;

#pragma mark ReaderContentPage class methods

+ (Class)layerClass
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [ReaderContentTile class];
}

#pragma mark ReaderContentPage PDF link methods

- (void)highlightPageLinks
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if (_links.count > 0) // Add highlight views over all links
	{
		UIColor *hilite = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.15f];

		for (ReaderDocumentLink *link in _links) // Enumerate the links array
		{
			UIView *highlight = [[UIView alloc] initWithFrame:link.rect];

			highlight.autoresizesSubviews = NO;
			highlight.userInteractionEnabled = NO;
			highlight.clearsContextBeforeDrawing = NO;
			highlight.contentMode = UIViewContentModeRedraw;
			highlight.autoresizingMask = UIViewAutoresizingNone;
			highlight.backgroundColor = hilite; // Color

			[self addSubview:highlight]; [highlight release];
		}
	}
}

- (ReaderDocumentLink *)linkFromAnnotation:(CGPDFDictionaryRef)annotationDictionary
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	ReaderDocumentLink *documentLink = nil; // Document link object

	CGPDFArrayRef annotationRectArray = NULL; // Annotation co-ordinates array

	if (CGPDFDictionaryGetArray(annotationDictionary, "Rect", &annotationRectArray))
	{
		CGPDFReal ll_x = 0.0f; CGPDFReal ll_y = 0.0f; // PDFRect lower-left X and Y
		CGPDFReal ur_x = 0.0f; CGPDFReal ur_y = 0.0f; // PDFRect upper-right X and Y

		CGPDFArrayGetNumber(annotationRectArray, 0, &ll_x); // Lower-left X co-ordinate
		CGPDFArrayGetNumber(annotationRectArray, 1, &ll_y); // Lower-left Y co-ordinate

		CGPDFArrayGetNumber(annotationRectArray, 2, &ur_x); // Upper-right X co-ordinate
		CGPDFArrayGetNumber(annotationRectArray, 3, &ur_y); // Upper-right Y co-ordinate

		if (ll_x > ur_x) { CGPDFReal t = ll_x; ll_x = ur_x; ur_x = t; } // Normalize Xs
		if (ll_y > ur_y) { CGPDFReal t = ll_y; ll_y = ur_y; ur_y = t; } // Normalize Ys

		switch (_pageRotate) // Page rotation (in degrees)
		{
			case 90: // 90 degree page rotation
			{
				CGPDFReal swap;
				swap = ll_y; ll_y = ll_x; ll_x = swap;
				swap = ur_y; ur_y = ur_x; ur_x = swap;
				break;
			}

			case 270: // 270 degree page rotation
			{
				CGPDFReal swap;
				swap = ll_y; ll_y = ll_x; ll_x = swap;
				swap = ur_y; ur_y = ur_x; ur_x = swap;
				ll_x = ((0.0f - ll_x) + _pageSize.width);
				ur_x = ((0.0f - ur_x) + _pageSize.width);
				break;
			}

			case 0: // 0 degree page rotation
			{
				ll_y = ((0.0f - ll_y) + _pageSize.height);
				ur_y = ((0.0f - ur_y) + _pageSize.height);
				break;
			}
		}

		NSInteger vr_x = ll_x; NSInteger vr_w = (ur_x - ll_x); // Integer X and width
		NSInteger vr_y = ll_y; NSInteger vr_h = (ur_y - ll_y); // Integer Y and height

		CGRect viewRect = CGRectMake(vr_x, vr_y, vr_w, vr_h); // View CGRect from PDFRect

		documentLink = [ReaderDocumentLink withRect:viewRect dictionary:annotationDictionary];
	}

	return documentLink;
}

- (void)buildAnnotationLinksList
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	_links = [NSMutableArray new]; // Links list array

	CGPDFArrayRef pageAnnotations = NULL; // Page annotations array

	CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(_PDFPageRef);

	if (CGPDFDictionaryGetArray(pageDictionary, "Annots", &pageAnnotations) == true)
	{
		NSInteger count = CGPDFArrayGetCount(pageAnnotations); // Number of annotations

		for (NSInteger index = 0; index < count; index++) // Iterate through all annotations
		{
			CGPDFDictionaryRef annotationDictionary = NULL; // PDF annotation dictionary

			if (CGPDFArrayGetDictionary(pageAnnotations, index, &annotationDictionary) == true)
			{
				const char *annotationSubtype = NULL; // PDF annotation subtype string

				if (CGPDFDictionaryGetName(annotationDictionary, "Subtype", &annotationSubtype) == true)
				{
					if (strcmp(annotationSubtype, "Link") == 0) // Found annotation subtype of 'Link'
					{
						ReaderDocumentLink *documentLink = [self linkFromAnnotation:annotationDictionary];

						if (documentLink != nil) [_links insertObject:documentLink atIndex:0]; // Add link
					}
				}
			}
		}

//		[self highlightPageLinks]; // For link support debugging
	}
}

- (CGPDFArrayRef)findDestinationWithName:(const char *)destinationName inDestsTree:(CGPDFDictionaryRef)node
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGPDFArrayRef destinationArray = NULL;

	CGPDFArrayRef limitsArray = NULL; // Limits array

	if (CGPDFDictionaryGetArray(node, "Limits", &limitsArray) == true)
	{
		CGPDFStringRef lowerLimit = NULL; CGPDFStringRef upperLimit = NULL;

		if (CGPDFArrayGetString(limitsArray, 0, &lowerLimit) == true) // Lower limit
		{
			if (CGPDFArrayGetString(limitsArray, 1, &upperLimit) == true) // Upper limit
			{
				const char *ll = (const char *)CGPDFStringGetBytePtr(lowerLimit); // Lower string
				const char *ul = (const char *)CGPDFStringGetBytePtr(upperLimit); // Upper string

				if ((strcmp(destinationName, ll) < 0) || (strcmp(destinationName, ul) > 0))
				{
					return NULL; // Destination name is outside this node's limits
				}
			}
		}
	}

	CGPDFArrayRef namesArray = NULL; // Names array

	if (CGPDFDictionaryGetArray(node, "Names", &namesArray) == true)
	{
		NSInteger namesCount = CGPDFArrayGetCount(namesArray);

		for (NSInteger index = 0; index < namesCount; index += 2)
		{
			CGPDFStringRef destName; // Destination name string

			if (CGPDFArrayGetString(namesArray, index, &destName) == true)
			{
				const char *dn = (const char *)CGPDFStringGetBytePtr(destName);

				if (strcmp(dn, destinationName) == 0) // Found the destination name
				{
					if (CGPDFArrayGetArray(namesArray, (index + 1), &destinationArray) == false)
					{
						CGPDFDictionaryRef destinationDictionary = NULL; // Destination dictionary

						if (CGPDFArrayGetDictionary(namesArray, (index + 1), &destinationDictionary) == true)
						{
							CGPDFDictionaryGetArray(destinationDictionary, "D", &destinationArray);
						}
					}

					return destinationArray; // Return the destination array
				}
			}
		}
	}

	CGPDFArrayRef kidsArray = NULL; // Kids array

	if (CGPDFDictionaryGetArray(node, "Kids", &kidsArray) == true)
	{
		NSInteger kidsCount = CGPDFArrayGetCount(kidsArray);

		for (NSInteger index = 0; index < kidsCount; index++)
		{
			CGPDFDictionaryRef kidNode = NULL; // Kid node dictionary

			if (CGPDFArrayGetDictionary(kidsArray, index, &kidNode) == true) // Recurse into kid node
			{
				destinationArray = [self findDestinationWithName:destinationName inDestsTree:kidNode];

				if (destinationArray != NULL) return destinationArray; // Return the destination array
			}
		}
	}

	return NULL;
}

- (id)findLinkTarget:(CGPDFDictionaryRef)annotationDictionary
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	id linkTarget = nil; // Link target object

	CGPDFArrayRef destArray = NULL; CGPDFStringRef destName = NULL;

	CGPDFDictionaryRef actionDictionary = NULL; // Link action dictionary

	if (CGPDFDictionaryGetDictionary(annotationDictionary, "A", &actionDictionary) == true)
	{
		const char *actionType = NULL; // Annotation action type string

		if (CGPDFDictionaryGetName(actionDictionary, "S", &actionType) == true)
		{
			if (strcmp(actionType, "GoTo") == 0) // GoTo action type
			{
				if (CGPDFDictionaryGetArray(actionDictionary, "D", &destArray) == false)
				{
					CGPDFDictionaryGetString(actionDictionary, "D", &destName);
				}
			}
			else // Handle other link action type possibility
			{
				if (strcmp(actionType, "URI") == 0) // URI action type
				{
					CGPDFStringRef uriString = NULL; // Action's URI string

					if (CGPDFDictionaryGetString(actionDictionary, "URI", &uriString) == true)
					{
						const char *uri = (const char *)CGPDFStringGetBytePtr(uriString); // Destination URI string

						linkTarget = [NSURL URLWithString:[NSString stringWithCString:uri encoding:NSASCIIStringEncoding]];
					}
				}
			}
		}
	}
	else // Handle other link target possibility
	{
		if (CGPDFDictionaryGetArray(annotationDictionary, "Dest", &destArray) == false)
		{
			CGPDFDictionaryGetString(annotationDictionary, "Dest", &destName);
		}
	}

	if (destName != NULL) // Handle a destination name
	{
		CGPDFDictionaryRef catalogDictionary = CGPDFDocumentGetCatalog(_PDFDocRef);

		CGPDFDictionaryRef namesDictionary = NULL; // Destination names in the document

		if (CGPDFDictionaryGetDictionary(catalogDictionary, "Names", &namesDictionary) == true)
		{
			CGPDFDictionaryRef destsDictionary = NULL; // Document destinations dictionary

			if (CGPDFDictionaryGetDictionary(namesDictionary, "Dests", &destsDictionary) == true)
			{
				const char *destinationName = (const char *)CGPDFStringGetBytePtr(destName); // Name

				destArray = [self findDestinationWithName:destinationName inDestsTree:destsDictionary];
			}
		}
	}

	if (destArray != NULL) // Handle a destination array
	{
		NSInteger targetPageNumber = 0; // The target page number

		CGPDFDictionaryRef pageDictionaryFromDestArray = NULL; // Target reference

		if (CGPDFArrayGetDictionary(destArray, 0, &pageDictionaryFromDestArray) == true)
		{
			NSInteger pageCount = CGPDFDocumentGetNumberOfPages(_PDFDocRef);

			for (NSInteger pageNumber = 1; pageNumber <= pageCount; pageNumber++)
			{
				CGPDFPageRef pageRef = CGPDFDocumentGetPage(_PDFDocRef, pageNumber);

				CGPDFDictionaryRef pageDictionaryFromPage = CGPDFPageGetDictionary(pageRef);

				if (pageDictionaryFromPage == pageDictionaryFromDestArray) // Found it
				{
					targetPageNumber = pageNumber; break;
				}
			}
		}
		else // Try page number from array possibility
		{
			CGPDFInteger pageNumber = 0; // Page number in array

			if (CGPDFArrayGetInteger(destArray, 0, &pageNumber) == true)
			{
				targetPageNumber = (pageNumber + 1); // 1-based
			}
		}

		if (targetPageNumber > 0) // We have a target page number
		{
			linkTarget = [NSNumber numberWithInteger:targetPageNumber];
		}
	}

	return linkTarget;
}

- (id)singleTap:(UITapGestureRecognizer *)recognizer
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	id result = nil; // Tap result object

	if (_links.count > 0) // Process the single tap
	{
		CGPoint point = [recognizer locationInView:self];

		for (ReaderDocumentLink *link in _links) // Enumerate links
		{
			if (CGRectContainsPoint(link.rect, point) == true) // Found it
			{
				result = [self findLinkTarget:link.dictionary]; break;
			}
		}
	}

	return result;
}

#pragma mark ReaderContentPage instance methods

- (id)initWithFrame:(CGRect)frame
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	UIView *view = nil; // View

	if (CGRectIsEmpty(frame) == false)
	{
		if ((self = [super initWithFrame:frame]))
		{
			self.autoresizesSubviews = NO;
			self.userInteractionEnabled = NO;
			self.clearsContextBeforeDrawing = NO;
			self.contentMode = UIViewContentModeRedraw;
			self.autoresizingMask = UIViewAutoresizingNone;
			self.backgroundColor = [UIColor clearColor];

			view = self; // Return self
		}
	}
	else // Handle invalid frame size
	{
		[self release];
	}

	return view;
}

- (NSString *)setCGPDFStringValue:(CGPDFStringRef) string
{
    CFStringRef s;
    NSString * str = nil;
    s = CGPDFStringCopyTextString(string);
    if (s != NULL) {
        str = [NSString stringWithFormat:@"%@", (NSString *)s]; 
        CFRelease(s);
    }
    
    return str;
}

- (NSString *)setCGPDFStringValueAsDate:(CGPDFStringRef) string
{
    CFDateRef date;
    NSString * str = nil;
    date = CGPDFStringCopyDate(string);
    if (date != NULL) {
        str = [NSString stringWithFormat:@"%@", [(NSDate *)date description]];
        CFRelease(date);
    }
    return str;
}

void copyDictionaryValues (const char *key, CGPDFObjectRef object, void *info) {
    NSLog(@"key: %s", key);
    CGPDFObjectType type = CGPDFObjectGetType(object);
    switch ((CGPDFObjectType)type) {
        case kCGPDFObjectTypeString: {
            CGPDFStringRef objectString;
            if (CGPDFObjectGetValue(object, kCGPDFObjectTypeString, &objectString)) {
                NSString *tempStr = (NSString *)CGPDFStringCopyTextString(objectString);
                NSLog(@"=======> kCGPDFObjectTypeString: %@", tempStr);
//                [[selfClass auxInfo] setObject:tempStr
//                                        forKey:[NSString stringWithCString:key encoding:NSUTF8StringEncoding]];
                [tempStr release];
                NSLog(@"set string value");
            }
            
        }
        case kCGPDFObjectTypeInteger: {
            CGPDFInteger objectInteger;
            if (CGPDFObjectGetValue(object, kCGPDFObjectTypeInteger, &objectInteger)) {
//                [[selfClass auxInfo] setObject:[NSNumber numberWithInt:objectInteger]
//                                        forKey:[NSString stringWithCString:key encoding:NSUTF8StringEncoding]];
                NSLog(@"=======> kCGPDFObjectTypeString: %ld", objectInteger);
                NSLog(@"set int value");
            }
        }
        case kCGPDFObjectTypeBoolean: {
            CGPDFBoolean objectBool;
            if (CGPDFObjectGetValue(object, kCGPDFObjectTypeBoolean, &objectBool)) {
//                [[selfClass auxInfo] setObject:[NSNumber numberWithBool:objectBool]
//                                        forKey:[NSString stringWithCString:key encoding:NSUTF8StringEncoding]];
                NSLog(@"=======> kCGPDFObjectTypeBoolean: %d", objectBool);
                NSLog(@"set boolean value");
            }
        }
        case kCGPDFObjectTypeArray : {
            CGPDFArrayRef objectArray;
            if (CGPDFObjectGetValue(object, kCGPDFObjectTypeArray, &objectArray)) {
                NSArray *tempArr = [selfClass copyPDFArray:objectArray];
                NSLog(@"=======> %@", tempArr);
//                [[selfClass auxInfo] setObject:tempArr
//                                        forKey:[NSString stringWithCString:key encoding:NSUTF8StringEncoding]];
                [tempArr release];
                NSLog(@"set array value");
            }
        }
        case kCGPDFObjectTypeDictionary:{
            CGPDFDictionaryRef objectDictionary;
            if (CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &objectDictionary)) {
                
                size_t count = CGPDFDictionaryGetCount(objectDictionary); 
                NSLog(@"count = %ld", count);
                CGPDFDictionaryRef objectFirstDic;
                CGPDFDictionaryGetDictionary(objectDictionary, "First", &objectFirstDic);  
                
                count = CGPDFDictionaryGetCount(objectFirstDic);
                
                CGPDFStringRef string;
                CGPDFDictionaryGetString(objectFirstDic, "Title", &string);
                
                CFStringRef s;
                s = CGPDFStringCopyTextString(string);
                if (s != NULL) {
                    NSLog(@"list Label = %@", (NSString*)s);
                    CFRelease(s);
                }


                NSLog(@"set dictionary value");
            }
        }
    }
}


- (void)extractPDFDictionary:(CGPDFDocumentRef)pdf{
    NSLog(@"extractingPDFDictionary");
    CGPDFDictionaryRef oldDict =  CGPDFDocumentGetCatalog(pdf);//CGPDFDocumentGetInfo(pdf);
    CGPDFDictionaryApplyFunction(oldDict, copyDictionaryValues, NULL);
}

- (NSArray *)copyPDFArray:(CGPDFArrayRef)arr{
    int i = 0;
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for(i=0; i<CGPDFArrayGetCount(arr); i++){
        CGPDFObjectRef object;
        CGPDFArrayGetObject(arr, i, &object);
        CGPDFObjectType type = CGPDFObjectGetType(object);
        switch(type){
            case kCGPDFObjectTypeString: {
                CGPDFStringRef objectString;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeString, &objectString)) {
                    NSString *tempStr = (NSString *)CGPDFStringCopyTextString(objectString);
                    [temp addObject:tempStr];
                    [tempStr release];
                }
            }
            case kCGPDFObjectTypeInteger: {
                CGPDFInteger objectInteger;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeInteger, &objectInteger)) {
                    [temp addObject:[NSNumber numberWithInt:objectInteger]];
                }
            }
            case kCGPDFObjectTypeBoolean: {
                CGPDFBoolean objectBool;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeBoolean, &objectBool)) {
                    [temp addObject:[NSNumber numberWithBool:objectBool]];
                }
            }
            case kCGPDFObjectTypeArray : {
                CGPDFArrayRef objectArray;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeArray, &objectArray)) {
                    NSArray *tempArr = [selfClass copyPDFArray:objectArray];
                    [temp addObject:tempArr];
                    [tempArr release];
                }
            }
        }
    }
    return temp;
}

- (NSMutableDictionary *)copyPDFDictionary:(CGPDFDictionaryRef)dic{
    int i = 0;
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    for(i=0; i<CGPDFDictionaryGetCount(dic); i++){
        CGPDFObjectRef object;
        CGPDFDictionaryGetObject(dic, i, &object);
        CGPDFObjectType type = CGPDFObjectGetType(object);
        switch(type){
            case kCGPDFObjectTypeDictionary : {
                CGPDFDictionaryRef objectDictionary;
                if (CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &objectDictionary)) {
                    NSDictionary *tempDic = [selfClass copyPDFDictionary:objectDictionary];
                    [temp addEntriesFromDictionary:tempDic];
                    [tempDic release];
                }
            }                
        }
    }
    return temp;
}


- (void)loadDocumentInfo:(NSURL*)fileurl
{
//    CGPDFStringRef string;
//    CGPDFDictionaryRef infoDict;
    int majorVersion, minorVersion;
    
    CGPDFDocumentRef document;
    document = CGPDFDocumentCreateX((CFURLRef)fileurl, _password);
    CGPDFDocumentGetVersion(document, &majorVersion, &minorVersion);
    NSLog(@"VERSION : %@", [NSString stringWithFormat:@"%d.%d", majorVersion, minorVersion]);
    
    //CJH Outline 추출 하기
//    [self extractPDFDictionary:document];
/*
    int nPage = CGPDFDocumentGetNumberOfPages(document);
    NSLog(@"PAGENUMBER : %d", nPage);

	
    infoDict = CGPDFDocumentGetInfo(document);
    if (CGPDFDictionaryGetString(infoDict, "Title", &string))
        NSLog(@"[INFO]Title : %@", [self setCGPDFStringValue:string]);
    if (CGPDFDictionaryGetString(infoDict, "Author", &string))
        NSLog(@"[INFO]Author : %@", [self setCGPDFStringValue:string]);
    if (CGPDFDictionaryGetString(infoDict, "Subject", &string))
        NSLog(@"[INFO]Subject : %@", [self setCGPDFStringValue:string]);
    if (CGPDFDictionaryGetString(infoDict, "Keywords", &string))
        NSLog(@"[INFO]Keywords : %@", [self setCGPDFStringValue:string]);
    if (CGPDFDictionaryGetString(infoDict, "Creator", &string))
        NSLog(@"[INFO]Creator : %@", [self setCGPDFStringValue:string]);
    if (CGPDFDictionaryGetString(infoDict, "Producer", &string))
        NSLog(@"[INFO]Producer : %@", [self setCGPDFStringValue:string]);
    if (CGPDFDictionaryGetString(infoDict, "CreationDate", &string))
        NSLog(@"[INFO]CreationDate : %@", [self setCGPDFStringValueAsDate:string]);
    if (CGPDFDictionaryGetString(infoDict, "ModDate", &string))
        NSLog(@"[INFO]ModDate : %@", [self setCGPDFStringValueAsDate:string]);
*/    
    CGPDFDocumentRelease(document), document = NULL;
}

- (id)initWithURL:(NSURL *)fileURL page:(NSInteger)page password:(NSString *)phrase
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
    
    //Add CJH
    [self loadDocumentInfo:fileURL];

	CGRect viewRect = CGRectZero; // View rect

	if (fileURL != nil) // Check for non-nil file URL
	{
		_fileURL = [fileURL copy]; // Keep a copy of the file URL

		_password = [phrase copy]; // Keep a copy of any given password

		_PDFDocRef = CGPDFDocumentCreateX((CFURLRef)_fileURL, _password);
        
        AppDelegate * appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate setDocument:_PDFDocRef];

		if (_PDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (page < 1) page = 1; // Check the lower page bounds

			NSInteger pages = CGPDFDocumentGetNumberOfPages(_PDFDocRef);

			if (page > pages) page = pages; // Check the upper page bounds
            

			_PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page); // Get page
/*            
            //Add CJH
            
            CGPDFDocumentRef docRef = CGPDFDocumentCreateWithURL((CFURLRef)fileURL);
            
            int numberOfPages = CGPDFDocumentGetNumberOfPages(docRef); 
            NSMutableArray * pagePointers = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
            if (0<numberOfPages) for (int i=1; i<numberOfPages; i++) 
            {
                [pagePointers addObject:[NSValue valueWithPointer:CGPDFPageGetDictionary(CGPDFDocumentGetPage(docRef, i))]];
//                CGPDFDictionaryRef docRef = CGPDFDocumentGetInfo((CGPDFDocumentRef)docRef);
                CGPDFPageRef pageRef = CGPDFDocumentGetPage((CGPDFDocumentRef)docRef, i);
                CGPDFDictionaryRef pageDicRef = CGPDFPageGetDictionary(pageRef);
                
                //1: Title
                CGPDFStringRef titleStringRef;
                bool bRet = CGPDFDictionaryGetString(pageDicRef, "Title", &titleStringRef);
                if (bRet) {
                    const unsigned char *titleCstring = CGPDFStringGetBytePtr(titleStringRef);
                    printf("title: %s", titleCstring);
                }else{
                    NSLog(@"no title string!!");
                }
                
                //2: Keywords
                CGPDFStringRef keywordStringRef;
                bRet = CGPDFDictionaryGetString(pageDicRef, "Keywords", &keywordStringRef);
 //               bRet = CGPDFDictionaryGetString(docRef, "Keywords", &keywordStringRef);

                if (bRet) 
                {
                    CFStringRef s;
                    
                    s = CGPDFStringCopyTextString(keywordStringRef);
                    if (s != NULL) 
                    {
                        //need something in here in case it cant find anything
                        NSLog(@"Keywords: %@", s);
                        CFRelease(s);
                    }
                }
                else
                {
                    NSLog(@"no Keywords string!!");
                }
            }
            
            //Add CJH     
            char *titleKey = "Title";
            CGPDFStringRef titleStringRef;
            
            CGPDFDictionaryRef info = CGPDFDocumentGetInfo(docRef);
            bool bRet = CGPDFDictionaryGetString(info, titleKey, &titleStringRef);
            if (bRet) {
                const unsigned char *titleCstring = CGPDFStringGetBytePtr(titleStringRef);
                printf("title: %s", titleCstring);
            }else{
                NSLog(@"no title string!!");
            }
            //Add CJH End..
*/            
            //Add CJH      
/*            
            CGPDFStringRef string;
            CGPDFDictionaryRef infoDict;
            
            infoDict = CGPDFDocumentGetInfo(docRef);
            if (CGPDFDictionaryGetString(infoDict, "Keywords", &string))
            {
                CFStringRef s;
            
                s = CGPDFStringCopyTextString(string);
                if (s != NULL) 
                {
                    //need something in here in case it cant find anything
                    NSLog(@"%@ testing it", s);
                    CFRelease(s);
                }
            }
           
            //Add CJH End..
           
            
            CGPDFDocumentRelease(docRef), docRef = NULL;
            //Add CJH End..
*/              
			if (_PDFPageRef != NULL) // Check for non-NULL CGPDFPageRef
			{
				CGPDFPageRetain(_PDFPageRef); // Retain the PDF page
             
				CGRect cropBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFCropBox);
				CGRect mediaBoxRect = CGPDFPageGetBoxRect(_PDFPageRef, kCGPDFMediaBox);
				CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);

				_pageRotate = CGPDFPageGetRotationAngle(_PDFPageRef); // Angle

				switch (_pageRotate) // Page rotation (in degrees)
				{
					default: // Default case
					case 0: case 180: // 0 and 180 degrees
					{
						_pageSize.width = effectiveRect.size.width;
						_pageSize.height = effectiveRect.size.height;
						break;
					}

					case 90: case 270: // 90 and 270 degrees
					{
						_pageSize.height = effectiveRect.size.width ;
						_pageSize.width = effectiveRect.size.height ;
						break;
					}
				}

				NSInteger page_w = _pageSize.width; // Integer width
				NSInteger page_h = _pageSize.height; // Integer height

				if (page_w % 2) page_w--; if (page_h % 2) page_h--; // Even

				viewRect.size = CGSizeMake(page_w, page_h); // View size
			}
			else // Error out with a diagnostic
			{
				CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;

				NSAssert(NO, @"CGPDFPageRef == NULL");
			}
		}
		else // Error out with a diagnostic
		{
			NSAssert(NO, @"CGPDFDocumentRef == NULL");
		}
	}
	else // Error out with a diagnostic
	{
		NSAssert(NO, @"fileURL == nil");
	}

	id view = [self initWithFrame:viewRect]; // View setup

	if (view != nil) [self buildAnnotationLinksList];

	return view;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[_links release], _links = nil;

	@synchronized(self) // Block any other threads
	{
		CGPDFPageRelease(_PDFPageRef), _PDFPageRef = NULL;

		CGPDFDocumentRelease(_PDFDocRef), _PDFDocRef = NULL;
	}

	[_password release], _password = nil;

	[_fileURL release], _fileURL = nil;

	[super dealloc];
}

/*
- (void)layoutSubviews
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif
}
*/

#pragma mark CATiledLayer delegate methods

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGPDFPageRef drawPDFPageRef = NULL;

	CGPDFDocumentRef drawPDFDocRef = NULL;

	@synchronized(self) // Block any other threads
	{
		drawPDFDocRef = CGPDFDocumentRetain(_PDFDocRef);

		drawPDFPageRef = CGPDFPageRetain(_PDFPageRef);
	}

	CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // White

	CGContextFillRect(context, CGContextGetClipBoundingBox(context)); // Fill

	if (drawPDFPageRef != NULL) // Go ahead and render the PDF page into the context
	{
		CGContextTranslateCTM(context, 0.0f, self.bounds.size.height); CGContextScaleCTM(context, 1.0f, -1.0f);

		CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(drawPDFPageRef, kCGPDFCropBox, self.bounds, 0, true));

		CGContextSetRenderingIntent(context, kCGRenderingIntentDefault); CGContextSetInterpolationQuality(context, kCGInterpolationDefault);

		CGContextDrawPDFPage(context, drawPDFPageRef); // Render the PDF page into the context
	}

	CGPDFPageRelease(drawPDFPageRef); CGPDFDocumentRelease(drawPDFDocRef); // Cleanup
}

@end

#pragma mark -

//
//	ReaderDocumentLink class implementation
//

@implementation ReaderDocumentLink

#pragma mark Properties

@synthesize rect = _rect;
@synthesize dictionary = _dictionary;

#pragma mark ReaderDocumentLink class methods

+ (id)withRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	return [[[ReaderDocumentLink alloc] initWithRect:linkRect dictionary:linkDictionary] autorelease];
}

#pragma mark ReaderDocumentLink instance methods

- (id)initWithRect:(CGRect)linkRect dictionary:(CGPDFDictionaryRef)linkDictionary
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	if ((self = [super init]))
	{
		_dictionary = linkDictionary;

		_rect = linkRect;
	}

	return self;
}

- (void)dealloc
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	[super dealloc];
}

@end
