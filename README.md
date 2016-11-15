T行业的我们很是苦恼,如果做的应用要世界通用,那就是痛苦了,需要考虑很多。例如：如果我们做一个地图应用,兼容中国和外国。要么使用国内地图+Google，要么就是使用苹果自带地图。今天主要介绍使用苹果自带地图获取用户当前位置及用户周围信息,地图移动时,地图中间指针一直在中间,移动结束后有下落定位的动画效果并更新当前位置及用户周围信息。具体可以看微信分享当前位置功能,Demo需要真机测试查看效果。

**先看效果：**
gif动画是在模拟器上录制，由于模拟器不能获取周围信息，所以一直在转菊花。要看实际效果需要真机查看。


![](http://upload-images.jianshu.io/upload_images/2926059-f77b1aab8779e5dc.gif?imageMogr2/auto-orient/strip)

![IMG_2365.PNG](http://upload-images.jianshu.io/upload_images/2926059-038582bd5b5c11aa.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 步骤
1. 添加库`MapKit.framework`。
![模拟器效果展示](http://upload-images.jianshu.io/upload_images/2926059-128ced5cff4c3095.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 打开地图功能。
![真机截图](http://upload-images.jianshu.io/upload_images/2926059-bcaac77390f0f8a4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3. 代码实现。


* 获取当前位置周围信息,苹果提供了一个请求方法,[`MKLocalSearch`](https://developer.apple.com/reference/mapkit/mklocalsearch?language=objc)。其官方介绍为：
>An MKLocalSearch object initiates a map-based search operation and delivers the results back to your app asynchronously. Search objects are designed to perform one search operation only. To perform several different searches, you must create separate instances of this class and start them separately.
也就是说我们如果要搜索不同的类型需要分别创建多个实例进行操作。

如果我们要搜索周围100米餐厅代码如下：

```objective-c
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate,100, 100);
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.region = region;
    request.naturalLanguageQuery = @"Restaurants";
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            //do something.
        }else{
            //do something.
        }
    }];
```
其中`naturalLanguageQuery`就是要搜索的关键字,我试过的所有关键字有`cafe, supermarket,village,Community，Shop,Restaurant，School，hospital，Company，Street，Convenience store，Shopping Centre，Place names，Hotel，Grocery store`每个关键字搜索返回结果只有10条，如果当前范围无搜索结果,则扩散搜索范围。如果你想列出周围所有相关位置信息，我认为需要尽可能的把所有的能够想到的关键字都举例出来进行搜索，搜索完成后进行经纬度比较然后刷选出范围内的相关位置。而且由于数据来源问题，很多位置信息都没有！当然如果你只兼容国内，还是使用百度或者腾讯地图算了。

* 根据前经纬度获取位置相关信息。

```objective-c
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
            //do something.
            });
        }else{
            //do something.
        }
        
    }];
```
* 下落定位动画效果

```objective-c
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
                        }];
                    }
                }];
                
            }
        }];

```
这里我的思路是三个动画效果组合以达到大头针下落定位的效果。

* 获取用户滑动地图操作。
`MKMapViewDelegate`中有个方法在滑动结束后可以回调如下所示：

```objective-c
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
```
但是它有个缺点就是在最开始初始化地图并定位到用户所在位置时,它会被反复回调。所以很难确定用户是否是滑动导致函数回调的。所以这里我们需要知道用户是否和地图有过接触后导致它的回调。如何做呢？这里有两种方法以供参考。
方法一：这里你是否想起` UIScrollView`,如果我们想获取`touch`事件，我们应该怎么做，没错就是继承后重写`touch`方法，然后把`toush`事件传递下去。代码如下：
```objective-c
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

```

方法二：我在[修改 navigationBar 底部线条颜色总结](http://www.jianshu.com/p/48ddc88299dd)这篇文章中有用到查看View层次结构找到隐藏属性并对它进行操作。没错这里也是一样的道理，先看mapview层次结构例如如下所示：
![](http://upload-images.jianshu.io/upload_images/2926059-1b05bfa9cd4e7829.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这里我们可以发现`_MKMapContentView`里面有个手势数组，没错就是它了。我们获取它并对他进行操作，代码如下所示：

```objective-c
//打印完后我们发现有个View带有手势数组其类型为_MKMapContentView获取Span手势
    for (UIView *view in self.mapView.subviews) {
        NSString *viewName = NSStringFromClass([view class]);
        if ([viewName isEqualToString:@"_MKMapContentView"]) {
            UIView *contentView = view;//[self.mapView valueForKey:@"_contentView"];
            for (UIGestureRecognizer *gestureRecognizer in contentView.gestureRecognizers) {
                if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                    [gestureRecognizer addTarget:self action:@selector(mapViewSpanGesture:)];
                }
            }

        }
    }

```

*  加载时`UITableView`顶部展示菊花展示，这个原理和我们做分页展示时，滑动到底部或顶部有个菊花展示的道理一样。代码如下

```objective-c
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
```


