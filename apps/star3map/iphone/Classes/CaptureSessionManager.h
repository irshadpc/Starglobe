//
//  CaptureSessionManager.h
//
//  Created by Dave van Dugteren on 3/07/12..
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

#define M_PI   3.14159265358979323846264338327950288   /* pi */
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

@interface CaptureSessionManager : NSObject
{
    AVCaptureDeviceInput *backFacingCameraDeviceInput;
    AVCaptureDeviceInput *frontFacingCameraDeviceInput;
    
    BOOL isUsingFrontCamera;
}

@property (strong) AVCaptureConnection *videoConnection;

@property (strong) AVCaptureStillImageOutput *stillImageOutput;
@property (atomic, strong) UIImage *stillImage;

- (void)addStillImageOutput;
- (void)captureStillImage;

//@property (retain) AVCapture
@property (strong, atomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, atomic) AVCaptureSession *captureSession;

- (void)addVideoPreviewLayer;
- (void)addVideoInput;

//Tentative Code
#pragma Returns NO if not possible. Shouldnt rely on this for a check though.
- (BOOL) addFrontVideoInput;
- (BOOL) addBackVideoInput;

@end