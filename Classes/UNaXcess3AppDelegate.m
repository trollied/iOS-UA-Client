//
//  UNaXcess3AppDelegate.m
//  UNaXcess3
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UNaXcess3AppDelegate.h"
#import "UNaXcess3ViewController.h"
#import "UAFolder.h"
#import "UAMessage.h"
#import "SingleFolderViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

@implementation UNaXcess3AppDelegate

@synthesize window;
@synthesize viewController;
@synthesize foldersSubscribed,foldersUnread,foldersUnsubscribed,messagesUnread,messagesAll,users;
@synthesize foldersAll;
@synthesize folderRefreshNeeded;
@synthesize debugText;
@synthesize currentFolder;
@synthesize currentMessage;
@synthesize queue;
@synthesize database;
@synthesize UAUsername;
@synthesize UAPassword;
@synthesize UABaseURL;
@synthesize selectedMessage;
@synthesize messageMarkAsRead;
//@synthesize announceText;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
	NSLog(@"didFinishLaunchingWithOptions started");
	if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK) {
		NSLog(@"Can now use sqlite on multiple threads, using the same connection");
	}
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(eventHandler:)
	 name:@"refreshFolderData"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(eventHandler:)
	 name:@"refreshMessagesBG"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(eventHandler:)
	 name:@"refreshMemoryMessageList"
	 object:nil ];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(eventHandler:)
	 name:@"markMessageRead"
	 object:nil ];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	UAUsername = [userDefaults stringForKey:@"username"];
	UAPassword = [userDefaults stringForKey:@"password"];
	UABaseURL = [userDefaults stringForKey:@"jsonurl"];

	UABaseURL = [[NSString alloc] initWithString:@"https://www.ua2.org/uaJSON/"];
	
	NSLog(@"Username: %@ Pass: %@ url: %@",UAUsername,UAPassword,UABaseURL);
	
	if ([UAUsername length]==0 || [UAPassword length]==0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings" 
														message:@"Please add your UA username/password in iPhone Settings->UNaXcess"
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	
	databaseName = @"ua3.sqlite";
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
	// Execute the "checkAndCreateDatabase" function
	[self checkAndCreateDatabase];
	
	[self updateFoldersFromDatabase];
	if (folderRefreshNeeded==1) {
		self.updateFolderList;
	}
	//announceText = @"Announcement 1<br/>Announcement 2<br/>Announcement 3<br/>Announcement 4<br/>Announcement 5<br/>Announcement 6<br/>Announcement 7<br/>";
	
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	NSLog(@"didFinishLaunchingWithOptions finished");
    //CGRect  rect = [[UIScreen mainScreen] bounds];
    //[window setFrame:rect];
    return YES;
}

-(void) checkAndCreateDatabase{
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	NSLog(@"Checking if DB exists");
	// If the database already exists then return without doing anything
	if(success)
	{
		NSLog(@"DB exists");
		if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
			NSLog(@"Database opened");
		
		}
		return;
	}	
	
	NSLog(@"DB does not exist");

	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	[fileManager release];
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		NSLog(@"Database opened");
	}
}

