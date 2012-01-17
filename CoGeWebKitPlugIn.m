//
//  CoGeWebKitPlugIn.m
//  CoGeWebKit
//
//  Created by Tamas Nagy on 6/30/09.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "CoGeWebKitPlugIn.h"

#define	kQCPlugIn_Name				@"CoGeWebKit"
#define	kQCPlugIn_Description		@"CoGeWebKit 1.0 RC2 by .lov., vade and bangnoise. Renders the file to texture at the given URL with WebKit."


static void _TextureReleaseCallback(CGLContextObj cgl_ctx, GLuint name, void* info)
{
	glDeleteTextures(1, &name);
    [(NSBitmapImageRep *)info release];
}

@implementation CoGeWebKitPlugIn

@dynamic inputFilePath;
@dynamic inputShowWindow;

@dynamic inputWidth;
@dynamic inputHeight;
@dynamic inputJavascript;
@dynamic inputReexecuteJS;

@dynamic inputForceFlashRendering;

@dynamic inputReload;
@dynamic inputForwardHistory;
@dynamic inputBackwardHistory;

// event input
@dynamic inputMouseScrollX;
@dynamic inputMouseScrollY;
@dynamic inputMouseX;
@dynamic inputMouseY;
@dynamic inputMouseRightDown;
@dynamic inputMouseLeftDown;
@dynamic inputCharacter;

@dynamic outputJavascript;
@dynamic outputCurrentURL;
@dynamic outputImageUrls;
@dynamic outputHTMLStringSource;
@dynamic outputProgress;


@dynamic outputImage;
@dynamic outputDocWidth;
@dynamic outputDocHeight;

@dynamic inputHideScrollbar;

// class stuff
@synthesize theURLString;
@synthesize webBitmap;
@synthesize workingOn1;
@synthesize urlList;
@synthesize stringHTMLSource;

