//
//  DebugLog.m
//  Pebble
//
//  Created by techion on 8/8/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//

#import "DebugLog.h"

void _DebugLog(int level, NSString *format,...) {
    va_list ap;
    va_start (ap, format);
    if (![format hasSuffix: @"\n"]) {
		format = [format stringByAppendingString: @"\n"];
    }
    NSString *body =  [[NSString alloc] initWithFormat: format arguments: ap];
    va_end (ap);
	
	if (level <= D_LEVEL) {
		fprintf(stderr,"%s",[body UTF8String]);
	}
    [body release];
}
