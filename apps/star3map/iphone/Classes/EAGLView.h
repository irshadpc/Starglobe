//
//  EAGLView.h
//  star3map
//
//  Created by Cass Everitt on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{    
@private
	id <ESRenderer> renderer;
	
	BOOL animating;
	BOOL displayLinkSupported;
	NSInteger animationFrameInterval;
	// Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	// CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	// The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
	// isn't available.
	id displayLink;
    NSTimer *animationTimer;
    
    BOOL checkForTap;
    float initialX, initialY;
    BOOL hideGUI;
    float currentAlpha;
    bool calibrationAvailable;
    
    UIButton     * __weak redVisionOnButton;
    UIButton     * __weak redVisionOffButton;
    UIButton     * __weak optionsButton;
    UIButton     * __weak shareButton;
    UIButton     * __weak newsButton;
    UIButton     * __weak calibrateButton;
    UIView       * __weak fadeMessageView;
    UIView       * __weak calibrateView;
    UILabel      * __weak calibrateLabel;
    UITextView   * __weak calibrateInfo;
    UIImageView  * __weak calibrateTarget;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

@property (nonatomic, weak) UIButton    * redVisionOnButton;
@property (nonatomic, weak) UIButton    * redVisionOffButton;
@property (nonatomic, weak) UIButton    * optionsButton;
@property (nonatomic, weak) UIButton    * shareButton;
@property (nonatomic, weak) UIButton    * newsButton;
@property (nonatomic, weak) UIButton    * calibrateButton;
@property (nonatomic, weak) UIView      * fadeMessageView;
@property (nonatomic, weak) UIView      * calibrateView;
@property (nonatomic, weak) UILabel     * calibrateLabel;
@property (nonatomic, weak) UITextView  * calibrateInfo;
@property (nonatomic, weak) UIImageView * calibrateTarget;

- (void)setRenderer;
- (void) startAnimation;
- (void) stopAnimation;
- (void) drawView:(id)sender;
- (void) enableRetinaSupport;
- (void) setAppMode:(NSString*)mode;
- (NSString*) getAppMode;
- (void)toggleSatellites:(BOOL)show;
- (void)toggleCompass:(BOOL)use;
@end
