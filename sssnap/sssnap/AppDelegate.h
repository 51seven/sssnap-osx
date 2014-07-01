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

// Statusbar menu
- (IBAction)signIn:(id)sender;
- (IBAction)signInMenuItemClick:(id)sender;
- (IBAction)createAccountItem:(id)sender;

- (IBAction)takeScreenshotItem:(id)sender;
- (IBAction)mySnapsItem:(id)sender;
- (IBAction)preferencesMenuItemClick:(id)sender;
- (IBAction)logoutButton:(id)sender;

- (IBAction)preferencesStartupCheckboxAction:(id)sender;
- (IBAction)pref_retinaScale:(id)sender;
- (IBAction)pref_showDesktopNotification:(id)sender;
- (IBAction)pref_CopyLinkToClipboard:(id)sender;

// Preferences Toolbar
@property (weak) IBOutlet NSToolbar *preferencesToolbar;
- (IBAction)accountPreferences:(id)sender;
- (IBAction)generalPreferences:(id)sender;
- (IBAction)aboutPreferences:(id)sender;

@property (weak) IBOutlet NSToolbarItem *accountPreferences;
@property (weak) IBOutlet NSToolbarItem *generalPreferences;
@property (weak) IBOutlet NSToolbarItem *aboutPreferences;

@property (weak) IBOutlet NSView *preferencesWrapperView;
    @property (weak) IBOutlet NSView *preferencesGeneralView;
    @property (weak) IBOutlet NSView *preferencesAccountView;
        @property (weak) IBOutlet NSTextField *snapsMadeLabel;
        @property (weak) IBOutlet NSLevelIndicator *quotaBar;
        @property (weak) IBOutlet NSTextField *quotaBarLabel;

    @property (weak) IBOutlet NSView *preferencesAboutView;


- (BOOL) userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification;

+ (void) triggerNotification: (NSString *) imageUrl;
+ (void) takeScreenshot;
- (void) testInternetConnection;
- (void) changeStatusBarIcon: (int *) percentage;
- (void) resetStatusBarIcon;
- (BOOL) appIsLoginItem;

- (void) menuWillOpen:(NSMenu *)menu;
- (void) menuDidClose:(NSMenu *)menu;

@property (weak) IBOutlet NSButtonCell *pref_showDesktopNotification;
@property (weak) IBOutlet NSButtonCell *preferencesStartupCheckbox;
@property (weak) IBOutlet NSButtonCell *pref_retinaScale;
@property (weak) IBOutlet NSButtonCell *pref_CopyLinkToClipboard;

@property (weak) IBOutlet NSWindow *signInWindow;
@property (weak, nonatomic) IBOutlet NSWindow *preferencesWindow;

@property (weak) IBOutlet NSTextField *signInErrorLabel;
@property (weak) IBOutlet NSTextField *label_accountmail;
@property (weak) IBOutlet NSImageView *userAvatar;

@property (weak) IBOutlet NSMenuItem *takeScreenshotMenuItem;
@property (weak) IBOutlet NSMenuItem *noInternetConnection;
@property (weak) IBOutlet NSMenuItem *preferences;
@property (weak) IBOutlet NSMenuItem *createAccountItem;
@property (weak) IBOutlet NSMenuItem *signIn;
@property (weak) IBOutlet NSMenuItem *mySnapsItem;
@property (weak) IBOutlet NSMenuItem *seperatorRecentSnapsBegin;

@property (weak) IBOutlet NSTextField *usernameInput;
@property (weak) IBOutlet NSSecureTextField *passwordInput;

@property (weak) IBOutlet NSMenu *menuBarOutlet;
@property (strong, nonatomic) NSStatusItem *statusBar;



@end