/*
Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputFoo, outputBar;
*/

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			kQCPlugIn_Name,QCPlugInAttributeNameKey,			
			kQCPlugIn_Description,QCPlugInAttributeDescriptionKey,
			nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/*
	Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	*/
	
	if([key isEqualToString:@"inputFilePath"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:
				QCPortTypeString, QCPortAttributeTypeKey,
				@"URL", QCPortAttributeNameKey,
				@"http://coge.lovqc.hu",  QCPortAttributeDefaultValueKey,				
				nil];
	}
	
	if([key isEqualToString:@"inputWidth"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Width", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:640], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithDouble:1], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:[[NSScreen mainScreen] frame].size.width], QCPortAttributeMaximumValueKey,
				nil];
	}

	if([key isEqualToString:@"inputReload"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Reload", QCPortAttributeNameKey, nil];

	if([key isEqualToString:@"inputBackwardHistory"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Go Back", QCPortAttributeNameKey, nil];
	
	if([key isEqualToString:@"inputForwardHistory"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Go Forward", QCPortAttributeNameKey, nil];

	if([key isEqualToString:@"inputHeight"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Height", QCPortAttributeNameKey,
				[NSNumber numberWithDouble:480], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithDouble:1], QCPortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:[[NSScreen mainScreen] frame].size.height], QCPortAttributeMaximumValueKey,
				nil];
	}
		
	if([key isEqualToString:@"inputJavascript"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeString, QCPortAttributeTypeKey,
				@"Javascript", QCPortAttributeNameKey, nil];
	}
	
	if([key isEqualToString:@"inputReexecuteJS"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeBoolean, QCPortAttributeTypeKey,
				[NSNumber numberWithInt:0], QCPortAttributeDefaultValueKey,
				@"Re-execute Javascript", QCPortAttributeNameKey, nil];
	}

	if([key isEqualToString:@"inputHideScrollbar"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeBoolean, QCPortAttributeTypeKey,
				[NSNumber numberWithInt:0], QCPortAttributeDefaultValueKey,
				@"Hide Scrollbar", QCPortAttributeNameKey, nil];
	}
	
	if([key isEqualToString:@"inputForceFlashRendering"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeBoolean, QCPortAttributeTypeKey,
				[NSNumber numberWithInt:TRUE], QCPortAttributeDefaultValueKey,
				@"Force Flash Rendering", QCPortAttributeNameKey, nil];
	}
	
	
	if([key isEqualToString:@"inputMouseX"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeNumber, QCPortAttributeTypeKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				@"Mouse X Position", QCPortAttributeNameKey, nil];
	}
	
	if([key isEqualToString:@"inputMouseY"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeNumber, QCPortAttributeTypeKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				@"Mouse Y Position", QCPortAttributeNameKey, nil];
	}
	
	if([key isEqualToString:@"inputMouseLeftDown"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeNumber, QCPortAttributeTypeKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				@"Mouse Left Button", QCPortAttributeNameKey, nil];
	}	
	
	if([key isEqualToString:@"inputMouseRightDown"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeNumber, QCPortAttributeTypeKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				@"Mouse Right Button", QCPortAttributeNameKey, nil];
	}	
	
	if([key isEqualToString:@"inputMouseScrollX"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeNumber, QCPortAttributeTypeKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				@"Mouse Scroll X", QCPortAttributeNameKey, nil];
	}

	if([key isEqualToString:@"inputMouseScrollY"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeNumber, QCPortAttributeTypeKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				@"Mouse Scroll Y", QCPortAttributeNameKey, nil];
	}
	
	
	if([key isEqualToString:@"inputShowWindow"])
	{
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeBoolean, QCPortAttributeTypeKey,
				[NSNumber numberWithInt:0], QCPortAttributeDefaultValueKey,
				@"View Browser Window", QCPortAttributeNameKey, nil];
	}

	
	if([key isEqualToString:@"outputImage"])
		return [NSDictionary dictionaryWithObjectsAndKeys:QCPortTypeImage, QCPortAttributeTypeKey,@"Image", QCPortAttributeNameKey,nil];
	
	if([key isEqualToString:@"outputJavascript"])		
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Javascript Returns", QCPortAttributeNameKey, nil];
	
	if([key isEqualToString:@"outputDocWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Document Width", QCPortAttributeNameKey, nil];
	
	if([key isEqualToString:@"outputDocHeight"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Document Height", QCPortAttributeNameKey, nil];	
	
	if([key isEqualToString:@"outputImageUrls"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Image Locations", QCPortAttributeNameKey, nil];	
	
	if([key isEqualToString:@"outputHTMLStringSource"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"HTML Source String", QCPortAttributeNameKey, nil];	
	
	if([key isEqualToString:@"outputProgress"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Download Progress", QCPortAttributeNameKey, nil];	

	if([key isEqualToString:@"outputCurrentURL"])
		return [NSDictionary dictionaryWithObjectsAndKeys:@"Current URL", QCPortAttributeNameKey, nil];	

	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
	return [NSArray arrayWithObjects:@"inputFilePath",
			@"inputForceFlashRendering",
			@"inputWidth",
			@"inputHeight",
			@"inputJavascript",
			@"inputReexecuteJS",
			@"inputShowWindow",
			@"inputBackwardHistory",
			@"inputForwardHistory",
			@"inputHideScrollbar",
			@"inputReload",
			@"inputMouseX",
			@"inputMouseY",
			@"inputMouseLeftDown",
			@"inputMouseRightDown",
			@"inputMouseScrollX",
			@"inputMouseScrollY",
			@"inputKeyDown",
			@"outputImage",
			@"outputDocWidth", 
			@"outputDocHeight",
			@"outputJavascript",
			@"outputImageUrls", 
			@"outputHTMLStringSource",
			@"outputProgress",	
			@"outputCurrentURL",
			nil];
}


+ (QCPlugInExecutionMode) executionMode
{
	/*
	Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	*/
	
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode
{
	/*
	Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	*/
	
	return kQCPlugInTimeModeIdle;
}

-(void)initWebViewOnMainThread {

	WebViewNib = [[NSNib alloc] initWithNibNamed:@"WebWindow" bundle:[NSBundle bundleForClass:[self class]]];
	
	[WebViewNib instantiateNibWithOwner:self topLevelObjects:nil];
	
	[offscreenWindow setInitialFirstResponder:theWebView];
	[offscreenWindow display];
	
	// set delegates
	//we need to know the page download state
	[theWebView setFrameLoadDelegate:self];
	
	//delegate to make popup works
	[theWebView setPolicyDelegate:self];
	[theWebView setUIDelegate:self];
	
	//we should tell we are Safari, or some web services won't work as expected, like TypeKit
	[theWebView setApplicationNameForUserAgent:@"Safari"];

	

}

- (id) init
{
	if(self = [super init])
	{
		/*
		Allocate any permanent resource required by the plug-in.
		*/		
		
		//init on the main thread
		[self performSelectorOnMainThread:@selector(initWebViewOnMainThread) withObject:nil waitUntilDone:NO];
		
		lock1 = [[NSRecursiveLock alloc] init];
		
		[self setWorkingOn1:NO];
		
		
		[self setStringHTMLSource:@""];
		[self setUrlList:[NSMutableArray array]];
		
		updateOneshotOutputPorts = NO;
		
		JSOut = @"";
	}
	
	return self;
}

- (void) finalize
{
	/*
	Release any non garbage collected resources created in -init.
	*/
	
	
	[super finalize];
}

- (void) dealloc
{
	/*
	Release any resources created in -init.
	*/
	
	[self setStringHTMLSource:nil];
	[self setUrlList:nil];

	
	[theWebView setFrameLoadDelegate:nil];
	[theWebView setPolicyDelegate:nil];
	[theWebView setUIDelegate:nil];
	
	
	[lock1 release];
	
	[offscreenWindow close];
	[offscreenWindow release];
	[WebViewNib release];
	
	
	[super dealloc];
}


@end

@implementation CoGeWebKitPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/
	
	
	width = self.inputWidth;
	height = self.inputHeight;
	
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/
	//we are going to init our textures, and use client storage optimizations
//	CGLContextObj cgl_ctx = [context CGLContextObj];
	
//	[self buildWebTexture:cgl_ctx];
	
	needsrebuild = YES;
	
	
}

-(void)executeJavascriptWithString:(NSString *)string{

	[theWebView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:string waitUntilDone:NO];
}

-(void)setOutputWidthAndHeight {

	self.outputDocWidth = [[theWebView stringByEvaluatingJavaScriptFromString:@"document.width"] doubleValue];
	self.outputDocHeight = [[theWebView stringByEvaluatingJavaScriptFromString:@"document.height"] doubleValue];
}

-(void)webviewScrollY:(NSNumber *)value {

	NSPoint currentScrollPosition = [[[[[[theWebView mainFrame] frameView] documentView] enclosingScrollView] contentView] bounds].origin;
	
	if ([value doubleValue]<lastScrollValueY) {
		
		[[[[[[theWebView mainFrame] frameView] documentView] enclosingScrollView] documentView] scrollPoint:CGPointMake(currentScrollPosition.x, currentScrollPosition.y+50)];;
		
	} else {
		
		[[[[[[theWebView mainFrame] frameView] documentView] enclosingScrollView] documentView] scrollPoint:CGPointMake(currentScrollPosition.x, currentScrollPosition.y-50)];;
	}

	lastScrollValueY = [value doubleValue];

//	NSLog(@"scrollY %f", lastScrollValueY);
}

-(void)toggleScrollbarVisibility {

	BOOL val = !self.inputHideScrollbar; 
	
	[[theWebView windowScriptObject] evaluateWebScript:[NSString stringWithFormat:@"document.body.style.overflow='%@';",val?@"auto":@"hidden"]];
	
//	NSLog(@"%@", [NSString stringWithFormat:@"document.body.style.overflow='%@';",val?@"auto":@"hidden"]);
}

-(void)webviewScrollX:(NSNumber *)value {

	NSPoint currentScrollPosition = [[[[[[theWebView mainFrame] frameView] documentView] enclosingScrollView] contentView] bounds].origin;
	
	if ([value doubleValue]>lastScrollValueX) {
		
		[[[[[[theWebView mainFrame] frameView] documentView] enclosingScrollView] documentView] scrollPoint:CGPointMake(currentScrollPosition.x+50, currentScrollPosition.y)];;
		
	} else {
		
		[[[[[[theWebView mainFrame] frameView] documentView] enclosingScrollView] documentView] scrollPoint:CGPointMake(currentScrollPosition.x-50, currentScrollPosition.y)];;
		
	}

	lastScrollValueX = [value doubleValue];
	
	//NSLog(@"scrollX %f", lastScrollValueX);

}

-(void)webviewSetFrame {
	
	[theWebView setFrame:NSMakeRect(0, 0, width, height)];
;
	
	liveresize = NO;
	
	needsrebuild = YES;
}

-(void)webviewLoadRequest:(NSString *)filepath {
	
	//if (self.inputFilePath != nil) 
	{

		[offscreenWindow setBackgroundColor:[NSColor clearColor]];
		
		[[theWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filepath]]];
		[theWebView setDrawsBackground:NO];
		[offscreenWindow setOpaque:NO];
		
	//	NSLog(@"webview request loaded");
		
	}
	

}

-(void)loadHTMLOnMainThread:(NSString *)htmlstring {
	
    contentLoaded = NO;
//	NSLog(@"inject html: %@", htmlstring);
	
//	NSLog(@"load local flash stuff...");
	
	//first, we have to clear the current HTML	
	[self webviewLoadRequest:@""];

	
	[[theWebView mainFrame] loadHTMLString:htmlstring baseURL:[NSURL URLWithString:@"/"]];
	[theWebView setDrawsBackground:NO];
	[theWebView reload:nil];
	
}

-(void)webviewExecuteJS:(NSString *)newjs {

	JSOut = [theWebView stringByEvaluatingJavaScriptFromString:newjs];
}



- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/

	CGLContextObj cgl_ctx = [context CGLContextObj];
	
	//if filepath changed, reload
	if ([self didValueForInputKeyChange:@"inputShowWindow"])
	{
		if(self.inputShowWindow)
		{
			[offscreenWindow performSelectorOnMainThread:@selector(center) withObject:nil waitUntilDone:NO];
			[offscreenWindow performSelectorOnMainThread:@selector(orderFront:) withObject:nil waitUntilDone:NO];
		}
		else
		{
			[offscreenWindow performSelectorOnMainThread:@selector(orderOut:) withObject:nil waitUntilDone:NO];
		}	
			
	}


	//if filepath changed, reload
	if ([self didValueForInputKeyChange:@"inputForceFlashRendering"])
	{
		
	//	NSLog(@"inputForceFlashRendering changed!");
		
		if(self.inputForceFlashRendering)
		{
			needsforcerenderflash = YES;
		}
		else
		{
			needsforcerenderflash = NO;
		}	
		
	}
	
	
	
	//history handling
	if ([self didValueForInputKeyChange:@"inputBackwardHistory"] && (self.inputBackwardHistory == TRUE)) {
		
		[theWebView performSelectorOnMainThread:@selector(goBack:) withObject:nil waitUntilDone:NO];
		
		self.outputCurrentURL = [theWebView mainFrameURL];
	}

	if ([self didValueForInputKeyChange:@"inputForwardHistory"] && (self.inputForwardHistory == TRUE)) {
		
		[theWebView performSelectorOnMainThread:@selector(goForward:) withObject:nil waitUntilDone:NO];

		self.outputCurrentURL = [theWebView mainFrameURL];
}

	if ([self didValueForInputKeyChange:@"inputReload"] && (self.inputReload == TRUE)) {
		
		[theWebView performSelectorOnMainThread:@selector(reload:) withObject:nil waitUntilDone:NO];
		
		self.outputCurrentURL = [theWebView mainFrameURL];
	}
	
	//put the progress
	self.outputProgress = ([theWebView estimatedProgress]) ? [theWebView estimatedProgress] : 0; 

	//if width or height changed
	if (([self didValueForInputKeyChange:@"inputWidth"]) || ([self didValueForInputKeyChange:@"inputHeight"])) {

		liveresize = YES;

	//	NSLog(@"need new width or height, do it...");
		
		width = floorf(self.inputWidth);
		height = floorf(self.inputHeight);
		
		
		
		[self performSelectorOnMainThread:@selector(webviewSetFrame) withObject:nil waitUntilDone:NO];
		
		if (rendersflash) {
			
			[self performSelectorOnMainThread:@selector(handleLoadingFlashSetup:) withObject:[NSString stringWithString:self.inputFilePath] waitUntilDone:NO];
			
		}
		
	}
	
	
	
	if ([self didValueForInputKeyChange:@"inputFilePath"])
	{
		[offscreenWindow performSelectorOnMainThread:@selector(orderFront:) withObject:nil waitUntilDone:NO];
		//stops swf playing - this actually stops current swf audio playing
		//needed in any situation
		
		// special case flash handling:
		if ([self.inputFilePath length] > 4) {

			if (([[self.inputFilePath substringFromIndex:[self.inputFilePath length]-4] isEqualToString: @".swf"]))		{
				
				rendersflash = YES;
				NSLog(@"will render flash!");
				
				[self performSelectorOnMainThread:@selector(handleLoadingFlashSetup:) withObject:[NSString stringWithString:self.inputFilePath] waitUntilDone:NO];
				
				
			}
			else
			{	
				rendersflash = NO;
				
				//load content
				[self setTheURLString:self.inputFilePath];
				[self performSelectorOnMainThread:@selector(webviewLoadRequest:) withObject:[NSString stringWithString:self.inputFilePath] waitUntilDone:NO];
			}
			
			//for pure swf, we need to set the filepath on the transparent window's textfield, weird...
			//NO, WE DON'T WANNA THIS PIECE OF SITH
			//	[offscreenWindow setNaviPath:self.inputFilePath];
			
			
			
			NSLog(@"filepath changed, reload it...");
			
		} else {
			
			//it will just a reset
			[self setTheURLString:self.inputFilePath];
			[self performSelectorOnMainThread:@selector(webviewLoadRequest:) withObject:[NSString stringWithString:self.inputFilePath] waitUntilDone:NO];
		}

		self.outputCurrentURL = [NSString stringWithString:self.inputFilePath];

        [offscreenWindow performSelectorOnMainThread:@selector(orderOut:) withObject:nil waitUntilDone:NO];
	}
	
	
	if(updateOneshotOutputPorts)
	{
		self.outputImageUrls = urlList;
		self.outputHTMLStringSource = stringHTMLSource;
		
		[self performSelectorOnMainThread:@selector(setOutputWidthAndHeight) withObject:nil waitUntilDone:NO];

		updateOneshotOutputPorts = NO;
	}
	
#pragma mark input event handling - this needs MAJOR CLEANUP
	
	if ([self didValueForInputKeyChange:@"inputCharacter"]) {
		
		if (![[self inputCharacter] isEqualToString:@""]) {

			NSPoint location = [self normalizedMouseLocationForMouseX:self.inputMouseX mouseY:self.inputMouseY isFlippedY:NO];
			NSView* hitView = [(NSView*)theWebView hitTest:location];
			SEL selector = NSSelectorFromString(@"keyDown:");
			
			NSEvent* keyEvent = [NSEvent keyEventWithType:NSKeyDown
												 location:location 
											modifierFlags:NSKeyDownMask
												timestamp:(NSTimeInterval)CFAbsoluteTimeGetCurrent()
											 windowNumber:[[hitView window] windowNumber]	// dont assume offScreenWindow
												  context:[[hitView window] graphicsContext] // ^^
											   characters:self.inputCharacter
							  charactersIgnoringModifiers:@""
												isARepeat:NO
												  keyCode:0];
			
			
			if(hitView)
			{
				
				[hitView performSelectorOnMainThread:selector withObject:keyEvent waitUntilDone:NO];
			}
			
		} 

		
		
	}
	
	if([self didValueForInputKeyChange:@"inputMouseX"] || [self didValueForInputKeyChange:@"inputMouseX"] || [self didValueForInputKeyChange:@"inputMouseLeftDown"] || [self didValueForInputKeyChange:@"inputMouseRightDown"])
	{
		NSPoint location = [self normalizedMouseLocationForMouseX:self.inputMouseX mouseY:self.inputMouseY isFlippedY:NO];
		NSView* hitView = [(NSView*)theWebView hitTest:location];
		NSUInteger type = 0;
		NSUInteger flag = 0;
		NSUInteger clickCount = 0;
		SEL selector; 
		
		
		// now we switch through the possible mouse combinations and build flag and event lists.
		// left mouse drag
		if(([self didValueForInputKeyChange:@"inputMouseX"] || [self didValueForInputKeyChange:@"inputMouseY"]) && self.inputMouseLeftDown)
		{
			type = NSLeftMouseDragged;
			flag = NSLeftMouseDraggedMask;
			clickCount = 0;
			selector = NSSelectorFromString(@"mouseDragged:");
		}
		// right mouse drag
		else if(([self didValueForInputKeyChange:@"inputMouseX"] || [self didValueForInputKeyChange:@"inputMouseY"]) && self.inputMouseRightDown)
		{
			type = NSRightMouseDragged;
			flag = NSRightMouseDraggedMask;
			clickCount = 0;
			selector = NSSelectorFromString(@"rightMouseDragged:");
		}
		// left mouse down/up
		else if([self didValueForInputKeyChange:@"inputMouseLeftDown"])
		{
			if(self.inputMouseLeftDown)
			{
				type = NSLeftMouseDown;
				flag = NSLeftMouseDownMask;
				clickCount = 1;
				selector = NSSelectorFromString(@"mouseDown:");
			}
			else
			{
				type = NSLeftMouseUp;
				flag = NSLeftMouseUpMask;
				clickCount = 0;
				selector = NSSelectorFromString(@"mouseUp:");
			}
		}
		// right mouse down/up
		else if(self.inputMouseRightDown)
		{
			if(self.inputMouseLeftDown)
			{
				type = NSRightMouseDown;
				flag = NSRightMouseDownMask;
				clickCount = 1;
				selector = NSSelectorFromString(@"rightMouseDown:");
			}
			else
			{
				type = NSRightMouseUp;
				flag = NSRightMouseUpMask;
				clickCount = 0;
				selector = NSSelectorFromString(@"rightMouseUp:");
			}
		}
		// mouse moved
		else
		{
			type = NSMouseMoved;
			flag = NSMouseMovedMask;
			clickCount = 0;
			// odd that mouseDragged works in Java. Should really be mouseMoved but..
			// this seems to work for now...
			selector = NSSelectorFromString(@"mouseDragged:");
		}
		
			

		NSEvent* mouseEvent = [NSEvent mouseEventWithType:type 
												 location:location 
											modifierFlags:flag
												timestamp:(NSTimeInterval)CFAbsoluteTimeGetCurrent()
											 windowNumber:[[hitView window] windowNumber]	// dont assume offScreenWindow
												  context:[[hitView window] graphicsContext] // ^^
											  eventNumber:0 // % INT32_MAX;
											   clickCount:clickCount
												 pressure:0.0];
		
		
		if(hitView)
		{

			[hitView performSelectorOnMainThread:selector withObject:mouseEvent waitUntilDone:NO];
		}
		else
		{
			[theWebView performSelectorOnMainThread:selector withObject:mouseEvent waitUntilDone:NO];
		}
			
		
		
	}
	

#pragma mark Scroll handling
	
	//inital mouse scroll handle
	if ([self didValueForInputKeyChange:@"inputMouseScrollY"]) {
	
		//NSLog(@"mouse scroll");
		
		[self performSelectorOnMainThread:@selector(webviewScrollY:) withObject:[NSNumber numberWithDouble:self.inputMouseScrollY] waitUntilDone:NO];
	
	}

	if ([self didValueForInputKeyChange:@"inputMouseScrollX"]) {
		
		//NSLog(@"mouse scroll");

		[self performSelectorOnMainThread:@selector(webviewScrollX:) withObject:[NSNumber numberWithDouble:self.inputMouseScrollX] waitUntilDone:NO];
		
	}
	
	
	
#pragma mark javascript
	
	//the boolean value is a trigger!
	if ([self didValueForInputKeyChange:@"inputReexecuteJS"])
	{
		needJSExecute = YES;
	}
	
	//if javascript command changed, execute it
	if (([self didValueForInputKeyChange:@"inputJavascript"]) || (needJSExecute))
	{
		//be safe
		if ([self.inputJavascript rangeOfString:@"window.close"].location == NSNotFound) {
			NSLog(@"safe javascript :)");
			[self performSelectorOnMainThread:@selector(webviewExecuteJS:) withObject:[NSString stringWithString:self.inputJavascript] waitUntilDone:NO];
			self.outputJavascript = JSOut;
		}
		else
			self.outputJavascript = @"hey, don't kill our plugin with a window.close, dude!";
		
		needJSExecute = NO;
	}
	
	if ([self didValueForInputKeyChange:@"inputHideScrollbar"]) {
		
		[self performSelectorOnMainThread:@selector(toggleScrollbarVisibility) withObject:nil waitUntilDone:YES];
	}

	
#pragma mark Image provider
    

	
	if (!(self.workingOn1) || (needsrebuild)) 
	{
		
		if (justDisabled) {
			
			[self performSelectorOnMainThread:@selector(webviewLoadRequest:) withObject:[NSString stringWithString:self.inputFilePath] waitUntilDone:NO];
			
			
			justDisabled = NO;
		}
		
		
	//	NSLog(@"start rebuilding!");
	//	[self performSelectorOnMainThread:@selector(copyWebViewToBitmapInBackground) withObject:nil waitUntilDone:NO];
       [self performSelectorInBackground:@selector(copyWebViewToBitmapInBackground) withObject:nil];
	//	NSLog(@"rebuilding finished!");
	//	NSLog(@"bitmap width: %d  inputwidth: %d", [self.webBitmap pixelsWide], width);
		
	}	
	
	
    if (!liveresize)
    {
        NSBitmapImageRep *bitmap = self.webBitmap;
        
        if (bitmap != nil)
        {
            //NSLog(@"rendering...");
            glPushAttrib(GL_ENABLE_BIT | GL_TEXTURE_BIT);
            glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT);
            
            // create our texture 
            GLuint webTexture1;
            
            glEnable(GL_TEXTURE_RECTANGLE_EXT);
            glGenTextures(1, &webTexture1);
            glBindTexture(GL_TEXTURE_RECTANGLE_EXT, webTexture1);
            
            // Retain it for glTextureRangeApple, released in callback
            [bitmap retain];
            
            glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
            
            glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_SHARED_APPLE);
            glTextureRangeAPPLE(GL_TEXTURE_RECTANGLE_EXT, [bitmap bytesPerRow] * [bitmap pixelsHigh], [bitmap bitmapData]);
            
            glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap bytesPerRow] / [bitmap samplesPerPixel]);
            glPixelStorei (GL_UNPACK_ALIGNMENT, 1); 
            
            glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_S, GL_CLAMP);
            glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, GL_TEXTURE_WRAP_T, GL_CLAMP);
            
            glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, [bitmap samplesPerPixel] == 4 ? GL_RGBA8 : GL_RGB8, [bitmap pixelsWide], [bitmap pixelsHigh], 0, [bitmap samplesPerPixel] == 4 ? GL_RGBA : GL_RGB, GL_UNSIGNED_BYTE, [bitmap bitmapData]);
            
        
#if __BIG_ENDIAN__
#define CogePrivatePlugInPixelFormat QCPlugInPixelFormatARGB8
#else
#define CogePrivatePlugInPixelFormat QCPlugInPixelFormatBGRA8
#endif
        
            self.outputImage =  [context outputImageProviderFromTextureWithPixelFormat:CogePrivatePlugInPixelFormat
                                                                            pixelsWide:width
                                                                            pixelsHigh:height
                                                                                  name:webTexture1
                                                                               flipped:YES
                                                                       releaseCallback:_TextureReleaseCallback
                                                                        releaseContext:bitmap
                                                                            colorSpace:CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
                                                                      shouldColorMatch:YES];
            
            glPopClientAttrib();
            glPopAttrib();
	
        }
        else
        {
            self.outputImage = nil;
        }
    }
	
	return YES;
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/	
	
	[self performSelectorOnMainThread:@selector(webviewLoadRequest:) withObject:[NSString stringWithString:@""] waitUntilDone:NO];
	
	justDisabled = YES;
	
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/
    self.webBitmap = nil;
	
}


-(void)cacheTexture {

    NSView *view = [[theWebView mainFrame] frameView];

    NSBitmapImageRep *imagerep = [view bitmapImageRepForCachingDisplayInRect:[view visibleRect]];
    [view cacheDisplayInRect:[view visibleRect] toBitmapImageRep:imagerep];	
    
    if (imagerep != NULL) {
        [self setWebBitmap:imagerep];
    }
}

-(void)initMeOnStart {

    NSView *view = [[theWebView mainFrame] frameView];

    //	NSLog(@"visible: %f", [view visibleRect].size.width);
    //	NSLog(@"set new frame!");
    [offscreenWindow setContentSize:NSMakeSize(width, height+38.0)];
    [view setFrame:NSMakeRect(0, 0, width, height)];
    [view setNeedsDisplay:YES];
    [offscreenWindow display];
}

- (void) copyWebViewToBitmapInBackground
{

    [self setWorkingOn1:YES];

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	


	NSView *view = [[theWebView mainFrame] frameView];
	NSBitmapImageRep *bitmap = nil;

	// this shit needed
	// or 
	// the offscreen content won't update on startup
	//
	
	if ([view visibleRect].size.width != width) {
        [self performSelectorOnMainThread:@selector(initMeOnStart) withObject:nil waitUntilDone:YES];
	}
	
    if ((rendersflash) || (needsforcerenderflash)) {
        
        
        //NSLog(@"will render flash content!");
        [self performSelectorOnMainThread:@selector(cacheTexture) withObject:nil waitUntilDone:NO];
       
        
        
    } else {
        
        [view lockFocus];
        bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[view visibleRect]];
        [view unlockFocus];
        
        [self setWebBitmap:bitmap];
        [bitmap release]; 
    }

	
	[pool drain];
	
	[self setWorkingOn1:NO];
    needsrebuild = NO;

}

