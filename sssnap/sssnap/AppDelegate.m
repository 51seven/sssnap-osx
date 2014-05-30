//
//  AppDelegate.m
//  sssnap
//
//  Created by Sven Schiffer 30.05.2014
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "AppDelegate.h"
#import "sendPost.h"
#import "checkSignedIn.h"
#import <Carbon/Carbon.h>

@implementation AppDelegate{
    BOOL signedIn; //still needed?
}

@synthesize statusBar = _statusBar;


//
//  All code in here is executed immediately after the
//  application has finished loading.
//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_signInErrorLabel setStringValue:[NSString stringWithFormat:@"%@", @""]];
    
    // Found no Userdata = No User logged in
    if(![[[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"] count]){
        NSLog(@"AccountStore is empty.");
        [_signInErrorLabel setHidden:YES];
        [_signInWindow makeKeyAndOrderFront:_signInWindow];
    }
    // User already logged in
    else {
        [_signIn setHidden:YES];
        [_signInWindow close];
        NSLog(@"Auth2AccountStore: \n%@", [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:@"password"]);
    }
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    //Check internet connection
    [self testInternetConnection];
}

- (IBAction)takeScreenshotItem:(id)sender {
    [AppDelegate takeScreenshot];
}

//
//  Behavior of the Sign In button.
//  Keeps the Sign In window open until successful login.
//
- (IBAction)signIn:(id)sender {
    
    [[NXOAuth2AccountStore sharedStore] setClientID:@"testid"
                                             secret:@"testsecret"
                                   authorizationURL:[NSURL URLWithString:@"http://localhost:3000/api/oauth/token"]
                                           tokenURL:[NSURL URLWithString:@"http://localhost:3000/api/oauth/token"]
                                        redirectURL:[NSURL URLWithString:@"http://localhost:3000/"]
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
                                                      NSLog(@"Successfully logged in.");
                                                  }];
    
    // On Failure
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification) {
                                                      NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                      [_signInErrorLabel setHidden: NO];
                                                      [_signInErrorLabel setStringValue:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
                                                      NSLog(@"Failed to login: \n%@", error);
                                                  }];
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
    
    // self.statusBar.title = @"S";
    NSString *pathToIcon = [NSHomeDirectory() stringByAppendingString:@"/sssnap/iconx2.png"];
    NSImage *icon = [[NSImage alloc]initWithContentsOfFile:pathToIcon];
    NSLog(@"%@",[icon description]);
    
    self.statusBar.image = icon;
    self.statusBar.menu = self.menuBarOutlet;
    self.statusBar.highlightMode = YES;
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData) {
    
    //Take the Screenshot
    [AppDelegate takeScreenshot];
    return noErr;
}


