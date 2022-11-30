//
//  CFADirectSelfieSettings.h
//  IDMetricsSelfieCapture
//
//  Created by IDM014 on 27/09/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFASelfieROI.h"
@interface CFADirectSelfieSettings : NSObject
/*
 This value checks the focus in the frame.
 Default: 20
 */
@property (nonatomic) int blurIntensityThreshold;
/*
 Controls the threshold for face motion intensity that is estimated by taking the difference between two consecutive frames.
 Default: 0.7
 */
@property (nonatomic) double faceMotionThreshold;
/*
 This value decides the percentage of pixels inside the eye box that need to be in motion. If you decrease this value small eye motion will be detected and easy to capture.
 Default: 0.2
 */
@property (nonatomic) double eyeMotionThreshold;
/*
 This value decides the threshold for Focus value of the frame for the given ROI.
 Default: 30
 */
@property (nonatomic) int roiFocusThreshold;
/*
 Controls the threshold for eye motion intensity that is estimated by taking the difference between two consecutive frames.Valid values are in the range 0 to 100.
 Default: 30
 */
@property (nonatomic) int eyeIntensityThreshold;
/*
 Boolean value that will enable algorithm to detect open eyes.
 Default : false
 */
@property (nonatomic) BOOL useOpenEyeDetector;
/*
 CGRect value to check focus in given frame.
 Default : Frame Rect
 */
@property (nonatomic,retain) CFASelfieROI *ROI;

@end
