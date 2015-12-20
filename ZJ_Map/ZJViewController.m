//
//  ZJViewController.m
//  ZJ_Map
//
//  Created by lanou3g on 15/12/20.
//  Copyright © 2015年 zhangjianjun. All rights reserved.
//

#import "ZJViewController.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

#import "ZJViewController_Navigation.h"

@interface ZJViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKPoiSearchDelegate, UITextFieldDelegate, BMKGeoCodeSearchDelegate>


//地图
@property (nonatomic, strong) BMKMapView * mapView;
//定位button
@property (nonatomic, strong) UIButton * btn_location;
//定位服务
@property (nonatomic, strong) BMKLocationService * locService;
//当前经纬度
@property (nonatomic, assign) float current_location;
@property (nonatomic, assign) float current_latitude;

//搜索
@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) UIButton * btn_cancel;
//寻找
@property (nonatomic, strong) BMKPoiSearch * searcher;
@property (nonatomic, assign) int curPage;
//检索
@property (nonatomic, strong) BMKPoiSearch * poisearch;

//地理编码
@property (nonatomic, strong) BMKGeoCodeSearch * geocodesearch;

//切换卫星/普通模式
@property (nonatomic, strong) UIButton * btn_mapType;
//放大缩小
@property (nonatomic, strong) UIButton * btn_up;
@property (nonatomic, strong) UIButton * btn_down;
//路况
@property (nonatomic, strong) UIButton * btn_road;

//规划路线页面
//@property (nonatomic, strong) JCViewController1__navigation * jcViewController1__navigation;

@property (nonatomic, strong) ZJViewController_Navigation * zjViewController__Navigation;





@end

@implementation ZJViewController


#pragma mark - 系统的
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //navigationItem.title
    self.navigationItem.title = @"定位/周边";
    // 把地图加在视图上
    [self p_addMapView];
    //布局
    [self p_setupView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 所有btn的点击事件
//定位
- (void)btn_locationAction:(UIButton *)sender
{
    self.locService = [[BMKLocationService alloc] init];
    
    self.locService.delegate = self;
    self.locService.userLocation.title = @"您当前位置";
    self.locService.userLocation.subtitle = @"正在定位";
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    self.mapView.zoomLevel = 18;
    //精确度
    self.locService.desiredAccuracy = kCLLocationAccuracyBest;
    //启动LocationService
    [self.locService startUserLocationService];
    
}
//搜索框
- (void)leftBarButtonItemAction:(UIBarButtonItem *)bar
{
    self.textField.hidden = NO;
    self.btn_cancel.hidden = NO;
}
//取消
- (void)btn_cancelAction:(UIButton *)sender
{
    self.textField.hidden = YES;
    self.btn_cancel.hidden = YES;
    [self.textField resignFirstResponder];
}
//切换地图模式
- (void)btn_mapTypeAction:(UIButton *)sender
{
    if(self.mapView.mapType == 1)
    {
        self.mapView.mapType = 2;
    }
    else
    {
        self.mapView.mapType = 1;
    }
}

//放大和缩小地图的btn
- (void)btn_upAction:(UIButton *)sender
{
    self.mapView.zoomLevel ++;
}

- (void)btn_downAction:(UIButton *)sender
{
    self.mapView.zoomLevel --;
}
//打开实时路况!
- (void)btn_roadAction:(UIButton *)sender
{
    if(self.mapView.trafficEnabled == 0)
    {
        //打开实时路况图层
        [self.mapView setTrafficEnabled:YES];
    }
    else
    {
        [self.mapView setTrafficEnabled:NO];
    }
}

//规划路线
- (void)rightBarButtonItemAction:(UIBarButtonItem *)bar
{
    //    NSLog(@"规划路线");
    //    self.jcViewController1__navigation = [[JCViewController1__navigation alloc] init];
    //
    //    [self showViewController:self.jcViewController1__navigation sender:nil];
    
    //导航
    self.zjViewController__Navigation = [[ZJViewController_Navigation alloc] init];
    
    [self showViewController:self.zjViewController__Navigation sender:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([self.textField.text length] == 0)
    {//弹出提示框,搜索不能为空
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"周边搜索内容不能为空" preferredStyle:(UIAlertControllerStyleAlert)];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        
        return NO;
    }
    else
    {//开始检索!!
        self.curPage = 0;
        self.searcher = [[BMKPoiSearch alloc] init];
        self.searcher.delegate = self;
        //发起检索
        BMKNearbySearchOption * option = [[BMKNearbySearchOption alloc] init];
        option.pageIndex = self.curPage;
        //搜索个数;
        option.pageCapacity = 17;
        option.location = CLLocationCoordinate2DMake(self.current_latitude, self.current_location);
        option.keyword = self.textField.text;
        BOOL flag = [_searcher poiSearchNearBy:option];
        if(flag)
        {
            //            NSLog(@"周边检索发送成功");
        }
        else
        {
            NSLog(@"周边检索发送失败");
        }
        return YES;
    }
}

#pragma mark - BMKPoiSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    [self.textField resignFirstResponder];
    
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotations = [NSMutableArray array];
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [annotations addObject:item];
        }
        [_mapView addAnnotations:annotations];
        [_mapView showAnnotations:annotations animated:YES];
        
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
}

