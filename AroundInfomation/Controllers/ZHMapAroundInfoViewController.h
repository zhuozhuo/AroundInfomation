//
//  ZHMapAroundInfoViewController.h
//  AroundInfomation
//
//  Created by aimoke on 16/11/9.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ZHMapView.h"


@interface ZHMapAroundInfoViewController : UIViewController<MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *showTableView;
@end
