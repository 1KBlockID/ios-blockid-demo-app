//
//  CFAOCRDataDelegate.h
//  IDMetricsDocumentCapture
//
//  Created by IDM014 on 08/03/18.
//  Copyright © 2018 IdMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  The CFAOCRDataDelegate encapsulates methods which will return OCR data.
 */
__deprecated_msg("This class will be removed in v6.0.0; please migrate to the new DSHandler API.")
@protocol CFAOCRDataDelegate <NSObject>
@optional
-(void)onOCRData:(NSDictionary*)dictOCRData;

-(void)onCheckDigitFailure:(int)calculatedCheckDigit extractedCheckDigit:(int)extractedCheckDigit;

@end
