//
//  CFASelfieController.h
//  Catfish Air
//
//  Created by CH0007 on 1/29/15.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CFASelfieSettings.h"
#import "CFASelfieScanDelegate.h"
#import "CFADirectSelfieSettings.h"
#import "CFASelfieLiveDelegate.h"
#import "CFASelfieCapturedDelegate.h"
#import "CFASelfieEnum.h"
#import "CFADirectSelfieSettings.h"

@interface CFASelfieController : NSObject

@property (nonatomic, weak) id<CFASelfieScanDelegate> selfieScandelegate;
@property (nonatomic, weak) id<CFASelfieLiveDelegate> selfieLivedelegate;
@property (nonatomic, weak) id<CFASelfieCapturedDelegate> selfieCapturedDelegate;

-(void)scanSelfie:(UIViewController*)vc selfieSettings:(CFASelfieSettings*)selfieSettings selfieScanDelegate:(id<CFASelfieScanDelegate>)selfieScanDelegate;
/**
 *  This function gives version of SDK
 *
 *  @return The current bundle version of SDK
 */
-(NSString*)getVersion;

/**
 *  Initialize a blank View with given text
 *
 *  @param vc       The Parent View Controller used to present child view controller.
 */
-(void)showTextView:(UIViewController*)vc locale:(NSString*)locale;

+(id)sharedInstance;
/**
 *  @param selfieSettings      Instance of selfieSettings. These settings will be applied on given  image in live frame.
 */
-(void)initWithSelfieSettings:(CFADirectSelfieSettings*)selfieSettings;
/**
 *
 *  @param image                        Set Image for live scan process.
 *  @param orientation                  Set the orientation of image.
 *  @param selfieLiveDelegate           Set delegate to get live result.
 */
- (void)processLiveFrame:(UIImage *)image orientation:(CFASelfieOrientation)orientation selfieLiveDelegate:(id<CFASelfieLiveDelegate>)selfieLiveDelegate;
/**
 *
 *  @param frame                        Set frame for rectification.
 *  @param orientation                  Set the orientation of frame.
 *  @param selfieCapturedDelegate       Set delegate to get captured selfie result.
 */
- (void)processCapturedFrame:(NSData*)frame compressionQuality:(int)compressionQuality orientation:(CFASelfieOrientation)orientation selfieCapturedDelegate:(id<CFASelfieCapturedDelegate>)selfieCapturedDelegate;
/**
 *  Use this method to release live and captured instances once whole process is done.
 */
- (void)releaseSelfieProcess;
/**
 *  Use this method to get live process status of given image. This will 1 only if live process is called in background.
 */
-(CFASelfieStatus)getSelfieStatus;
/**
 *  Use this method to enable logs in console.
 */
- (void)enableDebugMode:(BOOL)debugMode;

@end