-(void)updateCurrentMessagesListFromDatabase {
	messagesUnread = [[NSMutableArray alloc] init];
	messagesAll = [[NSMutableArray alloc] init];
	
	NSLog(@"Loading messages from database");
	NSString *q = [[NSString alloc] initWithFormat:@"select count(*) from messages where foldername='%@'",currentFolder];
	//const char *sqlCountStatement = "select count(*) from messages where foldername";
	char *sqlCountStatement = [q cString];
	NSInteger cnt;
	sqlite3_stmt *compiledCountStatement;
	if(sqlite3_prepare_v2(database, sqlCountStatement, -1, &compiledCountStatement, NULL) == SQLITE_OK) {
		NSLog(@"Executing messages count sql query, folder %@",currentFolder);	
		
		while(sqlite3_step(compiledCountStatement) == SQLITE_ROW) {
			cnt = sqlite3_column_int(compiledCountStatement,0);
			NSLog(@"count is : %d from database",cnt);
			
		}
	}
	if (cnt==0) {
		NSLog(@"Folder %@ empty in DB. Queueing message fetch",currentFolder);
		[self grabAllMessagesInTheBackground:currentFolder];
	} else {
		NSLog(@"Folder %@ not empty in DB. Fetching messages",currentFolder);

		NSString *qu = [[NSString alloc] initWithFormat:@"select distinct id,foldername, fromname, toname,subject,body,epoch,read from messages where foldername='%@' order by id asc",currentFolder];
		char *query = [qu cString];
		NSLog(@"query: %@", qu);
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, query, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				NSInteger messageId = sqlite3_column_int(compiledStatement,0);
				NSString *folderName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
				NSString *fromName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
				NSString *toName;
				NSString *subject;
				NSString *body;
				
				char *ctoName = sqlite3_column_text(compiledStatement, 3);
				if (ctoName == NULL)
				{
					toName = [[NSString alloc] initWithString:@""];
				}
				else
				{
					toName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
				}
				
				char *csubject = sqlite3_column_text(compiledStatement, 4);
				
				if (csubject == NULL)
				{
					subject = [[NSString alloc] initWithString:@""];
				}
				else
				{
					subject = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
				}
				
				char *cbody = sqlite3_column_text(compiledStatement, 5);
				
				if (cbody == NULL)
				{
					body = [[NSString alloc] initWithString:@""];
				}
				else
				{
					body = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
				}
				
				NSInteger epoch = sqlite3_column_int(compiledStatement,6);
				NSInteger read = sqlite3_column_int(compiledStatement,7);

				NSLog(@"Adding message: %d from database",messageId);
				//UAFolder *folder = [[UAFolder alloc] initWithName:folderName folderid:folderId unread:unread unreadtome:unreadtome nummessages:nummessages];
				UAMessage *message = [[UAMessage alloc] initWithMesageId:messageId foldername:folderName from:fromName to:toName subject:subject body:body read:read epoch:epoch];
				NSLog(@"after constructor");

				if (read == 0)
				{
					[messagesUnread addObject:message];
				}
				
				[messagesAll addObject:message];
				[message release];
			}
		}
		else {
			NSLog("Error selecting messages from database for folder %@",currentFolder);
		}
	
	}
	NSLog(@"Posting messages table update notification");
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"refreshMessagesTable"
	 object:nil ];
}

