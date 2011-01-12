//
//  SingleFolderViewController.h
//  UNaXcess3
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SingleFolderViewController : UIViewController {
	//IBOutlet UITableView *singleFolderViewTable;
	IBOutlet UITableView *tableView;

	IBOutlet UIButton *singleFolderBackButton;
	IBOutlet UIButton *singleFolderRefreshButton;
	IBOutlet UIButton *markAsReadButton;
	IBOutlet UIButton *holdMessageButton;

	IBOutlet UINavigationBar *singleFolderViewNavbar;
	IBOutlet UIWebView *messageView;
}

//@property (nonatomic, retain) IBOutlet UITableView *singleFolderViewTable;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIButton *singleFolderBackButton;
@property (nonatomic, retain) IBOutlet UIButton *singleFolderRefreshButton;
@property (nonatomic, retain) IBOutlet UIButton *markAsReadButton;

@property (nonatomic, retain) IBOutlet UINavigationBar *singleFolderViewNavbar;
@property (nonatomic, retain) IBOutlet UIWebView *messageView;

- (IBAction)buttonPressed_SingleFolderBack:(id)sender;
- (IBAction)buttonPressed_SingleFolderRefresh:(id)sender;
- (IBAction)buttonPressed_MarkAsRead:(id)sender;
- (IBAction)buttonPressed_HoldMessage:(id)sender;

- (void)refreshTable;

@end
