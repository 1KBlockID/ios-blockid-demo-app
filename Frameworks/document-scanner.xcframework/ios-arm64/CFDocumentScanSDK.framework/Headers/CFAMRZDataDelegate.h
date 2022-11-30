//
//  CFAMRZDataDelegate.h
//  CFDocumentScanSDK
//
//  Created by Jeremy Osterhoudt on 3/2/20.
//  Copyright © 2020 IDMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The CFAMRZDataDelegate encapsulates methods which will return MRZ data.
 */
__deprecated_msg("This class will be removed in v6.0.0; please migrate to the new DSHandler API.")
@protocol CFAMRZDataDelegate <NSObject>
@optional
-(void)onPassportMRZData:(NSString*)MRZString1 mrzString2:(NSString*)MRZString2 DEPRECATED_MSG_ATTRIBUTE("Deprecated since 4.1.0 Use onPassMRZData: ");
-(void)onPassportMRZData:(NSDictionary *)mrzData;

@end


NS_ASSUME_NONNULL_END
