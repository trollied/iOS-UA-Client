//
//  UNaXcess3AppDelegate.h
//  UNaXcess3
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "ASIHTTPRequest.h"
#import "UAMessage.h"

@class UNaXcess3ViewController;

@interface UNaXcess3AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UNaXcess3ViewController *viewController;
	NSMutableArray *foldersSubscribed;
	NSMutableArray *foldersUnread;
	NSMutableArray *foldersUnsubscribed;
//	NSMutableArray *foldersAll;
	
	NSMutableArray *messagesUnread;
	NSMutableArray *messagesAll;
	NSMutableArray *users;
	
	NSString *databaseName;
	NSString *databasePath;
	NSInteger folderRefreshNeeded;
	
	NSString *UAUsername;
	NSString *UAPassword;
	NSString *UABaseURL;
	
	NSString *debugText;
	
//	NSString *announceText;
	
	NSString *currentFolder;
	NSString *currentMessage;
	UAMessage *selectedMessage;
	sqlite3 *database;
	NSOperationQueue *queue;
	NSInteger messageMarkAsRead;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UNaXcess3ViewController *viewController;
@property (nonatomic, retain) NSMutableArray *foldersSubscribed;
@property (nonatomic, retain) NSMutableArray *foldersUnread;
@property (nonatomic, retain) NSMutableArray *foldersUnsubscribed;
@property (nonatomic, retain) NSMutableArray *foldersAll;

@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, retain) NSMutableArray *messagesUnread;
@property (nonatomic, retain) NSMutableArray *messagesAll;

@property (nonatomic) NSInteger folderRefreshNeeded;
@property (nonatomic, retain) NSString *UAUsername;
@property (nonatomic, retain) NSString *UAPassword;
@property (nonatomic, retain) NSString *UABaseURL;
@property (nonatomic, retain) NSString *debugText;
@property (nonatomic, retain) NSString *currentFolder;
@property (nonatomic, retain) NSString *currentMessage;
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) UAMessage *selectedMessage;
@property (nonatomic) NSInteger messageMarkAsRead;

//@property (nonatomic, retain) NSString *announceText;

@property (nonatomic) sqlite3 *database;

-(void) checkAndCreateDatabase;
-(void) updateFoldersFromDatabase;

-(void) updateFolderList;
-(void) getAllMessages;
-(void) getAllMessagesInFolder:(NSString*)folderName;
-(void) getNewMessagesInFolder:(NSString*)folderName;
-(void) getMessage:(NSInteger)messageId;
- (void)updateFolderListFinish:(ASIHTTPRequest *)request;
- (void)updateFolderListFail:(ASIHTTPRequest *)request;
- (void)grabAllMessagesInTheBackground:(NSString*)folderName;
- (void)grabAllMessagesInTheBackground;
- (NSString *)convertTokenToDeviceID:(NSData *)token;


@end

