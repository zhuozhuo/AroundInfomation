//
//  ZHMapAroundInfoViewController.m
//  AroundInfomation
//
//  Created by aimoke on 16/11/9.
//  Copyright © 2016年 zhuo. All rights reserved.
//

#import "ZHMapAroundInfoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ZHPlaceInfoModel.h"
#import "ZHPlaceInfoTableViewCell.h"
#import "ZHMapPolylineManager.h"
#import <objc/runtime.h>

#define DEFAULTSPAN 50
#define CellIdntifier @"placeInfoCellIdentifier"

@interface ZHMapAroundInfoViewController (){
    BOOL haveGetUserLocation;//是否获取到用户位置
    CLGeocoder *geocoder;
    NSMutableArray *infoArray;//周围信息
    UIImageView *imgView;//中间位置标志视图
    BOOL spanBool;//是否是滑动
    BOOL pinchBool;//是否缩放
}

@end

@implementation ZHMapAroundInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showTableView.tableFooterView = [UIView new];
    spanBool = NO;
    pinchBool = NO;
    [self.showTableView registerNib:[UINib nibWithNibName:@"ZHPlaceInfoTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdntifier];
    geocoder=[[CLGeocoder alloc]init];
    infoArray = [NSMutableArray array];
    haveGetUserLocation = NO;
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    //先查看MapView层次结构
   // NSLog(@"mapview recursiveDescription:\n%@",[self.mapView performSelector:@selector(recursiveDescription)]);
    
    //打印完后我们发现有个View带有手势数组其类型为_MKMapContentView获取Span和Pinch手势
    for (UIView *view in self.mapView.subviews) {
        NSString *viewName = NSStringFromClass([view class]);
        if ([viewName isEqualToString:@"_MKMapContentView"]) {
            UIView *contentView = view;//[self.mapView valueForKey:@"_contentView"];
            for (UIGestureRecognizer *gestureRecognizer in contentView.gestureRecognizers) {
                if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                    [gestureRecognizer addTarget:self action:@selector(mapViewSpanGesture:)];
                }
                if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    [gestureRecognizer addTarget:self action:@selector(mapViewPinchGesture:)];
                }
            }

        }
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self resetTableHeadView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    
}
-(void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    NSLog(@"mapViewWillStartLocatingUser");
}

-(void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    NSLog(@"mapViewDidStopLocatingUser");
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"userLocation:longitude:%f---latitude:%f",userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude);
    if (!haveGetUserLocation) {
        if (self.mapView.userLocationVisible) {
            haveGetUserLocation = YES;
            [self getAddressByLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
            [self addCenterLocationViewWithCenterPoint:self.mapView.center];
        }
        
    }
}
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"didFailToLocateUserWithError:%@",error.localizedDescription);
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"regionWillChangeAnimated");
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionDidChangeAnimated");
    if (imgView && (spanBool||pinchBool)) {
        [infoArray removeAllObjects];
        [self.showTableView reloadData];
        [self resetTableHeadView];
        CGPoint mapCenter = self.mapView.center;
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:mapCenter toCoordinateFromView:self.mapView];
        [self getAddressByLatitude:coordinate.latitude longitude:coordinate.longitude];
        imgView.center = CGPointMake(mapCenter.x, mapCenter.y-15);
        [UIView animateWithDuration:0.2 animations:^{
            imgView.center = mapCenter;
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    imgView.transform = CGAffineTransformMakeScale(1.0, 0.8);
                    
                }completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            imgView.transform = CGAffineTransformIdentity;
                        }completion:^(BOOL finished){
                            if (finished) {
                                spanBool = NO;
                            }
                        }];
                    }
                }];
                
            }
        }];
    }
   
}

