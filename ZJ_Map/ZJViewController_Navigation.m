//
//  ZJViewController_Navigation.m
//  ZJ_Map
//
//  Created by lanou3g on 15/12/20.
//  Copyright © 2015年 zhangjianjun. All rights reserved.
//

#import "ZJViewController_Navigation.h"

//导航相关的头文件
#import "BNRoutePlanModel.h"
#import "BNCoreServices.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件


@interface ZJViewController_Navigation ()<BNNaviUIManagerDelegate, BNNaviRoutePlanDelegate, UITextFieldDelegate, BMKGeoCodeSearchDelegate>
//导航类型，分为模拟导航和真实导航
@property (assign, nonatomic) BN_NaviType naviType;

//起点和终点
@property (nonatomic, strong) UILabel * label1;
@property (nonatomic, strong) UILabel * label2;
//起点和终点的信息
@property (nonatomic, strong) UITextField * text_start;
@property (nonatomic, strong) UITextField * text_end;

@property (nonatomic, strong) UILabel * label3;

//模拟导航, 和真实导航
@property (nonatomic, strong) UIButton * btn_simulatorNavi;
@property (nonatomic, strong) UIButton * btn_realNavi;

//地理编码
@property (nonatomic, strong) BMKGeoCodeSearch * geocodesearch;

@property (nonatomic, strong) BMKGeoCodeSearch * searcher;
//开始的位置坐标
@property (nonatomic, assign) double start_latitude;
@property (nonatomic, assign) double start_longitude;
//结束的位置坐标
@property (nonatomic, assign) double end_latitude;
@property (nonatomic, assign) double end_longitude;

//保存数据
@property (nonatomic, assign) double x1;
@property (nonatomic, assign) double x2;
@property (nonatomic, assign) double x3;
@property (nonatomic, assign) double x4;


@end

@implementation ZJViewController_Navigation

#pragma mark - 系统自带的;
- (void)viewDidLoad
{
    [super viewDidLoad];
    //地理编码
    self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
    
    [self p_setupView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.text_start resignFirstResponder];
    [self.text_end resignFirstResponder];
}

#pragma mark - 地理编码

- (void)geocodingWithAddress:(NSString *)address
{
    self.searcher =[[BMKGeoCodeSearch alloc]init];
    self.searcher.delegate = self;
    BMKGeoCodeSearchOption * geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc] init];
    //    geoCodeSearchOption.city= @"北京市";
    geoCodeSearchOption.address = address;
    BOOL flag = [_searcher geoCode:geoCodeSearchOption];
    if(flag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        NSLog(@"geo检索发送失败");
    }
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        //        NSLog(@"%@",result.address);
        //判断是那次的数据编码
        if([result.address isEqualToString:self.text_start.text])
        {
            self.start_latitude = result.location.latitude;
            self.start_longitude = result.location.longitude;
        }
        else
        {
            self.end_latitude = result.location.latitude;
            self.end_longitude = result.location.longitude;
        }
        
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

#pragma mark - 开始导航

- (void)startNavi
{
    
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    //起点 传入的是原始的经纬度坐标，若使用的是百度地图坐标，可以使用BNTools类进行坐标转化
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = self.start_longitude;
    startNode.pos.y = self.start_latitude;
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:startNode];
    
    //也可以在此加入1到3个的途经点
    
    //    BNRoutePlanNode *midNode = [[BNRoutePlanNode alloc] init];
    //    midNode.pos = [[BNPosition alloc] init];
    //    midNode.pos.x = 113.977004;
    //    midNode.pos.y = 22.556393;
    //    midNode.pos.eType = BNCoordinate_BaiduMapSDK;
    //    [nodesArray addObject:midNode];
    
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = self.end_longitude;
    endNode.pos.y = self.end_latitude;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Highway naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}

- (BOOL)checkServicesInited
{
    if(![BNCoreServices_Instance isServicesInited])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"引擎尚未初始化完成，请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate;
- (BOOL )textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length == 0)
    {//弹出提示框,搜索不能为空
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"起始内容不能为空" preferredStyle:(UIAlertControllerStyleAlert)];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        
        return NO;
        
    }
    else
    {
        //进行编码
        [self geocodingWithAddress:textField.text];
        //收回键盘
        [textField resignFirstResponder];
        
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self geocodingWithAddress:textField.text];
}

#pragma mark - button点击方法,

- (UIButton*)createButton:(NSString*)title target:(SEL)selector frame:(CGRect)frame
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [button setBackgroundColor:[UIColor whiteColor]];
    }else
    {
        [button setBackgroundColor:[UIColor clearColor]];
    }
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}
//模拟导航
- (void)simulateNavi:(UIButton*)button
{
    if (![self checkServicesInited]) return;
    _naviType = BN_NaviTypeSimulator;
    
    if(self.text_start.text.length != 0 && self.text_end.text.length != 0)
    {
        [self startNavi];
    }
    else
    {
        //弹出提示框,搜索不能为空
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"模拟导航时,起始内容不能为空" preferredStyle:(UIAlertControllerStyleAlert)];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
    }
}

