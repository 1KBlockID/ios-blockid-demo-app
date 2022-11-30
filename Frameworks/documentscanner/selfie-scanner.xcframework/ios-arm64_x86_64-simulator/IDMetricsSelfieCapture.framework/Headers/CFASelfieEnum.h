//
//  CFASelfieEnum.h
//  IDMetricsSelfieCapture
//
//  Created by IDM014 on 05/10/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CFASelfieCaptureMode) {
    AutoCapture=1,
    ManualCapture,
    Semi_Auto
};
typedef NS_ENUM(NSInteger, CFASelfieStatus) {
    SelfieProcessing,
    SelfieFinished
};
typedef NS_ENUM(NSInteger, CFASelfieOrientation)  {
    PORTRAIT,
    LANDSCAPELEFT,
    LANDSCAPERIGHT
};
typedef NS_ENUM(NSInteger, CFACancelIconPosition) {
    TOP_LEFT,
    TOP_RIGHT
};
