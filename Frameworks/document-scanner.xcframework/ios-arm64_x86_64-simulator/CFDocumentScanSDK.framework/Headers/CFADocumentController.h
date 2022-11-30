//
//  CFADocumentController.h
//  CFDocumentScanSDK
//
//  Created by Jeremy Osterhoudt on 3/2/20.
//  Copyright © 2020 IDMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol CFADocumentScanDelegate;
@protocol CFABarcodeDataDelegate;
@protocol CFAMRZDataDelegate;
@protocol CFALivenessSelfieDelegate;
@protocol CFAOCRDataDelegate;

@class CFADocumentSettings;
@class DSCapture;
typedef DSCapture CFDocumentScanSDK;

__deprecated_msg("This class will be removed in v6.0.0; please migrate to the new DSHandler API.")
@interface CFADocumentController : NSObject {
}

/** delegate object which will control DocumentScan events */
@property (nonatomic, weak) id<CFADocumentScanDelegate> documentScanDelegate;
/** delegate object which will control BarcodeData scan events */
@property (nonatomic, weak) id<CFABarcodeDataDelegate> barcodeDataDelegate;
/** delegate object which will control OCRData scan events */
@property (nonatomic, weak) id<CFAOCRDataDelegate> ocrDataDelegate;
/** delegate object which will control MRZData scan events */
@property (nonatomic, weak) id<CFAMRZDataDelegate> mrzDataDelegate;
/** delegate object which will control LivenessSelfie events */
@property (nonatomic, weak) id<CFALivenessSelfieDelegate> livenessSelfieDelegate;
/**
 *  Initialize Document Scan
 *  @param vc                           The Parent View Controller used to present child view controller.
 *  @param docSettings                  Instance of documentSettings to scan document.
 *  @param documentScanDelegate         Set delegate to get scan result.
 */
- (void)scanDocument:(UIViewController * _Nullable)vc docSettings:(CFADocumentSettings*)docSettings documentScanDelegate:(id<CFADocumentScanDelegate>)documentScanDelegate;
/**
 * Starts liveness selfie scan
 *
 *  @param compressionQuality         The Compression quality value for the above compression type selected. Valid values are in the range 0 -100.
 *  @param livenessSelfieDelegate     Set delegate to get livenessSelfie result.
 */
- (void)scanLivenessSelfieWithCompressionQuality:(int)compressionQuality livenessSelfieDelegate:(id<CFALivenessSelfieDelegate>)livenessSelfieDelegate;
/**
 * Use this method to handle liveness selfie in background lifecycle.
 */
- (void)cancelLivenessSelfie;
/**
 *  This function gives version of SDK.
 *  @return The current build version of SDK.
 */
- (NSString*)getVersion;
/**
 * Get shared Instance.
 */
+ (instancetype)sharedInstance;

/**
 *  Use this method to add Delegate for 2D Barcode Data.
 */
- (void)addBarcodeDataDelegate : (id<CFABarcodeDataDelegate>)barcodeDataDelegate;
/**
 *  Use this method to add Delegate for Passport MRZ Data.
 */
- (void)addMrzDataDelegate : (id<CFAMRZDataDelegate>)mrzDataDelegate;
/**
 *  Use this method to add Delegate for OCR Data.
 */
- (void)addOcrDataDelegate : (id<CFAOCRDataDelegate>)ocrDataDelegate;

@end

NS_ASSUME_NONNULL_END
