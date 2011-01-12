//
//  UAFolder.h
//  UNaXcess
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UAFolder : NSObject {
	NSInteger folderid;
	NSString *foldername;
	NSInteger unread;
	NSInteger unreadtome;
	NSInteger nummessages;

}

@property (nonatomic, retain) NSString *foldername;
@property (nonatomic) NSInteger folderid;
@property (nonatomic) NSInteger unread;
@property (nonatomic) NSInteger unreadtome;
@property (nonatomic) NSInteger nummessages;



-(id)initWithName:(NSString *)n folderid:(NSInteger)fid unread:(NSInteger)ur unreadtome:(NSInteger)urtm nummessages:(NSInteger)nm;


@end