#pragma mark - BMKGeoCodeSearchDelegate代理, 这个为地理反编码
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if(error == 0)
    {
        self.locService.userLocation.title = @"您当前的位置:";
        //获取位置:
        self.locService.userLocation.subtitle = result.address;
    }
}


#pragma mark - BMKLocationServiceDelegate代理,也为定位服务
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //以下_mapView为BMKMapView对象
    self.mapView.showsUserLocation = YES;//显示定位图层
    [self.mapView updateLocationData:userLocation];
    
    //开始定位的时候, 得到地理编码
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    if (userLocation.location.coordinate.longitude != 0 && userLocation.location.coordinate.latitude != 0) {
        pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude , userLocation.location.coordinate.longitude};
    }
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag1 = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag1)
    {
        //        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
    self.current_location = userLocation.location.coordinate.longitude;
    self.current_latitude = userLocation.location.coordinate.latitude;
    
    //    //开始定位的时候, 得到地理编码
    //    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    //    if (self.current_location != 0 && self.current_latitude != 0) {
    //        pt = (CLLocationCoordinate2D){self.current_latitude , self.current_location};
    //    }
    //    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    //    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    //    BOOL flag1 = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    //    if(flag1)
    //    {
    //        NSLog(@"反geo检索发送成功");
    //    }
    //    else
    //    {
    //        NSLog(@"反geo检索发送失败");
    //    }
}

#pragma mark - 把地图加在视图上
- (void)p_addMapView
{
    //    显示地图
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 49)];
    //切换为普通地图
    [self.mapView setMapType:BMKMapTypeStandard];
    //打开实时路况图层
    [self.mapView setTrafficEnabled:NO];
    //缩放尺度
    self.mapView.zoomLevel = 19;
    //跟随指针模式
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    //比例尺
    self.mapView.showMapScaleBar = YES;
    
    [self.view addSubview:self.mapView];
    
    self.locService = [[BMKLocationService alloc] init];
    
    self.locService.delegate = self;
    self.locService.userLocation.title = @"您当前位置";
    self.locService.userLocation.subtitle = @"正在定位";
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    self.mapView.zoomLevel = 18;
    //精确度
    self.locService.desiredAccuracy = kCLLocationAccuracyBest;
    //启动LocationService
    [self.locService startUserLocationService];
    
    //地理编码
    self.geocodesearch = [[BMKGeoCodeSearch alloc]init];
    [self.mapView setZoomLevel:18];
}

