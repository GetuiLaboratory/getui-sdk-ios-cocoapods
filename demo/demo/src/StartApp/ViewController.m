//
//  ViewController.m
//  StartApp
//
//  Created by CoLcY on 12-1-4.
//  Copyright (c) 2012年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)logMsg:(NSString *)aMsg
{
    CGPoint p = [mMsgView contentOffset];
    
    NSString *response = [NSString stringWithFormat:@"%@\n%@", mMsgView.text, aMsg];
    [mMsgView setText:response];
    
    [mMsgView setContentOffset:p animated:NO];
    [mMsgView scrollRangeToVisible:NSMakeRange([mMsgView.text length], 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
