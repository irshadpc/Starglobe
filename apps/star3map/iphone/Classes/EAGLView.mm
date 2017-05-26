//
//  EAGLView.m
//  star3map
//
//  Created by Cass Everitt on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "EAGLView.h"

#import "ES1Renderer.h"
#import "ES2Renderer.h"
#import <sys/time.h>
#include "app.h"
#include "star3map.h"
#import "star3mapAppDelegate.h"
#include "r3/var.h"
#include "r3/command.h"

double yRotation = 0.0;
extern bool calibrationEnabled;

float GetScaleFactor()
{
    NSString * reqiredSystemVersion = @"4.0";
    NSString * currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    if([currentSystemVersion compare: reqiredSystemVersion options: NSNumericSearch] != NSOrderedAscending)
    {
        if([[UIScreen mainScreen] scale] == 2.0) {
            return 2.0f;
        } else if([[UIScreen mainScreen] scale] == 3.0) {
            return 3.0f;
        }
    }
    
    return 1.0f;
}

uint timeGetTime()
{
	timeval time;
	gettimeofday(&time, NULL);
	return (time.tv_sec * 1000) + (time.tv_usec / 1000);
}

extern float GUIAlpha;
extern bool ButtonWasPressed;
extern bool lowResolution;
extern r3::VarFloat app_nightFactor;
float redVisionDestination = 0.0f;

@implementation EAGLView

@synthesize animating;
@synthesize redVisionOnButton;
@synthesize redVisionOffButton;
@synthesize optionsButton;
@synthesize shareButton;
@synthesize newsButton;
@synthesize fadeMessageView;
@synthesize calibrateButton;
@synthesize calibrateView;
@synthesize calibrateLabel;
@synthesize calibrateInfo;
@synthesize calibrateTarget;
@dynamic animationFrameInterval;

// You must implement this method
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (void)setRenderer {
    renderer = [[ES1Renderer alloc] init];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id) initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
	{
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		
		renderer = [[ES1Renderer alloc] init];
		//renderer = [[ES2Renderer alloc] init];
		if (!renderer)
		{
			return nil;
		}
        
		animating = FALSE;
		displayLinkSupported = FALSE;
		animationFrameInterval = 1;
		displayLink = nil;
		animationTimer = nil;
		
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
			displayLinkSupported = TRUE;
        
        // enable Retina display support
        [self enableRetinaSupport];
        
        hideGUI = NO;
        currentAlpha = 1.0f;
        calibrationAvailable = false;
    }

	self.multipleTouchEnabled = true;
    return self;
}

- (void) enableRetinaSupport
{
    NSString * reqiredSystemVersion = @"4.0";
    NSString * currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    if([currentSystemVersion compare: reqiredSystemVersion options: NSNumericSearch] != NSOrderedAscending) {
        if([[UIScreen mainScreen] scale] == 2.0) {
            self.contentScaleFactor = 2.0f;
        } else if([[UIScreen mainScreen] scale] == 3.0) {
            self.contentScaleFactor = 3.0f;
        } else {
            lowResolution = true;
        }
    } 
    else
    {
        lowResolution = true;
    }
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        lowResolution = false;
}

