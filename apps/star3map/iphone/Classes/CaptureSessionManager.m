//
//  CaptureSessionManager.m
//
//  Created by Dave van Dugteren on 3/07/12.
//

#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
//#import "UIImage-Extensions.h"
//#import "Tracker.h"

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;
@synthesize videoConnection;

- (id)init {
    if ((self = [super init]))
    {
        isUsingFrontCamera = NO;
        [self setCaptureSession:[[AVCaptureSession alloc] init]];
        captureSession.sessionPreset =AVCaptureSessionPresetMedium;
    }
    return self;
}

- (void) addCameraVideoLayer
{
    
}

- (void)addVideoPreviewLayer
{
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
    [[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (void)addVideoInput
{
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (videoDevice)
    {
        NSError *error;
        
        if (backFacingCameraDeviceInput == nil)
        {
            backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        }
        
        if (!error)
        {
            if ([[self captureSession] canAddInput: backFacingCameraDeviceInput])
            {
                [[self captureSession] addInput: backFacingCameraDeviceInput];
            }
            else
                NSLog(@"Couldn't add video input");
        }
        else
            NSLog(@"Couldn't create video input");
    }
    else
        NSLog(@"Couldn't create video capture device");
}

- (BOOL) addFrontVideoInput
{
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    
    for (AVCaptureDevice *device in devices)
    {
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] != AVCaptureDevicePositionBack)
            {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    if (frontFacingCameraDeviceInput == nil)
        frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    
    if (!error)
    {
        if (backFacingCameraDeviceInput != nil)
        {
            [[self captureSession] removeInput: backFacingCameraDeviceInput];
        }
        
        if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput])
        {
            [[self captureSession] addInput:frontFacingCameraDeviceInput];
            isUsingFrontCamera = YES;
            return YES;
        }
        else
        {
            NSLog(@"Couldn't add front facing video input: %@", error.description);
            
            return NO;
        }
    }
    
    return NO;
}

- (BOOL) addBackVideoInput
{
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices)
    {
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : Back");
                backCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    
    if (backFacingCameraDeviceInput == nil)
        backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice: backCamera error:&error];
    
    if (!error)
    {
        if (frontFacingCameraDeviceInput != nil)
        {
            [[self captureSession] removeInput: frontFacingCameraDeviceInput];
        }
        
        if ([[self captureSession] canAddInput:backFacingCameraDeviceInput])
        {
            [[self captureSession] addInput:backFacingCameraDeviceInput];
            isUsingFrontCamera = NO;
            
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    return NO;
}

- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init]];
    
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    videoConnection = nil;
    
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections])
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                NSLog(@"addStillImageOutput::videoConnectionSet");
                break;
            }
        }
        if (videoConnection)
        {
            NSLog(@"addStillImageOutput::videoConnectionSet");
            break;
        }
    }
    
    [[self captureSession] addOutput:[self stillImageOutput]];
    
    [[self captureSession] startRunning];
}

