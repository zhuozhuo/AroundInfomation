//
//  ZHMapPolylineManager.m
//  TestDrawMapLine
//
//  Created by aimoke on 16/7/19.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import "ZHMapPolylineManager.h"

const double a = 6378245.0;
const double ee = 0.00669342162296594323;
@implementation ZHMapPolylineManager


+(ZHMapPolylineManager *)shareZHMapPolylineManager
{
    static ZHMapPolylineManager *mapPolylineManager;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        mapPolylineManager = [[ZHMapPolylineManager alloc]init];
    });
    return mapPolylineManager;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
       
              
    }
    return self;
}


+ (BOOL)outOfChina:(CLLocation *)location {
    if (location.coordinate.longitude < 72.004 || location.coordinate.longitude > 137.8347) {
        return YES;
    }
    if (location.coordinate.latitude < 0.8293 || location.coordinate.latitude > 55.8271) {
        return YES;
    }
    return NO;
}




+ (CLLocation *)transformToMars:(CLLocation *)location {
    //是否在中国大陆之外
    if ([[self class] outOfChina:location]) {
        return location;
    }
    CLLocationCoordinate2D coordinate = [self transFormToMarsCLLocationCoordinate2D:location.coordinate];
    
    return [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}


+(CLLocationCoordinate2D)transFormToMarsCLLocationCoordinate2D:(CLLocationCoordinate2D )coordinate
{
    
    double dLat = [[self class] transformLatWithX:coordinate.longitude - 105.0 y:coordinate.latitude - 35.0];
    double dLon = [[self class] transformLonWithX:coordinate.longitude - 105.0 y:coordinate.latitude - 35.0];
    double radLat = coordinate.latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    return CLLocationCoordinate2DMake(coordinate.latitude + dLat, coordinate.longitude + dLon);
}

+ (double)transformLatWithX:(double)x y:(double)y {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

+ (double)transformLonWithX:(double)x y:(double)y {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

@end
