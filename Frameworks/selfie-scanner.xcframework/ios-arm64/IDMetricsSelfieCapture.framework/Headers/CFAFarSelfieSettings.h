//
//  CFAFarSelfieSettings.h
//  IDMetricsSelfieCapture
//
//  Created by CH0007 on 08/10/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFASelfieEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface CFAFarSelfieSettings : NSObject
/*
 Shows Modes for Selfie Capture(AutoCapture, Semi Auto or Manual Capture).
 Default:Semi_Auto
 */
@property (nonatomic,assign) CFASelfieCaptureMode captureMode;
/*
 This is an integer value that will Decide to control the blur in the images and  higher the value, the most blur images will be captured.
 Default: 20
 */
@property (nonatomic) int blurIntensityThreshold;
/*
 Timeout for resetting the motions of your eye and face.
 Default: 10
 */
@property (nonatomic) int resetTimeOutInSec;
/*
 The Compression quality value jpeg compression used for selfie. Valid values are in the range 0 -100.
 Default : 50
 */
@property (nonatomic) int compressionQuality;
/*
 Boolean Value to enable Help.
 Default:false
 */
@property (nonatomic) BOOL enableHelp DEPRECATED_MSG_ATTRIBUTE("This setting will be removed in a future version.");
/*
 Boolean Value to enable Auto To Manual Overlay.
 Default:true
 */
@property (nonatomic) BOOL enableManualOverlay;
/*
 Boolean Value to enable Far Selfie Overlay.
 Default:true
 */
@property (nonatomic) BOOL enableFarSelfieOverlay;
/*
 Boolean Value to enable Far Selfie Gif.
 Default:true
 */
@property (nonatomic) BOOL enableFarSelfieOverlayGif;
/*
 Boolean Value to enable Far Selfie Avatar.
 Default:true
 */
@property (nonatomic) BOOL enableFarSelfieAvatar;
/*
 This is an integer value that will decide the threshold for Focus value of the Far Selfie Image within the Oval. Valid values are in the range 0-200.
 Default: 20
 */
@property (nonatomic) int roiFocusThreshold;
/*
 Boolean Value to show confirmation screen when capture mode is AUTO.
 Default : false
 */
@property (nonatomic) BOOL showConfirmationScreen;
/*
 Set to “True”, the application will click the liveness selfie and if set to “False” then application will not click liveness selfie.
 Default : true
 */
@property (nonatomic) BOOL captureLivenessOnConfirmation;
/*
 Boolean value to exitAfterTimeOutFarSelfie, when set to true sdk will return back to app with error callback when requested timeout is completed.
 Default:FALSE
 */
@property (nonatomic,assign) BOOL exitAfterTimeOutFarSelfie;
@end

NS_ASSUME_NONNULL_END