#pragma mark - 布局
- (void)p_setupView
{
    //定位的button
    self.btn_location = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.btn_location.frame = CGRectMake(5, self.mapView.frame.size.height - 100, 32, 32);
    [self.btn_location setImage:[UIImage imageNamed:@"0001"] forState:(UIControlStateNormal)];
    self.btn_location.tintColor = [UIColor grayColor];
    [self.mapView addSubview:self.btn_location];
    //添加点击事件;
    [self.btn_location addTarget:self action:@selector(btn_locationAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    //左检索
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemSearch) target:self action:@selector(leftBarButtonItemAction:)];
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"0005"] style:(UIBarButtonItemStyleDone) target:self action:@selector(leftBarButtonItemAction:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    //搜索框
    self.textField = [[UITextField alloc] init];
    self.textField.frame = CGRectMake(15, 3, self.view.frame.size.width - 30 - 40, 35);
    self.textField.backgroundColor = [UIColor grayColor];
    self.textField.delegate = self;
    self.textField.alpha = 0.6;
    self.textField.layer.cornerRadius = 5;
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.placeholder = @"请输入你要搜索的周边位置信息";
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    self.textField.clearsOnBeginEditing = YES;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 35)];
    self.textField.leftView = view;
    self.textField.hidden = YES;
    [self.mapView addSubview:self.textField];
    //取消btn
    self.btn_cancel = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.btn_cancel.frame = CGRectMake(CGRectGetMaxX(self.textField.frame) + 9, 3, 32, 32);
    [self.btn_cancel setImage:[UIImage imageNamed:@"0002"] forState:(UIControlStateNormal)];
    self.btn_cancel.tintColor = [UIColor grayColor];
    [self.mapView addSubview:self.btn_cancel];
    self.btn_cancel.hidden = YES;
    
    [self.btn_cancel addTarget:self action:@selector(btn_cancelAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    //切换地图模式
    self.btn_mapType = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.btn_mapType.frame = CGRectMake(self.mapView.frame.size.width - 42, 50, 32, 32);
    [self.btn_mapType addTarget:self action:@selector(btn_mapTypeAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.btn_mapType setImage:[UIImage imageNamed:@"0003"] forState:(UIControlStateNormal)];
    self.btn_mapType.tintColor = [UIColor brownColor];
    
    [self.mapView addSubview:self.btn_mapType];
    
    //路况模式打开
    self.btn_road = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.btn_road.frame = CGRectMake(self.mapView.frame.size.width - 42, 92, 32, 32);
    [self.btn_road addTarget:self action:@selector(btn_roadAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.btn_road setImage:[UIImage imageNamed:@"0004"] forState:(UIControlStateNormal)];
    self.btn_road.tintColor = [UIColor blackColor];
    
    [self.mapView addSubview:self.btn_road];
    
    
    //放大和缩小地图
    self.btn_up = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.btn_up.frame = CGRectMake(self.mapView.frame.size.width - 42, self.mapView.frame.size.height - 90, 30, 30);
    [self.btn_up setImage:[UIImage imageNamed:@"0006"] forState:(UIControlStateNormal)];
    self.btn_up.tintColor = [UIColor blackColor];
    [self.btn_up addTarget:self action:@selector(btn_upAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.mapView addSubview:self.btn_up];
    
    self.btn_down = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.btn_down.frame = CGRectMake(self.mapView.frame.size.width - 42, self.mapView.frame.size.height - 58, 30, 30);
    [self.btn_down setImage:[UIImage imageNamed:@"0007"] forState:(UIControlStateNormal)];
    self.btn_down.tintColor = [UIColor blackColor];
    [self.btn_down addTarget:self action:@selector(btn_downAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.mapView addSubview:self.btn_down];
    
    //右 规划路线
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemAdd) target:self action:@selector(rightBarButtonItemAction:)];
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"0008"] style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItemAction:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
    
}

#pragma mark - 当视图出现的时候,和消失的时候
- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self;
    _geocodesearch.delegate = self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _poisearch.delegate = nil;
    _geocodesearch.delegate = nil;
}


@end
