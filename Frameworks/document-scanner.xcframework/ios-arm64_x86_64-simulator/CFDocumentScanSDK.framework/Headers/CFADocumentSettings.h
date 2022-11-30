//
//  CFADocumentSettings.h
//  CFDocumentScanSDK
//
//  Created by Jeremy Osterhoudt on 3/2/20.
//  Copyright © 2020 IDMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CFA2DBarcodeDelegate;
@protocol CFAOCRDataDelegate;
@protocol CFAMRZDataDelegate;
@protocol CFALivenessSelfieDelegate;
typedef NS_ENUM(NSInteger, CFACompressionType);
typedef NS_ENUM(NSInteger, CFACaptureMode);
typedef NS_ENUM(NSInteger, CFADocumentSide);
typedef NS_ENUM(NSInteger, CFADocumentType);
typedef NS_ENUM(NSInteger, CFAActionBarPosition);

__deprecated_msg("This class will be removed in v6.0.0; please migrate to the new DSHandler API.")
@interface CFADocumentSettings : NSObject

/*
 Shows type of document (Licence, Passport).
 Default : License
 */
@property (nonatomic,assign) CFADocumentType  documentType;
/*
 Shows document side that needs to be scanned (Front or Back).
 Default : Front
 */

@property (nonatomic,assign) CFADocumentSide  documentSide;

/*
 Shows to capture in Manual Mode.  In 5.0 the only mode is manual mode.
 Default : Manual Mode
 */
@property (nonatomic,assign) CFACaptureMode  captureMode;

/*
 Shows Final cropped images will be compressed in the specified format.
 Currently, supports only JPEG
 */
@property (nonatomic,assign) CFACompressionType compressionType;
/*
 The Compression quality value for the above compression type selected.
 Default: 30.
 */
@property (nonatomic) int compressionQuality;
/*
 Shows Integer value that defines the focus threshold (possible values 0 – 254).
 Default  : 150
 */
@property (nonatomic) int focusThreshold;
/*
 Float value that defines the glare threshold (possible values 0.005 - 0.5).
 Default  : 0.005
 */
@property (nonatomic) float glareThreshold;
/*
 The target resolution of the final rectified images. If a value of 0 is specified the default resolution is applied.
 Supported range is 300 to 600.
 Default: 460
 */
@property (nonatomic) int targetDPI;
/*
 Integer timeout that control the transition from Auto to Manual capture.
 Default: 10
 */
@property (nonatomic) int timeouttoManualinSec;
/*
 Integer Initial timeout for card detection,if card is detected Initial timeout will stop.
 Default: 10
 */
@property (nonatomic) int initialTimeOutToManualInSec;
/*
 Boolean Value  to upload a image from gallery.
 Default:TRUE
 */
@property (nonatomic) BOOL   enablePickFromGallery;
/*
 Boolean Value to show the cropper screen after the document rectification process completes.
 Default:FALSE
 */
@property (nonatomic) BOOL   showCropper;
/*
 Boolean Value that enables to capture sneaky selfie during document scan.
 Default:TRUE
 */
@property (nonatomic) BOOL   captureLivenessSelfie;
/*
 Boolean Value which determines to capture flash and no flash images.
 Default:TRUE
 */
@property (nonatomic) BOOL   enableFlashCapture;
/*
 Boolean Value for enabling bubble level.If set to True, document is captured only when the bubble turns Green and centered
 Default:TRUE
 */
@property (nonatomic) BOOL   enableLevelling;
/*
 Boolean Value for enabling rectification of image.If set to True,image will be rectified and it is set to false image will not be rectified.
 Default: TRUE
 */
@property (nonatomic) BOOL   enableRectification;
/*
 Boolean Value to show title on the screen.
 Default: FALSE
 */
@property (nonatomic) BOOL   showTitle;
/*
This is a string value which Displays the license key for opening SDK.
Default:nil
*/
@property (nonatomic,assign) NSString *licenseKey;
/*
 Boolean Value to enable detection of Hongkong ID Card.
 Default:FALSE
 */
@property (nonatomic) BOOL   isHKIDDocument;
/*
 This is a string value which Displays the selected language code for the application. For example: en for English. zh for Chinese, de for German etc.
 Default:""
 */
@property (nonatomic,assign) NSString *locale;
/*
 Boolean Value to remove bubble levelling when user moved from auto to manual.This will apply only when captureMode is set to Auto.
 Default: FALSE
 */
@property (nonatomic) BOOL   removeLevellerAfterTimeOut;
/*
 Boolean Value to show overlay on the screen,if it is set to false overlay will not appear when SDK is triggered.
 Default: FALSE
 */
@property (nonatomic) BOOL   enableInitialOverlay;
/*
 Boolean Value to enable Auto To Manual Overlay.
 Default:TRUE
 */
@property (nonatomic) BOOL enableManualOverlay;
/*
 Boolean Value  to show help message.
 Default:TRUE
 */
@property (nonatomic) BOOL   enableHelp;
/*
 Shows type of position for Action Bar (Left, Right).
 Default:Right
*/
@property (nonatomic,assign) CFAActionBarPosition actionBarPosition;
/*
 Boolean Value for enable glare detection on card.
 Default:FALSE
 */
@property (nonatomic,assign) BOOL enableGlareDetection;
/*
 Boolean Value for enable face detection on card.
 Default:FALSE
 */
@property (nonatomic,assign) BOOL enableFaceDetection;
/*
 Boolean value for enable Cancel Dailog Alert.
 Default:TRUE
 */
@property(nonatomic, assign) BOOL enableCancelDialog;
/*
 Boolean Value to return app,if given time interval exceeds
 Default:FALSE
 */
@property (nonatomic,assign) BOOL exitAfterTimeout;
/*Boolean value for swap Cancel Alert Actions
 Default:FALSE
 */
@property (nonatomic) BOOL swapDialogActions;
/*
 Initializes the DocumentSettings with all default values.
 return Initialized DocumentSettings object.
 */
- (_Nullable instancetype)init;

@end

NS_ASSUME_NONNULL_END
