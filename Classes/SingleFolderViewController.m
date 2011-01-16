    //
//  SingleFolderViewController.m
//  UNaXcess3
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SingleFolderViewController.h"
#import "UNaXcess3AppDelegate.h"
#import "UAMessage.h"
#import "MessageListCustomCell.h"

@implementation SingleFolderViewController

//
//@synthesize singleFolderViewTable;
@synthesize tableView;
@synthesize singleFolderBackButton;
@synthesize singleFolderViewNavbar;
@synthesize singleFolderRefreshButton;
@synthesize messageView;

- (IBAction)buttonPressed_SingleFolderBack:(id)sender
{
	UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.messageMarkAsRead = appDelegate.selectedMessage.messageid;
	
	[messageView loadHTMLString:@"" baseURL:[NSURL URLWithString:@""]];
	//self.messageMarkAsRead
	NSLog(@"singlefolderback pressed. marking message as read");
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"markMessageRead"
	 object:nil ];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	//[self.parentViewController release];
	//[self.parentViewController 
	 
}
		
- (IBAction)buttonPressed_SingleFolderRefresh:(id)sender
{
	NSLog(@"singlefolderrefresh pressed");
[[NSNotificationCenter defaultCenter]
 postNotificationName:@"refreshMessagesBG"
 object:nil ];
}


- (IBAction)buttonPressed_MarkAsRead:(id)sender
{
	NSLog(@"markasread pressed");
	//[[NSNotificationCenter defaultCenter]
	// postNotificationName:@"refreshMessagesBG"
	// object:nil ];
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"markMessageRead"
	 object:nil ];
}

- (IBAction)buttonPressed_HoldMessage:(id)sender
{
	NSLog(@"hold message pressed");

	
}
	
- (void)viewWillAppear {
	NSLog(@"singlefolderviewcontroller viewwillappear");

}

- (void)viewDidAppear {
	NSLog(@"singlefolderviewcontroller viewDidAppear");
	
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"SingleFolderViewController viewDidLoad start");
    UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];
	singleFolderViewNavbar.topItem.title = appDelegate.currentFolder;
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:@"refreshTable"];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(eventHandler:)
	 name:@"refreshMessagesTable"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"refreshMemoryMessageList"
	 object:nil ];
	
	//[self.messageView loadHTMLString:@""];
	
    [super viewDidLoad];
	
	//NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
    //[tableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionBottom];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)refreshTable {
	NSLog(@"Refresh table");
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (tableView.tag == 0) {
		
		return 2;
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [arryData count];
	
	UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (tableView.tag == 0) {
		
		if (section == 0)
		{
			NSLog(@"Section %d unread %d",0,appDelegate.messagesUnread.count);
			return appDelegate.messagesUnread.count;
			
		} else if (section == 1) {
			NSLog(@"Section %d all %d",1,appDelegate.messagesAll.count);
			
			return appDelegate.messagesAll.count;
		} else {
			NSLog(@"Section %d !!!",section);
			return 0;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView.tag == 0) {
		
		static NSString *CellIdentifier = @"MessageListCell";
		
		MessageListCustomCell *cell = (MessageListCustomCell*)
		[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if (cell == nil) {
			NSLog(@"Loading cell nib");
			NSArray *topLevelObjects = [[NSBundle mainBundle]
										loadNibNamed:@"MessageListCustomCell" owner:nil options:nil];
			NSLog(@"After nib load");
			
			for (id currentObject in topLevelObjects){
				if ([currentObject isKindOfClass:[UITableViewCell class]]){
					cell = (MessageListCustomCell *) currentObject;
					//cell =  currentObject;
					break;
				}
			}
			//cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
		//cell.
		
		UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];
		UAMessage *message;
		//FIX change dates to be nice, like in mail.app
		//NSLog(@"indexpath.row = %@, section = %@, cell: %@",indexPath.row, indexPath.section);
		if (indexPath.section == 0)
		{
			message = (UAMessage*)[appDelegate.messagesUnread objectAtIndex:indexPath.row];
			[cell.messageSubject setText:message.subject];	
			[cell.messageSummary setText:message.messageSummary];
		}
		else if (indexPath.section == 1)
		{
			message = (UAMessage*)[appDelegate.messagesAll objectAtIndex:indexPath.row];
			[cell.messageSubject setText:message.subject];	
			[cell.messageSummary setText:message.messageSummary];
		}
		
		//cell.messageSubject = message.subject;
		//	NSDateFormatter *format = [[NSDateFormatter alloc] init];
		//	[format setDateFormat:@"MMM dd, yyyy HH:mm"];
		//	NSString *dateString = [format stringFromDate:message.date];
		//	cell.messageSummary = [[NSString alloc] initWithFormat:@"%@ From: %@ To: %@",dateString,message.from,message.to];
		//cell.messageSummary = message.messageSummary;
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (tableView.tag == 0)
	{
		UAMessage *selectedMessage;
		UAMessage *previousSelectedMessage;
	
		previousSelectedMessage = appDelegate.selectedMessage;
	
		if (previousSelectedMessage)
		{
			NSLog(@"Marking previous selected message as read %d",previousSelectedMessage.messageid);
			[[NSNotificationCenter defaultCenter]
			postNotificationName:@"markMessageRead"
			object:nil ];
		}
	
		if (indexPath.section == 0)
		{
			selectedMessage = (UAMessage*)[appDelegate.messagesUnread objectAtIndex:indexPath.row];
			appDelegate.selectedMessage = selectedMessage;
		} else if (indexPath.section == 1) {
			selectedMessage = (UAMessage*)[appDelegate.messagesAll objectAtIndex:indexPath.row];
			appDelegate.selectedMessage = selectedMessage;
		}
	
	//appDelegate.currentFolder = selectedFolder.foldername;
		NSLog(@"didSelectRowAtIndexPath (%@) %@ id: %d body: %@", indexPath.description,
			  selectedMessage.messageSummary, selectedMessage.messageid, selectedMessage.body);
	
	
	//[self presentModalViewController:singleFolderView animated:YES];
	//singleFolderView.singleFolderViewNavbar.topItem.title = appDelegate.currentFolder;
	//NSLog(@"Calling updateCurrentMessagesListFromDatabase");
	//[appDelegate updateCurrentMessagesListFromDatabase];
		[messageView loadHTMLString:appDelegate.selectedMessage.prettybody baseURL:[NSURL URLWithString:@""]];
	}
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	
	if (tableView.tag == 0) {
		if(section == 0) {
			return @"Unread Messages";
		} else if (section == 1) {
			return @"All Messages";
		} else {
			return @"";
		}
	}
}

-(void)refreshMessageTable
{
	//[singleFolderViewTable reloadData];
	[tableView reloadData];

}

-(void)eventHandler: (NSNotification *) notification
{
    NSLog(@"event triggered %@",notification);
	[self refreshMessageTable];
}


@end