-(void) updateFoldersFromDatabase {
	// Setup the database object
	foldersSubscribed = [[NSMutableArray alloc] init];
	foldersUnread = [[NSMutableArray alloc] init];
	foldersUnsubscribed = [[NSMutableArray alloc] init];
	foldersAll = [[NSMutableArray alloc] init];
	
	NSLog(@"Loading folders from database");
		const char *sqlCountStatement = "select count(*) from folders";
		NSInteger cnt;
		sqlite3_stmt *compiledCountStatement;
		if(sqlite3_prepare_v2(database, sqlCountStatement, -1, &compiledCountStatement, NULL) == SQLITE_OK) {
			NSLog(@"Executing folders count sql query");	
			
			while(sqlite3_step(compiledCountStatement) == SQLITE_ROW) {
				cnt = sqlite3_column_int(compiledCountStatement,0);
				NSLog(@"count is : %d from database",cnt);

			}
		}
		
		sqlite3_finalize(compiledCountStatement);
		if (cnt ==0) {
			folderRefreshNeeded = 1;
			NSLog(@"Folder refresh needed flagged");
			self.updateFolderList;
			return;
		}

	const char *sqlUnreadStatement = "select distinct name,id,unreadcount,unreadtoyou,nummessages from folders where subscribed=1 and unreadcount>0 order by name asc";

		sqlite3_stmt *compiledUnreadStatement;
		if(sqlite3_prepare_v2(database, sqlUnreadStatement, -1, &compiledUnreadStatement, NULL) == SQLITE_OK) {
			NSLog(@"Executing folders sql query");	

			while(sqlite3_step(compiledUnreadStatement) == SQLITE_ROW) {
				NSInteger folderId = sqlite3_column_int(compiledUnreadStatement,1);
				NSString *folderName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledUnreadStatement, 0)];
				NSInteger unread = sqlite3_column_int(compiledUnreadStatement,2);
				NSInteger unreadtome = sqlite3_column_int(compiledUnreadStatement,3);
				NSInteger nummessages = sqlite3_column_int(compiledUnreadStatement,4);
				NSLog(@"Adding folder: %@ from database",folderName);
				UAFolder *folder = [[UAFolder alloc] initWithName:folderName folderid:folderId unread:unread unreadtome:unreadtome nummessages:nummessages];
				[foldersUnread addObject:folder];
				[foldersAll addObject:folder];
				[folder release];
			}
		} else {
			NSLog(@"Cannot execute folders unread sql query");	
		}
	
		const char *sqlFoldersSubscribedStatement = "select name,id,unreadcount,unreadtoyou,nummessages from folders where subscribed=1 and unreadcount=0 order by name asc";
		
		sqlite3_stmt *compiledFSStatement;
		if(sqlite3_prepare_v2(database, sqlFoldersSubscribedStatement, -1, &compiledFSStatement, NULL) == SQLITE_OK) {
			NSLog(@"Executing folders subscribed sql query");	
			
			while(sqlite3_step(compiledFSStatement) == SQLITE_ROW) {
				NSInteger folderId = sqlite3_column_int(compiledFSStatement,1);
				NSString *folderName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledFSStatement, 0)];
				NSInteger unread = sqlite3_column_int(compiledFSStatement,2);
				NSInteger unreadtome = sqlite3_column_int(compiledFSStatement,3);
				NSInteger nummessages = sqlite3_column_int(compiledFSStatement,4);
				NSLog(@"Adding folder: %@ from database",folderName);
				UAFolder *folder = [[UAFolder alloc] initWithName:folderName folderid:folderId unread:unread unreadtome:unreadtome nummessages:nummessages];
				[foldersSubscribed addObject:folder];
				[foldersAll addObject:folder];

				[folder release];
			}
		} else {
			NSLog(@"Cannot execute folders subscribed sql query");	
		}
		
		sqlite3_finalize(compiledFSStatement);
	
		const char *sqlFoldersUnsubscribedStatement = "select name,id,unreadcount,unreadtoyou,nummessages from folders where subscribed=0 order by name asc";
		
		sqlite3_stmt *compiledFUStatement;
		if(sqlite3_prepare_v2(database, sqlFoldersUnsubscribedStatement, -1, &compiledFUStatement, NULL) == SQLITE_OK) {
			NSLog(@"Executing folders unsubscribed sql query");	
			
			while(sqlite3_step(compiledFUStatement) == SQLITE_ROW) {
				NSInteger folderId = sqlite3_column_int(compiledFUStatement,1);
				NSString *folderName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledFUStatement, 0)];
				NSInteger unread = sqlite3_column_int(compiledFUStatement,2);
				NSInteger unreadtome = sqlite3_column_int(compiledFUStatement,3);
				NSInteger nummessages = sqlite3_column_int(compiledFUStatement,4);
				NSLog(@"Adding folder: %@ from database",folderName);
				UAFolder *folder = [[UAFolder alloc] initWithName:folderName folderid:folderId unread:unread unreadtome:unreadtome nummessages:nummessages];
				[foldersUnsubscribed addObject:folder];
				[foldersAll addObject:folder];

				[folder release];
			}
		} else {
			NSLog(@"Cannot execute folders unread sql query");	
		}
		
		sqlite3_finalize(compiledFUStatement);
		
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"refreshFolderTable"
	 object:nil ];
}	

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	NSLog(@"applicationWillResignActive");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	NSLog(@"applicationWillResignActive");
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	NSLog(@"applicationWillEnterForeground");
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	UAUsername = [userDefaults stringForKey:@"username"];
	UAPassword = [userDefaults stringForKey:@"password"];
	UABaseURL = [userDefaults stringForKey:@"jsonurl"];
	
	UABaseURL = [[NSString alloc] initWithString:@"https://www.ua2.org/uaJSON/"];
	
	NSLog(@"Username: %@ Pass: %@ url: %@",UAUsername,UAPassword,UABaseURL);
	
	if ([UAUsername length]==0 || [UAPassword length]==0 ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings" 
														message:@"Please add your UA username/password in iPhone Settings->UNaXcess"
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	NSLog(@"applicationDidBecomeActive");
	[[NSUserDefaults standardUserDefaults] synchronize];

	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	UAUsername = [userDefaults stringForKey:@"username"];
	UAPassword = [userDefaults stringForKey:@"password"];
	NSLog(@"Got user: %@",UAUsername);
	self.updateFolderList;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	NSLog(@"applicationWillTerminate");
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}



