// ======================================================================================================================
//  MyPDFView.m
// ======================================================================================================================


#import "MyPDFView.h"

@implementation MyPDFView

#pragma mark -------- event overrides
// ------------------------------------------------------------------------------------------- setCursorForAreaOfInterest

- (void) setCursorForAreaOfInterest: (PDFAreaOfInterest) area
{
/*
	NSPoint		viewMouse;
	BOOL		overDocument;
	
	// Get mouse in document view coordinates.
	viewMouse = [[self documentView] convertPoint: [[NSApp currentEvent] locationInWindow] fromView: NULL];
	overDocument = [[self documentView] mouse: viewMouse inRect: [[self documentView] visibleRect]];
	if (overDocument == NO)
	{
		[[NSCursor arrowCursor] set];
		return;
	}
	
	// Handle link-edit mode.
	if ([(MyWindowController *)[[self window] windowController] linkMode] == kLinkEditMode)
		[[NSCursor arrowCursor] set];
	else
		[super setCursorForAreaOfInterest: area];
*/
		
		[[NSCursor arrowCursor] set];
}

- (void)mouseDown:(NSEvent *)theEvent
{
//	[[self nextResponder] mouseDown:theEvent];
}

#pragma mark -------- menu actions
// -------------------------------------------------------------------------------------------------------- printDocument

- (void) printDocument: (id) sender
{
	// Let PDFView handle the printing.
	[super printWithInfo: [NSPrintInfo sharedPrintInfo] autoRotate: YES];
	
	return;
}

@end
