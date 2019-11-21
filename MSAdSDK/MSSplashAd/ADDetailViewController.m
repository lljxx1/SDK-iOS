//
//  ADDetailViewController.m
//  启动屏加启动广告页
//
//  Created by WOSHIPM on 16/8/29.
//  Copyright © 2016年 WOSHIPM. All rights reserved.
//

#import "ADDetailViewController.h"
#import "MSCommCore.h"

@interface ADDetailViewController ()<UIWebViewDelegate>
@property(nonatomic, strong)UIWebView *webView;
@property(nonatomic, strong)UILabel *titleLabel;
@end

@implementation ADDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.title = @"广告详情页";
//    self.navigationController.navigationBar.translucent = NO;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    view.frame  = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 64) ;

    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"";
    label.font = [UIFont systemFontOfSize:17];
    [label sizeToFit];
    label.frame  = CGRectMake(120, 35, [UIScreen mainScreen].bounds.size.width-120, 16) ;
    self.titleLabel = label;
    [view addSubview:self.titleLabel];

    // 2.跳过按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, 35-14, 44, 44);
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"BUAdSDK.bundle/bu_leftback"] forState:UIControlStateNormal];
    backButton.imageView.contentMode=UIViewContentModeCenter;
    [view addSubview:backButton];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(70, 35-14, 44, 44);
    [closeButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"BUAdSDK.bundle/bu_close"] forState:UIControlStateNormal];
    closeButton.imageView.contentMode=UIViewContentModeCenter;
    [view addSubview:closeButton];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(view.frame))];
    _webView.scrollView.bounces = NO;
    _webView.delegate = self;
    [_webView setScalesPageToFit:NO];
    [self.view addSubview:_webView];
    MSWS(ws);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSURL *url = [NSURL URLWithString:ws.URLString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.webView loadRequest:[NSURLRequest requestWithURL:url]];
        });
    });
}

//在代理webViewDidFinishLoad方法中
-(void) webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible =NO;
    self.titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //获取当前页面的title
}
//关闭窗口
- (void)closeVC{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
//返回上一级
- (void)dismiss{
    if(self.webView.canGoBack){
        //返回上级页面
        [self.webView goBack];
    }
    else{
        [self closeVC];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
