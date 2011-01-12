//
//  UAMessage.m
//  UNaXcess
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UAMessage.h"


@implementation UAMessage
@synthesize messageid,foldername,from,to,subject,body,prettybody,date,read, messageSummary;

//foldername, fromname, toname,subject,body,epoch,read
//"subject":"Consider Phlebas","epoch":1290118487,"read":true,"from":"Orion"}

-(id)initWithMesageId:(NSInteger)i foldername:(NSString*)fn from:(NSString*)f to:(NSString*)t
		subject:(NSString*)s body:(NSString*)b
		   read:(NSInteger)r epoch:(NSInteger)e
{
	self.messageid = i;
	self.date = [NSDate dateWithTimeIntervalSince1970:e];
	self.from = f;
	self.to = t;
	self.foldername = fn;
	self.read = r;
	self.body = b;
	self.subject = s;
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:@"MMM dd, yyyy HH:mm"];
	NSString *dateString = [format stringFromDate:self.date];
	
	NSLog(@"initting message %d",self.messageid);
	
	if ( self.to != nil)
	{
		self.messageSummary = [[NSString alloc] initWithFormat:@"%@ From: %@ To: %@",dateString,self.from,self.to];
	} else {
		self.messageSummary = [[NSString alloc] initWithFormat:@"%@ From: %@",dateString,self.from];		
	}
	
	//NSString *tempPretty = [[NSString alloc] initWithString:self.body];
	
	//NSString *tempPretty = [[NSString alloc] initWithFormat:@"<HTML><HEAD></HEAD><BODY>%@</BODY></HTML>"];
	
	NSString *tempPretty = [[NSString alloc] initWithFormat:@"%@",self.body];
	tempPretty = [tempPretty stringByReplacingOccurrencesOfString:@"\r\n>" withString:@"<br/>&gt;"];
	
	tempPretty = [tempPretty stringByReplacingOccurrencesOfString:@"\r\n" withString:@"<br/>"];

	tempPretty = [tempPretty stringByReplacingOccurrencesOfString:@"\r" withString:@"<br/>"];

	tempPretty = [tempPretty stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];

	
	NSString *messageheader;
	
	if (self.to != nil) {
		messageheader = [[NSString alloc] initWithFormat:@"<B>Message: </B> %d <B>From:</B> %@ <B>To:</B> %@<BR/><BR/>",
						  self.messageid, self.from, self.to];
	} else {
		messageheader = [[NSString alloc] initWithFormat:@"<B>Message: </B> %d <B>From:</B> %@<BR/><BR/>",
						  self.messageid, self.from];		
	}
	
	self.prettybody = [[NSString alloc] initWithFormat:@"<HTML><HEAD></HEAD><BODY>%@%@</BODY></HTML>",
					   messageheader, tempPretty];
	NSLog(@"done initting message %d",self.messageid);

	return self;
}

@end
