//
//  SYGLVideoCamera.h
//  SYGLKit
//
//  Created by Sylar on 2018/6/8.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLProducer.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIDevice.h>
#import "SYGLContext.h"
#import "SYGLTexture.h"

//Optionally override the YUV to RGB matrices
void setColorConversion601( GLfloat conversionMatrix[9] );
void setColorConversion601FullRange( GLfloat conversionMatrix[9] );
void setColorConversion709( GLfloat conversionMatrix[9] );

typedef enum SYGLVideoCaptorOrientation {
    SYGLVideoCaptorOrientationUnknown            = UIDeviceOrientationUnknown,
    SYGLVideoCaptorOrientationPortrait           = UIDeviceOrientationPortrait,
    SYGLVideoCaptorOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
    SYGLVideoCaptorOrientationLandscapeLeft      = UIDeviceOrientationLandscapeLeft,
    SYGLVideoCaptorOrientationLandscapeRight     = UIDeviceOrientationLandscapeRight
} SYGLVideoCaptorOrientation;

typedef enum SYGLVideoCaptorFocusMode {
    SYGLVideoCaptorFocusModeLocked              = AVCaptureFocusModeLocked,
    SYGLVideoCaptorFocusModeAutoFocus           = AVCaptureFocusModeAutoFocus,
    SYGLVideoCaptorFocusModeContinuousAutoFocus = AVCaptureFocusModeContinuousAutoFocus,
} SYGLVideoCaptorFocusMode;

typedef enum SYGLVideoCaptorExposureMode {
    SYGLVideoCaptorExposureModeLocked                    = AVCaptureExposureModeLocked,
    SYGLVideoCaptorExposureModeAutoExpose                = AVCaptureExposureModeAutoExpose,
    SYGLVideoCaptorExposureModeContinuousAutoExposure    = AVCaptureExposureModeContinuousAutoExposure,
} SYGLVideoCaptorExposureMode;

@class SYGLVideoCamera;
@protocol SYGLVideoCameraDelegate <NSObject>

@optional
- (void)videoCaptor:(SYGLVideoCamera *)videoCaptor willOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface SYGLVideoCamera : SYGLProducer <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t cameraQueue_;
    
    AVCaptureSession *cameraSession_;
    AVCaptureDevice *camera_;
    AVCaptureDeviceInput *videoInput_;
    AVCaptureVideoDataOutput *videoOutput_;
    
    AVCaptureDevicePosition position_;
    NSString *sessionPreset_;
    int frameRate_;
    SYGLVideoCaptorFocusMode focusMode_;
    CGPoint focusPoint_;
    SYGLVideoCaptorExposureMode exposureMode_;
    CGPoint exposurePoint_;
    float exposureTargetBias_;
    
    CMMotionManager *videoCaptorMotionManager_;
    
    SYGLVideoCaptorOrientation orientation_;
}


@property (assign, nonatomic) id <SYGLVideoCameraDelegate> delegate;
@property (readonly, nonatomic) AVCaptureDevicePosition position;  // The value of this property is an AVCaptureDevicePosition indicating where the receiver's device is physically located on the system hardware.
@property (readwrite, copy, nonatomic) NSString *sessionPreset;
@property (readwrite, nonatomic) CMTime minFrameDuration;  // Default value is kCMTimeInvalid.
@property (readwrite, nonatomic) CMTime maxFrameDuration;  // Default value is kCMTimeInvalid.
@property (readwrite, nonatomic) int frameRate;
@property (readwrite, nonatomic) SYGLVideoCaptorFocusMode focusMode;
@property (readwrite, nonatomic) CGPoint focusPoint;
@property (readwrite, nonatomic) SYGLVideoCaptorExposureMode exposureMode;
@property (readwrite, nonatomic) CGPoint exposurePoint;
@property (readwrite, nonatomic) float exposureTargetBias;

- (id)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition sessionPreset:(NSString *)sessionPreset NS_DESIGNATED_INITIALIZER;
-(instancetype)init NS_UNAVAILABLE;

@property (readonly, nonatomic) SYGLVideoCaptorOrientation orientation;

- (void)startRunning;
- (void)stopRunning;
- (void)switchCamera;  // Switching the receiver's position between AVCaptureDevicePositionFront and AVCaptureDevicePositionBack.

@end
