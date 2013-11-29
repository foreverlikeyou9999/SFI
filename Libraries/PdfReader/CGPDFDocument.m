//
//	CGPDFDocument.m
//	Reader v2.1.0
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

#import "CGPDFDocument.h"


// table methods to parse pdf
static void op_MP (CGPDFScannerRef s, void *info) {
    const char *name;
    if (!CGPDFScannerPopName(s, &name))
        return;
    printf("MP /%s\n", name);   
}

static void op_DP (CGPDFScannerRef s, void *info) {
    const char *name;
    if (!CGPDFScannerPopName(s, &name))
        return;
    printf("DP /%s\n", name);   
}

static void op_BMC (CGPDFScannerRef s, void *info) {
    const char *name;
    if (!CGPDFScannerPopName(s, &name))
        return;
    printf("BMC /%s\n", name);  
}

static void op_BDC (CGPDFScannerRef s, void *info) {
    const char *name;
    if (!CGPDFScannerPopName(s, &name))
        return;
    printf("BDC /%s\n", name);  
}

static void op_EMC (CGPDFScannerRef s, void *info) {
    const char *name;
    if (!CGPDFScannerPopName(s, &name))
        return;
    printf("EMC /%s\n", name);  
}
//
//	CGPDFDocumentRef CGPDFDocumentCreateX(CFURLRef, NSString *) function
//

CGPDFDocumentRef CGPDFDocumentCreateX(CFURLRef theURL, NSString *password)
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	CGPDFDocumentRef thePDFDocRef = NULL;

	if (theURL != NULL) // Check for non-NULL CFURLRef
	{
		thePDFDocRef = CGPDFDocumentCreateWithURL(theURL);
/*        
        //Add CJH
        int k;
        CGPDFPageRef myPage;
        CGPDFScannerRef myScanner;
        CGPDFContentStreamRef myContentStream;
        
        CGPDFOperatorTableRef myTable;
        
        myTable = CGPDFOperatorTableCreate();
        
        CGPDFOperatorTableSetCallback (myTable, "MP", &op_MP);
        CGPDFOperatorTableSetCallback (myTable, "DP", &op_DP);
        CGPDFOperatorTableSetCallback (myTable, "BMC", &op_BMC);
        CGPDFOperatorTableSetCallback (myTable, "BDC", &op_BDC);
        CGPDFOperatorTableSetCallback (myTable, "EMC", &op_EMC);

        int numOfPages = CGPDFDocumentGetNumberOfPages (thePDFDocRef);// 1
        

        CGPDFStringRef titleStringRef;

        for (k = 0; k < numOfPages; k++) {
            myPage = CGPDFDocumentGetPage (thePDFDocRef, k + 1 );// 2
            myContentStream = CGPDFContentStreamCreateWithPage (myPage);// 3
            myScanner = CGPDFScannerCreate (myContentStream, myTable, NULL);// 4
            
            CGPDFStringRef string;
            CGPDFDictionaryRef infoDict;
            
            infoDict = CGPDFDocumentGetInfo(thePDFDocRef);
 
            if(CGPDFDictionaryGetString(infoDict, "title", &titleStringRef))
            {
                NSString * str = (NSString *)CGPDFStringCopyTextString(titleStringRef);
//            const unsigned char *titleCstring = CGPDFStringGetBytePtr(titleStringRef);

                NSLog(@"title: %@", str);    
            }
//            if (CGPDFDictionaryGetString(infoDict, "Keywords", &string));
//            CFStringRef s;
//            
//            s = CGPDFStringCopyTextString(string);
//            if (s != NULL) {
//                //need something in here in case it cant find anything
//                NSLog(@"%@ testing it", s);
//                CFRelease(s);
//            } else {
//                NSLog(@"No Keywords");
//            }
                
            
            CGPDFScannerScan (myScanner);// 5
            CGPDFPageRelease (myPage);// 6
            CGPDFScannerRelease (myScanner);// 7
            CGPDFContentStreamRelease (myContentStream);// 8
        }
 
        CGPDFOperatorTableRelease(myTable);

        //Add CJH End..
*/        
		if (thePDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (CGPDFDocumentIsEncrypted(thePDFDocRef) == TRUE) // Encrypted
			{
				// Try a blank password first, per Apple's Quartz PDF example

				if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE)
				{
					// Nope, now let's try the provided password to unlock the PDF

					if ((password != nil) && ([password length] > 0)) // Not blank?
					{
						char text[128]; // char array buffer for the string conversion

						[password getCString:text maxLength:126 encoding:NSUTF8StringEncoding];

						if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, text) == FALSE) // Log failure
						{
							#ifdef DEBUG
								NSLog(@"CGPDFDocumentCreateX: Unable to unlock [%@] with [%@]", theURL, password);
							#endif
						}
					}
				}

				if (CGPDFDocumentIsUnlocked(thePDFDocRef) == FALSE) // Cleanup unlock failure
				{
					CGPDFDocumentRelease(thePDFDocRef), thePDFDocRef = NULL;
				}
			}
		}
	}
	else // Log an error diagnostic
	{
		#ifdef DEBUG
			NSLog(@"CGPDFDocumentCreateX: theURL == NULL");
		#endif
	}

	return thePDFDocRef;
}

//
//	BOOL CGPDFDocumentNeedsPassword(CFURLRef, NSString *) function
//

BOOL CGPDFDocumentNeedsPassword(CFURLRef theURL, NSString *password)
{
#ifdef DEBUGX
	NSLog(@"%s", __FUNCTION__);
#endif

	BOOL needPassword = NO; // Default flag

	if (theURL != NULL) // Check for non-NULL CFURLRef
	{
		CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateWithURL(theURL);

		if (thePDFDocRef != NULL) // Check for non-NULL CGPDFDocumentRef
		{
			if (CGPDFDocumentIsEncrypted(thePDFDocRef) == TRUE) // Encrypted
			{
				// Try a blank password first, per Apple's Quartz PDF example

				if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE)
				{
					// Nope, now let's try the provided password to unlock the PDF

					if ((password != nil) && ([password length] > 0)) // Not blank?
					{
						char text[128]; // char array buffer for the string conversion

						[password getCString:text maxLength:126 encoding:NSUTF8StringEncoding];

						if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, text) == FALSE)
						{
							needPassword = YES;
						}
					}
					else
						needPassword = YES;
				}
			}

			CGPDFDocumentRelease(thePDFDocRef); // Cleanup CGPDFDocumentRef
		}
	}
	else // Log an error diagnostic
	{
		#ifdef DEBUG
			NSLog(@"CGPDFDocumentNeedsPassword: theURL == NULL");
		#endif
	}

	return needPassword;
}

// EOF
