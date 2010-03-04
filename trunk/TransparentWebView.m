//
//  TransparentWebView.m
//  CoGeWebKit
//
//  Created by vade on 7/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TransparentWebView.h"


@implementation TransparentWebView

- (BOOL) isOpaque
{
	return NO;
}

-(IBAction)triggerGoBack:(id)sender {

	[naviField setTitleWithMnemonic:[self mainFrameURL]];
	
	NSLog(@"mainframeURL: %@", [self mainFrameURL]);
}


@end
