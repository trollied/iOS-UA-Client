//
//  FolderListCustomCell.h
//  UNaXcess3
//
//  Created by Phillip Jones on 29/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FolderListCustomCell : UITableViewCell {
	IBOutlet UILabel *folderName;
	IBOutlet UILabel *msgText;
}

@property (nonatomic,retain) 	IBOutlet UILabel *folderName;

@property (nonatomic,retain) 	IBOutlet UILabel *msgText;


@end
