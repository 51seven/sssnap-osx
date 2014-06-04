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

- (IBAction)takeScreenshotItem:(id)sender;
- (IBAction)signIn:(id)sender;
- (IBAction)logoutButton:(id)sender;
- (IBAction)mySnapsItem:(id)sender;
- (IBAction)createAccountItem:(id)sender;
- (IBAction)preferencesMenuItemClick:(id)sender;
- (IBAction)signInMenuItemClick:(id)sender;
- (IBAction)preferencesStartupCheckboxAction:(id)sender;

- (BOOL) userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification;

+ (void) triggerNotification: (NSString *) imageUrl;
- (void) takeScreenshot;
- (void) testInternetConnection;
- (void) changeStatusBarIcon: (int *) percentage;
- (void) resetStatusBarIcon;
- (BOOL) appIsLoginItem;

@property (weak) IBOutlet NSButton *pref_retinaScale;

@property (weak) IBOutlet NSWindow *signInWindow;
@property (weak, nonatomic) IBOutlet NSWindow *preferencesWindow;

@property (weak) IBOutlet NSTextField *signInErrorLabel;
@property (weak) IBOutlet NSTextField *label_accountmail;

@property (weak) IBOutlet NSButtonCell *preferencesStartupCheckbox;
@property (weak) IBOutlet NSMenuItem *takeScreenshotMenuItem;
@property (weak) IBOutlet NSMenuItem *noInternetConnection;
@property (weak) IBOutlet NSMenuItem *preferences;
@property (weak) IBOutlet NSMenuItem *createAccountItem;
@property (weak) IBOutlet NSMenuItem *signIn;
@property (weak) IBOutlet NSMenuItem *mySnapsItem;

@property (weak) IBOutlet NSTextField *usernameInput;
@property (weak) IBOutlet NSSecureTextField *passwordInput;

@property (weak) IBOutlet NSMenu *menuBarOutlet;
@property (strong, nonatomic) NSStatusItem *statusBar;

@end
