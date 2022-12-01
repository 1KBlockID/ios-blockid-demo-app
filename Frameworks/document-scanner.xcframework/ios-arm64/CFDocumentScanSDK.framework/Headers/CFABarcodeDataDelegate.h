//
//  CFABarcodeDataDelegate.h
//  CFDocumentScanSDK
//
//  Created by Jeremy Osterhoudt on 3/2/20.
//  Copyright © 2020 IDMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The CFABarcodeDataDelegate encapsulates methods which will return 2DBarcode data.
 */
__deprecated_msg("This class will be removed in v6.0.0; please migrate to the new DSHandler API.")
@protocol CFABarcodeDataDelegate <NSObject>
@optional
-(void)on2DBarcodeData:(NSDictionary*)dict2DBarcode;

@end

NS_ASSUME_NONNULL_END
