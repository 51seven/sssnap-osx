//
//  AppDelegate.h
//  sssnap
//
//  Created by Christian Poplawski on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reachability.h"
#import "functions.h"
#import <OAuth2Client/NXOAuth2.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>{
    Reachability *internetReachable;
}
@property (unsafe_unretained) IBOutlet NSWindow *signInWindow;


- (IBAction)takeScreenshotItem:(id)sender;
- (IBAction)signIn:(id)sender;
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification;
+ (void) triggerNotification: (NSString *) imageUrl;
+ (void) takeScreenshot;
+ (BOOL) tokenIsValid;
- (void)testInternetConnection;



@property (weak) IBOutlet NSMenuItem *preferences;

@property (weak) IBOutlet NSTextField *signInErrorLabel;
@property (weak) IBOutlet NSMenuItem *takeScreenshotMenuItem;
@property (weak) IBOutlet NSMenuItem *noInternetConnection;

@property (weak) IBOutlet NSMenuItem *signIn;

@property (weak) IBOutlet NSTextField *usernameInput;
@property (weak) IBOutlet NSSecureTextField *passwordInput;



@property (weak) IBOutlet NSMenu *menuBarOutlet;
@property (strong, nonatomic) NSStatusItem *statusBar;

@end
