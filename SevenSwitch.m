//
//  SevenSwitch
//
//  Created by Benjamin Vogelzang on 6/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "SevenSwitch.h"
#import <QuartzCore/QuartzCore.h>

@interface SevenSwitch ()  {
    UIView *background;
    UIView *knob;
    UIImageView *onImageView;
    UIImageView *offImageView;
    UIImageView *thumbImageView;
    BOOL currentVisualValue;
    BOOL startTrackingValue;
    BOOL didChangeWhileTracking;
    BOOL isAnimating;
    BOOL userDidSpecifyOnThumbTintColor;
    BOOL userDidSpecifyOnThumbImage;
}

- (void)showOn:(BOOL)animated;
- (void)showOff:(BOOL)animated;
- (void)setup;

@end


@implementation SevenSwitch

@synthesize inactiveColor, activeColor, onTintColor, borderColor, thumbTintColor, onThumbTintColor, shadowColor;
@synthesize onImage, offImage, thumbImage, onThumbImage;
@synthesize offThumbImageView, onThumbImageView;
@synthesize isRounded;
@synthesize on;


#pragma mark init Methods

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 50, 30)];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    // use the default values if CGRectZero frame is set
    CGRect initialFrame;
    if (CGRectIsEmpty(frame)) {
        initialFrame = CGRectMake(0, 0, 50, 30);
    }
    else {
        initialFrame = frame;
    }
    self = [super initWithFrame:initialFrame];
    if (self) {
        [self setup];
    }
    return self;
}


/**
 *	Setup the individual elements of the switch and set default values
 */
- (void)setup {

    // default values
    self.direction = SevenSwitchDirection_Horizontal;
    self.on = NO;
    self.isRounded = YES;
    self.inactiveColor = [UIColor clearColor];
    self.activeColor = [UIColor colorWithRed:0.89f green:0.89f blue:0.89f alpha:1.00f];
    self.onTintColor = [UIColor colorWithRed:0.30f green:0.85f blue:0.39f alpha:1.00f];
    self.borderColor = [UIColor colorWithRed:0.89f green:0.89f blue:0.91f alpha:1.00f];
    self.thumbTintColor = [UIColor whiteColor];
    self.onThumbTintColor = [UIColor whiteColor];
    self.shadowColor = [UIColor grayColor];
    currentVisualValue = NO;
    userDidSpecifyOnThumbTintColor = NO;
    userDidSpecifyOnThumbImage = NO;

    // background
    background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    background.backgroundColor = [UIColor clearColor];
    background.layer.cornerRadius = self.frame.size.height * 0.5;
    background.layer.borderColor = self.borderColor.CGColor;
    background.layer.borderWidth = 1.0;
    background.userInteractionEnabled = NO;
	background.clipsToBounds = YES;
    [self addSubview:background];

    // on/off images
    onImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height)];
    onImageView.alpha = 0;
    onImageView.contentMode = UIViewContentModeCenter;
    [background addSubview:onImageView];

    offImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height)];
    offImageView.alpha = 1.0;
    offImageView.contentMode = UIViewContentModeCenter;
    [background addSubview:offImageView];
	
    // labels
	self.onLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height)];
	self.onLabel.textAlignment = NSTextAlignmentCenter;
    self.onLabel.textColor = [UIColor lightGrayColor];
    self.onLabel.font = [UIFont systemFontOfSize:12];
    [background addSubview:self.onLabel];

	self.offLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height)];
    self.offLabel.textAlignment = NSTextAlignmentCenter;
    self.offLabel.textColor = [UIColor lightGrayColor];
    self.offLabel.font = [UIFont systemFontOfSize:12];
    [background addSubview:self.offLabel];
	
    // knob
    knob = [[UIView alloc] initWithFrame:CGRectMake(1, 1, self.frame.size.height - 2, self.frame.size.height - 2)];
    knob.backgroundColor = self.thumbTintColor;
    knob.layer.cornerRadius = (self.frame.size.height * 0.5) - 1;
    knob.layer.shadowColor = self.shadowColor.CGColor;
    knob.layer.shadowRadius = 2.0;
    knob.layer.shadowOpacity = 0.5;
    knob.layer.shadowOffset = CGSizeMake(0, 3);
    knob.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:knob.bounds cornerRadius:knob.layer.cornerRadius].CGPath;
    knob.layer.masksToBounds = NO;
    knob.userInteractionEnabled = NO;
    [self addSubview:knob];
    
    // knob image
    thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, knob.frame.size.width, knob.frame.size.height)];
    thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
    thumbImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [knob addSubview:thumbImageView];

    isAnimating = NO;
}