/*
-(void) updateFolderList
{
	NSString *s = [[NSString alloc] initWithFormat:@"@%/folders/all",UABaseURL];
	NSURL *url = [NSURL URLWithString:s];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request startAsynchronous];
}
*/
-(void) updateFolderList
{
	NSString *s = [[NSString alloc] initWithFormat:@"%@folders/subscribed",UABaseURL];
	NSURL *url = [NSURL URLWithString:s];

	NSLog(@"updateFolderList start. URL: %@",s);
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setUsername:UAUsername];
	[request setPassword:UAPassword];
	[request setValidatesSecureCertificate:NO]; 
	[request addRequestHeader:@"User-Agent" value:@"iOS UA Client 0.1"];
	[request setDidFailSelector:@selector(updateFolderListFail:)];
	[request setDidFinishSelector:@selector(updateFolderListFinish:)];
	[request setDelegate:self];

	[request startAsynchronous];

};

-(void) markMessageRead
{
#define ASIHTTPREQUEST_DEBUG 1
	NSString *s = [[NSString alloc] initWithFormat:@"%@message/read",UABaseURL];
	//NSString *s = [[NSString alloc] initWithFormat:@"%@message/%d",UABaseURL, self.messageMarkAsRead];
	//NSString *s = [[NSString alloc] initWithFormat:@"%@message/%d",UABaseURL, self.selectedMessage.messageid];
	
	NSURL *url = [NSURL URLWithString:s];
	
	NSLog(@"markMessageRead start. URL: %@",s);
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setUsername:UAUsername];
	[request setPassword:UAPassword];
	[request setValidatesSecureCertificate:NO]; 
	[request addRequestHeader:@"User-Agent" value:@"iOS UA Client 0.1"];
	[request setDidFailSelector:@selector(markMessageReadFail:)];
	[request setDidFinishSelector:@selector(markMessageReadFinish:)];
	[request setDelegate:self];
	
	NSString *postdata = [[NSString alloc] initWithFormat:@"[ %d ]", self.selectedMessage.messageid];
	NSLog(@"post data: %@",postdata);
	[request setRequestMethod:@"POST"];

	[request appendPostData:[postdata dataUsingEncoding:NSUTF8StringEncoding]];
	self.messageMarkAsRead = self.selectedMessage.messageid;
	//NSData *postd = [[NSData alloc] initWithBytes:[postdata UTF8String] length:[postdata length]];
	
//	[request setPostValue:postd forKey:@"data"];
	[request startAsynchronous];
	

		
	
};


- (void)markMessageReadFinish:(ASIHTTPRequest *)request
{
	NSLog(@"message marked as read %@. Updating database", [request responseStatusMessage]);
	
	NSString *markAsReadQuery = [[NSString alloc] 
								  initWithFormat:@"update messages set read = 1 where id = %d",
								 self.messageMarkAsRead];
	NSString *markAsReadQuery2 = [[NSString alloc]
								  initWithFormat:@"update folders set unreadcount = unreadcount - 1 where name = ( select distinct foldername from messages where id = %d )",
								  self.messageMarkAsRead];
	
	sqlite3_stmt *markAsReadStatement;
	sqlite3_stmt *markAsReadStatement2;

	if(sqlite3_prepare_v2(database, [markAsReadQuery UTF8String], -1, &markAsReadStatement, NULL) == SQLITE_OK) {
		NSLog(@"Executing message read query %@", markAsReadQuery);	
		
		sqlite3_step(markAsReadStatement);
		sqlite3_finalize(markAsReadStatement);
	} else {
		NSLog(@"Failed to execute message read update 1");
	}
	
	if(sqlite3_prepare_v2(database, [markAsReadQuery2 UTF8String], -1, &markAsReadStatement2, NULL) == SQLITE_OK) {
		NSLog(@"Executing message read query %@", markAsReadQuery2);	
		
		sqlite3_step(markAsReadStatement2);
		sqlite3_finalize(markAsReadStatement2);
	} else {
		NSLog(@"Failed to execute message read update 2");
	}
}

- (void)markMessageReadFail:(ASIHTTPRequest *)request
{
	NSLog(@"Fail %@", [request responseStatusMessage]);

}