- (NSPoint) normalizedMouseLocationForMouseX:(double)inputMouseX mouseY:(double)inputMouseY isFlippedY:(BOOL)flippedy
{
	double mouseX = inputMouseX;
	double mouseY = inputMouseY;
	double aspect = self.inputHeight / self.inputWidth;

	// fix coordinates	
	mouseX /= 2.0;
	mouseX += 0.5;
	
	// handle aspect ratio conversion for QC coordinates since they normalize to x...
	mouseY += aspect;
	mouseY /= (aspect*2.0);
	
	mouseX *= self.inputWidth;
	//mouseY *= self.inputHeight;
	
	if (flippedy)
		mouseY = (self.inputHeight - (mouseY * self.inputHeight));
	else 
		mouseY *= self.inputHeight;
	
	NSPoint normalizedPoint = NSMakePoint((CGFloat) mouseX, (CGFloat) (mouseY));
	//NSLog(@"converted mouse coords are: %@", NSStringFromPoint(normalizedPoint));
	
	return normalizedPoint;
}

#pragma mark -
#pragma mark WebView Delegate Methods

//delegate to view javascript alert window
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
	
	//NSLog(@"alertpanel");
	
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
	[alert addButtonWithTitle:@"OK"];	
	[alert setMessageText:@"Javascript says:"];	
	[alert setAlertStyle:NSWarningAlertStyle];	
	[alert setInformativeText:message];	
	[alert beginSheetModalForWindow:offscreenWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
}

