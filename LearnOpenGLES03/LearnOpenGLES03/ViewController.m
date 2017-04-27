//
//  ViewController.m
//  LearnOpenGLES03
//
//  Created by 黄维平 on 2017/4/22.
//  Copyright © 2017年 hwp. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLESView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [[OpenGLESView alloc]initWithFrame:[UIScreen mainScreen].bounds];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
