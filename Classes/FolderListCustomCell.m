//
//  FolderListCustomCell.m
//  UNaXcess3
//
//  Created by Phillip Jones on 29/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FolderListCustomCell.h"


@implementation FolderListCustomCell

@synthesize folderName, msgText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
