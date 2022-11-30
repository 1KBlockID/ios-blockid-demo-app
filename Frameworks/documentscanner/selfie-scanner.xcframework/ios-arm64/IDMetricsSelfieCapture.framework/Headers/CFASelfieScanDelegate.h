//
//  CFASelfieScanDelegate.h
//  IDMetricsSelfieCapture
//
//  Created by CH0007 on 13/03/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFASelfieScanData.h"

@protocol CFASelfieScanDelegate <NSObject>
/**
 *  The CFASelfieScanDelegate encapsulates methods which will return selfie scan results.
 */

-(void)onFinishSelfieScan:(CFASelfieScanData*)selfieScanData;
-(void)onCancelSelfieScan;
-(void)onFinishSelfieScanWithError:(int)errorCode errorMessage:(NSString*)errorMessage;



@end
