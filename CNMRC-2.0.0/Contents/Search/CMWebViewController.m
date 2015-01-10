//
//  CMWebViewController.m
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMWebViewController.h"

@interface CMWebViewController ()

@end

@implementation CMWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = @"검색";
    
    self.webView.scalesPageToFit = YES;
	self.webView.allowsInlineMediaPlayback = YES;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// 로딩 종료.
	[self hide];
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
	// 로딩 시작.
    [self show];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	// 로딩 종료.
	[self hide];
}

@end