#pragma mark - Private Methods
-(void)resetTableHeadView
{
    if (infoArray.count>0) {
        self.showTableView.tableHeaderView = nil;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30.0)];
        view.backgroundColor = self.showTableView.backgroundColor;
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = view.center;
        [indicatorView startAnimating];
        [view addSubview:indicatorView];
        self.showTableView.tableHeaderView = view;
        
    }
}

-(void)addCenterLocationViewWithCenterPoint:(CGPoint)point
{
    if (!imgView) {
        imgView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 100, 18, 38)];
        imgView.center = point;
        imgView.image = [UIImage imageNamed:@"map_location"];
        imgView.center = self.mapView.center;
        [self.view addSubview:imgView];
    }
    
}

-(void)getAroundInfoMationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, DEFAULTSPAN, DEFAULTSPAN);
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.region = region;
    request.naturalLanguageQuery = @"Restaurants";
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            [self getAroundInfomation:response.mapItems];
        }else{
            haveGetUserLocation = NO;
            NSLog(@"Quest around Error:%@",error.localizedDescription);
        }
    }];
}


-(void)getAroundInfomation:(NSArray *)array
{
    for (MKMapItem *item in array) {
        MKPlacemark * placemark = item.placemark;
        ZHPlaceInfoModel *model = [[ZHPlaceInfoModel alloc]init];
        model.name = placemark.name;
        model.thoroughfare = placemark.thoroughfare;
        model.subThoroughfare = placemark.subThoroughfare;
        model.city = placemark.locality;
        model.coordinate = placemark.location.coordinate;
        [infoArray addObject:model];
    }
    [self.showTableView reloadData];
}


#pragma mark 根据坐标取得地名
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    
    //反地理编码
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initialData:placemarks];
                [self getAroundInfoMationWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
                [self.showTableView reloadData];
                [self resetTableHeadView];
            });
        }else{
            haveGetUserLocation = NO;
            NSLog(@"error:%@",error.localizedDescription);
        }
        
    }];
}


#pragma mark - Initial Data
-(void)initialData:(NSArray *)places
{
    [infoArray removeAllObjects];
    for (CLPlacemark *placemark in places) {
        ZHPlaceInfoModel *model = [[ZHPlaceInfoModel alloc]init];
        model.name = placemark.name;
        model.thoroughfare = placemark.thoroughfare;
        model.subThoroughfare = placemark.subThoroughfare;
        model.city = placemark.locality;
        model.coordinate = placemark.location.coordinate;
        [infoArray insertObject:model atIndex:0];
    }
}

#pragma mark － TableView datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return infoArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZHPlaceInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdntifier forIndexPath:indexPath];
    ZHPlaceInfoModel *model = [infoArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = model.name;
    cell.subTitleLabel.text = model.thoroughfare;
    return cell;
}


#pragma mark - TableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - touchs
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"moved");
    spanBool = YES;
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   
}


#pragma mark - MapView Gesture
-(void)mapViewSpanGesture:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            NSLog(@"SpanGesture Began");
        }
            break;
        case UIGestureRecognizerStateChanged:{
             NSLog(@"SpanGesture Changed");
            spanBool = YES;
        }
            
            break;
        case UIGestureRecognizerStateCancelled:{
             NSLog(@"SpanGesture Cancelled");
        }
            
            break;
        case UIGestureRecognizerStateEnded:{
             NSLog(@"SpanGesture Ended");
        }
            
            break;
            
        default:
            break;
    }
}

-(void)mapViewPinchGesture:(UIGestureRecognizer*)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            NSLog(@"PinchGesture Began");
        }
            break;
        case UIGestureRecognizerStateChanged:{
            NSLog(@"PinchGesture Changed");
            pinchBool = YES;
        }
            
            break;
        case UIGestureRecognizerStateCancelled:{
            NSLog(@"PinchGesture Cancelled");
        }
            
            break;
        case UIGestureRecognizerStateEnded:{
            pinchBool = NO;
            NSLog(@"PinchGesture Ended");
        }
            
            break;
            
        default:
            break;
    }

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
