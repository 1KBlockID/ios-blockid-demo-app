//
//  CFADocumentScanDelegate.h
//  CFDocumentScanSDK
//
//  Created by Jeremy Osterhoudt on 3/2/20.
//  Copyright © 2020 IDMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CFADocumentScanData;


__deprecated_msg("This class will be removed in v6.0.0; please migrate to the new DSHandler API.")
/**
  The CFADocumentScanDelegate encapsulates methods which will return document scan data.
*/
@protocol CFADocumentScanDelegate <NSObject>
 
@required
-(void)onFinishDocumentScan:(CFADocumentScanData*)documentScanData;

-(void)onCancelDocumentScan;

-(void)onFinishDocumentScanWithError:(int)errorCode errorMessage:(NSString*)errorMessage;


@end

NS_ASSUME_NONNULL_END
