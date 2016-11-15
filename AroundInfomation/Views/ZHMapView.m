//
//  ZHMapView.m
//  AroundInfomation
//
//  Created by aimoke on 16/11/10.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import "ZHMapView.h"

@implementation ZHMapView

#pragma mark - touchs
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [[self nextResponder] touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [[self nextResponder] touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [[self nextResponder] touchesEnded:touches withEvent:event];
  
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
     [super touchesCancelled:touches withEvent:event];
    [[self nextResponder]touchesCancelled:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
