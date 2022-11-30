//
//  CFASelfieSettings.h
//  IDMetricsSelfieCapture
//
//  Created by IDM014 on 12/03/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFASelfieEnum.h"
#import "CFAFarSelfieSettings.h"
@interface CFASelfieSettings : NSObject
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
 Controls the blur in the images. Higher the value, the more blur images will be captured.
 Default: 0.7
 */
@property (nonatomic) double faceMotionThreshold;
/*
 This is a float value that will decide the percentage of pixels inside the eye box that need to be in motion. If you decrease this value small eye motion will be detected and easy to capture. Valid values are in the range 0 to 1.
 Default: 0.2
 */
@property (nonatomic) double eyeMotionThreshold;
/*
 This is an integer value that will decide the threshold for Focus value of the Selfie Image within the Oval. Valid values are in the range 0-254.
 Default: 30
 */
@property (nonatomic) int roiFocusThreshold;
/*
Controls the threshold for eye motion intensity that is estimated by taking the difference between two consecutive frames.Valid values are in the range 0 to 100.
 Default: 30
 */
@property (nonatomic) int eyeIntensityThreshold;
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
 Boolean value that will enable algorithm to detect open eyes.
 Default : false
 */
@property (nonatomic) BOOL useOpenEyeDetector;
/*
Displays on screen statistics of selfie capture.
Default : false
 */
@property (nonatomic) BOOL isdebugMode;
/*
 Boolean Value to trigger the camera front or back.
 Default : true
 */
@property (nonatomic) BOOL enableSwitchCamera;
/*
 Boolean Value to show back or front camera.
 Default : false
 */
@property (nonatomic) BOOL useBackCamera;
/*
 Boolean Value to show confirmation screen when capture mode is AUTO.
 Default : false
 */
@property (nonatomic) BOOL showConfirmationScreen;
/*
 Set to “True”, the application will click the liveness selfie and if set to “false” then application will not click liveness selfie.
 Default : true
 */
@property (nonatomic) BOOL captureLivenessOnConfirmation;
/*
 This is a string value which Displays the selected language code for the application. For example: en for English. zh for Chinese, de for German etc.
 Default:en
 */
@property (nonatomic,assign) NSString *locale;
/*
 Boolean Value to show overlay on the screen,if it is set to "false"" overlay will not appear when SDK is triggered.
 Default: false
 */
@property (nonatomic) BOOL enableInitialOverlay;
/*
 Boolean Value to enable Help Icon,It displays help icon on live screens when set as "true".
 Default:false
 */
@property (nonatomic) BOOL enableHelp DEPRECATED_MSG_ATTRIBUTE("This setting will be removed in a future version.");
/*
 Boolean Value to enable Auto To Manual Overlay,Displays overlay on live screens when set as "true".
 Default:true
 */
@property (nonatomic) BOOL enableManualOverlay;
/*
 Boolean Value to enable Far Selfie.
 Default:true
 */
@property (nonatomic) BOOL enableFarSelfie;
/*Initializes the CFAFarSelfieSettings values.
 */
@property(nonatomic,retain)CFAFarSelfieSettings *objFarSelfieSettings;
/*Boolean value for enable Canel Dialog Alert,if it is "false" it will  redirect to the app instead of showing alert pop up with cancel callback.
 Default:TRUE
 */
@property(nonatomic, assign) BOOL enableCancelDialog;
/*Boolean value for swap Cancel Alert Actions.If it is "true" then button actions in the cancel alert popup will swap.
 Default:FALSE
 */
@property (nonatomic) BOOL swapDialogActions;
/*
  Boolean value to exitAfterTimeout, when set to true sdk will return back to app with error callback when requested timeout is completed.
 Default:FALSE
 */
@property (nonatomic,assign) BOOL exitAfterTimeout;
/*
 Shows cancel icon position on the live screen (Left, Right).
 Default:LEFT
 */
@property (nonatomic,assign) CFACancelIconPosition cancelIconPosition;
/*
 Initializes the SelfieSettings with all default values.
 return Initialized SelfieSettings object.
 */
- (instancetype)init;
@end
