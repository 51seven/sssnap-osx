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
    BOOL signedIn; //still needed?
    
}

@synthesize statusBar = _statusBar;


//
//  All code in here is executed immediately after the
//  application has finished loading.
//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    //NSLog(@"//////////");
    //NSLog(@"STARTUP DEBUG LOGS");
    
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    //Check internet connection
    //TODO: Implement necessary actions
    //(Later, not important by now)
    [self testInternetConnection];
    
    
    
   
    if([AppDelegate tokenIsValid]){
        //Hide sign in option from menu
        NSLog(@"The token is valid, Sig In Window should be hidden");
        [_signIn setHidden:YES];
        //[_signInWindow setHidden:YES];
    }else {
        //Hide the error label on
        [_signInErrorLabel setHidden:YES];
        //Show sign in window
        [_signInWindow makeKeyAndOrderFront:_signInWindow];
    }
    
        

}

- (IBAction)takeScreenshotItem:(id)sender {
        
    //Take the Screenshot
    NSString *imageUrl = [AppDelegate takeScreenshot];
    
    //Fire the Notification
    [AppDelegate triggerNotification:imageUrl];
    
}

//
//  Behavior of the Sign In button.
//  Only called if a username:token combination is not valid anymore.
//  Keeps the Sign In window open until successful login.
//
- (IBAction)signIn:(id)sender {
    
    //get the entered username
    NSString *username = [_usernameInput stringValue];
    //get the entered password
    NSString *password = [_passwordInput stringValue];

    //Create a new token
    //TODO: check if there already is one
    //TODO: Check this at startup, too
    Token *createToken = [[Token alloc]init];
    NSString *userToken = [createToken setToken:username and:password];
   
    //  Check for Authentification Error
    if([userToken  isEqual: @"Authentification failed."]){
        //Show error label
        [_signInErrorLabel setHidden:NO];
    }else{
        //Authentification successful, save username and token
        [createToken writeToken:username and:userToken];
    
        //Hide SignIn from Menu
        [_signIn setHidden:YES];
        //Close Sign In Window
        [_signInWindow close];
    }
    
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
    //Path to file with keyboard codes:
    // /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
    RegisterEventHotKey(0x15, shiftKey+optionKey, gMyHotKeyID,
                        GetApplicationEventTarget(), 0, &gMyHotKeyRef);
    
    
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    // self.statusBar.title = @"S";
    NSString *pathToIcon = [NSHomeDirectory() stringByAppendingString:@"/sssnap/iconx2.png"];
    NSImage *icon = [[NSImage alloc]initWithContentsOfFile:pathToIcon];
    NSLog(@"%@",[icon description]);
    
    // you can also set an image
    self.statusBar.image = icon;
    
    self.statusBar.menu = self.menuBarOutlet;
    self.statusBar.highlightMode = YES;
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                         void *userData)
{
    
    //Take the Screenshot
    NSString *imageUrl = [AppDelegate takeScreenshot];
    
    //Fire the Notification
    [AppDelegate triggerNotification:imageUrl];
    
    
    return noErr;
}


+(NSString *) takeScreenshot {
    
    //  Starts Screencapture Process
    NSTask *theProcess;
    theProcess = [[NSTask alloc] init];
    [theProcess setLaunchPath:@"/usr/sbin/screencapture"];
    
    //  Array with Arguments to be given to screencapture
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"-i", @"-c" ,@"image.jpg",nil];
    
    
    
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
    
    //Retina shizzle
    //SWEET MOTHER OF GOD, PUT THIS IN A FUNCTION!!
    
    NSLog(@"~~~~START OF RETINA SCALE LOGS~~~~~");
    
    //Debug: Log the size of the image
    NSSize imageSize = [clipboardimage size];
    NSLog(@"Image size: %f x %f",imageSize.width, imageSize.height);
    
    //Debug: Log the actual pixel-size of the image
    NSImageRep *rep = [[clipboardimage representations] objectAtIndex:0];
    NSSize imagePixelSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
    NSLog(@"Image pixel size: %f x %f", imagePixelSize.width, imagePixelSize.height);
    
    //Check if the tow size differ
    //If so, the image needs to be sscaled down
    if(imageSize.width < imagePixelSize.width){
        
        /*This is commented out.
        //Debug
        NSLog(@"Checked the size, they differ, I NEED TO SCALE THE IMAGE DOWN");
        
        
        NSRect targetFrame = NSMakeRect(0, 0, imageSize.width, imageSize.height);
        NSSize rectSize = targetFrame.size;
        NSLog(@"The size of the Rectangle to draw in is %f x %f", rectSize.width, rectSize.height);

        
        
        NSImage* scaledImage = nil;
        NSImageRep *sourceImageRep = [clipboardimage bestRepresentationForRect:targetFrame context:nil hints:nil];
        NSSize sourceImageRepSize = NSMakeSize(sourceImageRep.pixelsWide, sourceImageRep.pixelsHigh);
        NSLog(@"The size of the sourceImageRep is %f x %f", sourceImageRepSize.width, sourceImageRepSize.height);
        
        scaledImage = [[NSImage alloc] initWithSize:imageSize];
        
        
        [scaledImage lockFocus];
        [sourceImageRep drawInRect: targetFrame];
        [scaledImage unlockFocus];
        
        
        
        NSLog(@"Theoratically, I should have scaled the image by now");
        
        NSImageRep *repScaledImage = [[scaledImage representations] objectAtIndex:0];
        NSSize ScaledPixelSize = NSMakeSize(repScaledImage.pixelsWide, repScaledImage.pixelsHigh);
        NSLog(@"The Pixel size of the new created image is: %f x %f", ScaledPixelSize.width, ScaledPixelSize.height);
        
        
        NSImageRep *repClipboardImage = [[clipboardimage representations] objectAtIndex:0];
        NSSize ScaledClipboardPixelSize = NSMakeSize(repClipboardImage.pixelsWide, repClipboardImage.pixelsHigh);
        NSLog(@"The Pixel size of the clipboard image image is: %f x %f", ScaledClipboardPixelSize.width, ScaledClipboardPixelSize.height);
        */
        
        
        
        //Yet, another try
        NSLog(@"Imagesize * 0.5 is %@", imageSize*0.5);
        [rep setSize:imageSize];
        clipboardimage = [[NSImage alloc] initWithSize:[rep size]];
        [clipboardimage addRepresentation: rep];
        
        NSLog(@"%@", [clipboardimage description]);
        
        
        

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
    
    return imageUrl;
}


//  Checks if we have an internet connection or not
//  TODO: WTF do these errors mean?
- (void)testInternetConnection
{
    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            [_noInternetConnection setHidden:YES];
            
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            [_noInternetConnection setHidden:NO];
            [_signIn setHidden:YES];
            [_takeScreenshotMenuItem setHidden:YES];
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
    
    NSLog(@"Notification - Clicked");
    NSString *url = notification.title;
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}



//
//Checks if the currently saved token is valid.
//
+(BOOL)tokenIsValid {
    Token *checkToken = [[Token alloc]init];
    if([checkToken readTokenFile]){
        
        NSString *username = [checkToken getUsername];
        NSString *token = [checkToken getToken];
        
        sendPost *readToken = [[sendPost alloc]init];
        if([readToken isValidToken:username with:token]){
            //Token found and valid
            NSLog(@"Token is found an valid");
            return YES;
        }else {
            //Token found but is not valid
            NSLog(@"Token is found but not valid");
            return NO;
        }
    }else {
        //No token found
        NSLog(@"Token is not found");
        return NO;
    }

}



@end