#pragma mark Touch Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];

    startTrackingValue = self.on;
    didChangeWhileTracking = NO;

    // make the knob larger and animate to the correct color
    CGFloat activeKnobStretchSide;
    if (self.isHorizontal)
        activeKnobStretchSide = self.bounds.size.height - 2 + 5;
    else
        activeKnobStretchSide = self.bounds.size.width - 2 + 5;
    
    isAnimating = YES;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (self.on) {
            if (self.isHorizontal)
                knob.frame = CGRectMake(self.bounds.size.width - (activeKnobStretchSide + 1), knob.frame.origin.y, activeKnobStretchSide, knob.frame.size.height);
            else
                knob.frame = CGRectMake(knob.frame.origin.x, knob.frame.origin.y, knob.frame.size.width, activeKnobStretchSide);
            background.backgroundColor = self.onTintColor;
            knob.backgroundColor = self.onThumbTintColor;
            if (self.onThumbImageView)
            {
                self.onThumbImageView.hidden  = NO;
                self.offThumbImageView.hidden = YES;
            }
            else
                thumbImageView.image = self.onThumbImage;
        }
        else {
            if (self.isHorizontal)
                knob.frame = CGRectMake(knob.frame.origin.x, knob.frame.origin.y, activeKnobStretchSide, knob.frame.size.height);
            else
                knob.frame = CGRectMake(knob.frame.origin.x, self.bounds.size.height - (activeKnobStretchSide + 1), knob.frame.size.width, activeKnobStretchSide);
            background.backgroundColor = self.activeColor;
            knob.backgroundColor = self.thumbTintColor;
            if (self.onThumbImageView)
            {
                self.onThumbImageView.hidden  = YES;
                self.offThumbImageView.hidden = NO;
            }
            else
                thumbImageView.image = self.thumbImage;
        }
    } completion:^(BOOL finished) {
        isAnimating = NO;
    }];

    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];

    // Get touch location
    CGPoint lastPoint = [touch locationInView:self];

    // update the switch to the correct visuals depending on if
    // they moved their touch to the right or left side of the switch
    if (self.isHorizontal)
    {
        if (lastPoint.x > self.bounds.size.width * 0.5) {
            [self showOn:YES];
            if (!startTrackingValue) {
                didChangeWhileTracking = YES;
            }
        }
        else {
            [self showOff:YES];
            if (startTrackingValue) {
                didChangeWhileTracking = YES;
            }
        }
    }
    else
    {
        if (lastPoint.y < self.bounds.size.height * 0.5) {
            [self showOn:YES];
            if (!startTrackingValue) {
                didChangeWhileTracking = YES;
            }
        }
        else {
            [self showOff:YES];
            if (startTrackingValue) {
                didChangeWhileTracking = YES;
            }
        }
    }

    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];

    BOOL previousValue = self.on;
    
    if (didChangeWhileTracking) {
        [self setOn:currentVisualValue animated:YES];
    }
    else {
        [self setOn:!self.on animated:YES];
    }

    if (previousValue != self.on)
        [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];

    // just animate back to the original value
    if (self.on)
        [self showOn:YES];
    else
        [self showOff:YES];
}


