//
//  CMKeyboardViewController.m
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 20..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import "CMKeyboardViewController.h"

@interface CMKeyboardViewController ()

@end

@implementation CMKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupLayout
{
    // 백그라운트 컬러 설정.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    
    // 탭 제스처 추가.
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)recognizeTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self cancelAction:recognizer];
    }
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
