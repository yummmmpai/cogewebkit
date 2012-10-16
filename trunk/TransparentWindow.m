//
//  TransparentWindow.m
//  CoGeWebKit
//
//  Created by vade on 7/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TransparentWindow.h"


@implementation TransparentWindow

@synthesize urlField;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	self = [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];

    if (self) {

        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];

    }
    
	
	return self;
}

-(void)setNaviPath:(NSString *)path {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    
        [urlField setTitleWithMnemonic:[NSString stringWithFormat:@"file://%@", path]];

        
    } else {

        [urlField setTitleWithMnemonic:path];

    }
	
	[urlField sendAction:[urlField action] to:[urlField target]];
}


//this makes animated gifs working
-(BOOL)isVisible {
	
	return YES;
}

@end
