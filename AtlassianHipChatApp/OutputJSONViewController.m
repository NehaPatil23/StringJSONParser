//
//  OutputJSONViewController.m
//  AtlassianHipChatApp
//
//  Created by Neha Patil on 26/04/2016.
//  Copyright © 2016 University. All rights reserved.
//

#import "OutputJSONViewController.h"

@interface OutputJSONViewController ()

@property (weak, nonatomic) IBOutlet UILabel *outputLbl;

@end

@implementation OutputJSONViewController
@synthesize outputString;

- (void)viewDidLoad {
    [super viewDidLoad];
    _outputLbl.text = [NSString stringWithFormat:@"%@",outputString];
    // Do any additional setup after loading the view.
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
