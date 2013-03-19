//
//  GridView.m
//  PAR Works iOS SDK
//
//  Copyright 2013 PAR Works, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "GridView.h"
#import "GridCellView.h"
#import "UIViewAdditions.h"

@implementation GridView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self)
		[self setup];
	return self;
}

- (void)awakeFromNib
{
	[self setup];
}

- (void)setup
{
	_statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
	_statusSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[_statusSpinner setCenter:CGPointMake(295, 30)];
	[_statusSpinner startAnimating];
	[_statusView addSubview:_statusSpinner];
	_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 15, 250, 30)];
	[_statusLabel setBackgroundColor:[UIColor clearColor]];
	[_statusLabel setFont:[UIFont boldSystemFontOfSize:15]];
	[_statusLabel setTextColor:[UIColor darkGrayColor]];
	[_statusView addSubview:_statusLabel];

	_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_scrollView setDelegate:self];
	[self addSubview:_scrollView];

	_cells = [[NSMutableArray alloc] init];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self reloadData];
}

- (void)reloadData
{
	if (!_unusedCells)
		_unusedCells = [[NSMutableArray alloc] init];
	[_unusedCells addObjectsFromArray:_cells];
	[_cells removeAllObjects];

	CGPoint offset = [_scrollView contentOffset];
	CGRect templateFrame = CGRectMake(5, 5, 100, 100);
	NSArray * collection = [delegate objectCollectionForGridView:self];

	int itemsPerRow = self.bounds.size.width / templateFrame.size.width;

	// what is the first opportunity view that is onscreen?
	int startRow = floorf(offset.y / (templateFrame.size.height + templateFrame.origin.y));
	int startIndex = fmaxf(0, startRow * itemsPerRow);

	int endRow = ceilf((offset.y + self.frame.size.height) / templateFrame.size.height);
	int endIndex = fminf([collection count], endRow * itemsPerRow);

	CGFloat offsetX = (self.bounds.size.width - ((templateFrame.origin.x + templateFrame.size.width) * itemsPerRow)) / 2;

	if (startIndex > [collection count]) {
		[_scrollView scrollRectToVisible:CGRectZero animated:YES];
		return;
	}
	// the optimizations below are designed to minimize the number of unusedCells whose
	// contents change as the grid is laid out with new cells. The idea is that by
	// reorganizing the unusedCells array, more of the cells are loaded in with the
	// correct contents still in them. This is important because changing out the images
	// in the cells is a pretty expensive operation.

	if (([_unusedCells count] > itemsPerRow) && ([collection count] > startIndex) && ([[_unusedCells objectAtIndex:itemsPerRow] dataProvider] == [collection objectAtIndex:startIndex])) {
		// take the first three cells, put them at the end of the unusedCells array
		[_unusedCells addObjectsFromArray:[_unusedCells subarrayWithRange:NSMakeRange(0, itemsPerRow)]];
		[_unusedCells removeObjectsInRange:NSMakeRange(0, itemsPerRow)];
	}

	if (([_unusedCells count] > itemsPerRow) && ([collection count] > startIndex + itemsPerRow) && ([[_unusedCells objectAtIndex:0] dataProvider] == [collection objectAtIndex:startIndex + itemsPerRow])) {
		// take the last three cells and bring them to the beginning of the unusedCells array
		NSRange r = NSMakeRange([_unusedCells count] - (itemsPerRow + 1), itemsPerRow);
		[_unusedCells insertObjects:[_unusedCells subarrayWithRange:r] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, itemsPerRow)]];
		[_unusedCells removeObjectsInRange:NSMakeRange([_unusedCells count] - (itemsPerRow + 1), itemsPerRow)];
	}

	for (int ii = startIndex; ii < endIndex; ii++) {
		id item = [collection objectAtIndex:ii];
		GridCellView * c = nil;

		CGRect f = templateFrame;
		f.origin.x = offsetX + itemsPerRow + (ii % itemsPerRow) * (templateFrame.size.width + templateFrame.origin.x);
		f.origin.y = templateFrame.origin.y + floorf(ii / itemsPerRow) * (templateFrame.size.height + templateFrame.origin.y);

		if ([_unusedCells count] > 0) {
			c = [_unusedCells objectAtIndex:0];
			[_unusedCells removeObjectAtIndex:0];
		}

		if (c == nil) {
			c = [[GridCellView alloc] initWithDataProvider:nil];
			[c setParent:self];
		}
		[c setFrame:f];
		[c setDataProvider:item];
		[_cells addObject:c];

		if ([c superview] == nil)
			[_scrollView addSubview:c];
	}

	[_unusedCells makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_unusedCells removeAllObjects];

	int totalRows = ceilf([collection count] / (itemsPerRow * 1.0));
	CGSize s = CGSizeMake(self.frame.size.width, (templateFrame.size.height + templateFrame.origin.y) * totalRows + templateFrame.origin.y);

	if (([delegate respondsToSelector:@selector(isLoadingForGridView:)]) && ([delegate isLoadingForGridView:self])) {
		[_statusSpinner startAnimating];
		[_statusLabel setText:@"Loading Items..."];
		[_scrollView addSubview:_statusView];
		[_statusView setFrameOrigin:CGPointMake(0, s.height)];
		s.height += [_statusView frame].size.height;
	}
	else if ([collection count] == 0) {
		[_statusSpinner stopAnimating];
		[_statusLabel setText:@"No Items to Display."];
		[_scrollView addSubview:_statusView];
		[_statusView setFrameOrigin:CGPointMake(0, s.height)];
		s.height += [_statusView frame].size.height;
	}
	else {
		[_statusView removeFromSuperview];
	}
	[_scrollView setContentSize:s];
}

- (void)drillDownOnCell:(GridCellView *)cell
{
	if ([delegate respondsToSelector:@selector(object:selectedInGridView:)])
		[delegate object:[cell dataProvider] selectedInGridView:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self reloadData];
}

@end