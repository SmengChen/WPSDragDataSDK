//
//  WPSDragDataViewModel.m
//  Send
//
//  Created by 吕家腾 on 16/8/9.
//  Copyright © 2016年 Kingsoft. All rights reserved.
//

#import "WPSDragDataViewModel.h"
#import "WPSDragDataModel.h"
#import "WPSDefine.h"

@implementation WPSDragDataViewModel

+ (nullable NSArray*)getDragDataModelList
{
    NSArray *fileList = [WPSDragDataViewModel getFileList];
    
    NSMutableArray *wpsFileModelList = [[NSMutableArray alloc]init];
    
    for (NSDictionary *fileInfo in fileList)
    {
        WPSDragDataModel *wpsDragDataModel = [[WPSDragDataModel alloc] init];
        NSString *filePath = [fileInfo objectForKey:@"filePath"];
        wpsDragDataModel.filePath = filePath;
        wpsDragDataModel.fileName = [filePath.lastPathComponent stringByDeletingPathExtension];
        wpsDragDataModel.fileType = filePath.pathExtension;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        wpsDragDataModel.fileSize = [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
        wpsDragDataModel.dragDataType = WPSDragDataTypeFile;
        [wpsFileModelList addObject:wpsDragDataModel];
    }
    
    [wpsFileModelList addObjectsFromArray:[WPSDragDataViewModel getStringModelList]];
    
    return [wpsFileModelList copy];
}

+ (NSArray *)getStringModelList
{
    NSMutableArray *wpsStringModelList = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < 4; i++) {
        WPSDragDataModel *wpsDragDataModel = [[WPSDragDataModel alloc] init];
        wpsDragDataModel.dragDataType = WPSDragDataTypeString;
        wpsDragDataModel.text = [NSString stringWithFormat:@"This is a String%d",i];
        [wpsStringModelList addObject:wpsDragDataModel];
    }
    
    return [wpsStringModelList copy];
}

+ (NSArray *) getFileList {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // return results
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    for (NSString *directory in [WPSDragDataViewModel getDocumentPath]) {
        
        NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
        
        for (NSString *filename in tmplist) {
            NSString *filepath = [directory stringByAppendingPathComponent:filename];
            if ([self isDocument:filepath]) {
                NSMutableDictionary *fileDict = [[NSMutableDictionary alloc] init];
                NSError *attributesRetrievalError = nil;
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:filepath error:&attributesRetrievalError];
                
                NSString *realFilename = [filename lastPathComponent];
                [fileDict setObject:realFilename forKey:@"fileName"];
                [fileDict setObject:filepath forKey:@"filePath"];
                [fileDict setObject:[attributes fileCreationDate] forKey:@"fileCreationDate"];
                [fileList addObject:fileDict];
            }
        }
    }
    
    [fileList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDate *first = [(NSMutableDictionary *) obj1 valueForKey:@"fileCreationDate"];
        NSDate *second = [(NSMutableDictionary *) obj2 valueForKey:@"fileCreationDate"];
        return [second compare:first];
    }];
    
    return fileList;
}

+ (BOOL) isDocument:(NSString *)filepath {
    NSArray *formatList = [Formats componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *extension = [filepath pathExtension];
    for (NSString *formatName in formatList) {
        if ([extension isEqualToString:formatName])
            return YES;
    }
    return NO;
}

+ (NSMutableArray *) getDocumentPath {
    NSString *docPaths = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    NSMutableArray *paths = [NSMutableArray array];
    [paths addObject:[[NSBundle mainBundle] resourcePath]];
    [paths addObject:docPaths];
    
    return paths;
}

@end