- (void)layoutSubviews {
    [super layoutSubviews];

    if (!isAnimating) {
        CGRect frame = self.frame;

        // background
        background.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        if (self.isHorizontal)
            background.layer.cornerRadius = self.isRounded ? frame.size.height * 0.5 : 2;
        else
            background.layer.cornerRadius = self.isRounded ? frame.size.width * 0.5 : 2;
        
        // images
        if (self.isHorizontal)
            [onImageView setFrame:CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height)];
        else
            [onImageView setFrame:CGRectMake(0, frame.size.width, frame.size.width, frame.size.height - frame.size.width)];
        
        if (self.isHorizontal)
            [offImageView setFrame:CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height)];
        else
            [offImageView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - frame.size.width)];
        
        // labels
        if (self.isHorizontal)
            [self.onLabel setFrame:CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height)];
        else
            [self.onLabel setFrame:CGRectMake(0, frame.size.width, frame.size.width, frame.size.height - frame.size.width)];
        
        if (self.isHorizontal)
            [self.offLabel setFrame:CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height)];
        else
            [self.offLabel setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - frame.size.width)];
       
        if (self.isHorizontal)
        {
            if (self.on)
                [knob setFrame:CGRectMake(frame.size.width - (frame.size.height - 1), 1, frame.size.height - 2, frame.size.height - 2)];
            else
                [knob setFrame:CGRectMake(1, 1, frame.size.height - 2, frame.size.height - 2)];
            knob.layer.cornerRadius = self.isRounded ? (frame.size.height * 0.5) - 1 : 2;
        }
        else
        {
            if (self.on)
                [knob setFrame:CGRectMake(1, 1, frame.size.width - 2, frame.size.width - 2)];
            else
                [knob setFrame:CGRectMake(1, frame.size.height - (frame.size.width - 1), frame.size.width - 2, frame.size.width - 2)];
            knob.layer.cornerRadius = self.isRounded ? (frame.size.width * 0.5) - 1 : 2;
        }
    }
}


#pragma mark Setters

/*
 *	Sets the background color when the switch is off.
 *  Defaults to clear color.
 */
- (void)setInactiveColor:(UIColor *)color {
    inactiveColor = color;
    if (!self.on && !self.isTracking)
        background.backgroundColor = color;
}

/*
 *	Sets the background color that shows when the switch is on.
 *  Defaults to green.
 */
- (void)setOnTintColor:(UIColor *)color {
    onTintColor = color;
    if (self.on && !self.isTracking) {
        background.backgroundColor = color;
        background.layer.borderColor = color.CGColor;
    }
}

/*
 *	Sets the border color that shows when the switch is off. Defaults to light gray.
 */
- (void)setBorderColor:(UIColor *)color {
    borderColor = color;
    if (!self.on)
        background.layer.borderColor = color.CGColor;
}

/*
 *	Sets the knob color. Defaults to white.
 */
- (void)setThumbTintColor:(UIColor *)color {
    thumbTintColor = color;
    if (!userDidSpecifyOnThumbTintColor)
        onThumbTintColor = color;
    if ((!userDidSpecifyOnThumbTintColor || !self.on) && !self.isTracking)
        knob.backgroundColor = color;
}

/*
 *	Sets the knob color that shows when the switch is on. Defaults to white.
 */
- (void)setOnThumbTintColor:(UIColor *)color {
    onThumbTintColor = color;
    userDidSpecifyOnThumbTintColor = YES;
    if (self.on && !self.isTracking)
        knob.backgroundColor = color;
}

/*
 *	Sets the shadow color of the knob. Defaults to gray.
 */
- (void)setShadowColor:(UIColor *)color {
    shadowColor = color;
    knob.layer.shadowColor = color.CGColor;
}

/*
 *	Sets the thumb image.
 */
- (void)setThumbImage:(UIImage *)image
{
    thumbImage = image;
    if (!userDidSpecifyOnThumbImage)
        onThumbImage = image;
    if ((!userDidSpecifyOnThumbImage || !self.on) && !self.isTracking && !self.onThumbImageView)
        thumbImageView.image = image;
}

- (void)setOnThumbImage:(UIImage *)image
{
    onThumbImage = image;
    userDidSpecifyOnThumbImage = YES;
    if (self.on && !self.isTracking && !self.onThumbImageView)
        thumbImageView.image = image;
}

/*
 *	Sets the thumb imageview.
 */
