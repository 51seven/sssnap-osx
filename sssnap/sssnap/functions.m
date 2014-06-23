//
//  functions.m
//  sssnap
//
//  Created by Sven Schiffer on 23.5.14.
//  Copyright (c) 2014 AwesomePeople. All rights reserved.
//

#import "functions.h"

@implementation functions

+ (void)sendGrowl:(NSString *)data {
    //New Notification
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    
    //Properties of the Notification
    notification.title = data;
    notification.informativeText = @"Link copied to clipboard";
    notification.soundName = NSUserNotificationDefaultSoundName;
    
    //Deliver
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

+ (void)copyToClipboard:(NSString *)data {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:data forType:NSStringPboardType];
}

+ (BOOL)dateIsExpired:(NSDate *) date {
    
    NSDate *now = [NSDate date];
    
    NSLog(@"Comparing %@ with %@", date, now);
    
    // Given Date is taller then Now -> not expired
    if ([date compare:now] == NSOrderedDescending) {
        NSLog(@"Liegt in der Zukunft -> date is later than now");
        return false;
        
    }
    // Given Date is smaller then Now -> expired
    else if ([date compare:now] == NSOrderedAscending) {
        NSLog(@"Liegt in der Vergangenheit -> date is earlier than now");
        return true;
        
    }
    else {
        NSLog(@"dates are the same");
        return true;
    }
}

// Downscaling Retina Screenshots // gist.github.com/mattstevens/4400775
+ (NSImage *)downscaleToNonRetina:(NSImage *)image {
    
    NSInteger height = [image size].height;
    NSInteger width = [image size].width;

    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:width
                             pixelsHigh:height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSCalibratedRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    [rep setSize:NSMakeSize(width, height)];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [image drawInRect:NSMakeRect(0, 0, width, height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    NSData *imageData = [rep representationUsingType:NSPNGFileType properties:nil];
    NSImage *scaledImage = [[NSImage alloc] initWithData:imageData];
    
    return scaledImage;
}

@end