- (void)updateFolderListFinish:(ASIHTTPRequest *)request
{
//		sqlite3 *database;
//		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//		NSString *documentsDir = [documentPaths objectAtIndex:0];
		//databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
		// Use when fetching text data
		NSString *responseString = [request responseString];
	NSDictionary *dictionary = [responseString JSONValue];

		// Use when fetching binary data
		//NSData *responseData = [request responseData];
		NSLog(@"updateFolderList response: %@",responseString);
		//NSData *jsonData = [responseString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
		//NSError *error = nil;
	//NSLog(@"jsonData : %@",responseString);



	//NSDictionary *dictionary = nil;//[[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
		
//	NSLog(@"err: %@",error.description); 
	sqlite3_stmt *compiledStatement;
	
	NSString *deletequery = [[NSString alloc] initWithFormat:@"delete from folders"];
	
	char *query3 = [deletequery UTF8String];
	if(sqlite3_prepare_v2(database, query3, -1, &compiledStatement, NULL) == SQLITE_OK) {
		NSLog(@"Deleting folders");	
		
		sqlite3_step(compiledStatement);
		sqlite3_finalize(compiledStatement);							
	} else {
		NSLog(@"Cannot execute folders delete sql query",sqlite3_errmsg(database));	
	}
	
	
	NSLog(@"Dictionary: %@",[dictionary description]); 
	
//	for (NSArray *element in dictionary) {
//		NSLog(@"dictionary element array: %@", element);
//	}
	
//	NSArray *folders = [dictionary valueForKey:@"folder"];

//		NSLog(@"Folders: %@",[folders description]); 
		
		//NSArray *keys = [folders allValues];
		for (NSArray *folder in dictionary) {
			NSLog(@"folder array: %@",folder);
			NSString *folderName = [folder valueForKey:@"folder"];
			NSInteger messageCount = [[folder valueForKey:@"count"] intValue];
			NSInteger messagesUnread = [[folder valueForKey:@"unread"] intValue];
			//NSInteger subscribed = [[folder valueForKey:@"subscribed"] intValue];
			NSLog(@"Folder: %@ Subscribed: @d Messages: %d Unread: %d",folderName,1,messageCount,messagesUnread); 
				NSString *query = [[NSString alloc] initWithFormat:@"select count(*) from folders where name='%@'",folder];
			char *query2 = [query UTF8String];
				sqlite3_stmt *compiledStatement;
				NSLog(@"before sqlite3_prepare_v2");	

				if(sqlite3_prepare_v2(database, query2, -1, &compiledStatement, NULL) == SQLITE_OK) {
					NSLog(@"Executing folders query for folder %@", folder);	
					
					sqlite3_step(compiledStatement);
					NSInteger cnt = sqlite3_column_int(compiledStatement,0);
					sqlite3_finalize(compiledStatement);
					
					NSLog(@"Count: %d",cnt);
					if (cnt == 0) {
						NSString *insertquery = [[NSString alloc] initWithFormat:@"insert into folders (name,subscribed,unreadcount,unreadtoyou,nummessages) values ('%@',%d,%d,0,%d)",folderName,1,messagesUnread,messageCount];
						char *query3 = [insertquery UTF8String];
						if(sqlite3_prepare_v2(database, query3, -1, &compiledStatement, NULL) == SQLITE_OK) {
							NSLog(@"Executing folders insert for folder %@: %s", folder, query3);	
							
							sqlite3_step(compiledStatement);
							sqlite3_finalize(compiledStatement);							
						} else {
							NSLog(@"Cannot execute folders insert sql query",sqlite3_errmsg(database));	
						}
					}
					
				} else {
					NSLog(@"Cannot execute folders count sql query %s",sqlite3_errmsg(database));	
				}

		}

	self.updateFoldersFromDatabase;
}	
		
- (void)updateFolderListFail:(ASIHTTPRequest *)request
{
	NSLog(@"Fail %@", [request responseStatusMessage]);
}


-(void) getAllMessages
{
	
}

-(void) getAllMessagesInFolder:(NSString*)folderName
{
	
}

-(void) getNewMessagesInFolder:(NSString*)folderName
{
	
}

-(void) getMessage:(NSInteger)messageId
{
	
}

- (void)grabAllMessagesInTheBackground
{
	[self grabAllMessagesInTheBackground:currentFolder];
}

- (void)grabAllMessagesInTheBackground:(NSString*)folderName
{
	NSLog(@"grabAllMessagesInTheBackground");
	
	if (![self queue]) {
		[self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
	}
	
	NSString *s = [[NSString alloc] initWithFormat:@"http://ua2.org/uaJSON/folder/%@/full",folderName];
	NSURL *url = [NSURL URLWithString:s];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setUsername:UAUsername];
	[request setPassword:UAPassword];
	[request setValidatesSecureCertificate:NO]; 
	[request addRequestHeader:@"User-Agent" value:@"iOS UA Client 0.1"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(folderallGetRequestDone:)];
	
	[request setDidFailSelector:@selector(folderallGetRequestFailed:)];
	
	[[self queue] addOperation:request];
}