-(UIImage*) nightImageWithName: (NSString*)name
{
    UIImage * sourceImage = [UIImage imageNamed:name];
    
    UIGraphicsBeginImageContext(sourceImage.size);

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float inverseNight = 1.0f - app_nightFactor.GetVal();
    
    UIColor * nightColor = [UIColor colorWithRed: 1.0f green: inverseNight blue: inverseNight alpha: 1.0f];
    [nightColor setFill];

    CGContextTranslateCTM(context, 0, sourceImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect rect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
    CGContextDrawImage(context, rect, sourceImage.CGImage);

    CGContextClipToMask(context, rect, sourceImage.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    
    UIImage * coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return coloredImage;
}

- (void) setAppMode:(NSString *)mode {
    if ([mode isEqualToString:@"globe"]) {
        r3::ExecuteCommand("setAppMode viewGlobe");
    } else {
        r3::ExecuteCommand("setAppMode viewStars");
    }
}

- (void)toggleSatellites:(BOOL)show {
    if (show) {
        r3::ExecuteCommand("app_showSatellites 1");
    } else {
        r3::ExecuteCommand("app_showSatellites 0");
    }
}

- (void)toggleCompass:(BOOL)use {
    if (use) {
        r3::ExecuteCommand("app_useCompass 1");
    } else {
        r3::ExecuteCommand("app_useCompass 0");
    }
}

- (NSString*)getAppMode {
    star3map::AppModeEnum appMode = star3map::GetDisplayMode();
    if ( appMode == star3map::AppMode_ViewGlobe ) {
        return @"globe";
    }
    return @"stars";
}

- (void) drawView:(id)sender
{
    NSString * reqiredSystemVersion = @"4.0";
    NSString * currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    if([currentSystemVersion compare: reqiredSystemVersion options: NSNumericSearch] != NSOrderedAscending
       && [[UIDevice currentDevice].model isEqualToString: @"iPod touch"])
    {
        calibrationAvailable = [((star3mapAppDelegate*)[UIApplication sharedApplication].delegate) gyroAvailable];
    }
    
    [[UIApplication sharedApplication].delegate performSelector: @selector(updateGyroscope)];
    
    calibrateView.hidden = !(calibrationEnabled && star3map::GetDisplayMode() == star3map::AppMode_ViewStars);
    calibrateButton.hidden = !(calibrationAvailable && star3map::GetDisplayMode() == star3map::AppMode_ViewStars);
    
    //fadeMessageView.hidden = calibrationEnabled;
    fadeMessageView.hidden = YES;
    static uint lastTime = timeGetTime();
    
    float destinationAlpha = 1.0;
    if(hideGUI)
        destinationAlpha = 0.0f;
    
    if(destinationAlpha != currentAlpha)
    {
        float delta = destinationAlpha - currentAlpha;
        float sign = 0.0f;
        if(delta < 0.0f)
            sign = -1.0f;
        
        if(delta > 0.0f)
            sign = 1.0f;
        
        delta = sign * float(timeGetTime() - lastTime) / 1000.0f;
        
        currentAlpha += delta;
        
        if(currentAlpha < 0.0f)
            currentAlpha = 0.0f;
        
        if(currentAlpha > 1.0f)
            currentAlpha = 1.0f;
        
        GUIAlpha = currentAlpha;
        
        redVisionOnButton.alpha = currentAlpha;
        redVisionOffButton.alpha = currentAlpha;
        optionsButton.alpha = currentAlpha * 0.5f;
        shareButton.alpha = currentAlpha * 0.5f;
        newsButton.alpha = currentAlpha * 0.5f;
        calibrateButton.alpha = currentAlpha * 0.5f;
        
        //if(fadeMessageView != nil)
          //  fadeMessageView.alpha = fadeMessageView.alpha < currentAlpha ? fadeMessageView.alpha : currentAlpha;
    }
    
    if(redVisionDestination != app_nightFactor.GetVal())
    {
        float delta = redVisionDestination - app_nightFactor.GetVal();
        float sign = 0.0f;
        if(delta < 0.0f)
            sign = -1.0f;
        
        if(delta > 0.0f)
            sign = 1.0f;
        
        delta = sign * float(timeGetTime() - lastTime) / 1000.0f;
        
        app_nightFactor.SetVal(app_nightFactor.GetVal() + delta);

        if(app_nightFactor.GetVal() < 0.0f)
            app_nightFactor.SetVal(0.0f);
        
        if(app_nightFactor.GetVal() > 1.0f)
            app_nightFactor.SetVal(1.0f);
        
        [optionsButton setImage: [self nightImageWithName: @"settings.png"] forState: UIControlStateNormal];
        [shareButton setImage: [self nightImageWithName: @"share.png"] forState: UIControlStateNormal];
        [newsButton setImage: [self nightImageWithName: @"news.png"] forState: UIControlStateNormal];
        [redVisionOnButton setImage: [self nightImageWithName: @"redeyeoff.png"] forState: UIControlStateNormal];
        
        if(calibrateButton)
        {
            [calibrateButton setBackgroundImage: [self nightImageWithName: @"calibrate.png"] forState: UIControlStateNormal];
            [calibrateButton setBackgroundImage: [self nightImageWithName: @"calibrate_pressed.png"] forState: UIControlStateHighlighted];
            
            float inverseNight = 1.0f - app_nightFactor.GetVal();
            UIColor * nightColor = [UIColor colorWithRed: 1.0f green: inverseNight blue: inverseNight alpha: 1.0f];

            [calibrateButton setTitleColor: nightColor forState: UIControlStateNormal];
            [calibrateButton setTitleColor: nightColor forState: UIControlStateHighlighted];
            
            [calibrateInfo setTextColor: nightColor];
            [calibrateLabel setTextColor: nightColor];
            [calibrateTarget setImage: [self nightImageWithName: @"target.png"]];
        }
    }
    
    lastTime = timeGetTime();

	display();
}

- (void) layoutSubviews
{
	[renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (NSInteger) animationFrameInterval
{
	return animationFrameInterval;
}

- (void) setAnimationFrameInterval:(NSInteger)frameInterval
{
	// Frame interval defines how many display frames must pass between each time the
	// display link fires. The display link will only fire 30 times a second when the
	// frame internal is two on a display that refreshes 60 times a second. The default
	// frame interval setting of one will fire 60 times a second when the display refreshes
	// at 60 times a second. A frame interval setting of less than one results in undefined
	// behavior.
	if (frameInterval >= 1)
	{
		animationFrameInterval = frameInterval;
		
		if (animating)
		{
			[self stopAnimation];
			[self startAnimation];
		}
	}
}

- (void) startAnimation
{
	if (!animating)
	{
		if (displayLinkSupported)
		{
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.

			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
			[displayLink setFrameInterval:animationFrameInterval];
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		}
		else
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
		
		animating = TRUE;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}
		
		animating = FALSE;
	}
}



- (void) handleTouches:(NSSet*)touches withEvent:(UIEvent*)event {
    float scale = GetScaleFactor();
	int touchCount = 0;
	int points[16];
    float dx, dy;
	ButtonWasPressed = false;
    
	NSSet *t = [event allTouches];
    for (UITouch *myTouch in t)
    {
        CGPoint touchLocation = [myTouch locationInView:nil];
		
		points[ 2 * touchCount + 0 ] = touchLocation.x * scale;
		points[ 2 * touchCount + 1 ] = touchLocation.y * scale; // ( h - 1 ) - touchLocation.y;
		
		touchCount++;
		
        if (myTouch.phase == UITouchPhaseBegan) {
            // new touch handler
            checkForTap = [[event allTouches] count] == 1;
            if(checkForTap)
            {
                initialX = touchLocation.x * scale;
                initialY = touchLocation.y * scale;
            }
        }
        if (myTouch.phase == UITouchPhaseMoved) {
            // touch moved handler
        }
        if (myTouch.phase == UITouchPhaseEnded) {
			touchCount--;
            
            if(checkForTap && touchCount == 0)
            {
                dx = touchLocation.x * scale - initialX;
                dy = touchLocation.y * scale - initialY;
            }
        }
    }
	::touches( touchCount, points );
    
    if(!ButtonWasPressed)
    {
        if(checkForTap && touchCount == 0)
        {
            checkForTap = NO;

            if(sqrtf(dx * dx + dy * dy) < 20.0f * scale && !calibrationEnabled)
            {
                hideGUI = !hideGUI;
                
                //if(fadeMessageView != nil)
                //{
                  //  [[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"FadeGestureUsed"];
                    //[[NSUserDefaults standardUserDefaults] synchronize];
                //}
            }
        }
    }
}



- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[self handleTouches:touches withEvent:event];
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	[self handleTouches:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self handleTouches:touches withEvent:event];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(calibrationEnabled)
    {
        CGPoint touchLocation = [[touches anyObject] locationInView: nil];
        CGPoint previousTouchLocation = [[touches anyObject] previousLocationInView: nil];

        float delta = touchLocation.x - previousTouchLocation.x;
        
        yRotation += delta / 300.0f;
    }
    
	[self handleTouches:touches withEvent:event];
}



@end
