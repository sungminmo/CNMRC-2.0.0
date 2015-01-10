//
//  CMWebViewController.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 8. 7..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import "CMBaseViewController.h"

@interface CMWebViewController : CMBaseViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *url;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