- (void)setOffThumbImageView:(UIImageView *)imageView
{
    [imageView setFrame:CGRectMake(0, 0, knob.frame.size.width, knob.frame.size.height)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (onThumbImageView == nil)
    {
        onThumbImageView = [[UIImageView alloc] initWithFrame:imageView.frame];
        onImageView.autoresizingMask = imageView.autoresizingMask;
        onThumbImageView.image = imageView.image;
        [thumbImageView addSubview:onThumbImageView];
    }
    if (offThumbImageView)
    {
        [offThumbImageView removeFromSuperview];
    }
    offThumbImageView = imageView;
    [thumbImageView addSubview:offThumbImageView];
    if (!self.isTracking)
    {
        onThumbImageView.hidden = !self.on;
        offThumbImageView.hidden = self.on;
    }
    thumbImageView.image = nil;
}

- (void)setOnThumbImageView:(UIImageView *)imageView
{
    [imageView setFrame:CGRectMake(0, 0, knob.frame.size.width, knob.frame.size.height)];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (offThumbImageView == nil)
    {
        offThumbImageView = [[UIImageView alloc] initWithFrame:imageView.frame];
        offImageView.autoresizingMask = imageView.autoresizingMask;
        offThumbImageView.image = imageView.image;
        [thumbImageView addSubview:offThumbImageView];
    }
    if (onThumbImageView)
    {
        [onThumbImageView removeFromSuperview];
    }
    onThumbImageView = imageView;
    [thumbImageView addSubview:onThumbImageView];
    if (!self.isTracking)
    {
        onThumbImageView.hidden = !self.on;
        offThumbImageView.hidden = self.on;
    }
    thumbImageView.image = nil;
}

/*
 *	Sets the image that shows when the switch is on.
 *  The image is centered in the area not covered by the knob.
 *  Make sure to size your images appropriately.
 */
- (void)setOnImage:(UIImage *)image {
    onImage = image;
    onImageView.image = image;
}

/*
 *	Sets the image that shows when the switch is off.
 *  The image is centered in the area not covered by the knob.
 *  Make sure to size your images appropriately.
 */
- (void)setOffImage:(UIImage *)image {
    offImage = image;
    offImageView.image = image;
}


/*
 *	Sets whether or not the switch edges are rounded.
 *  Set to NO to get a stylish square switch.
 *  Defaults to YES.
 */
- (void)setIsRounded:(BOOL)rounded {
    isRounded = rounded;

    if (rounded) {
        if (self.isHorizontal)
            background.layer.cornerRadius = self.frame.size.height * 0.5;
        else
            background.layer.cornerRadius = self.frame.size.width * 0.5;

        if (self.isHorizontal)
            knob.layer.cornerRadius = self.frame.size.height * 0.5 - 1;
        else
            knob.layer.cornerRadius = self.frame.size.width * 0.5 - 1;
    }
    else {
        background.layer.cornerRadius = 2;
        knob.layer.cornerRadius = 2;
    }
    
    knob.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:knob.bounds cornerRadius:knob.layer.cornerRadius].CGPath;
}


/*
 * Set (without animation) whether the switch is on or off
 */
- (void)setOn:(BOOL)isOn {
    [self setOn:isOn animated:NO];
}


/*
 * Set the state of the switch to on or off, optionally animating the transition.
 */
- (void)setOn:(BOOL)isOn animated:(BOOL)animated {
    on = isOn;

    if (isOn) {
        [self showOn:animated];
    }
    else {
        [self showOff:animated];
    }
}


#pragma mark Getters

/*
 *	Detects whether the switch is on or off
 *
 *	@return	BOOL YES if switch is on. NO if switch is off
 */
- (BOOL)isOn {
    return self.on;
}


#pragma mark State Changes


/*
 * update the looks of the switch to be in the on position
 * optionally make it animated
 */