//真实GPS导航
- (void)realNavi:(UIButton*)button
{
    if (![self checkServicesInited]) return;
    _naviType = BN_NaviTypeReal;
    
    if(self.text_start.text.length != 0 && self.text_end.text.length != 0)
    {
        [self geocodingWithAddress:self.text_start.text];
        [self geocodingWithAddress:self.text_end.text];
        [self startNavi];
    }
    else
    {
        //弹出提示框,搜索不能为空
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"GPS导航时,起始内容不能为空" preferredStyle:(UIAlertControllerStyleAlert)];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
    }
}


#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    //    NSLog(@"算路成功");
    //路径规划成功，开始导航
    [BNCoreServices_UI showNaviUI:_naviType delegete:self isNeedLandscape:YES];
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    //    NSLog(@"算路失败");
    if ([error code] == BNRoutePlanError_LocationFailed) {
        NSLog(@"获取地理位置失败");
    }
    else if ([error code] == BNRoutePlanError_LocationServiceClosed)
    {
        NSLog(@"定位服务未开启");
    }
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    //    NSLog(@"算路取消");
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航回调
-(void)onExitNaviUI:(NSDictionary*)extraInfo
{
    //    NSLog(@"退出导航");
}

//退出导航声明页面回调
- (void)onExitDeclarationUI:(NSDictionary*)extraInfo
{
    //    NSLog(@"退出导航声明页面");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask )supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - 布局 和 地理编码
- (void)p_setupView
{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"GPS导航";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 55, 30)];
    self.label1.backgroundColor = [UIColor clearColor];
    self.label1.text = @"起点:";
    self.label1.textAlignment = NSTextAlignmentCenter;
    self.label1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.label1];
    
    self.text_start = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.label1.frame) + 5, CGRectGetMinY(self.label1.frame), self.view.frame.size.width - 80 - 15, 30)];
    self.text_start.backgroundColor = [UIColor grayColor];
    self.text_start.placeholder = @"请输入要导航的起点:";
    self.text_start.clearButtonMode = UITextFieldViewModeAlways;
    self.text_start.leftViewMode = UITextFieldViewModeAlways;
    self.text_start.returnKeyType = UIReturnKeyDone;
    UIView * view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.text_start.leftView = view1;
    self.text_start.delegate = self;
    self.text_start.layer.cornerRadius = 5;
    self.text_start.layer.borderColor = [UIColor blackColor].CGColor;
    self.text_start.layer.borderWidth = 1;
    [self.view addSubview:self.text_start];
    
    self.label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.label1.frame) + 10, 55, 30)];
    self.label2.backgroundColor = [UIColor clearColor];
    self.label2.text = @"终点:";
    self.label2.textAlignment = NSTextAlignmentCenter;
    self.label2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.label2];
    
    self.text_end = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.label2.frame) + 5, CGRectGetMinY(self.label2.frame), self.view.frame.size.width - 80 - 15, 30)];
    self.text_end.backgroundColor = [UIColor grayColor];
    self.text_end.placeholder = @"请输入要导航的终点:";
    self.text_end.clearButtonMode = UITextFieldViewModeAlways;
    self.text_end.leftViewMode = UITextFieldViewModeAlways;
    self.text_end.delegate = self;
    UIView * view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    self.text_end.leftView = view2;
    self.text_end.returnKeyType = UIReturnKeyDone;
    self.text_end.layer.cornerRadius = 5;
    self.text_end.layer.borderColor = [UIColor blackColor].CGColor;
    self.text_end.layer.borderWidth = 1;
    [self.view addSubview:self.text_end];
    
    self.btn_simulatorNavi = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.btn_simulatorNavi.frame = CGRectMake(20, CGRectGetMaxY(self.label2.frame) + 15, self.view.frame.size.width - 35, 30);
    self.btn_simulatorNavi.backgroundColor = [UIColor brownColor];
    self.btn_simulatorNavi.layer.cornerRadius = 5;
    [self.btn_simulatorNavi setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [self.btn_simulatorNavi setTitle:@"开始模拟导航" forState:(UIControlStateNormal)];
    [self.view addSubview:self.btn_simulatorNavi];
    [self.btn_simulatorNavi addTarget:self action:@selector(simulateNavi:) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    self.btn_realNavi = [UIButton buttonWithType:(UIButtonTypeSystem)];
    self.btn_realNavi.frame = CGRectMake(20, CGRectGetMaxY(self.btn_simulatorNavi.frame) + 15, self.view.frame.size.width - 35, 30);
    self.btn_realNavi.backgroundColor = [UIColor cyanColor];
    self.btn_realNavi.layer.cornerRadius = 5;
    [self.btn_realNavi setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [self.btn_realNavi setTitle:@"进行真实导航" forState:(UIControlStateNormal)];
    [self.view addSubview:self.btn_realNavi];
    [self.btn_realNavi addTarget:self action:@selector(realNavi:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.label3 = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.btn_realNavi.frame) + 5, self.view.frame.size.width - 30, 70)];
    self.label3.text = @"如果导航的搜索不准确,请您加上导航地前加省市名,比如:北京故宫,沈阳故宫.\n对您使用的不便,我们深感抱歉.";
    self.label3.numberOfLines = 0;
    self.label3.font = [UIFont systemFontOfSize:13];
    self.label3.lineBreakMode = NSLineBreakByClipping;
    self.label3.textColor = [UIColor redColor];
    [self.view addSubview:self.label3];
}

#pragma mark - 当视图出现的时候,和消失的时候
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _geocodesearch.delegate = self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    _geocodesearch.delegate = nil;
}



@end
