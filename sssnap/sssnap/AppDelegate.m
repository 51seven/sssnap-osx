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
    if ([theProcess terminationStatus] == 0)
    {
        NSLog(@"Got here");
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSArray *classes = [[NSArray alloc] initWithObjects: [NSImage class], nil];
        NSDictionary *options = [NSDictionary dictionary];
        NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
        if (copiedItems != nil) {
            // Do something with the contents...
            NSString *items = [copiedItems description];
            NSLog(@"%@", items);
        }

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
    if ([theProcess terminationStatus] == 0)
    {
        NSLog(@"Got here");
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        NSArray *classes = [[NSArray alloc] initWithObjects: [NSImage class], nil];
        NSDictionary *options = [NSDictionary dictionary];
        NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
        if (copiedItems != nil) {
            // Do something with the contents...
            NSString *items = [copiedItems description];
            NSLog(@"%@", items);
        }
        
    }

    
    return noErr;
}

    

@end
