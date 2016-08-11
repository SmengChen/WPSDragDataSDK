//  WPSDragDataSDK Version 1.1.0
//  WPSDragDataSDK.h
//
//  Created by Kingsoft Office on 15/10/18.
//  Copyright © 2015年 Kingsoft Office. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KWAppPosition)
{
    KWAppPositionNone,
    KWAppPositionLeft,
    KWAppPositionRight,
};

typedef void (^WPSVoidBlock) (void);
typedef void (^WPSReplyHandler) (id _Nullable replyObject);

@protocol WPSDragDataDelegate <NSObject>

@optional

#pragma mark - 接收数据回调

/**
 *  接收数据回调
 *
 *  @param receiveObject 接收到的数据，和发送方的数据类型相同 NSString，JSON 或 NSData
 */
- (void)receive:(nullable id)receiveObject;

/**
 *  接收数据回调，并且可响应
 *
 *  @param receiveObject 接收到的数据，和发送方的数据类型相同 NSString，JSON 或 NSData
 *  @param replayObject  回应数据，支持 NSString，JSON， NSData
 */
- (void)receive:(nullable id)receiveObject
          reply:(id _Nullable * _Nullable)replayObject;

/**
 *  指定文件接收路径
 *  如果不指定路径，将放入 tmp 文件夹中
 *
 *  @return 文件接受保存路径
 */
- (nullable NSString *)designateSaveDirectory;

/**
 *  文件接收回调
 *
 *  @param filePath 文件路径
 */
- (void)receiveFileWithPath:(nonnull NSString*)filePath;

/**
 *  接收指定发送的文件（接收通过designationSendFile发送的数据）
 *
 *  @param filePath 文件路径
 */
- (void)receiveDesignationSendFileWithPath:(nonnull NSString*)filePath;

#pragma mark - 接受拖拽事件回调
/**
 *  图标拖拽开始时的回调 （接收通过dragBeganSyncDragIconRect发送的数据）
 *
 *  @param rect 当前图标rect
 */
- (void)dragBeganWithIconRect:(CGRect)rect;

/**
 *  图标拖拽过程中的回调 （接收通过dragChangedSyncDragIconWithImage发送的数据）
 *
 *  @param iconImage 图标截图
 *  @param rect      图标rect
 */
- (void)dragChangedWithIconImage:(nonnull UIImage *)iconImage
                          toRect:(CGRect)rect;

/**
 *  图标拖拽结束的回调 （接收通过dragEndedSyncDragIconRect发送的数据）
 *
 *  @param rect 图标rect
 */
- (void)dragEndedWithIconRect:(CGRect)rect;

/**
 *  图标拖拽中断的回调 （接收通过dragAbortSyncDragIconRect发送的数据）
 *
 *  @param rect 图标rect
 */
- (void)dragAbortWithIconRect:(CGRect)rect;

#pragma mark - 服务相关回调

/**
 *  服务中断回调
 */
- (void)serverAbort;

/**
 *  客户端连接成功回调
 */
- (void)clientConnectionSucceed;

/**
 *  无法处理当前接收的数据（一般情况是自身版本过低，无法处理高版本发送的新数据）
 */
- (void)cannotHandleCurrentlyReceivedData;

@end

@interface WPSDragDataSDK : NSObject

@property (nonatomic, weak) id<WPSDragDataDelegate>delegate;

+ (WPSDragDataSDK *)shareManager;

#pragma mark - 发送数据或文件

/**
 *  发送数据
 *  此接口只负责发送，无对方响应回调
 *
 *  @param parameters 发送的数据，类型支持 NSString，JSON，NSData
 *  @param completion 发送完成回调
 */
- (void)send:(nullable id)sendObject
  completion:(nullable WPSVoidBlock)completion;

/**
 *  发送数据，并负责监听对方响应
 *  对方需实现 `receive:reply:` 接口进行回应，否则将会超时。
 *
 *  @param parameters   发送的数据，类型支持 NSString，JSON，NSData
 *  @param replyTimeout 超时时间。设置而为 -1 时为无超时。
 *  @param replyHandler 对方回应回调
 */
- (void)send:(nullable id)sendObject
replyTimeout:(NSTimeInterval)replyTimeout
replyHandler:(nullable WPSReplyHandler)replyHandler;

/**
 *  发送文件
 *  此接口只负责发送，无对方响应回调
 *
 *  @param fileURL    本地文件路径
 *  @param completion 发送完成回调
 */
- (void)sendFile:(nonnull NSURL *)fileURL
      completion:(nullable WPSVoidBlock)completion;


/**
 *  将文件发送到指定的App (接收方通过调用connectShareServerWithDelegate接口连接该服务)
 *
 *  @param fileURL    本地文件路径
 *  @param openURL    指定的App URL scheme
 *  @param delegate   委托
 *  @param completion 发送完成回调
 */
- (void)designationSendFile:(NSURL*)fileURL
                   delegate:(id)delegate
                    openURL:(NSString*)openURL
                 completion:(nullable WPSVoidBlock)completion;

