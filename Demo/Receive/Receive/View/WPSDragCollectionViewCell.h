//
//  WPSDragCollectionViewCell.h
//  Receive
//
//  Created by 吕家腾 on 16/8/1.
//  Copyright © 2016年 Kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPSDragDataModel.h"

@interface WPSDragCollectionViewCell : UICollectionViewCell

- (void)configCellWithFileModel:(WPSDragDataModel *)model;

@end
