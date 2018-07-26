/* PDFKitViewer - MyPDFDocument.m
 *
 * Author: John Calhoun
 * Created 2004
 * 
 * Copyright (c) 2004 Apple Computer, Inc.
 * All rights reserved.
 */

#import "MyPDFDocument.h"
#import "AppDelegate.h"
#import <Quartz/Quartz.h>

@implementation MyPDFDocument
// ======================================================================================================== MyPDFDocument
// ----------------------------------------------------------------------------------------------------------------- init

- (id) init
{
	self = [super init];
	if (self)
	{
		// Add your subclass-specific initialization here.
		// If an error occurs here, send a [self release] message and return nil.
		
	}
	
	return self;
}

// -------------------------------------------------------------------------------------------------------------- dealloc

- (void) dealloc
{
	// No more notifications.
	[[NSNotificationCenter defaultCenter] removeObserver: self];
 	
	// Clean up.
	[_searchResults release];
	
	// Super.
	[super dealloc];
}

// -------------------------------------------------------------------------------------------------------- windowNibName

- (NSString *) windowNibName
{
	// Override returning the nib file name of the document
	return @"MyDocument";
}

// ------------------------------------------------------------------------------------------- windowControllerDidLoadNib

- (void) windowControllerDidLoadNib: (NSWindowController *) controller
{
	NSSize		windowSize;
	
	// Super.
	[super windowControllerDidLoadNib: controller];
	
	// Load PDF.
    if ([self fileURL])
	{
		PDFDocument	*pdfDoc;
		
        pdfDoc = [[PDFDocument alloc] initWithURL: [self fileURL]]; // JMN Fix
		[_pdfView setDocument: pdfDoc];
	}
	
	// Page changed notification.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(pageChanged:) 
			name: PDFViewPageChangedNotification object: _pdfView];
	
	// Find notifications.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(startFind:) 
			name: PDFDocumentDidBeginFindNotification object: [_pdfView document]];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(findProgress:) 
			name: PDFDocumentDidEndPageFindNotification object: [_pdfView document]];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(endFind:) 
			name: PDFDocumentDidEndFindNotification object: [_pdfView document]];
	
	// Set self to be delegate (find).
	[[_pdfView document] setDelegate: self];
	
	// Get outline.
	_outline = [[[_pdfView document] outlineRoot] retain];
	if (_outline)
	{
		// Remove text that says, "No outline."
		[_noOutlineText removeFromSuperview];
		_noOutlineText = NULL;
		
		// Force it to load up.
		[_outlineView reloadData];
	}
	else
	{
		// Remove outline view (leaving instead text that says, "No outline.").
		[[_outlineView enclosingScrollView] removeFromSuperview];
		_outlineView = NULL;
	}
	
	// Open drawer.
	[_drawer open];
	
	// Size the window.
    windowSize = [_pdfView rowSizeForPage: (PDFPage *)[(PDFView *)_pdfView currentPage]];
	if ((([_pdfView displayMode] & 0x01) == 0x01) && ([[_pdfView document] pageCount] > 1))
    {
        CGFloat scrollerWidth = [NSScroller scrollerWidthForControlSize:NSControlSizeRegular scrollerStyle:NSScrollerStyleLegacy];
        windowSize.width += scrollerWidth;
    }
    CGFloat scrollerWidth = [NSScroller scrollerWidthForControlSize:NSControlSizeRegular scrollerStyle:NSScrollerStyleLegacy];
    windowSize.width += scrollerWidth;
	[[controller window] setContentSize: windowSize];
}

// --------------------------------------------------------------------------------------------- dataRepresentationOfType

- (NSData *) dataRepresentationOfType: (NSString *) aType
{
	// Insert code here to write your document from the given data.  You can also choose to override 
	// -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	return nil;
}

// ---------------------------------------------------------------------------------------- loadDataRepresentation:ofType

- (BOOL) loadDataRepresentation: (NSData *) data ofType: (NSString *) aType
{
	// Insert code here to read your document from the given data.  You can also choose to override 
	// -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
	return YES;
}

#pragma mark -
// --------------------------------------------------------------------------------------------------------- toggleDrawer

- (IBAction) toggleDrawer: (id) sender
{
	[_drawer toggle: self];
}

// ------------------------------------------------------------------------------------------- takeDestinationFromOutline

- (IBAction) takeDestinationFromOutline: (id) sender
{
	// Get the destination associated with the search result list.  Tell the PDFView to go there.
	[_pdfView goToDestination: [[sender itemAtRow: [sender selectedRow]] destination]];
}

// ---------------------------------------------------------------------------------------------------- displaySinglePage

- (IBAction) displaySinglePage: (id) sender
{
	// Display single page mode.
	if ([_pdfView displayMode] > kPDFDisplaySinglePageContinuous)
		[_pdfView setDisplayMode: [_pdfView displayMode] - 2];
}

// --------------------------------------------------------------------------------------------------------- displayTwoUp

- (IBAction) displayTwoUp: (id) sender
{
	// Display two-up.
	if ([_pdfView displayMode] < kPDFDisplayTwoUp)
		[_pdfView setDisplayMode: [_pdfView displayMode] + 2];
}

// ---------------------------------------------------------------------------------------------------------- pageChanged

