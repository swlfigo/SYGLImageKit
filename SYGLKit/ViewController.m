//
//  ViewController.m
//  SYGLKit
//
//  Created by Sylar on 2018/5/11.
//  Copyright © 2018年 Sylar. All rights reserved.
//

#import "ViewController.h"
#import "SYGLView.h"
#import "SYGLImage.h"
#import "SYGLFilter.h"
#import "SYGLVideoCamera.h"
#import "SYGLBlendFilter.h"

@interface ViewController ()<SYGLVideoCameraDelegate>

@property (nonatomic,strong)SYGLView *presentView;

@property (nonatomic) CGRect presentViewRect;

@property (nonatomic,strong)SYGLVideoCamera *camera;

@property (nonatomic,strong)SYGLImage *firstImageTexture;

@property (nonatomic,strong)SYGLImage *secondImageTexture;

@property (nonatomic,strong)SYGLBlendFilter *twoInputFilters;

@property (nonatomic,strong)SYGLFilter *firstEmptyFilter;

@property (nonatomic,strong)SYGLFilter *secondEmptyFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configDisplayView];
    
    [self configImageSource];
    
    [self configEmptyFilter];
    
    [self configCameraSource];
    
    [self configTwoInputsFilter];
    
    [self configFilterChain];

    
}


-(void)configImageSource{
    //测试图片渲染
//    _imageTexture = [[SYGLImage alloc]initWithUIImage:[UIImage imageNamed:@"backGroundImageSource.jpg"]];
    _firstImageTexture = [[SYGLImage alloc]initWithUIImage:[UIImage imageNamed:@"backGroundImageSource.jpg"]];
    
    _secondImageTexture =  [[SYGLImage alloc]initWithUIImage:[UIImage imageNamed:@"smallSizeImageSource.jpg"]];
    
    _presentViewRect = AVMakeRectWithAspectRatioInsideRect(_firstImageTexture.size, self.view.frame);
    
}

-(void)configCameraSource{
    _camera = [[SYGLVideoCamera alloc]initWithCameraPosition:AVCaptureDevicePositionBack sessionPreset:AVCaptureSessionPresetPhoto];
    //    (width = 1080, height = 1440)
    
    _camera.delegate = self;
}

-(void)configTwoInputsFilter{
    //Two Inputs
    _twoInputFilters = [[SYGLBlendFilter alloc]initWithContentSize:_presentView.contentSize];
    _twoInputFilters.opacity = 0.5f;
}

-(void)configEmptyFilter{
    //Empty Filter
    _firstEmptyFilter = [[SYGLFilter alloc]initWithContentSize:_presentView.contentSize];
    
    _firstEmptyFilter.outputFrame = CGRectMake(0, 0, _presentView.contentSize.width, _presentView.contentSize.height);
    
    _secondEmptyFilter = [[SYGLFilter alloc]initWithContentSize:_presentView.contentSize];
    
    _secondEmptyFilter.outputFrame = CGRectMake(0, 0, _presentView.contentSize.width, _presentView.contentSize.height);
}

-(void)configDisplayView{
    _presentView = [[SYGLView alloc]initWithFrame:self.view.frame];
    
    //屏幕居中自适应模式
//    _presentView.contentMode = SYGLFrameBufferObjectContentModeResizeAspect;
    _presentView.contentMode = SYGLFrameBufferObjectContentModeNormal;
    
    [self.view addSubview:_presentView];
}

-(void)configFilterChain{
//    [_firstImageTexture addConsumer:_firstEmptyFilter];
//
//    [_firstEmptyFilter addConsumer:_presentView];
//
//    [_firstImageTexture produceAtTime:kCMTimeInvalid];
//
//
//    [_secondEmptyFilter addConsumer:_presentView];
//
//    [_secondEmptyFilter produceAtTime:kCMTimeInvalid];
//
//
//    [_secondImageTexture addConsumer:_firstEmptyFilter];
//
//    [_firstEmptyFilter addConsumer:_presentView];
//
//    [_secondImageTexture produceAtTime:kCMTimeInvalid];
    
    
    
//    [_secondImageTexture addConsumer:_firstEmptyFilter];
//
//    _firstEmptyFilter.contentSize = CGSizeMake(640, 640);
//
//    _firstImageTexture.outputFrame = CGRectMake(0, 0, _twoInputFilters.contentSize.width, _twoInputFilters.contentSize.height);
//
//    [_firstEmptyFilter addConsumer:_presentView];
//
//    [_secondImageTexture produceAtTime:kCMTimeInvalid];
    
    
    
    //presetPhoto质量全屏幕显示
//    [_camera addConsumer:_firstEmptyFilter];
//
//    _firstEmptyFilter.contentSize = CGSizeMake(_camera.outputFrame.size.width, _camera.outputFrame.size.height);
//
//    CGFloat x = (_camera.outputFrame.size.height * 3 / 4.0  - _camera.outputFrame.size.width)/2.0;
//
//    _firstEmptyFilter.outputFrame = CGRectMake(x, 0,_presentView.contentSize.height * 3 /4.0, _presentView.contentSize.height);
//
//    [_firstEmptyFilter addConsumer:_presentView];
//
//    [_camera startRunning];




    [_camera addConsumer:_secondEmptyFilter];
    
    _secondEmptyFilter.contentSize = CGSizeMake(_camera.outputFrame.size.width, _camera.outputFrame.size.height);
    
    CGFloat x = (_camera.outputFrame.size.height * 3 / 4.0  - _camera.outputFrame.size.width)/2.0;
    
    _secondEmptyFilter.outputFrame = CGRectMake(x, 0,_presentView.contentSize.height * 3 /4.0, _presentView.contentSize.height);
    
    
    [_secondEmptyFilter addConsumer:_twoInputFilters];
    
    [_secondImageTexture addConsumer:_firstEmptyFilter];
    
    _firstEmptyFilter.contentSize = CGSizeMake(640, 640);
    
    _firstImageTexture.outputFrame = CGRectMake(0, 0, 1440, 1440);
    
    [_firstEmptyFilter addConsumer:_twoInputFilters];
    
    [_twoInputFilters addConsumer:_presentView];
    
    [_camera startRunning];
    

    

//    [_firstImageTexture addConsumer:_firstEmptyFilter];
//
//    [_firstEmptyFilter addConsumer:_twoInputFilters];
//
//    [_secondImageTexture addConsumer:_secondEmptyFilter];
//
//    [_secondEmptyFilter addConsumer:_twoInputFilters];
//
//    [_twoInputFilters addConsumer:_presentView];
//
//
//    [_secondImageTexture produceAtTime:kCMTimeInvalid];
//    [_firstImageTexture produceAtTime:kCMTimeInvalid];
//
//
//
//    UIImage *image = [_firstEmptyFilter imageFromCurrentFrame];
//    UIImage *image2 = [_secondEmptyFilter imageFromCurrentFrame];


}

#pragma mark - Camera Delegate
-(void)videoCaptor:(SYGLVideoCamera *)videoCaptor willOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    [_secondImageTexture produceAtTime:kCMTimeInvalid];
    
//    [_firstImageTexture produceAtTime:kCMTimeInvalid];
//    [_secondImageTexture produceAtTime:kCMTimeInvalid];
    

    
}

@end
