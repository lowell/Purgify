//
//  NSProcessInfo+PAAvailablePhysicalMemory.m
//  Purgify
//
//  Created by lowell on 7/20/2011
//  Copyright (c) 2011 tCB. All rights reserved.
//

#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>

#import "NSProcessInfo+PAAvailablePhysicalMemory.h"

@implementation NSProcessInfo (PAAvailablePhysicalMemory)
- (unsigned int) availablePhysicalMemory; {
    // http://stackoverflow.com/a/6095158/327470
    int mib[6];
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    unsigned int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0) {
        fprintf (stderr, "getting page size");
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS) {
        fprintf (stderr, "Failed to get VM statistics.");
    }
    
    task_basic_info_64_data_t info;
    unsigned size = sizeof (info);
    task_info (mach_task_self (), TASK_BASIC_INFO_64, (task_info_t) &info, &size);
    return (vmstat.free_count * pagesize);
}
@end
