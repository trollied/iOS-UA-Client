//
//  UAMessage.h
//  UNaXcess
//
//  Created by Phillip Jones on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UAMessage : NSObject {
	NSInteger messageid;
	NSString *foldername;
	NSString *from;
	NSString *to;
	NSString *subject;
	NSString *body;
	NSString *prettybody;
	NSDate *date;
	NSInteger read;
	NSString *messageSummary;
}
//foldername, fromname, toname,subject,body,epoch,read
@property (nonatomic) NSInteger messageid;
@property (nonatomic, retain) NSString *foldername;
@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *to;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSString *prettybody;
@property (nonatomic, retain) NSString *messageSummary;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic) NSInteger read;

-(id)initWithMesageId:(NSInteger)i foldername:(NSString*)fn from:(NSString*)f to:(NSString*)t
			  subject:(NSString*)s body:(NSString*)b
				 read:(NSInteger)r epoch:(NSInteger)e;


@end