- (void)showOn:(BOOL)animated {
    CGFloat normalKnobStretchSide;
    if (self.isHorizontal)
        normalKnobStretchSide = self.bounds.size.height - 2;
    else
        normalKnobStretchSide = self.bounds.size.width - 2;
    CGFloat activeKnobStretchSide = normalKnobStretchSide + 5;
    if (animated) {
        isAnimating = YES;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (self.tracking)
            {
                if (self.isHorizontal)
                    knob.frame = CGRectMake(self.bounds.size.width - (activeKnobStretchSide + 1), knob.frame.origin.y, activeKnobStretchSide, knob.frame.size.height);
                else
                    knob.frame = CGRectMake(knob.frame.origin.x, 1, knob.frame.size.width, activeKnobStretchSide);
            }
            else
            {
                if (self.isHorizontal)
                    knob.frame = CGRectMake(self.bounds.size.width - (normalKnobStretchSide + 1), knob.frame.origin.y, normalKnobStretchSide, knob.frame.size.height);
                else
                    knob.frame = CGRectMake(knob.frame.origin.x, 1, knob.frame.size.width, normalKnobStretchSide);
            }
            background.backgroundColor = self.onTintColor;
            background.layer.borderColor = self.onTintColor.CGColor;
            knob.backgroundColor = self.onThumbTintColor;
            if (self.onThumbImageView)
            {
                self.onThumbImageView.hidden  = NO;
                self.offThumbImageView.hidden = YES;
            }
            else
                thumbImageView.image = self.onThumbImage;
            onImageView.alpha = 1.0;
            offImageView.alpha = 0;
			self.onLabel.alpha = 1.0;
			self.offLabel.alpha = 0;
        } completion:^(BOOL finished) {
            isAnimating = NO;
        }];
    }
    else {
        if (self.tracking)
        {
            if (self.isHorizontal)
                knob.frame = CGRectMake(self.bounds.size.width - (activeKnobStretchSide + 1), knob.frame.origin.y, activeKnobStretchSide, knob.frame.size.height);
            else
                knob.frame = CGRectMake(knob.frame.origin.x, 1, knob.frame.size.width, activeKnobStretchSide);
        }
        else
        {
            if (self.isHorizontal)
                knob.frame = CGRectMake(self.bounds.size.width - (normalKnobStretchSide + 1), knob.frame.origin.y, normalKnobStretchSide, knob.frame.size.height);
            else
                knob.frame = CGRectMake(knob.frame.origin.x, 1, knob.frame.size.width, normalKnobStretchSide);
        }
        background.backgroundColor = self.onTintColor;
        background.layer.borderColor = self.onTintColor.CGColor;
        knob.backgroundColor = self.onThumbTintColor;
        if (self.onThumbImageView)
        {
            self.onThumbImageView.hidden  = NO;
            self.offThumbImageView.hidden = YES;
        }
        else
            thumbImageView.image = self.onThumbImage;
        onImageView.alpha = 1.0;
        offImageView.alpha = 0;
		self.onLabel.alpha = 1.0;
		self.offLabel.alpha = 0;
    }
    
    currentVisualValue = YES;
}


/*
 * update the looks of the switch to be in the off position
 * optionally make it animated
 */
- (void)showOff:(BOOL)animated {
    CGFloat normalKnobStretchSide;
    if (self.isHorizontal)
        normalKnobStretchSide = self.bounds.size.height - 2;
    else
        normalKnobStretchSide = self.bounds.size.width - 2;
    CGFloat activeKnobStretchSide = normalKnobStretchSide + 5;
    if (animated) {
        isAnimating = YES;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            if (self.tracking) {
                if (self.isHorizontal)
                    knob.frame = CGRectMake(1, knob.frame.origin.y, activeKnobStretchSide, knob.frame.size.height);
                else
                    knob.frame = CGRectMake(knob.frame.origin.x, self.bounds.size.height - (activeKnobStretchSide + 1), knob.frame.size.width, activeKnobStretchSide);
                background.backgroundColor = self.activeColor;
            }
            else {
                if (self.isHorizontal)
                    knob.frame = CGRectMake(1, knob.frame.origin.y, normalKnobStretchSide, knob.frame.size.height);
                else
                    knob.frame = CGRectMake(knob.frame.origin.x, self.bounds.size.height - (normalKnobStretchSide + 1), knob.frame.size.width, normalKnobStretchSide);
                background.backgroundColor = self.inactiveColor;
            }
            background.layer.borderColor = self.borderColor.CGColor;
            knob.backgroundColor = self.thumbTintColor;
            if (self.onThumbImageView)
            {
                self.onThumbImageView.hidden  = YES;
                self.offThumbImageView.hidden = NO;
            }
            else
                thumbImageView.image = self.thumbImage;
            onImageView.alpha = 0;
            offImageView.alpha = 1.0;
			self.onLabel.alpha = 0;
			self.offLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            isAnimating = NO;
        }];
    }
    else {
        if (self.tracking) {
            if (self.isHorizontal)
                knob.frame = CGRectMake(1, knob.frame.origin.y, activeKnobStretchSide, knob.frame.size.height);
            else
                knob.frame = CGRectMake(knob.frame.origin.x, self.bounds.size.height - (activeKnobStretchSide + 1), knob.frame.size.width, activeKnobStretchSide);
            background.backgroundColor = self.activeColor;
        }
        else {
            if (self.isHorizontal)
                knob.frame = CGRectMake(1, knob.frame.origin.y, normalKnobStretchSide, knob.frame.size.height);
            else
                knob.frame = CGRectMake(knob.frame.origin.x, self.bounds.size.height - (normalKnobStretchSide + 1), knob.frame.size.width, normalKnobStretchSide);
            background.backgroundColor = self.inactiveColor;
        }
        background.layer.borderColor = self.borderColor.CGColor;
        knob.backgroundColor = self.thumbTintColor;
        if (self.onThumbImageView)
        {
            self.onThumbImageView.hidden  = YES;
            self.offThumbImageView.hidden = NO;
        }
        else
            thumbImageView.image = self.thumbImage;
        onImageView.alpha = 0;
        offImageView.alpha = 1.0;
		self.onLabel.alpha = 0;
		self.offLabel.alpha = 1.0;
    }
    
    currentVisualValue = NO;
}