- (void)captureStillImage
{
    NSString *orientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationUnknown:
            orientation = @"UIDeviceOrientationUnknown";
            break;
        case UIDeviceOrientationPortrait:
            orientation = @"UIDeviceOrientationPortrait";
            NSLog(@"UIDeviceOrientationPortrait");
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = @"UIDeviceOrientationPortraitUpsideDown";
            NSLog(@"UIDeviceOrientationPortraitUpsideDown");
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = @"UIDeviceOrientationLandscapeLeft";
            NSLog(@"UIDeviceOrientationLandscapeLeft");
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = @"UIDeviceOrientationLandscapeRight";
            NSLog(@"UIDeviceOrientationLandscapeRight");
            break;
        case UIDeviceOrientationFaceUp:
            orientation = @"UIDeviceOrientationFaceUp";
            NSLog(@"UIDeviceOrientationFaceUp");
            break;
        case UIDeviceOrientationFaceDown:
            orientation = @"UIDeviceOrientationFaceDown";
            NSLog(@"UIDeviceOrientationFaceDown");
            break;
        default:
            orientation = @"UIDeviceOrientationUnknown";
            break;
    }
    
    if (isUsingFrontCamera)
    {
        //[Tracker trackEvent: [NSString stringWithFormat: @"AVCameraView/PhotoTaken/FrontCamera/%@", orientation]];
    }
    else
    {
        //[Tracker trackEvent: [NSString stringWithFormat: @"AVCameraView/PhotoTaken/BackCamera/%@", orientation]];
    }
    
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    videoConnection = nil;
    
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections])
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo])
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [self.captureSession beginConfiguration];
    [device lockForConfiguration:nil];
    
    if ([device isTorchModeSupported:(AVCaptureTorchModeAuto)])
    {
        [device setTorchMode: AVCaptureTorchModeAuto];
        [device setFlashMode: AVCaptureFlashModeAuto];
    }
    
    [device unlockForConfiguration];
    [[self captureSession] commitConfiguration];
    
   // NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         
         if (error != nil)
         {
     //        NSLog(@"error: %@", error.description);
             //[Tracker trackEvent: [NSString stringWithFormat: @"AVCameraView/PhotoTaken/Error/%@", error.description]];
         }
         
         if (exifAttachments)
         {
             //NSLog(@"exifAttachments: %@", exifAttachments);
         }
         else
         {
           //  NSLog(@"no attachments");
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
         
         if (isUsingFrontCamera)
         {
             if (deviceOrientation == UIDeviceOrientationPortrait)
             {
                 image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                    scale: 1.0
                                              orientation: UIImageOrientationLeftMirrored];
             }
             else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
             {
                 image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                    scale: 1.0
                                              orientation: UIImageOrientationDownMirrored];
             }
             else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
             {
                 image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                    scale: 1.0
                                              orientation: UIImageOrientationUpMirrored];
             }
             else if ((deviceOrientation == UIDeviceOrientationFaceUp) || (deviceOrientation == UIDeviceOrientationFaceDown) || (deviceOrientation == UIDeviceOrientationUnknown) )
             {
                 if (previewLayer.orientation == AVCaptureVideoOrientationLandscapeRight)
                 {
                     NSLog(@"(front)previewLayer.orientation = AVCaptureVideoOrientationLandscapeRight %i",image.imageOrientation);
                     
                     image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationDownMirrored];
                 }
                 else if (previewLayer.orientation == AVCaptureVideoOrientationLandscapeLeft)
                 {
                     NSLog(@"(front)previewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft %i",image.imageOrientation);
                     
                     image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationUpMirrored];
                 }
                 else if (previewLayer.orientation == AVCaptureVideoOrientationPortrait)
                 {
                     NSLog(@"(front)previewLayer.orientation = AVCaptureVideoOrientationPortrait %i",image.imageOrientation);
                     image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationLeftMirrored];
                 }
             }
         }
         else
         {
             if (deviceOrientation == UIDeviceOrientationLandscapeRight)
             {
                 if (image.imageOrientation == UIImageOrientationRight)
                 {
                     image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationDown];
                 }
             }
             else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
             {
                 if (image.imageOrientation == UIImageOrientationRight) {
                     image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationUp];
                 }
             }
             else if ((deviceOrientation == UIDeviceOrientationFaceUp) || (deviceOrientation == UIDeviceOrientationFaceDown) || (deviceOrientation == UIDeviceOrientationUnknown) )
             {
                 /*
                  AVCaptureVideoOrientationPortrait           = 1,
                  AVCaptureVideoOrientationPortraitUpsideDown = 2,
                  AVCaptureVideoOrientationLandscapeRight     = 3,
                  AVCaptureVideoOrientationLandscapeLeft      = 4,
                  */
                 if (previewLayer.orientation == AVCaptureVideoOrientationLandscapeRight)
                 {
                     NSLog(@"previewLayer.orientation = AVCaptureVideoOrientationLandscapeRight %i",image.imageOrientation);
                     
                     image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationUp];
                 }
                 else if (previewLayer.orientation == AVCaptureVideoOrientationLandscapeLeft)
                 {
                     NSLog(@"previewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft %i",image.imageOrientation);
                     
                     image = [[UIImage alloc] initWithCGImage: image.CGImage
                                                        scale: 1.0
                                                  orientation: UIImageOrientationDown];
                 }
                 else if (previewLayer.orientation == AVCaptureVideoOrientationPortrait)
                 {
                     NSLog(@"image.imageOrientation: %i",image.imageOrientation);
                 }
                 else
                 {
                     NSLog(@"else::image.imageOrientation: %i",image.imageOrientation);
                 }
             }
         }
         
         [self setStillImage: image];
         [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
     }];
}

-(void) takeAPhoto
{
    
}

@end