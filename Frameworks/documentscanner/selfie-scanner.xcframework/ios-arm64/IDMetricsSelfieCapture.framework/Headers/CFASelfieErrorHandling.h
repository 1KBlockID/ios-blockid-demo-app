// #define Direct API Selfie Error Codes
#define  DirectAPI_INIT_SETTINGS_Code                            @"5000"
#define  DirectAPI_BLUR_INTENSITY_Code                           @"5001"
#define  DirectAPI_FACE_MOTION_Code                              @"5002"
#define  DirectAPI_EYE_MOTION_Code                               @"5003"
#define  DirectAPI_EYE_INTENSITY_Code                            @"5004"
#define  DirectAPI_FOCUS_THRESHOLD_Code                          @"5005"
#define  DirectAPI_PROCESS_LIVE_SETTINGS_Code                    5006
#define  DirectAPI_IMAGE_NOTFOUND_Code                           5007
#define  DirectAPI_COMPRESSION_QUALITY_Code                      5008
#define  DirectAPI_PROCESS_CAPTURE_SETTINGS_Code                 5009

// #define CFASDK Selfie API Error Codes
#define CAMERA_PERMISSION_Code                                   4000
#define RESET_TIMEOUT_Code                                       4001
#define BLUR_INTENSITY_Code                                      4002
#define EYE_INTENSITY_Code                                       4003
#define FACE_MOTION_Code                                         4004
#define EYE_MOTION_Code                                          4005
#define FOCUS_THRESHOLD_Code                                     4006
#define COMPRESSION_QUALITY_Code                                 4007
#define FARSELFIE_Code                                           4008
#define CAMERA_EXECEPTION_Code                                   4010
#define SELFIEEXIT_TIMEOUT_Code                                  4011

#define FARSELFIE_RESET_TIMEOUT_Code                             4050
#define FARSELFIE_BLUR_INTENSITY_Code                            4051
#define FARSELFIE_FOCUS_THRESHOLD_Code                           4055
#define FARSELFIE_COMPRESSION_QUALITY_Code                       4056
#define FARSELFIE_EXIT_TIMEOUT_Code                              4058

// #define Direct API Selfie Error Messages
#define CAMERA_PERMISSION_ERRORMSG                               @"You cant access to Selfie scan, as Camera permission is not enable."
#define INITIALIZATION_SETTINGS_FAILURE                          @"Initialization failed due to Settings are not provided."
#define PROCESS_LIVE_SETTINGS_FAILURE                            @"Settings not found to process the frame,call init before you call live frame method."
#define PROCESS_CAPTURE_SETTINGS_FAILURE                         @"Settings not found to process the frame,call init before you call captured frame method."
#define PROCESS_IMAGE_NOT_FOUND                                  @"Provide Image to process."

// #define CFASDK Selfie API Error Messages
#define RESETTIMEOUT_ERRORMSG                                    @"resetTimeOutInSec should be greater than 0"
#define BLURINTENSITY_ERRORMSG                                   @"blurIntensity should be between 0 to 100"
#define EYEINTENSITY_ERRORMSG                                    @"eyeIntensity should be between 0 to 100"
#define FACEMOTION_ERRORMSG                                      @"faceMotion should be between 0 to 1"
#define EYEMOTION_ERRORMSG                                       @"eyeMotion should be between 0 to 1"
#define ROI_FOCUSTHRESHOLD_ERRORMSG                              @"roiFocusThreshold should be between 0 to 254"
#define COMPRESSION_ERRORMSG                                     @"compressionQuality should be between 0 to 100"
#define FARSELFIE_ERRORMSG                                       @"useBackCamera cannot be used when Far Selfie is enabled"
#define FARSELFIE_ROI_FOCUSTHRESHOLD_ERRORMSG                    @"farSelfieRoiFocusThreshold should be between 0 to 200"
#define SELFIE_EXIT_TIMEOUT_ERRORMSG                             @"Unable to capture Selfie,due to timeout"
#define FARSELFIE_EXIT_TIMEOUT_ERRORMSG                           @"Unable to capture FarSelfie,due to timeout"


/**DIRECT API SELFIE TAGS*/
#define CFASELFIE_LIVE                                           @"CFASelfieLive"
#define CFASELFIE_CAPTURE                                        @"CFASelfieCapture"
#define CAMERA_ACTION_EXCEPTION_ERRORMSG                         @"Camera related actions can't be accessed in simulator"
