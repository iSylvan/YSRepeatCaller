//
//  ViewController.m
//  YSRepeatCallerExample
//
//  Created by yt_liyanshan on 2017/12/8.
//

#import "ViewController.h"
#import "YSRepeatCaller.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *logLable;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@property(assign, nonatomic) NSInteger runCount;
@property(assign, nonatomic) BOOL viewRepe;
@end

@implementation ViewController
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.statusBtn addTarget:self action:@selector(statusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.statusBtn setTitle:@"star" forState:UIControlStateNormal];
    [self.statusBtn setTitle:@"stop" forState:UIControlStateSelected];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.viewRepe) {
        [self startRepeatCallMethod2:@selector(doSomeThing)](@1);
    }
}

-(void)statusBtnClick:(UIButton *)statusBtn{
    statusBtn.selected = !statusBtn.selected;
    __weak typeof (self) wself = self;
    if (statusBtn.selected) {
        [self startRepeatCallBlock2:^{
            [wself doSomeThing];
        }](@1);
    }else{
        [self stopRepeatCallBlock];
    }

}

-(void)doSomeThing{
    self.runCount ++;
    self.logLable.text = [NSString stringWithFormat:@"run count %zd",self.runCount];
    NSLog(@"%@",self.logLable.text);
    NSLog(@"%@",self.repeatCallerWithBlock);
    NSLog(@"%@",[self repeatCallerWithMethod:@selector(doSomeThing)]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)dealloc{

}

@end
