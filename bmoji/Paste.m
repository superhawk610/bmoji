//
//  Paste.m
//  bmoji
//
//  Created by Aaron Ross on 10/2/20.
//

#import <Foundation/Foundation.h>
#import "Paste.h"

@implementation Paste

+ (void) withString:(NSString*)str {
    // get process identifier for front process (the app we want to paste to)
    ProcessSerialNumber psn;

    // GetFrontProcess is deprecated, but I was unable to find a modern alternative,
    // so this is what we're stuck with for now
    if (GetFrontProcess(&psn) != noErr) {
        fprintf(stderr, "Unable to get the process serial number for the front process\n");
        return;
    }

    // generate key events
    CGEventRef keyup, keydown;
    keydown = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)0, true);
    CGEventKeyboardSetUnicodeString(keydown, [str length], (const unichar*)[str cStringUsingEncoding: NSUnicodeStringEncoding]);
    keyup = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)0, false);
    
    // send key events
    CGEventPostToPSN(&psn, keydown);
    CGEventPostToPSN(&psn, keyup);
    
    // cleanup
    CFRelease(keydown);
    CFRelease(keyup);
}

@end
