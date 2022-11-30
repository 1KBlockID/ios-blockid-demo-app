//
//  CFALivenessSelfieDelegate.h
//  IDMetricsDocumentCapture
//
//  Created by IDM014 on 08/03/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The CFALivenessSelfieDelegate encapsulates methods which will return LivenessSelfie data.
 */
__deprecated_msg("This class will be removed in v6.0.0; please migrate to the new DSHandler API.")
@protocol CFALivenessSelfieDelegate <NSObject>
@optional
-(void)onFinishLivenessSelfie:(NSData*)livenessSelfieData;

-(void)onFinishLivenessSelfieWithError:(int)errorCode errorMessage:(NSString*)errorMessage;

@end

