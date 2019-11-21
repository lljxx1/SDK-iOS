//
//  NativeExpressAdViewController.m
//  GDTMobApp
//
//  Created by michaelxing on 2017/4/17.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "NativeExpressAdViewController.h"
#import "MSNativeAdView.h"

@interface NativeExpressAdViewController ()<MSNativeAdDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *expressAdViews;

//@property (nonatomic, strong) MSNativeAdView *nativeExpressAd;

@property (weak, nonatomic) IBOutlet UILabel *widthLabel;
@property (weak, nonatomic) IBOutlet UISlider *widthSlider;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UISlider *heightSlider;
@property (weak, nonatomic) IBOutlet UISlider *adCountSlider;
@property (weak, nonatomic) IBOutlet UILabel *adCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *placementIdTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) CGFloat height1;

@property (assign, nonatomic) CGFloat height2;

@property (assign, nonatomic) CGFloat height3;


@end

@implementation NativeExpressAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.widthSlider.value = [UIScreen mainScreen].bounds.size.width;
    self.heightSlider.value = 50;
    self.adCountSlider.value = 3;
    
    self.widthLabel.text = [NSString stringWithFormat:@"宽：%@", @(self.widthSlider.value)];
    self.heightLabel.text = [NSString stringWithFormat:@"高：%@", @(self.heightSlider.value)];
    self.adCountLabel.text = [NSString stringWithFormat:@"count:%@", @(self.adCountSlider.value)];
    
    [self.widthSlider addTarget:self action:@selector(sliderPositionWChanged) forControlEvents:UIControlEventValueChanged];
    [self.heightSlider addTarget:self action:@selector(sliderPositionHChanged) forControlEvents:UIControlEventValueChanged];
    [self.adCountSlider addTarget:self action:@selector(sliderPositionCountChanged) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"nativeexpresscell"];
    
    
    [self refreshButton:nil];

}

- (IBAction)refreshButton:(id)sender {
    NSString *placementId = self.placementIdTextField.text.length > 0? self.placementIdTextField.text: self.placementIdTextField.placeholder;
    MSWS(ws);
    //请求信息流数据
    [MSNativeAdView requestMSAdData:^(MSAdModel* adModel){
        ws.height1 = [MSNativeAdView heightCellForRow:adModel nativeAdViewShowType:MSLeftImage];
        ws.height2 = [MSNativeAdView heightCellForRow:adModel nativeAdViewShowType:MSLeftImageNoButton];
        ws.height3 = [MSNativeAdView heightCellForRow:adModel nativeAdViewShowType:MSBottomImage];
        
        //主线程刷新页面
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.tableView reloadData];
        });
    }];
//    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:kGDTMobSDKAppId
//                                                         placementId:placementId
//                                                              adSize:CGSizeMake(self.widthSlider.value, self.heightSlider.value)];
//    self.nativeExpressAd.delegate = self;
//    [self.nativeExpressAd loadAd:(NSInteger)self.adCountSlider.value];
}


- (void)sliderPositionWChanged {
    self.widthLabel.text = [NSString stringWithFormat:@"宽：%.0f",self.widthSlider.value];
}

- (void)sliderPositionHChanged {
    self.heightLabel.text = [NSString stringWithFormat:@"高：%.0f",self.heightSlider.value];
}

- (void)sliderPositionCountChanged {
    self.adCountLabel.text = [NSString stringWithFormat:@"count:%d",(int)self.adCountSlider.value];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}



#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row ==0) {
        return self.height1;
    }
    else if (indexPath.row == 1){
        return self.height2;

    }
    else if (indexPath.row == 2){
        return self.height3;

    }
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"nativeexpresscell"
                                                                forIndexPath:indexPath];
        // Configure the cell...
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1
                                          reuseIdentifier: @"nativeexpresscell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        for (UIView *view in cell.subviews) {
            [view removeFromSuperview];
        }
    
        MSNativeAdView *ativeAdView = [[MSNativeAdView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) curController:self];
        ativeAdView.delegate = self;
        if (indexPath.row ==0) {
            ativeAdView.nativeAdViewShowType = MSLeftImage;
        }
        else if (indexPath.row == 1){
            ativeAdView.nativeAdViewShowType = MSLeftImageNoButton;
        }
        else if (indexPath.row == 2){
            ativeAdView.nativeAdViewShowType = MSBottomImage;
        }
        [cell addSubview:ativeAdView];
        cell.accessibilityIdentifier = @"nativeTemp_ad";
    return cell;
}

/**
 This method is called when native ad material loaded successfully.
 */
- (void)nativeAdDidLoad:(MSNativeAdView *)nativeAd{
    
}

/**
 This method is called when native ad materia failed to load.
 @param error : the reason of error
 */
- (void)nativeAd:(MSNativeAdView *)nativeAd didFailWithError:(NSError *)error{
    NSLog(@"%s%@",__FUNCTION__,error);
}

/**
 This method is called when native ad slot has been shown.
 */
- (void)nativeAdDidBecomeVisible:(MSNativeAdView *)nativeAd{
    
}

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeAdDidCloseOtherController:(MSNativeAdView *)nativeAd{
    
}

/**
 This method is called when native ad is clicked.
 */
- (void)nativeAdDidClick:(MSNativeAdView *)nativeAd{
    
}

@end
