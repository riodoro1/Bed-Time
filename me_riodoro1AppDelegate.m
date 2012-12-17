//
//  me_riodoro1AppDelegate.m
//  Bed Time
//
//  Created by Rafał Białek on 12/13/12.
//  Copyright (c) 2012 Rafał Białek. All rights reserved.
//

#import "me_riodoro1AppDelegate.h"
#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPowerSources.h>

@implementation me_riodoro1AppDelegate

int64_t systemIdleTime(void) {  //This function I got from the internet
    int64_t idlesecs = -1;
    io_iterator_t iter = 0;
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IOHIDSystem"), &iter) == KERN_SUCCESS) {
        io_registry_entry_t entry = IOIteratorNext(iter);
        if (entry) {
            CFMutableDictionaryRef dict = NULL;
            if (IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0) == KERN_SUCCESS) {
                CFNumberRef obj = CFDictionaryGetValue(dict, CFSTR("HIDIdleTime"));
                if (obj) {
                    int64_t nanoseconds = 0;
                    if (CFNumberGetValue(obj, kCFNumberSInt64Type, &nanoseconds)) {
                        idlesecs = (nanoseconds >> 30); // Divide by 10^9 to convert from nanoseconds to seconds.
                    }
                }
                CFRelease(dict);
            }
            IOObjectRelease(entry);
        }
        IOObjectRelease(iter);
    }
    return idlesecs;
} //Check idle time.

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"Starting timer... Will check power saver status every 20 seconds.");
    [NSTimer scheduledTimerWithTimeInterval:20.0
                                     target:self
                                   selector:@selector(check:)
                                   userInfo:nil
                                    repeats:YES];
}

-(IBAction)check:(id)sender
{
    NSInteger disp = [self displayState];
    NSInteger batt = [self battCharge];
    int64_t idle = systemIdleTime();
    NSInteger pwSource = [self getPowerSource];     //1 for AC, 0 for Battery
    NSDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/Library/Preferences/SystemConfiguration/com.apple.PowerManagement.plist"];
    NSInteger sleep;
    
    
    
    if (pwSource) sleep = [[dict valueForKeyPath:@"Custom Profile.AC Power.System Sleep Timer"]integerValue];
    else sleep = [[dict valueForKeyPath:@"Custom Profile.Battery Power.System Sleep Timer"]integerValue];
    sleep*=60;
    
    //NSLog(@"Chcking with idle time: %llds, sleep timer %lds display state: %ld power source: %ld",idle,sleep,disp,pwSource);
    
    if(batt <=10 && !pwSource)                                        //Cheking safe sleep
    {
        NSLog(@"Safe sleeping the computer!");
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to sleep"];
        [script executeAndReturnError:nil];
        [script release];

    }
    
    if(sleep!=0 && idle>=sleep && disp==0)              //Checking idle sleep
    {
        [NSTimer scheduledTimerWithTimeInterval:10.0
                                         target:self
                                       selector:@selector(sleepMac:)
                                       userInfo:nil
                                        repeats:NO];
        NSLog(@"Computer's been idle for more then %ld, Will wait 10 more seconds for user activity.",sleep);
    }
}

-(NSInteger)getPowerSource
{
    if(IOPSCopyExternalPowerAdapterDetails()!=NULL) return 1; else return 0;
}

-(IBAction)sleepMac:(id)sender
{
    if(systemIdleTime()>7)
    {
        NSLog(@"Time passed, sleeping...");
        NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\" to sleep"];
        [script executeAndReturnError:nil];
        [script release];
    }
}

-(NSInteger)battCharge
{
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"return do shell script \"ioreg -l | grep -i capacity | tr '\\n' ' | ' | awk '{printf(\\\"%.0f\\\", $10/$5 * 100)}'\""];
    NSAppleEventDescriptor* descriptor = [script executeAndReturnError:nil];
    [script release];
    return [[descriptor stringValue] integerValue];
}

-(NSInteger)displayState
{
    NSAppleScript* script = [[NSAppleScript alloc] initWithSource:@"set result to do shell script \"ioreg -n IODisplayWrangler |grep -i IOPowerManagement\" \n if result contains \"\\\"CurrentPowerState\\\"=4\" then \n return\"2\" \n else if result contains \"\\\"CurrentPowerState\\\"=3\" then \n return \"1\" \n else \n return \"0\" \n end if"];
    
    NSAppleEventDescriptor* descriptor = [script executeAndReturnError:nil];
    [script release];
    return [[descriptor stringValue] integerValue];
}

@end
