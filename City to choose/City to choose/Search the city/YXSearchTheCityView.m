//  YXSearchTheCityView.m

#import "YXSearchTheCityView.h"
#import <MapKit/MapKit.h>
#import <Masonry.h>
#import "YXForInformationOnTheCity.h"
#import "YXDistrictModel.h"
#import "YXSearchCityCell.h"
#import "YXPublicServiceFactory.h"
#import "UIView+Extension.h"

#define StrValid(f) (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define ValidStr(f) StrValid(f)
#define WidthScale(number) ([UIScreen mainScreen].bounds.size.width/414.*(number))
//纵向比例
#define HeightScale(number) ([UIScreen mainScreen].bounds.size.height/736.*(number))
#define IOS8 [[[UIDevice currentDevice] systemVersion]floatValue]>=8.0
// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]


#define LZWidth                   [UIScreen mainScreen].bounds.size.width
#define LZHeight                  [UIScreen mainScreen].bounds.size.height

#define LZColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define YXStatusBarH ([UIApplication sharedApplication].statusBarFrame.size.height)
#define YXNavigationBarH (YXStatusBarH + 44)

//高德wed api Kay
#define   kLbsMAMapKay @"c72932eee49f7cd839e64a2d9871d442"

@interface YXSearchTheCityView () <UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,UITextFieldDelegate,YXPublicServiceFactoryDelegate>

/**搜索背景View*/
@property (weak, nonatomic) IBOutlet UIView           *sSearchBgView;

/**定位lab*/
@property (weak, nonatomic) IBOutlet UILabel          *sPositioningLb;

/**当前城市*/
@property (weak, nonatomic) IBOutlet UILabel          *currCityLb;

/**关键字输入框*/
@property (weak, nonatomic) IBOutlet UITextField *stheKeywordFl;

/**定位背景高度*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locBagHightLayout;

/**阴影距底部位置*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomImageLayout;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTableLayout;


/**是否在搜索状态*/
@property (nonatomic, assign)  BOOL  isSearch;

/**关键字输入框背景View*/
@property (weak, nonatomic) IBOutlet UIView *keyWordBgview;

/**返回*/
@property (weak, nonatomic) IBOutlet UIButton *sreturnBt;

/**返回*/
@property (weak, nonatomic) IBOutlet UIButton         *fallbackBt;

/**数据展示tab*/
@property (weak, nonatomic) IBOutlet UITableView      *seachTableView;

@property (nonatomic, strong) YXForInformationModel   *informationModel;

/**定位管理*/
@property (nonatomic, strong) CLLocationManager        *locationManager;

/**当前城市信息模型*/
@property (nonatomic, strong) YXDistrictModel          *currentCityModel;

/**搜索结果*/
@property (nonatomic, strong) NSMutableArray           *searcResults;

/**阴影*/
@property (weak, nonatomic) IBOutlet UIImageView *shadowImageView;

/**放大镜*/
@property (weak, nonatomic) IBOutlet UIImageView *searchIm;


@end

@implementation YXSearchTheCityView