//alertpanel delegate
- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{	
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
	//NSLog(@"create webview");	
	return theWebView;	
}

// getting image resources URL - ok, now only grab urls from html, not css 
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{	
    contentLoaded = YES;
	
    	
    [self performSelectorOnMainThread:@selector(grabImagesFromWebSiteWithSources:) withObject:[NSArray arrayWithObjects:sender,frame, nil] waitUntilDone:NO];

	
}

-(void)grabImagesFromWebSiteWithSources:(NSArray *)sources {

    id sender = [sources objectAtIndex:0];
    id frame = [sources objectAtIndex:1];
    
    DOMNodeList *imgList = [[frame DOMDocument] getElementsByTagName:@"img"];
	// NSLog(@"img elements count: %d", [imgList length]);
	
	// autoreleased temp array.
	NSMutableArray * newURLArray = [NSMutableArray arrayWithCapacity:[imgList length]];	
	for (int i=0;i<[imgList length];i++)
	{
		// NSLog(@"src value for 1.%d element:%@",i, [[imgList item:i] valueForKey:@"src"]);
		[newURLArray insertObject:[[imgList item:i] valueForKey:@"src"] atIndex:i];
	}
	
	// update our oneshot ports
	[self setUrlList:newURLArray];
	[self setStringHTMLSource:[[[[sender mainFrame] dataSource] representation] documentSource]];	
	updateOneshotOutputPorts = YES;

}

