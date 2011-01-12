//
//  MessageListCustomCell.m
//  UNaXcess3
//
//  Created by Phillip Jones on 01/12/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MessageListCustomCell.h"


@implementation MessageListCustomCell

@synthesize messageSubject, messageSummary;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
