//
//  AppDelegate.m
//  sssnap
//
//  Created by Christian Poplawski on 13.01.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

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

    

@end
