//
//  SYGLVideoCamera.m
//  SYGLKit
//
//  Created by Sylar on 2018/6/8.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "SYGLVideoCamera.h"

@implementation SYGLVideoCamera

@synthesize position = position_;
@synthesize sessionPreset = sessionPreset_;
@synthesize frameRate = frameRate_;
@synthesize focusMode = focusMode_;
@synthesize focusPoint = focusPoint_;
@synthesize exposureMode = exposureMode_;
@synthesize exposurePoint = exposurePoint_;
@synthesize exposureTargetBias = exposureTargetBias_;


- (void)dealloc
{
    if (videoCaptorMotionManager_) {
        if (videoCaptorMotionManager_.isDeviceMotionActive) {
            [videoCaptorMotionManager_ stopDeviceMotionUpdates];
        }
    }

    camera_ = nil;
    
    if (cameraSession_) {
        [self stopRunning];
        if (videoInput_) {
            [cameraSession_ removeInput:videoInput_];
        }
        if (videoOutput_) {
            [videoOutput_ setSampleBufferDelegate:nil queue:NULL];
            [cameraSession_ removeOutput:videoOutput_];
        }
        
    }

}

- (id)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition sessionPreset:(NSString *)sessionPreset{
    if (self = [super init]) {
        self.delegate = nil;
        
        cameraQueue_ = dispatch_queue_create("com.shuliansoftware.OpenGLESImage.cameraQueue", NULL);
        
        frameRate_ = 0; // This will not set frame rate unless this value gets set to 1 or above
        
        focusMode_ = SYGLVideoCaptorFocusModeContinuousAutoFocus;
        focusPoint_ = CGPointMake(0.5f, 0.5f);
        
        exposureMode_ = SYGLVideoCaptorExposureModeContinuousAutoExposure;
        exposurePoint_ = CGPointMake(0.5f, 0.5f);
        exposureTargetBias_ = 0.0;
        
        // Grab the back-facing or front-facing camera
        camera_ = nil;
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices)
        {
            if ([device position] == cameraPosition)
            {
                camera_ = device;
            }
        }
        
        if (!camera_) {
            NSLog(@"- initWithCameraPosition: sessionPreset: , Camera in specified position is not found");
            return nil;
        }
        
        position_ = cameraPosition;
        [self setOutputTextureorientationBasingOnCameraPosition:position_];
        
        // Create the capture session
        cameraSession_ = [[AVCaptureSession alloc] init];
        
        [cameraSession_ beginConfiguration];
        
        // Add the video input
        NSError *error = nil;
        videoInput_ = [[AVCaptureDeviceInput alloc] initWithDevice:camera_ error:&error];
        if ([cameraSession_ canAddInput:videoInput_])
        {
            [cameraSession_ addInput:videoInput_];
        }
        else {
            NSLog(@"- initWithCameraPosition: sessionPreset: , Couldn't add video input");
            return nil;
        }
        
        // Add the video frame output
        videoOutput_ = [[AVCaptureVideoDataOutput alloc] init];
        [videoOutput_ setAlwaysDiscardsLateVideoFrames:NO];
        
        [videoOutput_ setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        
        [videoOutput_ setSampleBufferDelegate:self queue:cameraQueue_];
        
        if ([cameraSession_ canAddOutput:videoOutput_])
        {
            [cameraSession_ addOutput:videoOutput_];
        }
        else
        {
            NSLog(@"- initWithCameraPosition: sessionPreset: , Couldn't add video output");
            return nil;
        }
        
        sessionPreset_ = sessionPreset;
        [cameraSession_ setSessionPreset:sessionPreset_];
        
        [cameraSession_ commitConfiguration];
        
        
        [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
            [SYGLContext useImageProcessingContext];
            outputTexture_ = [[SYGLTexture alloc]init];
        }];
        
        videoCaptorMotionManager_ = nil;
    }
    return self;
}

#pragma mark - Camera Controllers

- (void)startRunning
{
    if (![cameraSession_ isRunning]) {
        [cameraSession_ startRunning];
    }
}

