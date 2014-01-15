//
//  AppDelegate.h
//  sssnap
//
//  Created by Christian Poplawski on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Reachability.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>{
    Reachability *internetReachable;
}
@property (unsafe_unretained) IBOutlet NSWindow *signInWindow;


- (IBAction)takeScreenshotItem:(id)sender;
- (IBAction)signIn:(id)sender;
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification;
+ (void) triggerNotification: (NSString *) imageUrl;
+ (NSString *) takeScreenshot;


@property (weak) IBOutlet NSTextField *usernameLabel;
@property (weak) IBOutlet NSTextField *passwordLabel;

@property (weak) IBOutlet NSMenuItem *signIn;

@property (weak) IBOutlet NSTextField *usernameInput;
@property (weak) IBOutlet NSSecureTextField *passwordInput;



@property (weak) IBOutlet NSMenu *menuBarOutlet;
@property (strong, nonatomic) NSStatusItem *statusBar;

@end
