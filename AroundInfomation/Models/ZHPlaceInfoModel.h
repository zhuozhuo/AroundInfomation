//
//  ZHPlaceInfoModel.h
//  AroundInfomation
//
//  Created by aimoke on 16/11/10.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ZHPlaceInfoModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *thoroughfare;
@property (nonatomic, strong) NSString *subThoroughfare;
@property (nonatomic, strong) NSString *city;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@end
