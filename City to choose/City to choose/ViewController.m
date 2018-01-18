//  ViewController.m
//  City to choose
//  Created by 一笑 on 2018/1/17.

#import "ViewController.h"
#import "YXSearchTheCityView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray  *list = [[NSBundle mainBundle] loadNibNamed:@"YXSearchTheCityView" owner:nil options:nil];
    UIView *loadView = list.count ? [list lastObject] : [UIView new];
    YXSearchTheCityView *searchView = (YXSearchTheCityView *)loadView;
    searchView.frame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:searchView];
    [searchView loadData];//开始加载
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
