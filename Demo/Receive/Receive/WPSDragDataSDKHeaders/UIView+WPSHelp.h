//
//  UIView+WPSHelp.h
//  WPSDragDataSDK
//
//  Created by 何海伟 on 8/9/16.
//  Copyright © 2016 何海伟. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIView (WPSHelp)

/**
 *  将一个View生成一个图片
 *
 *  @param view 需要生成图片的view
 *
 *  @return 生成图片
 */
+ (nullable UIImage*)generateDragImageWithView:(nullable UIView*)view;

@end

NS_ASSUME_NONNULL_END