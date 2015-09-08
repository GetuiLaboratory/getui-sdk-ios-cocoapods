//
//  SendMessageController.m
//  SdkTester
//
//  Created by huang.haiyang on 13-4-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "SendMessageController.h"
#import "AppDelegate.h"

@implementation SendMessageController

@synthesize contentView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)send:(id)sender {
    NSString *content = contentView.text;    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSError *err = nil;
    [delegate sendMessage:[content dataUsingEncoding:NSUTF8StringEncoding] error:&err];
    if (err) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:[NSString stringWithFormat:@"send failed:%@", [err localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

@end
