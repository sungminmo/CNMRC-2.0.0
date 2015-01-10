//
//  CMNumberKey.h
//  CNMRC
//
//  Created by Jong Pil Park on 13. 7. 18..
//  Copyright (c) 2013년 Jong Pil Park. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CMNumberKeyDelegate;

@interface CMNumberKey : UIView

@property (assign, nonatomic) id<CMNumberKeyDelegate> delegate;

- (IBAction)keyAction:(id)sender;

@end

@protocol CMNumberKeyDelegate <NSObject>
- (void)selectedNumberKey:(UIButton *)numberKey;
@end
