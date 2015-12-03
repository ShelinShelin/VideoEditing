//
//  PlayViewController.m
//  MediaHandleDemo
//
//  Created by Shelin on 15/11/25.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import "PlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface PlayViewController ()
{
    MPMoviePlayerController *_moviePlayer;
}
@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString* videoName = @"export.mov";
    
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
//    NSLog(@"-------%@",exportPath);
    
    _moviePlayer = [[MPMoviePlayerController alloc] init];
    
    _moviePlayer.view.frame = self.view.bounds;
    _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_moviePlayer.view];
    _moviePlayer.contentURL = [NSURL fileURLWithPath:exportPath];
    [_moviePlayer play];
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
