# WPSDragDataSDK

## 功能

WPSDragDataSDK 用于实现 iPad 分屏下处于前台的两个 APP 相互之间数据通信的功能。

通信方式分为`单向型通信`和`响应型通信`，通信内容支持发送 `数据` 和 `文件`。

其中数据类型支持：NSString，JSON，NSData。

建立于通信机制上，WPSDragDataSDK 还提供了一套 UI 层面的用于实现拖拽流程的接口和回调，可轻松实现视图从一个 APP 移动到另一个 APP 的拖拽过程。

## 集成
首先 Build Phases -> Link Binary With Libraries选项中添加 libWPSDragDataSDK.a

然后 Build Settings -> Other Linker Flags 选项中增加 -ObjC 关键字，因为 WPSDragDataSDK 中使用到了Category，避免Category无法加载

最后 根据需求在需要使用拖拽SDK的类中包含 WPSDragDataSDK.h 、 UIView+WPSHelp.h 头文件

## 使用

### 1. 通信服务连接

使用通信功能之前，两个 APP 都需要加入观察者，用来随时等待对方 APP 发起的请求通信，此过程如同等待电话响铃的过程：

```
- (void)addObserver:(id)observer
           callback:(CFNotificationCallback)callback;
```

当一方 APP 需要进行通信时，首先需要开启服务：

```
- (BOOL)openServerWithDelegate:(id<WPSDragDataDelegate>)delegate;
```

并且发起通信请求：

```
- (void)postNotification:(nullable CFDictionaryRef)userInfo;
```

此时另一方 APP 会观察到有人发起了通信请求，此时只需连接对方开启的服务即可：

```
- (BOOL)connectServerWithDelegate:(id<WPSDragDataDelegate>)delegate;
```

此时，整个通信服务的建立流程就已经完成了，之后便可以正常通信。

**通信服务相关辅助接口**

 判断当前通信服务是否打开成功（**跨进程通知回调中使用，如果当前通信服务已打开成功则说明只需对方App连接该通信服务即可，自身则无需连接，具体使用场景见Demo**）
 
```
- (BOOL)isOpenSucceed;
```

 判断当前通信服务是否连接成功
 
```
- (BOOL)isConnectSucceed;
```

 关闭传输服务,完成发送功能之后，建议关闭服务，下一次发送之前，再次打开服务
 
```
- (BOOL)closeServer;
```

### 2. 通信数据发送及接受

**单向型通信**

```
/**
 * 此接口用于单向型通信，只负责发送，而不关心对方是否接收到。
 * sendObject 为发送的数据，支持 NSString，JSON，NSData
 * completion 为单方面发送完成的异步回调。
 */
- (void)send:(nullable id)sendObject
  completion:(nullable WPSVoidBlock)completion;
```

```
/*
 * 接收单向型通信发送的内容，receiveObject 为 sendObject 的内容。
 */
- (void)receive:(nullable id)receiveObject;
```

**响应型通信**

```
/**
 * 此接口用于响应型通信，负责发送，并且接受对方的响应。
 * replyTimeout 为响应超时时间
 * replyHandler 为对方响应的回调。
 */
- (void)send:(nullable id)sendObject
replyTimeout:(NSTimeInterval)replyTimeout
replyHandler:(nullable WPSReplyHandler)replyHandler;
```

```
/**
 * 此回调用于接收响应型通信发送的内容，并且做出响应。
 * receiveObject 为 sendObject 的内容
 * replayObject 用来设置响应的内容。
 */
- (void)receive:(nullable id)receiveObject
          reply:(id _Nullable * _Nullable)replayObject;
```

**文件发送**

```
/**
 * 此接口用来发送文件。
 * fileURL 为文件路径
 * completion 为发送完成的回调。
 */
- (void)sendFile:(NSURL *)fileURL
      completion:(nullable WPSVoidBlock)completion;
```

```
/**
 * 用来指定接收文件存储的目录，若不实现，文件则默认存储于 tmp 文件夹中
 */
- (nullable NSString *)designateSaveDirectory;

/**
 * 接收到文件后的回调
 * filePath 为文件路径
 */
- (void)receiveFileWithPath:(nonnull NSString*)filePath;
```

### 3. 拖拽 UI 数据发送及接受

WPSDragDataSDK 除了能够发送数据及文件，还能实现一个视图从一个 App 穿越到另一个 App 的效果，以达到 App 之间文件相互拖拽的功能。

**拖拽UI数据发送**

拖拽的接口需结合拖拽手势使用，具体接口如下：

```
/**
 *  拖拽开始时发送视图的 rect 给对方 App
 */
- (void)dragBeganSyncDragIconRect:(CGRect)rect;

/**
 *  拖拽移动过程将所拖拽视图的截图以及视图 rect 同步给对方 App
 */
- (void)dragChangedSyncDragIconWithImage:(UIImage *)iconImage
                                fromRect:(CGRect)rect;

/**
 *  拖拽结束发送视图的 rect 给对方 App
 *
 *  @param rect       图标rect
 *  @param completion 同步完成回调
 */
- (void)dragEndedSyncDragIconRect:(CGRect)rect
                       completion:(nullable WPSVoidBlock)completion;

/**
 *  拖拽中断发送视图的 rect 给对方 App
 *
 *  @param rect       图标rect
 *  @param completion 同步完成回调
 */
- (void)dragAbortSyncDragIconRect:(CGRect)rect
                       completion:(nullable WPSVoidBlock)completion;
```

**拖拽UI数据接收**

下列回调依次用于接收对方同步的拖拽数据：

```
/**
 *  图标拖拽开始时的回调 （接收通过dragBeganSyncDragIconRect发送的数据）
 */
- (void)dragBeganWithIconRect:(CGRect)rect;

/**
 *  图标拖拽过程中的回调 （接收通过dragChangedSyncDragIconWithImage发送的数据）
 */
- (void)dragChangedWithIconImage:(UIImage *)iconImage
                          toRect:(CGRect)rect;

/**
 *  图标拖拽结束的回调 （接收通过dragEndedSyncDragIconRect发送的数据）
 */
- (void)dragEndedWithIconRect:(CGRect)rect;

/**
 *  图标拖拽中断的回调 （接收通过dragAbortSyncDragIconRect发送的数据）
 */
- (void)dragAbortWithIconRect:(CGRect)rect;
```

**视图展现**

```
/**
 *  将一个View生成一个图片（用于生成拖拽的图片）
 *
 */
+ (nullable UIImage*)generateDragImageWithView:(nullable UIView*)view;
```

```
/**
 *  接收到拖拽视图时，是否自动展示出 view 加载到 window 上
 *  默认设置而为 YES
 */
- (void)autoAddReceiveIconView:(BOOL)isNeed;
```

### 4. 单向指定发送文件（非拖拽）
单向指定发送文件主要用于两个 App 之间单向传输文件，不要求接收方在前台运行，但单向指定发送需要知道所指定接收方 App 的 URL Scheme

**发送方调用接口**

```
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
```                         

**接收方调用接口**

```
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
 
 
 当调用以上接口返回YES说明来自对方指定发送，则可调用以下接口连接服务并接收文件数据              
/**
 *  连接指定发送文档传输服务(连接通过designationSendFileWithPath接口发送的文档（非拖拽）)
 *
 */
- (BOOL)connectDesignationSendServerWithDelegate:(id<WPSDragDataDelegate>)delegate;

/**
 *  接收指定发送的文件回调（接收通过designationSendFile发送的数据）
 *
 */
- (void)receiveDesignationSendFileWithPath:(nonnull NSString*)filePath;

```