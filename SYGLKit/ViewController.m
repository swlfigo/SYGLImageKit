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

@interface ViewController ()

@property (nonatomic,strong)SYGLView *presentView;

@property (nonatomic,strong)SYGLVideoCamera *camera;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _presentView = [[SYGLView alloc]initWithFrame:self.view.frame];

    //屏幕居中自适应模式
    _presentView.contentMode = SYGLFrameBufferObjectContentModeResizeAspect;
    
    [self.view addSubview:_presentView];
    
    /*
     //测试图片渲染
    SYGLImage *imageTexture = [[SYGLImage alloc]initWithUIImage:[UIImage imageNamed:@"backGroundImageSource.jpg"]];

    [imageTexture addConsumer:_presentView];

    [imageTexture produceAtTime:kCMTimeInvalid];
    */
    
    _camera = [[SYGLVideoCamera alloc]initWithCameraPosition:AVCaptureDevicePositionBack sessionPreset:AVCaptureSessionPresetPhoto];
//    (width = 1080, height = 1440)

    
    [_camera addConsumer:_presentView];
    
    [_camera startRunning];
    
}





@end
