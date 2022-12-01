//
//  CFADocumentScanData.h
//  CFDocumentScanSDK
//
//  Created by Jeremy Osterhoudt on 3/2/20.
//  Copyright © 2020 IDMetrics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

__deprecated_msg("This class will be removed in v6.0.0; please migrate to the new DSHandler API.")
@interface CFADocumentScanData : NSObject
/*
 Document data that got scanned without flash.For ID3/Passport documents,it will be nil in case of autocaptured and cropped image if it is picked from a gallery.
*/
@property (nonatomic,strong) NSData *_Nullable docData;
/*
 Document data that got scanned with flash.For ID3/Passport documents it will be nil in case the document is autocaptured or picked from the gallery.
*/
@property (nonatomic,strong) NSData * _Nullable docFlashData;
/*
 Original document data without cropping that is captured or picked from the gallery. In case of ID3/Passport,it will show original captured image
 */
@property (nonatomic,strong) NSData * _Nullable originalDocData;
/*
Original document data without cropping that is captured with flash. In case of ID3/Passport,it will show original captured flash image.
 */
@property (nonatomic,strong) NSData * _Nullable originalDocFlashData;
/*
 LivenessSelfie data captured at the time of document scan. Returns nil if livenessSelfie value is set to “False” in Scan Document method.
 */
@property (nonatomic,strong) NSData * _Nullable livenessSelfieData;
/*
The value is set as “True” for auto captured  and “False” for manually captured.
 */
@property (nonatomic) BOOL autoCaptured;
/*
The value is set as “True” if the document is captured under correct focus and set as “False” if the document is not in focus.
 */
@property (nonatomic) BOOL focus;
/*
The value is set as “True” if the document is captured under right glare and set as “False” if the document is captured under minimum glare.
 */
@property (nonatomic) BOOL glare;
/*
 The value is set as “True” if face is detected in the document and “False” if face is not detected in the document.
 */
@property (nonatomic) BOOL faceDetected;

@end

NS_ASSUME_NONNULL_END
