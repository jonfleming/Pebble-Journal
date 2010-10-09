/*
 *  constants.h
 *  Pebble
 *
 *  Created by techion on 6/24/10.
 *  Copyright 2010 Jon Fleming. All rights reserved.
 *
 */
#define SCREEN_FRAME [[UIScreen mainScreen] applicationFrame]
#define TABBAR_HEIGHT 49.0
#define	TABBAR_WIDTH 42.0
#define STATUSBAR_HEIGHT 20.0
#define HEADER_SPACE 44.0
#define DATE_LABEL_TOP 20.0
#define DATE_LABEL_WIDTH 100.0
#define DATE_LABEL_HEIGHT 30.0

#define ITEMS_TITLE @"Subjects"

#define NOTELIST 0
#define NOTEPAD 1
#define CHECKLIST 2

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

typedef enum 
{
	PasswordPebble,
	PasswordNew,
	PasswordSet,
	PasswordCurrent,
	PasswordIncorrect
} passwordPrompt;