//
//  UAFolder.m
//  UNaXcess
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UAFolder.h"


@implementation UAFolder
@synthesize folderid, foldername;
@synthesize unread,unreadtome,nummessages;

-(id)initWithName:(NSString *)n folderid:(NSInteger)fid unread:(NSInteger)ur unreadtome:(NSInteger)urtm nummessages:(NSInteger)nm
{
	self.foldername = n;
	self.folderid = fid;
	self.unread = ur;
	self.unreadtome = urtm;
	self.nummessages = nm;
	return self;
}

@end