- (void)stopRunning
{
    if ([cameraSession_ isRunning]) {
        [cameraSession_ stopRunning];
    }
}

- (void)switchCamera
{
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    AVCaptureDevicePosition newPosition;
    
    if (position_ == AVCaptureDevicePositionBack)
    {
        newPosition = AVCaptureDevicePositionFront;
    }
    else
    {
        newPosition = AVCaptureDevicePositionBack;
    }
    
    camera_ = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == newPosition)
        {
            camera_ = device;
        }
    }
    if (!camera_) {
        return;
    }
    newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera_ error:&error];
    
    if (newVideoInput != nil)
    {
        [cameraSession_ beginConfiguration];
        
        [cameraSession_ removeInput:videoInput_];
        if ([cameraSession_ canAddInput:newVideoInput])
        {
            [cameraSession_ addInput:newVideoInput];
            videoInput_ = newVideoInput;
        }
        else
        {
            [cameraSession_ addInput:videoInput_];
        }
        
        [cameraSession_ commitConfiguration];
    }
    
    position_ = newPosition;
    frameRate_ = 0;
    
    [self setOutputTextureorientationBasingOnCameraPosition:position_];
}


#pragma mark - Properties' Setters & Getters

- (void)setSessionPreset:(NSString *)sessionPreset
{
    [cameraSession_ beginConfiguration];
    
    sessionPreset_ = sessionPreset;
    [cameraSession_ setSessionPreset:sessionPreset_];
    
    [cameraSession_ commitConfiguration];
    
    frameRate_ = 0;
}

- (void)setMinFrameDuration:(CMTime)minFrameDuration
{
    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        NSError *error = nil;
        [videoInput_.device lockForConfiguration:&error];
        if (error) {
            NSLog(@"- setMinFrameDuration: , device can not be lock to Configure");
            return;
        }
        
        videoInput_.device.activeVideoMinFrameDuration = minFrameDuration;
        
        [videoInput_.device unlockForConfiguration];
#endif
    }
    else {
        for (AVCaptureConnection *connection in videoOutput_.connections)
        {
            if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
                connection.videoMinFrameDuration = minFrameDuration;
        }
    }
}

- (CMTime)minFrameDuration
{
    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        return videoInput_.device.activeVideoMinFrameDuration;
#endif
    }
    else {
        for (AVCaptureConnection *connection in videoOutput_.connections)
        {
            if ([connection respondsToSelector:@selector(videoMinFrameDuration)])
                return connection.videoMinFrameDuration;
        }
        
        return kCMTimeInvalid;
    }
    
    return kCMTimeInvalid;
}

- (void)setMaxFrameDuration:(CMTime)maxFrameDuration
{
    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        NSError *error = nil;
        [videoInput_.device lockForConfiguration:&error];
        if (error) {
            NSLog(@"- setMaxFrameDuration: , device can not be lock to Configure");
            return;
        }
        
        videoInput_.device.activeVideoMaxFrameDuration = maxFrameDuration;
        
        [videoInput_.device unlockForConfiguration];
#endif
    }
    else {
        for (AVCaptureConnection *connection in videoOutput_.connections)
        {
            if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
                connection.videoMaxFrameDuration = maxFrameDuration;
        }
    }
}

- (CMTime)maxFrameDuration
{
    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        return videoInput_.device.activeVideoMaxFrameDuration;
#endif
    }
    else {
        for (AVCaptureConnection *connection in videoOutput_.connections)
        {
            if ([connection respondsToSelector:@selector(videoMaxFrameDuration)])
                return connection.videoMaxFrameDuration;
        }
        
        return kCMTimeInvalid;
    }
    
    return kCMTimeInvalid;
}