- (void)folderallGetRequestDone:(ASIHTTPRequest *)request
{
	sqlite3_stmt *compiledStatement;
	sqlite3_stmt *compiledDeleteStatement;

	NSString *response = [request responseString];
	NSLog(@"folderallGetRequestDone: %@",response);
	NSDictionary *dictionary = [response JSONValue];
		
	
	for (NSArray *message in dictionary) {
		NSLog(@"message array: %@",message);
		NSString *messageFolder = [message valueForKey:@"folder"];
		NSInteger messageId = [[message valueForKey:@"id"] intValue];

		NSString *messageBody = [message valueForKey:@"body"];
		NSString *messageSubject = [message valueForKey:@"subject"];
		NSInteger messageEpoch = [[message valueForKey:@"epoch"] intValue];
		NSInteger messageRead = [[message valueForKey:@"read"] intValue];
		NSString *messageFrom = [message valueForKey:@"from"];
		NSString *messageTo = [message valueForKey:@"to"];

		NSLog(@"Folder: %@ id: %d read: %d dt: %d",messageFolder, messageId, messageRead, messageEpoch); 
		NSString *deletequery = [[NSString alloc] initWithFormat:@"delete from messages where id = %d",messageId];
		NSString *insertquery = [[NSString alloc] initWithFormat:@"insert into messages (id,foldername, fromname, toname,subject,body,epoch,read) values (%d,'%@','%@','%@',?,?,%d,%d)",
								 messageId,messageFolder,messageFrom,messageTo,messageEpoch,messageRead];
		char *dquery = [deletequery UTF8String];
		char *query3 = [insertquery UTF8String];
		
		NSLog(@"delete query: %s",dquery);
		
		if(sqlite3_prepare_v2(database, dquery, -1, &compiledDeleteStatement, NULL) == SQLITE_OK) {
			sqlite3_step(compiledDeleteStatement);
			sqlite3_finalize(compiledDeleteStatement);
		}
		
		NSLog(@"query: %s",query3);	

		
		if(sqlite3_prepare_v2(database, query3, -1, &compiledStatement, NULL) == SQLITE_OK) {
			NSLog(@"Executing folders insert for folder %@: %s", messageFolder, query3);	
			if (sqlite3_bind_text (
								   compiledStatement,
								   1,  // Index of wildcard
								   [messageSubject UTF8String],
								   -1,  // length of text
								   SQLITE_TRANSIENT
								   )
				!= SQLITE_OK) {
				NSLog(@"\nCould not bind subject.\n%s",sqlite3_errmsg(database));
				
			}
			if (sqlite3_bind_text (
								   compiledStatement,
								   2,  // Index of wildcard
								   [messageBody UTF8String],
								   -1,  // length of text
								   SQLITE_TRANSIENT
								   )
				!= SQLITE_OK) {
				NSLog("\nCould not bind body.\n%s",sqlite3_errmsg(database));
				
			}			
			sqlite3_step(compiledStatement);
			sqlite3_finalize(compiledStatement);							
		} else {
			NSLog(@"Cannot execute folders insert sql query %s\n%s",sqlite3_errmsg(database),query3);	
		}
	}	
	[self updateCurrentMessagesListFromDatabase];
}

- (void)folderallGetRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"folderallGetRequestFailed %@", error);

}


-(void)eventHandler: (NSNotification *) notification
{
    NSLog(@"event triggered %@",[notification name]);
	if ([[notification name] isEqualToString:@"refreshFolderData"]){
		NSLog(@"Calling updateFolderList from notification eventHandler");
		[self updateFolderList];
	} else if ([[notification name] isEqualToString:@"refreshMessagesBG"]){
		NSLog(@"Calling grabMessagesInTheBackground from notification eventHandler");
		[self grabAllMessagesInTheBackground:currentFolder];
	} else if ([[notification name] isEqualToString:@"refreshMemoryMessageList"]){
		NSLog(@"Calling updateCurrentMessagesListFromDatabase from notification eventHandler");
		[self updateCurrentMessagesListFromDatabase];
	} else if ([[notification name] isEqualToString:@"markMessageRead"]){
		NSLog(@"Calling markMessageRead from notification eventHandler");
		[self markMessageRead];
	} else {
		NSLog(@"Unknown notification sent to ua3appdelegate eventHandler");
	}
	
}



@end
