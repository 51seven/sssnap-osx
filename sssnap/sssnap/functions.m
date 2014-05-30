//
//  functions.m
//  sssnap
//
//  Created by Sven Schiffer on 23.5.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "functions.h"

@implementation functions

- (void)sendGrowl:(NSString *)data {
    //New Notification
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    //Properties of the Notification
    notification.title = data;
    notification.informativeText = @"Link copied to clipboard";
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    
    //Deliver
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)copyToClipboard:(NSString *)data {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:data forType:NSStringPboardType];
}

- (BOOL)dateIsExpired:(NSDate *) date {
    
    
    return true;
}
@end
