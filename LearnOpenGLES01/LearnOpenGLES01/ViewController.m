//
//  ViewController.m
//  LearnOpenGLES01
//
//  Created by 黄维平 on 2017/4/17.
//  Copyright © 2017年 hwp. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view = [[OpenGLView alloc]initWithFrame:[UIScreen mainScreen].bounds];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
