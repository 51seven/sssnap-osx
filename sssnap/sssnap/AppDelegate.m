//
//  AppDelegate.m
//  sssnap
//
//  Created by Sven Schiffer 30.05.2014
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "AppDelegate.h"
#import "sendPost.h"
#import <Carbon/Carbon.h>

@implementation AppDelegate{

}

@synthesize statusBar = _statusBar;

- (void)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(insertNewline:)) {
        [self proceedLogin];
    }
    else if (commandSelector == @selector(deleteForward:)) {
        //Do something against DELETE key
        
    }
    else if (commandSelector == @selector(deleteBackward:)) {
        //Do something against BACKSPACE key
        
    }
    else if (commandSelector == @selector(insertTab:)) {
        //Do something against TAB key
    }
}

//
//  All code in here is executed immediately after the
//  application has finished loading.
//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_signInErrorLabel setStringValue:[NSString stringWithFormat:@"%@", @""]];
    
    // Found no Userdata = User is logged out
    if(![[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] count]){
        NSLog(@"AccountStore is empty.");
        
        [_signInErrorLabel setHidden: YES];
        [_preferences setEnabled: NO];
        [_takeScreenshotMenuItem setEnabled: NO];
        [_mySnapsItem setEnabled: NO];
        [_signInWindow makeKeyAndOrderFront:_signInWindow];
        [_label_accountmail setStringValue: @"No user logged in."];
        [_createAccountItem setHidden: NO];
        
        self.passwordInput.delegate = self;
        self.statusBar.image = [NSImage imageNamed: @"icon-disabled"];
    }
    // User already logged in
    else {
        NSLog(@"Found %lu Account(s) in Auth2AccountStore: ", [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] count]);
        
        [_signIn setHidden: YES];
        [_preferences setEnabled: YES];
        [_takeScreenshotMenuItem setEnabled: YES];
        [_mySnapsItem setEnabled: YES];
        [_signInWindow close];
        [_createAccountItem setHidden: YES];
    
        //NSLog(@"%@", [[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] lastObject]);
        
        
        [_label_accountmail setStringValue: @"test@test.de"];
        
        self.statusBar.image = [NSImage imageNamed: @"icon"];
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate: self];
}

- (void) proceedLogin {
    [[NXOAuth2AccountStore sharedStore] setClientID:@"testid"
                                             secret:@"testsecret"
                                   authorizationURL:[NSURL URLWithString:@"http://51seven.de:8888/api/oauth/token"]
                                           tokenURL:[NSURL URLWithString:@"http://51seven.de:8888/api/oauth/token"]
                                        redirectURL:[NSURL URLWithString:@"http://51seven.de:8888/"]
                                     forAccountType:@"password"];
    
    NSString *username = [_usernameInput stringValue];  // get username by login-form
    NSString *password = [_passwordInput stringValue];  // get password by login-form
    
    // Request access
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:@"password"
                                                              username:username
                                                              password:password];
    
    // On Sucess
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification) {
                                                      [_signIn setHidden: YES];
                                                      [_signInWindow close];
                                                      [_takeScreenshotMenuItem setEnabled:YES];
                                                      [_takeScreenshotMenuItem setHidden: NO];
                                                      [_preferences setHidden: NO];
                                                      NSLog(@"Successfully logged in.");
                                                  }];
    
    // On Failure
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification) {
                                                      NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                      [_signInErrorLabel setHidden: NO];
                                                      [_signInErrorLabel setStringValue: [NSString stringWithFormat: @"%@", [error localizedDescription]]];
                                                      NSLog(@"Failed to login: \n%@", error);
                                                  }];
}

- (IBAction)takeScreenshotItem:(id)sender {
    [AppDelegate takeScreenshot];
}

//
//  Behavior of the Sign In button.
//  Keeps the Sign In window open until successful login.
//
- (IBAction)signIn:(id)sender {
    [self proceedLogin];
}

- (IBAction)mySnapsItem:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://51seven.de:8888/snap/list"]];
}

- (IBAction)createAccountItem:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString:@"http://51seven.de:8888/user/register"]];
}

//  Override AwakeFromNib
- (void) awakeFromNib {
    
    //  Register the Hotkeys
    EventHotKeyRef gMyHotKeyRef;
    EventHotKeyID gMyHotKeyID;
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    
    InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,NULL,NULL);
    
    //  Name and ID of Hotkey
    gMyHotKeyID.signature='htk1';
    gMyHotKeyID.id=1;
    
    // Register the Hotkey
    // Path to file with keyboard codes:
    // /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
    RegisterEventHotKey(0x15, shiftKey+optionKey, gMyHotKeyID,
                        GetApplicationEventTarget(), 0, &gMyHotKeyRef);
    
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.menu = self.menuBarOutlet;
    self.statusBar.highlightMode = YES;
}

