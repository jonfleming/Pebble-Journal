//
//  DebugLog.h
//  Pebble
//
//  Created by techion on 8/8/10.
//  Copyright 2010 Jon Fleming. All rights reserved.
//
#include <sys/types.h>
#include <unistd.h>

#define D_SEVERE	0
#define D_ERROR		1
#define D_WARNING	2
#define D_CONFIG	3
#define D_FINEST	4	//pertenant
#define D_INFO		5
#define D_FINER		6	//may be pertenant
#define D_TRACE		7
#define D_FINE		8	//superflous
#define D_VERBOSE	9

#define D_LEVEL		D_INFO

#ifdef DEBUG
	#define DebugLog(args...) _DebugLog(args);
#else
	#define DebugLog(x...)
#endif

//__asm__("int $3\n" : : );

#ifdef DEBUG
	#define DebugBreak() { kill( getpid(), SIGINT ) ; }
#else
	#define DebugBreak()
#endif

void _DebugLog(int level, NSString *format,...);