- (void)setFrameRate:(int)frameRate;
{
    frameRate_ = frameRate;
    
    if ([UIDevice currentDevice].systemVersion.floatValue >=7.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
        NSError *error = nil;
        [videoInput_.device lockForConfiguration:&error];
        if (error) {
            NSLog(@"- setFrameRate: , device can not be lock to Configure");
            return;
        }
        if (frameRate_ > 0)
        {
            videoInput_.device.activeVideoMinFrameDuration = CMTimeMake(1, frameRate_);
            videoInput_.device.activeVideoMaxFrameDuration = CMTimeMake(1, frameRate_);
        }
        else
        {
            videoInput_.device.activeVideoMinFrameDuration = kCMTimeInvalid;
            videoInput_.device.activeVideoMaxFrameDuration = kCMTimeInvalid;
        }
        [videoInput_.device unlockForConfiguration];
#endif
    }
    else {
        if (frameRate_ > 0)
        {
            for (AVCaptureConnection *connection in videoOutput_.connections)
            {
                if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
                    connection.videoMinFrameDuration = CMTimeMake(1, frameRate_);
                
                if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
                    connection.videoMaxFrameDuration = CMTimeMake(1, frameRate_);
            }
        }
        else
        {
            for (AVCaptureConnection *connection in videoOutput_.connections)
            {
                if ([connection respondsToSelector:@selector(setVideoMinFrameDuration:)])
                    connection.videoMinFrameDuration = kCMTimeInvalid; // This sets videoMinFrameDuration back to default
                
                if ([connection respondsToSelector:@selector(setVideoMaxFrameDuration:)])
                    connection.videoMaxFrameDuration = kCMTimeInvalid; // This sets videoMaxFrameDuration back to default
            }
        }
    }
}

- (void)setFocusPoint:(CGPoint)focusPoint
{
    if ([videoInput_.device isFocusPointOfInterestSupported] && [videoInput_.device isFocusModeSupported:(AVCaptureFocusMode)focusMode_]) {
        NSError *error;
        CGPoint adjustedPoint = focusPoint;
        if (position_ == AVCaptureDevicePositionBack) {
            adjustedPoint = CGPointMake(adjustedPoint.y, 1.0f - adjustedPoint.x);
        }
        else if (position_ == AVCaptureDevicePositionFront) {
            adjustedPoint = CGPointMake(adjustedPoint.y, adjustedPoint.x);
        }
        if ([videoInput_.device lockForConfiguration:&error]) {
            [videoInput_.device setFocusPointOfInterest:adjustedPoint];
            [videoInput_.device setFocusMode:(AVCaptureFocusMode)focusMode_];
            [videoInput_.device unlockForConfiguration];
        }
        else {
            NSLog(@"- setFocusPoint: , device can not be lock to Configure");
        }
        focusPoint_ = focusPoint;
    }
    else {
        NSLog(@"- setFocusPoint: , focusPoint or focusMode does not be supported in this device");
    }
}

- (void)setExposurePoint:(CGPoint)exposurePoint
{
    if ([videoInput_.device isExposurePointOfInterestSupported] && [videoInput_.device isExposureModeSupported:(AVCaptureExposureMode)exposureMode_]) {
        NSError *error;
        CGPoint adjustedPoint = exposurePoint;
        if (position_ == AVCaptureDevicePositionBack) {
            adjustedPoint = CGPointMake(adjustedPoint.y, 1.0f - adjustedPoint.x);
        }
        else if (position_ == AVCaptureDevicePositionFront) {
            adjustedPoint = CGPointMake(adjustedPoint.y, adjustedPoint.x);
        }
        if ([videoInput_.device lockForConfiguration:&error]) {
            [videoInput_.device setExposurePointOfInterest:adjustedPoint];
            [videoInput_.device setExposureMode:(AVCaptureExposureMode)exposureMode_];
            [videoInput_.device unlockForConfiguration];
        } else {
            NSLog(@"- setExposurePoint: , device can not be lock to configure");
        }
        exposurePoint_ = exposurePoint;
    }
    else {
        NSLog(@"- setExposurePoint: , exposurePoint or exposureMode does not be supported in this device");
    }
}

