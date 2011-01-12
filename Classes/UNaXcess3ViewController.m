//
//  UNaXcess3ViewController.m
//  UNaXcess3
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UNaXcess3ViewController.h"
#import "UNaXcess3AppDelegate.h"
#import "UAFolder.h"
#import "UAMessage.h"
#import "SingleFolderViewController.h"
#import "FolderListCustomCell.h"

@implementation UNaXcess3ViewController
@synthesize folderTestButton;
//@synthesize announceContent;
@synthesize folderToolbar;
@synthesize singleFolderView;


- (IBAction)buttonPressed_MainRefresh:(id)sender
{
	NSLog(@"button MainRefresh pressed");

	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"refreshFolderData"
	 object:nil ];
}


- (IBAction)buttonPressed_CatchupAll:(id)sender
{
	NSLog(@"button CatchupAll pressed");
}

- (IBAction)buttonPressed_Wholist:(id)sender
{
	NSLog(@"button WhoList pressed");
}

- (IBAction)buttonPressed_Page:(id)sender
{
	NSLog(@"button Page pressed");
}

- (IBAction)buttonPressed_Compose:(id)sender
{
	NSLog(@"button Compose pressed");
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
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
	NSLog(@"ua3viewcontroller viewDidLoad start");
	singleFolderView = [[SingleFolderViewController alloc] init];
	UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];

	//[announceContent loadHTMLString:appDelegate.announceText baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:///"]]];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:@"refreshTable"];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(eventHandler:)
	 name:@"refreshFolderTable"
	 object:nil ];
	
	[super viewDidLoad];
	
	NSLog(@"ua3viewcontroller viewDidLoad finish");

}

-(void)eventHandler: (NSNotification *) notification
{
    NSLog(@"event triggered %@",notification);
	[self refreshFolderTable];
}

- (void)refreshFolderTable {
	NSLog(@"refreshfoldertable called");
	[tableView reloadData];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	NSLog(@"ua3viewcontroller viewDidUnLoad");

}


- (void)dealloc {
    [super dealloc];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [arryData count];
	UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (section == 0)
	{
		NSLog(@"Section unread %d,%d",0,appDelegate.foldersUnread.count);
		return appDelegate.foldersUnread.count;
		
	} else if (section == 1) {
		NSLog(@"Section subbed %d,%d",1,appDelegate.foldersSubscribed.count);

		return appDelegate.foldersSubscribed.count;
	} else if (section == 2) {
		NSLog(@"Section unsub %d,%d",2,appDelegate.foldersUnsubscribed.count);

		return appDelegate.foldersUnsubscribed.count;
	} else {
		NSLog(@"Section %d !!!",section);
		return 0;
	}


}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"FolderListCell";

	FolderListCustomCell *cell = (FolderListCustomCell*)
			[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
//    }

	
    if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle]
									loadNibNamed:@"FolderListCustomCell" owner:nil options:nil];
		for (id currentObject in topLevelObjects){
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (FolderListCustomCell *) currentObject;
				//cell =  currentObject;
				break;
			}
		}
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	//cell.
	
    UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (indexPath.section == 0)
	{
		UAFolder *folder = (UAFolder*)[appDelegate.foldersUnread objectAtIndex:indexPath.row];
		//cell.text = folder.foldername;
		cell.folderName.text = folder.foldername;
		//[[NSString alloc] initWithFormat:@"%d messages. %d unread (%d to you)",folder.nummessages,folder.unread,folder.unreadtome];
		cell.msgText.text = [[NSString alloc] initWithFormat:@"%d/%d",folder.unread,folder.nummessages,folder.unreadtome];

		//cell.messageText = 
	} else if (indexPath.section == 1) {
		UAFolder *folder = (UAFolder*)[appDelegate.foldersSubscribed objectAtIndex:indexPath.row];
		//cell.text = folder.foldername;
		cell.folderName.text = folder.foldername;
		cell.msgText.text = [[NSString alloc] initWithFormat:@"%d/%d",folder.unread,folder.nummessages,folder.unreadtome];

	} else if (indexPath.section == 2) {
		UAFolder *folder = (UAFolder*)[appDelegate.foldersUnsubscribed objectAtIndex:indexPath.row];
		//cell.text = folder.foldername;
		cell.folderName.text = folder.foldername;
		cell.msgText.text = [[NSString alloc] initWithFormat:@"%d/%d",folder.unread,folder.nummessages,folder.unreadtome];

	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UNaXcess3AppDelegate *appDelegate = (UNaXcess3AppDelegate *)[[UIApplication sharedApplication] delegate];
	UAFolder *selectedFolder;
	if (indexPath.section == 0)
	{
		selectedFolder = (UAFolder*)[appDelegate.foldersUnread objectAtIndex:indexPath.row];
		appDelegate.currentFolder = selectedFolder.foldername;
	} else if (indexPath.section == 1) {
		selectedFolder = (UAFolder*)[appDelegate.foldersSubscribed objectAtIndex:indexPath.row];
		appDelegate.currentFolder = selectedFolder.foldername;
	} else if (indexPath.section == 2) {
		selectedFolder = (UAFolder*)[appDelegate.foldersUnsubscribed objectAtIndex:indexPath.row];
		appDelegate.currentFolder = selectedFolder.foldername;
	}
	appDelegate.currentFolder = selectedFolder.foldername;
	NSLog(@"didSelectRowAtIndexPath %@",selectedFolder.foldername);
	
	[self presentModalViewController:singleFolderView animated:YES];
	singleFolderView.singleFolderViewNavbar.topItem.title = appDelegate.currentFolder;
	NSLog(@"Calling updateCurrentMessagesListFromDatabase");
	[appDelegate updateCurrentMessagesListFromDatabase];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0) {
		return @"Unread Folders";
	} else if (section == 1) {
		return @"Subscribed Folders";
	} else if (section == 2){
		return @"Unsubscribed Folders";
	} else {
		return @"";
	}

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  28;
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//	return UITableViewCellAccessoryDetailDisclosureButton;
//}


@end
