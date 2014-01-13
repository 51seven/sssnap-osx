//
//  AppDelegate.m
//  sssnap
//
//  Created by Christian Poplawski on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>

@implementation AppDelegate

@synthesize statusBar = _statusBar;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

}

- (IBAction)takeScreenshot:(id)sender {
    
    //
    //  Sets the absolute path for the picture to be saved at.
    //  Necessary because on some machines MacOS seems to need the absolute path.
    //
    //  TODO: Try to make it less dirty
    //  TODO: Change location later on, Desktop for now
    //  TODO: Own class?
    //  TODO: Underscores etc in filname to mka it look like
    //        Screen Shot 13_01_14 at 03_08_36
    //        Do we need this? Only hash maybe?
    //
    NSString *homeDirectory = NSHomeDirectory(); //Users home directory
    NSString *location = @"/Desktop/"; //everything after /Users/HOME
    NSString *homeLocation = [homeDirectory stringByAppendingString: location]; //append
    NSDate *currDate = [NSDate date];
    NSString *dateString = [currDate description];
    NSString *fileName = [homeLocation stringByAppendingString:dateString];
    NSString *extension = @".png";
    NSString *fullPath = [fileName stringByAppendingString:extension];
    
    NSLog(@"%@", fullPath); //Debug
    
    
    //  Starts Screencapture Process
    NSTask *theProcess;
    theProcess = [[NSTask alloc] init];
    [theProcess setLaunchPath:@"/usr/sbin/screencapture"];
    
    //  Array with Arguments to be given to screencapture
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"-s",fullPath,nil];
    
    //  Apply arguments and start application
    [theProcess setArguments:arguments];
    [theProcess launch];
    
}

//  Ovveride AwakeFromNib

- (void) awakeFromNib {
    
    //  Register the Hotkeys
    EventHotKeyRef gMyHotKeyRef;
    EventHotKeyID gMyHotKeyID;
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    
    //  Fixed later
    InstallApplicationEventHandler(&MyHotKeyHandler,1,&eventType,NULL,NULL);
    
    //  Name and ID of Hotkey
    gMyHotKeyID.signature='htk1';
    gMyHotKeyID.id=1;
    
    //  Register the Hotkey
    RegisterEventHotKey(49, cmdKey+optionKey, gMyHotKeyID,
                        GetApplicationEventTarget(), 0, &gMyHotKeyRef);
    
    
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.statusBar.title = @"G";
    
    // you can also set an image
    //self.statusBar.image =
    
    self.statusBar.menu = self.menuBarOutlet;
    self.statusBar.highlightMode = YES;
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                         void *userData)
{
    
    
    //
    //  Sets the absolute path for the picture to be saved at.
    //  Necessary because on some machines MacOS seems to need the absolute path.
    //
    //  TODO: Try to make it less dirty
    //  TODO: Change location later on, Desktop for now
    //  TODO: Own class?
    //  TODO: Underscores etc in filname to mka it look like
    //        Screen Shot 13_01_14 at 03_08_36
    //        Do we need this? Only hash maybe?
    //
    NSString *homeDirectory = NSHomeDirectory(); //Users home directory
    NSString *location = @"/Desktop/"; //everything after /Users/HOME
    NSString *homeLocation = [homeDirectory stringByAppendingString: location]; //append
    NSDate *currDate = [NSDate date];
    NSString *dateString = [currDate description];
    NSString *fileName = [homeLocation stringByAppendingString:dateString];
    NSString *extension = @".png";
    NSString *fullPath = [fileName stringByAppendingString:extension];
    
    NSLog(@"%@", fullPath); //Debug
    
    
    //  Starts Screencapture Process
    NSTask *theProcess;
    theProcess = [[NSTask alloc] init];
    [theProcess setLaunchPath:@"/usr/sbin/screencapture"];
    
    //  Array with Arguments to be given to screencapture
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects:@"-s",fullPath,nil];
    
    //  Apply arguments and start application
    [theProcess setArguments:arguments];
    [theProcess launch];
    
    return noErr;
}

    

@end
