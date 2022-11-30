//
//  CFASelfieScanResult.h
//  IDMetricsSelfieCapture
//
//  Created by IDM014 on 27/09/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFASelfieScanResult : NSObject
/*
 The value is set as “True” if face is detected in the Selfie and “False” if face is not detected.
 */
@property(nonatomic)BOOL faceDetected;
/*
 The value is set as “True” if the selfie has glare and set as “False” if the selfie dont have any glare.
 */
@property(nonatomic)BOOL glare;
/*
 The value is set as “True” if the selfie is focused and set as “False” if the selfie is blur.
 */
@property(nonatomic)BOOL focus;
/*
 The value is set as “True” if the motion is detected and set as “False” if the no motion is detected.
 */
@property(nonatomic)BOOL motionDetected;
/*
 The value is set as “True” if the person blinks are detected for bunch of frames and set as “False” if not.
 */
@property(nonatomic)BOOL blinkDetected;
/*
 The value is set as “True” if face and blinks both are detected for bunch of frames and set as “False” if not.
 */
@property(nonatomic)BOOL autoSnapped;
/*
 The value indicates processed frame per second.
 */
@property(nonatomic)int fps;
/*
 The value indicates frame number is being processed.
 */
@property(nonatomic)int frameNum;
/*
 The value indicates number of blinks detected for bunch of frames.
 */
@property(nonatomic)int numBlinks;
/*
 The value indicates face rect includes x, y, width, height of face detected.
 */
@property(nonatomic)CGRect faceRect;


@end

