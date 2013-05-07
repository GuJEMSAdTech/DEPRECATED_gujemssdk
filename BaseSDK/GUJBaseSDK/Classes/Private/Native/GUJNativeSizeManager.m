/*
 * BSD LICENSE
 * Copyright (c) 2012, Mobile Unit of G+J Electronic Media Sales GmbH, Hamburg All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, 
 * this list of conditions and the following disclaimer .
 * Redistributions in binary form must reproduce the above copyright notice, 
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. 
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * The source code is just allowed for private use, not for commercial use.
 * 
 */
#import "GUJNativeSizeManager.h"

@implementation GUJNativeSizeManager

static GUJNativeSizeManager *sharedInstance_;

#pragma mark private methods
- (void)__initialize
{
    
}

- (void)__startEventListener
{
    if( runLoop_ == nil ) {
        runLoop_ = [NSRunLoop currentRunLoop];
    }
    timer_ = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(__sizeChangedListenerEvent) userInfo:nil repeats:YES];
    [runLoop_ run];
}

- (void)__stopEventListener
{
    if( runLoop_ != nil ) {            
        [timer_ invalidate];
        CFRunLoopStop([runLoop_ getCFRunLoop]);
        runLoop_ = nil;
        timer_   = nil;
    }
}

- (void)__sizeChangedListenerEvent
{
    @autoreleasepool {
        if( superview_ ) {
            CGSize viewSize = superview_.frame.size;
            if( viewSize.width != lastSuperviewSize_.width || viewSize.height != lastSuperviewSize_.height ) {
                [[NSNotificationCenter defaultCenter] postNotification:
                 [NSNotification notificationWithName:GUJDeviceSuperviewSizeChangedNotification object:superview_]
                 ];   
                lastSuperviewSize_ = superview_.frame.size;
            }
        }
        if( window_ ) {
            CGSize windowSize = window_.frame.size;
            if( windowSize.width != lastWindowSize_.width || windowSize.height != lastWindowSize_.height ) {
                [[NSNotificationCenter defaultCenter] postNotification:
                 [NSNotification notificationWithName:GUJDeviceScreenSizeChangedNotification object:window_]
                 ];   
                lastWindowSize_ = window_.frame.size;
            } 
        }
        if( adView_ ) {
            CGSize adViewSize = adView_.frame.size;
            if( adViewSize.width != lastAdViewSize_.width || adViewSize.height != lastAdViewSize_.height ) {
                [[NSNotificationCenter defaultCenter] postNotification:
                 [NSNotification notificationWithName:GUJBannerSizeChangeNotification object:adView_]
                 ];   
                lastAdViewSize_ = adView_.frame.size;
            } 
        }
    }
}

#pragma mark public methods
+(GUJNativeSizeManager*)sharedInstance
{
    if( sharedInstance_ == nil ) {
        sharedInstance_ = [[GUJNativeSizeManager alloc] init];
    }          
    return sharedInstance_;   
}

- (id)init 
{    
    if( sharedInstance_ == nil ) {
        self = [super init];        
        if( self ) {
            
        }
    }           
    return self;
}   

#pragma mark overridden methods
- (BOOL)willPostNotification
{
    return YES;
}

- (void)registerForNotification:(id)receiver selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:receiver selector:selector name:GUJBannerSizeChangeNotification object:nil];
}

#pragma mark public methods
- (void)startListening
{
    if( !runLoop_ ) {
        // start a thread to be safe and non blocking
        [NSThread detachNewThreadSelector:@selector(__startEventListener) toTarget:self withObject:nil];    
    }
}

- (void)stopListening
{
    if( runLoop_ ) {
        [self __stopEventListener];
    }
}

- (void)listenForResizingAdView:(GUJAdView*)adView
{
    if( adView ) {
        @autoreleasepool {         
            adView_          = adView;
            lastAdViewSize_  = adView.frame.size;
        }
        // register for banner size change notification
        [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJBannerSizeChangeNotification object:adView_]; 
        // start if not allready started
        [self startListening];
    }    
}

- (void)stopListeningForResizingAdView
{
    superview_ = nil;
    lastSuperviewSize_ = CGSizeZero;
}

- (void)listenForResizingSuperview:(UIView*)view
{
    if( [view superview] ) {
        @autoreleasepool {         
            superview_          = [view superview];
            lastSuperviewSize_  = [view superview].frame.size;
        }
        // register for size change notification
        [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceSuperviewSizeChangedNotification object:superview_]; 
        
        // start if not allready started
        [self startListening];
    }
}

- (void)stopListeningForResizingSuperview
{
    superview_ = nil;
    lastSuperviewSize_ = CGSizeZero;
}

- (void)listenForScreenResizing
{
    @autoreleasepool {    
        window_ = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        if( window_ ) {
            lastWindowSize_ = window_.frame.size;
        }
    }        
    // register for size change notification
    [[NSNotificationCenter defaultCenter] addObserver:[GUJNotificationObserver sharedInstance] selector:@selector(receiveNotificationMessage:) name:GUJDeviceScreenSizeChangedNotification object:window_];  
    
    // start if not allready started
    [self startListening];   
}

- (void)stopListeningForScreenResizing
{
    window_         = nil;
    lastWindowSize_ = CGSizeZero;
}

@end