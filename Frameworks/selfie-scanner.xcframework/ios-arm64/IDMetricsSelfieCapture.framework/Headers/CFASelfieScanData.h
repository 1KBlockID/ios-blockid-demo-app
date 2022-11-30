//
//  CFASelfieScanData.h
//  IDMetricsSelfieCapture
//
//  Created by CH0007 on 14/03/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFASelfieScanData : NSObject
/*
 Refers to the image (headshot) that got captured successfully.
 */
@property (nonatomic,strong) NSData *selfieData;
/*
Refers to the image (headshot) that got captured successfully.
*/
@property (nonatomic,strong) NSData *farSelfieData;
/*
Refers to the value set in “captureLivenessOnConfirmation” parameter. If the value is “True”, the liveness selfie data is the result and if the value is “False”, then the result is null.
*/
@property (nonatomic,strong) NSData *livenessSelfieData;
/*
 Refers to the value set in “captureLivenessOnConfirmation” parameter. If the value is “True”, the liveness selfie data is the result and if the value is “False”, then the result is null.
 */
@property (nonatomic,strong) NSData *farLivenessSelfieData;
/*
 Refers to the selfie which if set as “True” is auto captured or if set as “False” is manually captured.
 */
@property (nonatomic) BOOL autoCaptured;
/*
 Refers to the far selfie which if set as “True” is auto captured or if set as “False” is manually captured.
 */
@property (nonatomic) BOOL farSelfieAutoCaptured;

@end