- (void) pageChanged: (NSNotification *) notification
{
	unsigned int	newPageIndex;
	int				numRows;
	int				i;
	int				newlySelectedRow;
	
	// Skip out if there is no outline.
	if ([[_pdfView document] outlineRoot] == NULL)
		return;
	
	// What is the new page number (zero-based).
    newPageIndex = (int)[[_pdfView document] indexForPage: (PDFPage *)[(PDFView *)_pdfView currentPage]];

	// Walk outline view looking for best firstpage number match.
	newlySelectedRow = -1;
	numRows = (int)[_outlineView numberOfRows];
	for (i = 0; i < numRows; i++)
	{
		PDFOutline	*outlineItem;
		
		// Get the destination of the given row....
		outlineItem = (PDFOutline *)[_outlineView itemAtRow: i];
		
		if ([[_pdfView document] indexForPage: [[outlineItem destination] page]] == newPageIndex)
		{
			newlySelectedRow = i;
            NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex: newlySelectedRow]; // row is NSUInteger
            [_outlineView selectRowIndexes:indexes byExtendingSelection:NO];

			break;
		}
		else if ([[_pdfView document] indexForPage: [[outlineItem destination] page]] > newPageIndex)
		{
			newlySelectedRow = i - 1;
            NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndex: newlySelectedRow]; // row is NSUInteger
            [_outlineView selectRowIndexes:indexes byExtendingSelection:NO];
			break;
		}
	}
	
	// Auto-scroll.
	if (newlySelectedRow != -1)
		[_outlineView scrollRowToVisible: newlySelectedRow];
}

#pragma mark -
// --------------------------------------------------------------------------------------------------------------- doFind

- (void) doFind: (id) sender
{
	if ([[_pdfView document] isFinding])
		[[_pdfView document] cancelFindString];
	
	// Lazily allocate _searchResults.
	if (_searchResults == NULL)
		_searchResults = [[NSMutableArray arrayWithCapacity: 10] retain];
	
	[[_pdfView document] beginFindString: [sender stringValue] withOptions: NSCaseInsensitiveSearch];
}

// ------------------------------------------------------------------------------------------------------------ startFind

- (void) startFind: (NSNotification *) notification
{
	// Empty arrays.
	[_searchResults removeAllObjects];
	
	[_searchTable reloadData];
	[_searchProgress startAnimation: self];
}

// --------------------------------------------------------------------------------------------------------- findProgress

- (void) findProgress: (NSNotification *) notification
{
	double		pageIndex;
	
	pageIndex = [[[notification userInfo] objectForKey: @"PDFDocumentPageIndex"] doubleValue];
	[_searchProgress setDoubleValue: pageIndex / [[_pdfView document] pageCount]];
}

// ------------------------------------------------------------------------------------------------------- didMatchString
// Called when an instance was located. Delegates can instantiate.

- (void) didMatchString: (PDFSelection *) instance
{
	// Add page label to our array.
	[_searchResults addObject: [instance copy]];
	
	// Force a reload.
	[_searchTable reloadData];
}

// -------------------------------------------------------------------------------------------------------------- endFind

- (void) endFind: (NSNotification *) notification
{
	[_searchProgress stopAnimation: self];
	[_searchProgress setDoubleValue: 0];
}

#pragma mark ------ NSTableView delegate methods
// ---------------------------------------------------------------------------------------------- numberOfRowsInTableView

// The table view is used to hold search results.  Column 1 lists the page number for the search result, 
// column two the section in the PDF (x-ref with the PDF outline) where the result appears.

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return ((int)[_searchResults count]);
}

// ------------------------------------------------------------------------------ tableView:objectValueForTableColumn:row

- (id) tableView: (NSTableView *) aTableView objectValueForTableColumn: (NSTableColumn *) theColumn
		row: (int) rowIndex
{
	if ([[theColumn identifier] isEqualToString: @"page"])
		return ([[[[_searchResults objectAtIndex: rowIndex] pages] objectAtIndex: 0] label]);
	else if ([[theColumn identifier] isEqualToString: @"section"])
		return ([[[_pdfView document] outlineItemForSelection: [_searchResults objectAtIndex: rowIndex]] label]);
	else
		return NULL;
}

// ------------------------------------------------------------------------------------------ tableViewSelectionDidChange

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
	int			rowIndex;
	
	// What was selected.  Skip out if the row has not changed.
	rowIndex = (int)[(NSTableView *)[notification object] selectedRow];
	if (rowIndex >= 0)
	{
		[_pdfView setCurrentSelection: [_searchResults objectAtIndex: rowIndex]];
		[_pdfView centerSelectionInVisibleArea: self];
	}
}

#pragma mark ------ NSOutlineView delegate methods
// ----------------------------------------------------------------------------------- outlineView:numberOfChildrenOfItem

// The outline view is for the PDF outline.  Not all PDF's have an outline.

- (int) outlineView: (NSOutlineView *) outlineView numberOfChildrenOfItem: (id) item
{
	if (item == NULL)
	{
		if (_outline)
			return (int)[_outline numberOfChildren];
		else
			return 0;
	}
	else
		return (int)[(PDFOutline *)item numberOfChildren];
}

// --------------------------------------------------------------------------------------------- outlineView:child:ofItem

- (id) outlineView: (NSOutlineView *) outlineView child: (int) index ofItem: (id) item
{
	if (item == NULL)
	{
		if (_outline)
			return [[_outline childAtIndex: index] retain];
		else
			return NULL;
	}
	else
		return [[(PDFOutline *)item childAtIndex: index] retain];
}

// ----------------------------------------------------------------------------------------- outlineView:isItemExpandable

- (BOOL) outlineView: (NSOutlineView *) outlineView isItemExpandable: (id) item
{
	if (item == NULL)
	{
		if (_outline)
			return ([_outline numberOfChildren] > 0);
		else
			return NO;
	}
	else
		return ([(PDFOutline *)item numberOfChildren] > 0);
}

// ------------------------------------------------------------------------- outlineView:objectValueForTableColumn:byItem

- (id) outlineView: (NSOutlineView *) outlineView objectValueForTableColumn: (NSTableColumn *) tableColumn 
		byItem: (id) item
{
    return [(PDFOutline *)item label];
}

@end