+(void) takeScreenshot {
    
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
    
    NSImage *clipboardimage;
    //NSLog(@"%ld", [theProcess terminationReason]);
    
    if ([theProcess terminationStatus] == 0) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSArray *classes = [[NSArray alloc] initWithObjects: [NSImage class], nil];
        NSDictionary *options = [NSDictionary dictionary];
        NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
        if (copiedItems != nil) {
            if([[copiedItems objectAtIndex:0] isKindOfClass:[NSImage class]]){
                clipboardimage = [copiedItems objectAtIndex:0];
            }
        }
    }
    
    //NSLog(@"%@", items);
    
    //Retina Resizing
    //NSLog(@"~~~~START OF RETINA SCALE LOGS~~~~~");
    
    //Debug: Log the size of the image
    NSSize imageSize = [clipboardimage size];
    //NSLog(@"Image size: %f x %f", imageSize.width, imageSize.height);
    
    //Debug: Log the actual pixel-size of the image
    NSImageRep *rep = [[clipboardimage representations] objectAtIndex:0];
    NSSize imagePixelSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    //NSLog(@"Image pixel size: %f x %f", imagePixelSize.width, imagePixelSize.height);
    
    /*
     This part creates CGFloats with half of the width and height of the original image.
     This is the size we desire for Retina screenshots
     All of this works on non-retina machines, but not on retina machines, which is quit unfortunate
     */
    //The error seems to be here
    //When Timo replaces the variables with constant numbers (i.e. "100") it works for him
    float halfWidth = rep.pixelsWide / 2;
    float halfHeight = rep.pixelsHigh / 2;
    // NSLog(@"The floats are: %f %f", halfWidth, halfHeight);
    
    //Convert the floats to CGFLoats
    CGFloat CGHalfWidth = halfWidth;
    CGFloat CGHalfHeight = halfHeight;
    // NSLog(@"The CGFloats are: %f %f", CGHalfWidth, CGHalfHeight);
    
    NSSize imagePixelSizeHalf = NSMakeSize(halfWidth, halfHeight);
    // NSLog(@"The width and size to calculate with (should be half of the pixels: %f x %f", imagePixelSizeHalf.width, imagePixelSizeHalf.height);
    
    NSImage *resizedImage = [[NSImage alloc] initWithSize:imagePixelSizeHalf];
    [resizedImage lockFocus];
    [[NSGraphicsContext currentContext]
     setImageInterpolation:NSImageInterpolationHigh];    // optional - higher
    
    [clipboardimage drawInRect:NSMakeRect(0,0,CGHalfWidth,CGHalfHeight) fromRect:NSZeroRect
                     operation:NSCompositeSourceOver fraction:1.0];
    
    [resizedImage unlockFocus];
    clipboardimage = resizedImage;
    
    //Check if the tow size differ
    //If so, the image needs to be sscaled down
    if(imageSize.width < imagePixelSize.width){
        /*Meh
         All of this could be deleted I guess
         
         NSString *pathToFile = [NSHomeDirectory() stringByAppendingString:@"/sssnap/copiedimage"];
         NSBitmapImageRep *imgRep = [[clipboardimage representations] objectAtIndex: 0];
         NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
         NSData *data = [imgRep representationUsingType:NSJPEGFileType properties:imageProps];
         [data writeToFile:pathToFile atomically:NO];
         
         
         NSLog(@"~~~~~~START OF SCALE ALGO~~~~~~");
         
         NSLog(@"Now creating a new rep from the clipboard image");
         NSBitmapImageRep *clipboardRep = [[clipboardimage representations] objectAtIndex: 0];
         NSSize clipboardRepPixels = NSMakeSize(clipboardRep.pixelsWide, clipboardRep.pixelsHigh);
         NSLog(@"Size of the new rep is %f x %f", clipboardRepPixels.width, clipboardRepPixels.height);
         
         NSLog(@"Now creating a new NSSize");
         NSSize updatedSize = imageSize;
         updatedSize.width = clipboardRepPixels.width / 2;
         updatedSize.height = clipboardRepPixels.height / 2;
         NSLog(@"New size has the dimensions %f x %f", updatedSize.width, updatedSize.height);
         
         NSRect dimensionsRect = NSMakeRect(0, 0, updatedSize.width, updatedSize.height);
         */
        
        // Some stuff from the Interwebs
        
        /*
         NSImage *resizedImage = [[NSImage alloc] initWithSize:NSMakeSize
         (imagePixelSizeHalf.width,imagePixelSizeHalf.height)];
         [resizedImage lockFocus];
         [[NSGraphicsContext currentContext]
         setImageInterpolation:NSImageInterpolationHigh];    // optional - higher
         
         [clipboardimage drawInRect:NSMakeRect(0,0,imagePixelSizeHalf.width,imagePixelSizeHalf.height) fromRect:NSZeroRect
         operation:NSCompositeSourceOver fraction:1.0];
         [resizedImage unlockFocus];
         
         clipboardimage = resizedImage;
         
         NSLog(@"resized Image: %@", [resizedImage description]);
         NSLog(@"Clipboard£ Image: %@", [clipboardimage description]);
         
         */
        
        
    }
    
    sendPost *post = [[sendPost alloc] init];
    [post uploadImage:clipboardimage];
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
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach) {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Connection: OFFLINE");
            [_noInternetConnection setHidden: NO];
            [_signIn setHidden:YES];
            [_takeScreenshotMenuItem setHidden: YES];
        });
    };
    
    [internetReachable startNotifier];
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
+(void)triggerNotification:(NSString *)imageUrl {
    
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


//
//Checks if the currently saved token is valid.
//
+(BOOL)tokenIsValid {
    return false;
}



@end
