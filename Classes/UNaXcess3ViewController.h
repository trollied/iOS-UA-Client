//
//  UNaXcess3ViewController.h
//  UNaXcess3
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleFolderViewController.h"

//@class SingleFolderView

@interface UNaXcess3ViewController : UIViewController {
	IBOutlet UIButton *folderTestButton;
	IBOutlet UITableView *tableView;
//	IBOutlet UIWebView *announceContent;
	IBOutlet UIToolbar *folderToolbar;
	SingleFolderViewController *singleFolderView;
//	IBOutlet TableCellView *tblCell;
}
@property (nonatomic, retain) IBOutlet UIButton *folderTestButton;
//@property (nonatomic, retain) IBOutlet UITableView *folderListTable;
//@property (nonatomic, retain) IBOutlet UIWebView *announceContent;
@property (nonatomic, retain) IBOutlet UIToolbar *folderToolbar;
@property (nonatomic, retain) SingleFolderViewController *singleFolderView;



- (IBAction)buttonPressed_MainRefresh:(id)sender;
- (IBAction)buttonPressed_OnlineOffline:(id)sender;
- (IBAction)buttonPressed_MainTest:(id)sender;
- (IBAction)buttonPressed_CatchupAll:(id)sender;
- (IBAction)buttonPressed_Wholist:(id)sender;
- (IBAction)buttonPressed_Page:(id)sender;
- (IBAction)buttonPressed_Compose:(id)sender;
//- (IBAction)buttonPressed_:(id)sender;
//- (IBAction)buttonPressed_:(id)sender;
//- (IBAction)buttonPressed_:(id)sender;
//- (IBAction)buttonPressed_:(id)sender;
//- (IBAction)buttonPressed_:(id)sender;
//- (IBAction)buttonPressed_:(id)sender;
- (void)refreshFolderTable;


@end

