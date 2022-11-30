//
//  CFASelfieLiveDelegate.h
//  IDMetricsSelfieCapture
//
//  Created by IDM014 on 27/09/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFASelfieScanResult.h"

/**
 *  The CFASelfieLiveDelegate encapsulates methods which will return selfie scan results.
 */

@protocol CFASelfieLiveDelegate <NSObject>

-(void)onSelfieScanResult:(CFASelfieScanResult*)scanResult;

-(void)onSelfieScanError:(int)errorCode errorMessage:(NSString*)errorMessage;

@end
