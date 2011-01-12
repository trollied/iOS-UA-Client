//
//  MessageListCustomCell.h
//  UNaXcess3
//
//  Created by Phillip Jones on 01/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageListCustomCell.h"


@interface MessageListCustomCell : UITableViewCell {
	IBOutlet UILabel *messageSubject;
	IBOutlet UILabel *messageSummary;
}

@property (nonatomic,retain) 	IBOutlet UILabel *messageSubject;

@property (nonatomic,retain) 	IBOutlet UILabel *messageSummary;

@end
