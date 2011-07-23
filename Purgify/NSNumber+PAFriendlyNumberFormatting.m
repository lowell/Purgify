//
//  NSNumber+PAFriendlyNumberFormatting.m
//  Purgify
//
//  Created by lowell on 7/20/2011
//  Copyright (c) 2011 tCB. All rights reserved.
//

#import "NSNumber+PAFriendlyNumberFormatting.h"

@implementation NSNumber (PAFriendlyNumberFormatting)
- (NSString *) pa_friendlyFormattedBaseTwoString; {
	if (self == nil)
		return nil;

	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    NSString *formattedNumber = nil;
	NSString *formattedString = nil;
	NSUInteger n = [self unsignedIntegerValue];
	if (n < 1024) {
		formattedNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:[self floatValue]]];
		formattedString = [NSString stringWithFormat:@"%@ B", formattedNumber];
	}
	else if (n < 1024 * 1024) {
		NSString *formattedNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:[self floatValue] / 1024.0]];
		formattedString = [NSString stringWithFormat:@"%@ KB", formattedNumber];
	}
	else if (n < 1024 * 1024 * 1024) {
		NSString *formattedNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:[self floatValue] / 1024.0 / 1024.0]];
		formattedString = [NSString stringWithFormat:@"%@ MB", formattedNumber];
	}
	else {
		NSString *formattedNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:[self floatValue] / 1024.0 / 1024.0 / 1024.0]];
		formattedString = [NSString stringWithFormat:@"%@ GB", formattedNumber];
	}
	[formatter release];
    
	return formattedString;
}

@end
