//
//  WPSDragDataModel.h
//  Send
//
//  Created by 吕家腾 on 16/8/9.
//  Copyright © 2016年 Kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WPSDragDataType)
{
    WPSDragDataTypeNone,
    WPSDragDataTypeString,
    WPSDragDataTypeJson,
    WPSDragDataTypeData,
    WPSDragDataTypeFile
};

@interface WPSDragDataModel : NSObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *text;

@property (nonatomic, assign) NSUInteger fileSize;
@property (nonatomic, assign) WPSDragDataType dragDataType;

@end