#pragma mark - 发送拖拽相关信息
/**
 *  拖拽开始发送图标的 rect 给对方
 *
 *  @param rect 图标 rect 此接口只负责发送，没有回复
 */
- (void)dragBeganSyncDragIconRect:(CGRect)rect;

/**
 *  拖拽移动过程将图标截图和当前的 rect 发送给对方
 *
 *  @param iconImage 图标截图
 *  @param rect      图标rect
 */
- (void)dragChangedSyncDragIconWithImage:(nonnull UIImage *)iconImage
                                fromRect:(CGRect)rect;

/**
 *  拖拽结束发送图标的 rect 给对方
 *
 *  @param rect       图标 rect
 *  @param completion 同步完成回调
 */
- (void)dragEndedSyncDragIconRect:(CGRect)rect
                       completion:(nullable WPSVoidBlock)completion;

/**
 *  拖拽中断同步图标 rect 给对方
 *
 *  @param rect       图标 rect
 *  @param completion 同步完成回调
 */
- (void)dragAbortSyncDragIconRect:(CGRect)rect
                       completion:(nullable WPSVoidBlock)completion;

#pragma mark - 服务相关
/**
 *  打开服务
 *  使用 SDK 发送功能，需先调用此接口开启服务，并且调用 `postNotification:` 接口，通知接受端 APP 调用 `connectServerWithDelegate:` 连接服务
 *
 *  @param delegate 回调委托
 *
 *  @return 开启结果
 */
- (BOOL)openServerWithDelegate:(id<WPSDragDataDelegate>)delegate;

/**
 *  连接服务
 *  接收端需调用 `addObserver:callback:` 监听通知，在收到通知后，调用 `connectServerWithDelegate:` 连接服务
 *
 *  @param delegate 回调委托
 *
 *  @return 连接结果
 */
- (BOOL)connectServerWithDelegate:(id<WPSDragDataDelegate>)delegate;


/**
 *  连接指定发送文档传输服务(连接通过designationSendFileWithPath接口发送的文档（非拖拽）)
 *
 *  @param delegate 回调委托
 *
 *  @return 连接结果
 */
- (BOOL)connectDesignationSendServerWithDelegate:(id<WPSDragDataDelegate>)delegate;

/**
 *  关闭服务
 *  完成发送功能之后，建议关闭服务，下一次发送之前，再次打开服务
 *
 *  @return 关闭结果
 */
- (BOOL)closeServer;

/**
 *  服务是否连接成功
 *
 *  @return 连接结果
 */
- (BOOL)isConnectSucceed;

/**
 *  通信端口是否打开(跨进程通知回调中使用，如果当前通信端口已打开则说明只需对方App连接该端口即可，自身则无需连接)
 *
 *  @return 打开结果
 */
- (BOOL)isOpenSucceed;

#pragma mark - 跨进程通知相关
/**
 *  添加观察者 （在 - (void)applicationDidBecomeActive:(UIApplication *)application 中调用）
 *  调用此接口，将自己注册为观察者，当接到对方发来的通知时，调用 `connectServerWithDelegate:` 连接服务
 *
 *  @param observer 观察者
 *  @param callback 收到通知回调
 */
- (void)addObserver:(id)observer
           callback:(CFNotificationCallback)callback;

/**
 *  移除观察者（在 -(void)applicationWillResignActive:(UIApplication *)application 中调用）
 *
 *  @param observer 观察者
 */
- (void)removeObserver:(id)observer;

/**
 *  发送通知 （拖拽手势结束，准备发送文件时调用）
 *
 *  @param userInfo 该参数暂时没有用到，可传nil
 */
- (void)postNotification:(nullable CFDictionaryRef)userInfo;

/**
 *  启动后台任务（在进入后台时调用）
 *
 *  @param application
 *
 *  @return 启动结果
 */
- (BOOL)setApplicationDidEnterBackground:(UIApplication *)application;

/**
 *  用于解析调用者传输过来url
 *
 *  @param url
 *  @param sourceApplication
 *  @param annotation
 *
 *  @return 是否是来自WPSDragDataSDK的调用
 */
+ (BOOL)parseHandleOpenURL:(nullable NSURL *)url
         sourceApplication:(nullable NSString *)sourceApplication
                annotation:(id)annotation;

#pragma mark - 其他
/**
 *  接受到拖拽视图时，是否自动展示出 view 加载到 window 上
 *  默认设置为 YES
 *
 *  @param isNeed 是否需要
 */
- (void)autoAddReceiveIconView:(BOOL)isNeed;

/**
 *  询问是否可以拖拽文件
 *
 *  @return 是否可拖拽
 */
- (BOOL)canDragFile;

/**
 *  设备处于分屏模式下时，获取当前 App 的位置
 *
 *  @return App位置 （左侧、右侧）
 */
+ (KWAppPosition)getAppPosition;

/**
 *  是否显示日志log
 *  默认设置为 NO
 *
 *  @param isDebugMode 是否显示
 */
+ (void)setDebugMode:(BOOL)isDebugMode;
@end

NS_ASSUME_NONNULL_END