- (UIColor *)onColor {
    return self.onTintColor;
}

- (void)setOnColor:(UIColor *)color {
    self.onTintColor = color;
}

- (UIColor *)knobColor {
    return self.thumbTintColor;
}

- (void)setKnobColor:(UIColor *)color {
    self.thumbTintColor = color;
}

- (void)setDirection:(SevenSwitchDirection)direction
{
    if (direction != _direction)
    {
        _direction = direction;
        [self adjustSwitch];
    }
}

- (BOOL)isHorizontal
{
    return self.direction == SevenSwitchDirection_Horizontal;
}

- (void)adjustSwitch
{
    // background
    [background setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    if (self.isHorizontal)
        background.layer.cornerRadius = self.isRounded ? self.frame.size.height * 0.5 : 2;
    else
        background.layer.cornerRadius = self.isRounded ? self.frame.size.width * 0.5 : 2;
    
    // on/off images
    if (self.isHorizontal)
        [onImageView setFrame:CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height)];
    else
        [onImageView setFrame:CGRectMake(0, self.frame.size.width, self.frame.size.width, self.frame.size.height - self.frame.size.width)];
    
    if (self.isHorizontal)
        [offImageView setFrame:CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height)];
    else
        [offImageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.frame.size.width)];
    
    // labels
    if (self.isHorizontal)
        [self.onLabel setFrame:CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height)];
    else
        [self.onLabel setFrame:CGRectMake(0, self.frame.size.width, self.frame.size.width, self.frame.size.height - self.frame.size.width)];
    
    if (self.isHorizontal)
        [self.offLabel setFrame:CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height)];
    else
        [self.offLabel setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.frame.size.width)];
    
    // knob
    if (self.isHorizontal)
    {
        if (self.on)
            [knob setFrame:CGRectMake(self.frame.size.width - (self.frame.size.height - 1), 1, self.frame.size.height - 2, self.frame.size.height - 2)];
        else
            [knob setFrame:CGRectMake(1, 1, self.frame.size.height - 2, self.frame.size.height - 2)];
        knob.layer.cornerRadius = self.isRounded ? (self.frame.size.height * 0.5) - 1 : 2;
        knob.layer.shadowOffset = CGSizeMake(0, 3);
        knob.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:knob.bounds cornerRadius:knob.layer.cornerRadius].CGPath;
    }
    else
    {
        if (self.on)
            [knob setFrame:CGRectMake(1, 1, self.frame.size.width - 2, self.frame.size.width - 2)];
        else
            [knob setFrame:CGRectMake(1, self.frame.size.height - (self.frame.size.width - 1), self.frame.size.width - 2, self.frame.size.width - 2)];
        knob.layer.cornerRadius = self.isRounded ? (self.frame.size.width * 0.5) - 1 : 2;
        knob.layer.shadowOffset = CGSizeMake(0, 3);
        knob.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:knob.bounds cornerRadius:knob.layer.cornerRadius].CGPath;
    }
    
    // knob image
    [thumbImageView setFrame:CGRectMake(0, 0, knob.frame.size.width, knob.frame.size.height)];
}

@end