#pragma mark -
#pragma mark Helper Functions

- (void) handleLoadingFlashSetup:(NSString *)swffile;
{
	//
	// ok, the method is load the wrapper - replace size and name - load the string for the webview
	//
	
	//
	// ok, the method is load the wrapper - replace size and name - load the string for the webview
	//
	
	//load the wrapper to a string
	NSString *wrapper = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"wrapperNEW" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
	
	//replacing data
	NSString *html0 = [wrapper stringByReplacingOccurrencesOfString:@"swfobject.js" withString:[[NSBundle bundleForClass:[self class]] pathForResource:@"swfobject" ofType:@"js"]];
	NSString *html1 = [html0 stringByReplacingOccurrencesOfString:@"thewidth" withString:[NSString stringWithFormat:@"%d",[[NSNumber numberWithInteger:width] intValue]]];
	NSString *html2 = [html1 stringByReplacingOccurrencesOfString:@"theheight" withString:[NSString stringWithFormat:@"%d",[[NSNumber numberWithInteger:height] intValue]]];
	
	
	NSString *htmlfull = [html2 stringByReplacingOccurrencesOfString:@"thefilename.swf" withString:swffile];


//	NSLog(@"html content: %@", htmlfull);
//	NSLog(@"ok, 'upload' or html content...");
	
	//load with webframe
	[self performSelectorOnMainThread:@selector(loadHTMLOnMainThread:) withObject:htmlfull waitUntilDone:NO];
	
	[offscreenWindow setBackgroundColor:[NSColor clearColor]];
	[offscreenWindow setOpaque:NO];
	
	
	// set this to "fire" oneshot updates
	updateOneshotOutputPorts = YES;
}

@end