- (void)configSubView
{
    [self.sreturnBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.keyWordBgview).mas_offset(0);
        make.left.equalTo(self.keyWordBgview).mas_offset(0);
        make.height.mas_equalTo(HeightScale(30));
        make.width.mas_equalTo(WidthScale(40));
    }];
    
    [self.sSearchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.keyWordBgview).mas_offset(0);
        make.left.equalTo(self.sreturnBt).mas_offset(WidthScale(40));
        make.right.equalTo(self.keyWordBgview).mas_equalTo(-WidthScale(20));
        make.height.mas_equalTo(HeightScale(30));
    }];
    
    [self.searchIm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sSearchBgView).mas_equalTo(WidthScale(10));
        make.width.mas_equalTo(HeightScale(15));
        make.height.mas_equalTo(HeightScale(15));
        make.centerY.equalTo(self.sSearchBgView);
    }];
    
    [self.stheKeywordFl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchIm).mas_equalTo(WidthScale(30));
        make.right.equalTo(self.sSearchBgView).mas_offset(-WidthScale(20));
        make.top.equalTo(self.sSearchBgView).mas_offset(0);
        make.bottom.equalTo(self.sSearchBgView).mas_offset(0);
    }];
    
    [self.sPositioningLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sSearchBgView).mas_equalTo(HeightScale(45));
        make.left.equalTo(self.keyWordBgview).mas_equalTo(WidthScale(25));
        make.width.mas_equalTo(WidthScale(50));
        make.height.mas_equalTo(HeightScale(15));
    }];

    [self.currCityLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sPositioningLb).mas_equalTo(HeightScale(30));
        make.left.equalTo(self.keyWordBgview).mas_equalTo(WidthScale(25));
        make.width.mas_equalTo(WidthScale(80));
        make.height.mas_equalTo(HeightScale(30));
    }];

    [self.shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.keyWordBgview).mas_equalTo(0);
        make.left.equalTo(self.keyWordBgview).mas_offset(0);
        make.right.equalTo(self.keyWordBgview).mas_offset(0);
        make.height.mas_offset(HeightScale(28));
    }];

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self configSubView];
    if ([self.stheKeywordFl isFirstResponder]) {
        NSLog(@"是第一响应者");
        [self searchLayout];
    }else{
        NSLog(@"不是第一响应者");
        [self uploadLayout];
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
    
    ViewRadius(self.currCityLb, 5);
    
    self.seachTableView.delegate = self;
    self.seachTableView.dataSource = self;
    self.stheKeywordFl.delegate = self;
    
    self.informationModel = [[YXForInformationModel alloc]init];
    self.currentCityModel = [[YXDistrictModel alloc]init];
    
    //action
    [self.fallbackBt addTarget:self action:@selector(fallbackBtAction) forControlEvents:UIControlEventTouchUpInside];
    [self.sreturnBt addTarget:self action:@selector(fallbackBtAction) forControlEvents:UIControlEventTouchUpInside];
    
    //输入文字监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stheKeywordtextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    //键盘弹出监听
    [YXPublicServiceFactory sharedServiceFactory].delegate = self;
    [[YXPublicServiceFactory sharedServiceFactory] lookAtTheKeyboardPosition];
    
    //开启定位
    [self locationStart];
    
    //触摸手势
    UITapGestureRecognizer   *touTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popCityView)];
    [self.currCityLb addGestureRecognizer:touTap];
    
}

- (void)popCityView{
    
    [self.delegate  cityNameTitle:self.currentCityModel.name cityCode:self.currentCityModel.citycode];
}

#pragma mark YXPublicServiceFactoryDelegate
/**将要弹出*/
- (void)keyboardWillShow:(CGRect)rect keyboardAnimateDur:(CGFloat)keyboardAnimateDur{
    CGRect frame = CGRectMake(0, 0, LZWidth, LZHeight - rect.size.height);
    self.frame = frame;
}

/**将要收回*/
- (void)keyboardWillHide{}

/**已经收回*/
- (void)keyboardDidHideSc{
    CGRect frame = CGRectMake(0, 0, LZWidth, LZHeight);
    self.frame = frame;
}

#pragma mark /**搜索*/
- (void)stheKeywordtextDidChange:(NSNotification *)notification {
    if (self.stheKeywordFl!=notification.object) {
        return;
    }
    
    UITextField * textField = (UITextField *)notification.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            // @"[a-zA-Z\\u4e00-\\u9fa5]+" 正则只有英文和中文
            textField.text = [self processWithString:toBeString regularExpression:@"[a-zA-Z\\u4e00-\\u9fa5]+"];
            if ([textField.text length]>10) {
                [self endEditing:YES];
                textField.text = [textField.text substringToIndex:10];
            }
            [self searchTextDidChang:textField.text];
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
    }
}

