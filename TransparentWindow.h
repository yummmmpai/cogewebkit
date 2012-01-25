//
//  TransparentWindow.h
//  CoGeWebKit
//
//  Created by vade on 7/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TransparentWindow : NSWindow
{

	NSTextField *urlField;
}

@property (assign, readwrite) IBOutlet NSTextField *urlField;

-(void)setNaviPath:(NSString *)path;

@end
