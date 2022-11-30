//
//  CFASelfieCapturedDelegate.h
//  CatfishAir
//
//  Created by IDM014 on 28/09/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//


#import "CFASelfieCapturedResult.h"

/**
 *  The CFASelfieCapturedDelegate encapsulates methods which will return selfie captured results.
 */

@protocol CFASelfieCapturedDelegate <NSObject>

-(void)onSelfieCapturedResult:(CFASelfieCapturedResult*)capturedResult;

-(void)onSelfieCapturedError:(int)errorCode errorMessage:(NSString*)errorMessage;
@end
