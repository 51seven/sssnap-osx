//
//  AppDelegate.m
//  sssnap
//
//  Created by Christian Poplawski on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "AppDelegate.h"
#import "sendPost.h"
#import "Token.h"
#import "checkSignedIn.h"
#import <Carbon/Carbon.h>

@implementation AppDelegate{
    BOOL signedIn;
}

@synthesize statusBar = _statusBar;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    //Check internet connection
    //TODO: Implement necessary action
    //(Later, not important by now)
    [self testInternetConnection];
    
    
    checkSignedIn *signInCheck = [[checkSignedIn alloc]init];
    signedIn = [signInCheck checkSignInStatus];
    if(signedIn){
        [_signIn setHidden:YES];
    }

}

- (IBAction)takeScreenshot:(id)sender {
    // Hide Sign in snippet[_signIn setHidden:YES];
    
    //  Starts Screencapture Process
    NSTask *theProcess;
    theProcess = [[NSTask alloc] init];
    [theProcess setLaunchPath:@"/usr/sbin/screencapture"];
    
    //  Array with Arguments to be given to screencapture
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"-s", @"-c",@"image.jpg",nil];
    
    
    //  Apply arguments and start application
    [theProcess setArguments:arguments];
    [theProcess launch];
    
    [theProcess waitUntilExit];
    NSString *items;
    NSImage *clipboardimage;
    NSLog(@"%ld", [theProcess terminationReason]);
    if ([theProcess terminationStatus] == 0)
    {
        NSLog(@"Got here");
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSArray *classes = [[NSArray alloc] initWithObjects: [NSImage class], nil];
        NSDictionary *options = [NSDictionary dictionary];
        NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
        if (copiedItems != nil) {
            NSUInteger size = [copiedItems count];
            NSLog(@"Lenght of cpoied items arra is %lu", (unsigned long)size);
            // Do something with the contents...
            if([[copiedItems objectAtIndex:0] isKindOfClass:[NSImage class]]){
                clipboardimage = [copiedItems objectAtIndex:0];
                NSLog(@"%@", [clipboardimage description]);
            }
        }

    }
    
    NSLog(@"%@", items);
    
    sendPost *test = [[sendPost alloc] init];
    //TODO: Dirty, fix this
    Token *recieveAuth = [[Token alloc]init];
    [recieveAuth readTokenFile];
    NSString *imageUrl =  [test uploadImage:clipboardimage authWith:[recieveAuth getUsername] and:[recieveAuth getToken]];
    NSLog(@"USERNAME RECIEVED: %@", [recieveAuth getUsername]);
    NSLog(@"TOKEN RECIEVED: %@", [recieveAuth getToken]);
    NSLog(@"%@", [imageUrl description]);
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:imageUrl forType:NSStringPboardType];
    
    [AppDelegate triggerNotification:imageUrl];
    
    
}

//
//  Actions of the sign in button
//
- (IBAction)signIn:(id)sender {
    
    //get the entered username
    NSString *username = [_usernameInput stringValue];
    NSLog(@"%@",username);//debug
    //get the entered password
    NSString *password = [_passwordInput stringValue];
    NSLog(@"%@", password);//debug
    
    //Create a new token
    //TODO: check if there already is one
    //TODO: Check this at startup, too
    Token *createToken = [[Token alloc]init];
    NSString *userToken = [createToken setToken:username and:password];
   
    //  Check for Authentification Error
    //  TODO: Catch wrong combination, wait for right one.
    if([userToken  isEqual: @"Authentification failed."]){
        [_usernameLabel setStringValue:@"ERROR"];
        [_passwordLabel setStringValue:@"ERROR"];
    }
    NSString *tokenDir = [createToken writeToken:username and:userToken];
     [createToken readTokenFile];
    NSLog(@"%@", userToken);
    NSLog(@"%@", tokenDir);
    signedIn = true;
    
    //Hide SignIn from Menu
    [_signIn setHidden:YES];
    //Close Sign In Window
    [_signInWindow close];
}








//  Ovveride AwakeFromNib
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
    
    //  Register the Hotkey
    RegisterEventHotKey(0x17, shiftKey+optionKey, gMyHotKeyID,
                        GetApplicationEventTarget(), 0, &gMyHotKeyRef);
    
    
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.statusBar.title = @"sssnap";
    
    // you can also set an image
    //self.statusBar.image =
    
    self.statusBar.menu = self.menuBarOutlet;
    self.statusBar.highlightMode = YES;
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                         void *userData)
{
    
    
    //  Starts Screencapture Process
    NSTask *theProcess;
    theProcess = [[NSTask alloc] init];
    [theProcess setLaunchPath:@"/usr/sbin/screencapture"];
    
    //  Array with Arguments to be given to screencapture
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"-s", @"-c",@"image.jpg",nil];
    
    
    //  Apply arguments and start application
    [theProcess setArguments:arguments];
    [theProcess launch];
    
    [theProcess waitUntilExit];
    NSImage *clipboardimage;
    if ([theProcess terminationStatus] == 0)
    {
        NSLog(@"Got here");
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSArray *classes = [[NSArray alloc] initWithObjects: [NSImage class], nil];
        NSDictionary *options = [NSDictionary dictionary];
        NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
        if (copiedItems != nil) {
            NSUInteger size = [copiedItems count];
            NSLog(@"Lenght of cpoied items arra is %lu", (unsigned long)size);
            // Do something with the contents...
            if([[copiedItems objectAtIndex:0] isKindOfClass:[NSImage class]]){
                clipboardimage = [copiedItems objectAtIndex:0];
                NSLog(@"%@", [clipboardimage description]);
            }
        }

        
    }

    sendPost *test = [[sendPost alloc] init];
    //TODO: Dirty, fix this
    Token *recieveAuth = [[Token alloc]init];
    [recieveAuth readTokenFile];
    NSString *imageUrl =  [test uploadImage:clipboardimage authWith:[recieveAuth getUsername] and:[recieveAuth getToken]];
    NSLog(@"USERNAME RECIEVED: %@", [recieveAuth getUsername]);
    NSLog(@"TOKEN RECIEVED: %@", [recieveAuth getToken]);
    NSLog(@"%@", [imageUrl description]);
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:imageUrl forType:NSStringPboardType];
    
    [AppDelegate triggerNotification:imageUrl];
    
    
    return noErr;
}


// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [internetReachable startNotifier];
}


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}


+(void)triggerNotification:(NSString *)imageUrl {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = imageUrl;
    notification.informativeText = @"Link copied to clipboard";
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

    

@end