- (void)setExposureTargetBias:(float)exposureTargetBias
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    
    exposureTargetBias_ = exposureTargetBias > 8.0 ? 8.0 : (exposureTargetBias < -8.0 ? -8.0 : exposureTargetBias);
    
    NSError *error = nil;
    
    if ([videoInput_.device lockForConfiguration:&error])
    {
        [videoInput_.device setExposureTargetBias:exposureTargetBias_ completionHandler:nil];
        [videoInput_.device unlockForConfiguration];
    }
    else
    {

        NSLog(@"- setExposureTargetBias: , device can not be lock to configure");
    }
    
#endif
}

- (SYGLVideoCaptorOrientation)orientation
{
    if (!videoCaptorMotionManager_) {
        videoCaptorMotionManager_ = [[CMMotionManager alloc] init];
        if (videoCaptorMotionManager_.isDeviceMotionAvailable) {
            [videoCaptorMotionManager_ startDeviceMotionUpdates];
        }
    }

    SYGLVideoCaptorOrientation orientation = SYGLVideoCaptorOrientationUnknown;

    if (videoCaptorMotionManager_.isDeviceMotionActive && videoCaptorMotionManager_.deviceMotion) {
        float x = -videoCaptorMotionManager_.deviceMotion.gravity.x;//-[acceleration x];
        float y =  videoCaptorMotionManager_.deviceMotion.gravity.y;//[acceleration y];
        float radian = atan2(y, x);

        if(radian >= -2.25 && radian <= -0.75)
        {
            if(orientation != SYGLVideoCaptorOrientationPortrait)
            {
                orientation = SYGLVideoCaptorOrientationPortrait;
            }
        }
        else if(radian >= -0.75 && radian <= 0.75)
        {
            if(orientation != SYGLVideoCaptorOrientationLandscapeLeft)
            {
                orientation = SYGLVideoCaptorOrientationLandscapeLeft;
            }
        }
        else if(radian >= 0.75 && radian <= 2.25)
        {
            if(orientation != SYGLVideoCaptorOrientationPortraitUpsideDown)
            {
                orientation = SYGLVideoCaptorOrientationPortraitUpsideDown;
            }
        }
        else if(radian <= -2.25 || radian >= 2.25)
        {
            if(orientation != SYGLVideoCaptorOrientationLandscapeRight)
            {
                orientation = SYGLVideoCaptorOrientationLandscapeRight;
            }
        }
        NSLog(@"x = %f, y = %f, radian = %f", x, y, radian);
    }
    else {
        NSLog(@"- orientation , Cannot get the deviceMotion data");
    }

    return orientation;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!cameraSession_ || !cameraSession_.isRunning) {
        return;
    }
    if (!self.isEnabled) {
        return;
    }
    if (dispatch_semaphore_wait(imageProcessingSemaphore_, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }
    
    CFRetain(sampleBuffer);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCaptor:willOutputVideoSampleBuffer:)])
    {
        [self.delegate videoCaptor:self willOutputVideoSampleBuffer:sampleBuffer];
    }
    
    [SYGLContext performSynchronouslyOnImageProcessingQueue:^{
        [self processVideoSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
        dispatch_semaphore_signal(imageProcessingSemaphore_);
    }];
    
}

#pragma mark Processing Sample Buffer Motheds

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(cameraFrame, 0);
    
    [SYGLContext useImageProcessingContext];
    [outputTexture_ setupContentWithCVBuffer:cameraFrame];
    [self setOutputTextureorientationBasingOnCameraPosition:position_];
    
    if (CGRectEqualToRect(outputFrame_, CGRectZero)) {
        outputFrame_ = CGRectMake(0, 0, outputTexture_.size.width, outputTexture_.size.height);
    }
    
    [self produceAtTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
    
    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
}

- (void)setOutputTextureorientationBasingOnCameraPosition:(AVCaptureDevicePosition)position
{
    if (!outputTexture_) {
        return;
    }
    if (position == AVCaptureDevicePositionBack) {
        outputTexture_.orientation = SYTextureOrientationRightMirrored;
    }
    else if (position == AVCaptureDevicePositionFront) {
        outputTexture_.orientation = SYTextureOrientationRight;
    }
}
@end
