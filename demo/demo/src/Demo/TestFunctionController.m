//
//  TestFunctionController.m
//  SdkTester
//
//  Created by user on 12-2-7.
//  Copyright (c) 2012年 Gexin Interactive (Beijing) Network Technology Co.,LTD. All rights reserved.
//

#import "TestFunctionController.h"

#import "AppDelegate.h"

@implementation TestFunctionController

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
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 300)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)setDeviceToken:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate setDeviceToken:_deviceTokenView.text];
}

- (IBAction)setTag:(id)sender
{
    NSString *tagName = _tagNameView.text;
    NSArray *tagNames = [tagName componentsSeparatedByString:@","];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSError *err = nil;
    if (![delegate setTags:tagNames error:&err]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:[NSString stringWithFormat:@"setTag failed:%@", [err localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (IBAction)bindAlias:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate bindAlias:_aliasView.text];
}

- (IBAction)unbindAlias:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate unbindAlias:_aliasView.text];
}

- (void)dealloc
{
    [_deviceTokenView release];
    [_tagNameView release];
    [_scrollView release];
    
    [_aliasView release];
    [super dealloc];
}

@end