- (void)searchTextDidChang:(NSString *)searchText{

    if (searchText.length == 0) {
        self.isSearch = NO;
    }else{
        self.isSearch = YES;
        [self.searcResults removeAllObjects];
        for (NSArray  *list in self.informationModel.dateList){
            
            for (YXDistrictModel *city  in list) {
                if ([city.name containsString:searchText] || [city.pinyin containsString:searchText] || [city.initials containsString:searchText]) {
                    [self.searcResults addObject:city];
                }

            }
        
        }
        [self reloadData];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self searchLayout];
    [self reloadData];//更新
    return YES;
}

/**是否需要更新信息*/
- (BOOL)whetherNeedToUpdateTheInformation{
    
    BOOL flage = self.informationModel.dateList.count ? YES : NO;
    
    return flage;
}

- (void)loadData{
    
    if (![self whetherNeedToUpdateTheInformation]) {
        self.stheKeywordFl.enabled = NO;
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
         dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            //获取数据
            [[YXForInformationOnTheCity alloc] initWithAPIKey:kLbsMAMapKay citySubdistrictType:YXSubdistrictAreaType citiesWithCompletion:^(YXForInformationModel * _Nullable citieInforModel, NSError * _Nullable error) {
                self.informationModel = citieInforModel;
                CFAbsoluteTime useTime = (CFAbsoluteTimeGetCurrent() - startTime);
                NSLog(@"总耗时 %f ms", useTime *1000.0);
                [self reloadData];
            }];
            
        });
    }
}

- (void)configCurrentCityDataWith:(NSString *)searchText{
    if (ValidStr(searchText)) {
        for (NSArray  *list in self.informationModel.dateList){
            for (YXDistrictModel *city  in list) {
                if ([city.name containsString:searchText] || [city.pinyin containsString:searchText] || [city.initials containsString:searchText]) {
                    self.currentCityModel = city;
                }
            }
        }
    }
}

- (void)reloadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ValidStr(self.currCityLb.text)) {
            [self  configCurrentCityDataWith:self.currCityLb.text];
        }
        self.stheKeywordFl.enabled = YES;
        self.seachTableView.contentInset = self.isSearch ? UIEdgeInsetsMake(-45, 0, 0, 0) : UIEdgeInsetsMake(0, 0, 0, 0);
        [self.seachTableView reloadData];
    });
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.isSearch) {
        return nil;
    }
    return self.informationModel.nameKeyList;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.isSearch) {
        return @"";
    }
    return self.informationModel.nameKeyList[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.isSearch&&self.searcResults.count) {
        return 1;
    }
   return  self.informationModel.dateList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *ar =  self.informationModel.dateList[section];
    if (self.isSearch) {
        return self.searcResults.count;
    }
    return ar.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YXSearchCityCell  *cell = [[YXSearchCityCell alloc]initWithTableView:tableView];
    if (self.isSearch&&self.searcResults.count) {
        YXDistrictModel *mo = self.searcResults[indexPath.row];
        [cell configTitleString:mo.name];
        cell.lineLb.hidden = YES;
    }else{
        NSMutableArray *list =  self.informationModel.dateList[indexPath.section];
        YXDistrictModel *model =  list[indexPath.row];
        [cell configTitleString:model.name];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.isSearch) {
        return 0;
    }
    return 29.5f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.isSearch) {
        return 0;
    }
    return 0.5f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if (self.isSearch) {
        YXDistrictModel *mo = self.searcResults[indexPath.row];
//        self.cityCode = mo.citycode;
        [self.delegate cityNameTitle:mo.name cityCode:mo.citycode];
    }else{
        NSMutableArray *list =  self.informationModel.dateList[indexPath.section];
        YXDistrictModel *model =  list[indexPath.row];
//        self.cityCode = model.citycode;
        [self.delegate cityNameTitle:model.name cityCode:model.citycode];
    }
}

//- (NSString *)getCityCode{
//    return self.cityCode;
//}

#pragma mark  开始定位

