//
//  CMPressView.h
//  CNMRC-2.0.0
//
//  Created by Park Jong Pil on 2015. 3. 23..
//  Copyright (c) 2015년 LambertPark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMPressView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *pressImageView;
@property (weak, nonatomic) IBOutlet UILabel *pressLabel;

- (void)setImage:(NSString *)imageName andLabel:(NSString *)key;

@end
