//
//  PAAppDelegate.m
//  Purgify
//
//  Created by lowell on 7/20/2011
//  Copyright (c) 2011 tCB. All rights reserved.
//

#import <Growl/Growl.h>

#import "PAAppDelegate.h"
#import "PAConstants.h"

#import "NSNumber+PAFriendlyNumberFormatting.h"
#import "NSProcessInfo+PAAvailablePhysicalMemory.h"

@interface PAAppDelegate () <NSMenuDelegate, NSApplicationDelegate, GrowlApplicationBridgeDelegate> {

    IBOutlet NSMenu     *statusMenu;
    IBOutlet NSMenuItem *freeMemoryMenuItem;

    NSStatusItem *statusItem;
}
- (BOOL) loadStatusItemNib;
- (void) setUpStatusItem;
- (IBAction) purgeAction:(id)sender;
- (NSString *) availableRAM;
@end

@implementation PAAppDelegate
#pragma mark -
#pragma mark PAAppDelegate
- (BOOL) loadStatusItemNib; {
    
    return [NSBundle loadNibNamed:@"StatusMenu" owner:self];
}


- (void) setUpStatusItem; {
    
    NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
    statusItem = [[systemStatusBar statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"P"];
    [statusItem setHighlightMode:YES];
}


- (IBAction) purgeAction:(id)sender; {

    __block unsigned int availableMemoryBeforePurge =
        [[NSProcessInfo processInfo] availablePhysicalMemory];

    NSTask *purgeTask = [[NSTask alloc] init];
    [purgeTask setLaunchPath:@"/usr/bin/purge"];
    [purgeTask setTerminationHandler:^(NSTask *task) {
        
        unsigned int availableMemoryAfterPurge =
            [[NSProcessInfo processInfo] availablePhysicalMemory];
        
        // Growl Notification
        unsigned int freedMemory = (availableMemoryAfterPurge - availableMemoryBeforePurge);
        NSNumber *freeMemory = [NSNumber numberWithUnsignedInt:freedMemory];
        NSString *notificationDescription =
            [NSString stringWithFormat:@"%@ inactive memory freed.",
                                        [freeMemory pa_friendlyFormattedBaseTwoString]];
        NSData *iconData = [[NSImage imageNamed:NSImageNameInfo] TIFFRepresentation];
        [GrowlApplicationBridge notifyWithTitle:@"Purgify"
                                    description:notificationDescription
                               notificationName:PATaskDidFinishNotification
                                       iconData:iconData
                                       priority:0
                                       isSticky:NO
                                   clickContext:nil];
    }];
    [purgeTask waitUntilExit]; 
    [purgeTask launch];
    [purgeTask release];
}

- (NSString *) availableRAM; {
    
    unsigned int availableMemoryUInt =
    [[NSProcessInfo processInfo] availablePhysicalMemory];
    NSNumber *availableMemory =
    [NSNumber numberWithUnsignedInt:availableMemoryUInt];
    
    return [NSString stringWithFormat:@"%@ Free",
            [availableMemory pa_friendlyFormattedBaseTwoString]];
}


#pragma mark -
#pragma mark NSObject
- (void)dealloc {
    
    [super dealloc];
    [statusItem release];
}


#pragma mark -
#pragma mark NSApplicationDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification; {

    if ([self loadStatusItemNib]) {
        [self setUpStatusItem];
        [GrowlApplicationBridge setGrowlDelegate:self];
    } else {
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:@"Unable to load nib for status menu."
                                                              forKey:PANibLoadingErrorKey];
        [NSApp presentError:[NSError errorWithDomain:PAApplicationErrorDomain
                                                code:-1
                                            userInfo:errorInfo]];
    }
    return;
}


#pragma mark -
#pragma mark NSMenuDelegate
- (void)menuWillOpen:(NSMenu *)menu; {

    [freeMemoryMenuItem setTitle:[self availableRAM]];
}


#pragma mark -
#pragma mark GrowlApplicationBridgeDelegate
- (NSDictionary *) registrationDictionaryForGrowl; {

    NSArray *notifications =
        [NSArray arrayWithObject:PATaskDidFinishNotification];

    NSDictionary *growlNotifications =
        [NSDictionary dictionaryWithObjectsAndKeys:notifications,
                                                   GROWL_NOTIFICATIONS_ALL,
                                                   notifications,
                                                   GROWL_NOTIFICATIONS_DEFAULT,
                                                   nil];
    return growlNotifications;
}


- (NSString *) applicationNameForGrowl; {

    return @"Purgify";
}
@end
