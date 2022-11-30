//
//  CFASelfieCapturedResult.h
//  IDMetricsSelfieCapture
//
//  Created by IDM014 on 28/09/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFASelfieCapturedResult : NSObject
/*
 The value is set as “True” if the selfie has glare and set as “False” if the selfie dont have any glare.
 */
@property(nonatomic)BOOL glare;
/*
 The value is set as “True” if the selfie is focused and set as “False” if the selfie is blur.
 */
@property(nonatomic)BOOL focus;
/*
 The value is set as “True” if face is detected in the Selfie and “False” if face is not detected.
 */
@property(nonatomic)BOOL faceDetected;
/*
 Refers to the frame that is being processed for face, focus, glare and compressed as per given input.
 */
@property (nonatomic,strong) NSData *capturedImageData;
@end