-(void)locationStart{
    //判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init] ;
        self.locationManager.delegate = self;
        //设置定位精度
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;//每隔多少米定位一次（这里的设置为每隔百米)
        if (IOS8) {
            //使用应用程序期间允许访问位置数据
            [self.locationManager requestWhenInUseAuthorization];
        }
        // 开始定位
        [self.locationManager startUpdatingLocation];
    }else {
        //提示用户无法进行定位操作
        NSLog(@"%@",@"定位服务当前可能尚未打开，请设置打开！");
    }
}

#pragma mark - CoreLocation Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [self.locationManager stopUpdatingLocation];
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    
    //获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count >0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //获取城市
             NSString *currCity = placemark.locality;
             if (!currCity) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 currCity = placemark.administrativeArea;
             }
             self.currCityLb.text = currCity;
             self.currCityLb.backgroundColor = LZColorFromRGB(0x018ffd);
             if (!ValidStr(self.currentCityModel.citycode)&&self.informationModel.dateList.count) {
                 [self configCurrentCityDataWith:currCity];
             }
         } else if (error ==nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }else if (error !=nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error.code ==kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.fallbackBt.hidden   = NO;
    self.sreturnBt.hidden  = YES;
    self.locBagHightLayout.constant = HeightScale(125);
    self.isSearch = NO;
    [UIView animateWithDuration:0.01 animations:^{
        self.keyWordBgview.y = YXNavigationBarH;
    }];
    [self endEditing:YES];
}

- (void)fallbackBtAction
{
    [self endEditing:YES];
    [self.delegate cancelSearchTheCity];
    [self uploadLayout];
}

- (void)uploadLayout
{
    self.fallbackBt.hidden   = NO;
    self.sreturnBt.hidden  = YES;
    self.locBagHightLayout.constant = HeightScale(125);
    self.shadowImageView.hidden = YES;
    self.isSearch = NO;
    self.height = LZHeight;
    self.seachTableView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    self.topTableLayout.constant = 0;
    self.sPositioningLb.hidden = NO;
    self.currCityLb.hidden = NO;
    [UIView animateWithDuration:0.01 animations:^{
        self.keyWordBgview.y = YXNavigationBarH;
    }];
    self.stheKeywordFl.text = @"";
    [self.searcResults removeAllObjects];
    [self.seachTableView reloadData];
}

- (void)searchLayout
{
    self.fallbackBt.hidden   = YES;
    self.sreturnBt.hidden  = NO;
    self.locBagHightLayout.constant = HeightScale(64);
    self.shadowImageView.hidden = NO;
    self.sPositioningLb.hidden = YES;
    self.currCityLb.hidden = YES;
    self.topTableLayout.constant = -(HeightScale(105) - HeightScale(64));
    self.isSearch = YES;
    [UIView animateWithDuration:0.01 animations:^{
        self.keyWordBgview.y = 20;
    }];
}


-(NSMutableArray *)searcResults
{
    if (!_searcResults) {
        _searcResults = [NSMutableArray new];
    }
    return _searcResults;
}
/**
 *  利用正则表达式将字符串中的特定字符拼接起来并传出
 *
 *  @param string            传入的字符串
 *  @param regularExpression 传入的正则表达式
 *
 *  @return 返回一个内含所有符合条件的字符串
 */
- (NSString *)processWithString:(NSString *)string regularExpression:(NSString *)regularExpression {
    
    // 创建一个可变字符串,用来拼接符合条件的字符
    NSMutableString *mString = [[NSMutableString alloc] init];
    // 创建一个错误对象
    NSError *error;
    // 正则
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:&error];
    // 如果正则没有错误进行内部的代码
    if (!error) {
        // 将符合条件的字符位置记录到数组中
        NSArray *array = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        // 利用数组中的位置将所有符合条件的字符拼接起来
        for (NSTextCheckingResult *result in array) {
            NSRange range = [result range];
            NSString *mStr = [string substringWithRange:range];
            [mString appendString:mStr];
        }
        return mString;
    } else {
        NSLog(@"error is %@", error);
    }
    return nil;
}

@end
