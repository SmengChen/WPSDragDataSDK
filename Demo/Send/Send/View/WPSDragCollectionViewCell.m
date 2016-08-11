//
//  WPSDragCollectionViewCell.m
//  Send
//
//  Created by 吕家腾 on 16/8/1.
//  Copyright © 2016年 Kingsoft. All rights reserved.
//

#import "WPSDragCollectionViewCell.h"
#import "WPSDefine.h"
#import "Masonry.h"

@interface WPSDragCollectionViewCell ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *thumbImageView;
@end

@implementation WPSDragCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 5;

        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.iconImageView];
        
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(14);
            make.left.equalTo(self.contentView.mas_left).with.offset(8);
            make.width.height.with.mas_equalTo(34);
        }];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.label setNumberOfLines:0];
        [self.label setTextAlignment:NSTextAlignmentLeft];
        [self.label setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:self.label];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(14);
            make.left.equalTo(self.iconImageView.mas_right).with.offset(4);
            make.right.equalTo(self.contentView.mas_right).with.offset(-8);
            make.height.with.mas_equalTo(34);
        }];
        
        self.thumbImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.thumbImageView sizeToFit];
        [self.contentView addSubview:self.thumbImageView];
        
        [self.thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-14);
            make.left.equalTo(self.contentView.mas_left).with.offset(8);
            make.right.equalTo(self.contentView.mas_right).with.offset(-8);
            make.height.with.mas_equalTo(94);
        }];
    }
    return self;
}

- (void)configCellWithFileModel:(WPSDragDataModel*)model
{
    if (model.dragDataType == WPSDragDataTypeFile)
    {
        self.label.text = model.fileName;
        
        NSString *wordFormatStr = [NSString stringWithFormat:@"%@",WORD_EXT];
        NSArray *wordFormats = [wordFormatStr componentsSeparatedByString:@" "];
        
        NSString *pptFormatStr = [NSString stringWithFormat:@"%@",PPT_EXT];
        NSArray *pptFormats = [pptFormatStr componentsSeparatedByString:@" "];
        
        NSString *etFormatStr = [NSString stringWithFormat:@"%@",ET_EXT];
        NSArray *etFormats = [etFormatStr componentsSeparatedByString:@" "];
        
        NSString *musicFormatStr = [NSString stringWithFormat:@"%@",MUSIC_EXT];
        NSArray *musicFormats = [musicFormatStr componentsSeparatedByString:@" "];
        
        NSString *vedioFormatStr = [NSString stringWithFormat:@"%@",VEDIO_EXT];
        NSArray *vedioFormats = [vedioFormatStr componentsSeparatedByString:@" "];
        
        NSString *imageFormatStr = [NSString stringWithFormat:@"%@",IMAGE_EXT];
        NSArray *imageFormats = [imageFormatStr componentsSeparatedByString:@" "];
        
        NSString *iconImageName;
        NSString *thumbImageName;
        
        if ([wordFormats containsObject:model.fileType])
        {
            iconImageName = @"wps";
            thumbImageName = @"iPad_3_4_0_qing_help_doc";
            
        }
        else if ([pptFormats containsObject:model.fileType])
        {
            iconImageName = @"wpp";
            thumbImageName = @"iPad_3_4_0_qing_help_ppt";
        }
        else if ([etFormats containsObject:model.fileType])
        {
            iconImageName = @"et";
            thumbImageName = @"iPad_3_4_0_qing_help_xls";
        }
        else if ([model.fileType isEqualToString:@"pdf"])
        {
            iconImageName = @"pdf";
            thumbImageName = @"iPad_3_4_0_qing_help_pdf";
        }
        else if ([imageFormats containsObject:model.fileType])
        {
            iconImageName = @"image";
            thumbImageName = @"iPad_3_4_0_qing_photo";
        }
        else if ([musicFormats containsObject:model.fileType])
        {
            iconImageName = @"music";
            thumbImageName = @"iPad_3_4_0_qing_VideoandMusic";
        }
        else if ([vedioFormats containsObject:model.fileType])
        {
            iconImageName = @"vedio";
            thumbImageName = @"iPad_3_4_0_qing_VideoandMusic";
        }
        else if ([model.fileType isEqualToString:@"zip"])
        {
            iconImageName = @"zip";
            thumbImageName = @"iPad_3_4_0_qing_unknown";
        }
        else
        {
            iconImageName = @"unknown";
            thumbImageName = @"iPad_3_4_0_qing_unknown";
        }
        
        self.iconImageView.image = [UIImage imageNamed:iconImageName];
        self.thumbImageView.image = [UIImage imageNamed:thumbImageName];
    }
    else if (model.dragDataType == WPSDragDataTypeString)
    {
        self.label.text = model.text;
        
        self.iconImageView.image = [UIImage imageNamed:@"text"];
        self.thumbImageView.image = [UIImage imageNamed:@"iPad_3_4_0_qing_txt"];
    }
}

- (void)setSelected:(BOOL)selected
{
    if (selected)
    {
        self.contentView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.1];
    }
    else
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

@end