- (void)changeStatusBarIcon:(int *) percentage {
    
    // ToDo: Check if icon exists
    self.statusBar.image = [NSImage imageNamed: [NSString stringWithFormat: @"icon-progress-%d", percentage]];
}

- (void) resetStatusBarIcon {
    self.statusBar.image = [NSImage imageNamed: @"icon"];
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
    
    //Take the Screenshot
    if([[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] count]) {
        [AppDelegate takeScreenshot];
    }
    else {
        NSLog(@"Screenshot is forbidden because no User is logged in.");
    }
    return noErr;
}


+ (void) takeScreenshot {
    
    //  Starts Screencapture Process
    NSTask *theProcess;
    theProcess = [[NSTask alloc] init];
    [theProcess setLaunchPath:@"/usr/sbin/screencapture"];
    
    //  Array with Arguments to be given to screencapture
    NSArray *arguments = [NSArray arrayWithObjects:@"-i", @"-c", @"image.jpg", nil];
    
    //  Apply arguments and start application
    [theProcess setArguments:arguments];
    [theProcess launch];
    [theProcess waitUntilExit];
    
    //NSLog(@"%ld", [theProcess terminationReason]);
    
    if ([theProcess terminationStatus] == 0) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSArray *classes = [[NSArray alloc] initWithObjects: [NSImage class], nil];
        NSDictionary *options = [NSDictionary dictionary];
        NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
        
        if ([copiedItems count]) {
            if([[copiedItems objectAtIndex:0] isKindOfClass:[NSImage class]]) {
                NSImage *image = [copiedItems objectAtIndex:0];
                
                NSSize imageSize = [image size]; // Get the Image Size
                NSImageRep *imgrep = [[image representations] objectAtIndex:0];
                NSSize imagePixelSize = NSMakeSize(imgrep.pixelsWide, imgrep.pixelsHigh);
                
                if(imageSize.width < imagePixelSize.width) {
                    NSLog(@"Downscaling Retina Screenshot...");// imageSize(%f / %f) and pixelSize(%f / %f)", imageSize.width, imageSize.height, imagePixelSize.width, imagePixelSize.height);
                    
                    image = [functions downscaleToNonRetina: image];
                }
                
                sendPost *post = [[sendPost alloc] init];
                [post uploadImage:image];
            }
        }
        else {
            NSLog(@"Screencaputre aborted.");
        }
    }
}


//  Checks if we have an internet connection or not
- (void)testInternetConnection
{
    internetReachable = [Reachability reachabilityWithHostname:@"51seven.de"];
    
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach) {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Connection: ONLINE");
            [_noInternetConnection setHidden: YES];
            
            self.statusBar.image = [NSImage imageNamed: @"icon"];
            
            //Set takeScreenshotMenuItem to enabled only if the user is logged in
            if([[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] count]) {
                [_takeScreenshotMenuItem setEnabled: YES];
            }
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach) {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Connection: OFFLINE");
            [_noInternetConnection setHidden: NO];
            //[_signIn setHidden:YES];
            [_takeScreenshotMenuItem setEnabled: NO];
            
            self.statusBar.image = [NSImage imageNamed: @"icon-disabled"];
        });
    };
    
    [internetReachable startNotifier];
}

- (IBAction)logoutButton:(id)sender {
    
    // Remove all accounts from the keychain
    for (NXOAuth2Account *account in [[NXOAuth2AccountStore sharedStore] accounts]) {
        [[NXOAuth2AccountStore sharedStore] removeAccount: account];
    };
    
    [_preferences setHidden: YES];
    [_preferences setEnabled: NO];
    [_takeScreenshotMenuItem setEnabled: NO];
    [_takeScreenshotMenuItem setHidden: YES];
    [_signIn setEnabled: YES];
    [_signIn setHidden: NO];
    [_mySnapsItem setEnabled: NO];
    
    self.statusBar.image = [NSImage imageNamed: @"icon-disabled"];
    
    [_preferencesWindow close];
    NSLog(@"User was successfully logged out.");
}

//
//  Display Notification even if application is not key
//
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}


//
//  Triggers a Notification
//  Needs the imageUrl to display it in the notification
//
+ (void)triggerNotification:(NSString *)imageUrl {
    
    //New Notification
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    //Properties of the Notification
    notification.title = imageUrl;
    notification.informativeText = @"Link copied to clipboard";
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    //Deliver
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

//
//  Makes the notification clickable
//
- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSString *url = notification.title;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

@end
