//
//  CFADocumentEnum.h
//  CFDocumentScanSDK
//
//  Created by Jeremy Osterhoudt on 3/2/20.
//  Copyright © 2020 IDMetrics. All rights reserved.
//

#ifndef CFADocumentEnum_h
#define CFADocumentEnum_h

__deprecated_msg("This enum will be removed in v6.0.0; please migrate to the new DSHandler API.  In 5.0 only License and Passport_Landscape will function.")
typedef NS_ENUM(NSInteger, CFADocumentType) {
    License=1,
    Passport_Portrait,
    Passport_Landscape,
    ID2_Document,
    GreenID
};
typedef NS_ENUM(NSInteger, CFADocumentSide) {
    Front=1,
    Back
};

typedef NS_ENUM(NSInteger, CFACompressionType) {
    JPEG=1
};
typedef NS_ENUM(NSInteger, CFACaptureMode) {
    Auto=1,
    Manual
};
typedef NS_ENUM(NSInteger, CFAActionBarPosition) {
    LEFT=1,
    RIGHT
};


#endif /* CFADocumentEnum_h */
