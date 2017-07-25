//
//  WPSDragViewController.m
//  Receive
//
//  Created by 吕家腾 on 16/8/1.
//  Copyright © 2016年 Kingsoft. All rights reserved.
//

#import "WPSDragViewController.h"

#import "WPSDragDataSDK.h"
#import "UIView+WPSHelp.h"

#import "WPSDragCollectionViewCell.h"
#import "WPSDragDataViewModel.h"

#import "Masonry.h"

@interface WPSDragViewController ()
<
    WPSDragDataDelegate,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) WPSDragDataSDK *wpsDragDataSDK;

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *navigationBarTitle;
@property (nonatomic, strong) UILabel *helpLabel;
@property (nonatomic, strong) UILabel *fileReceivedTipLabel;
@property (nonatomic, strong) UIButton *sendDesignationFileButton;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, strong) UIImageView *dragImageView;

@property (nonatomic, strong) WPSDragCollectionViewCell *currentCell;
@property (nonatomic, strong) NSIndexPath *currentCellIndexPath;
@property (nonatomic, strong) NSIndexPath *pickCellIndexPath;

@property (nonatomic, strong) NSMutableArray *sendDataAry;


@end

@implementation WPSDragViewController

#pragma mark - Life circle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    
    self.sendDataAry = [[NSMutableArray alloc]initWithArray:[WPSDragDataViewModel getDragDataModelList]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDragDataNotification) name:@"receiveDragData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDesignationFileNotification) name:@"receiveDesignationFile" object:nil];
}

#pragma mark - Setup view

- (void)setupView
{
    // navigation bar
    
    self.navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    [self.navigationBar setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    self.navigationBarTitle = [[UINavigationItem alloc] initWithTitle:@"Receive"];
    [self.navigationBar pushNavigationItem:self.navigationBarTitle animated:YES];
    [self.view addSubview:self.navigationBar];
    
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.height.with.mas_equalTo(66);
    }];
    
    // help label
    
    self.helpLabel = [[UILabel alloc] init];
    [self.helpLabel setTextAlignment:NSTextAlignmentCenter];
    [self.helpLabel setNumberOfLines:0];
    [self.helpLabel setText:@"说明 : 将iPad处于分屏状态后，长按Cell并拖拽即可发送至另一APP"];
    [self.helpLabel setFont:[UIFont systemFontOfSize:14 weight:1]];
    [self.helpLabel setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    [self.helpLabel setTextColor:[UIColor redColor]];
    [self.view addSubview:self.helpLabel];
    [self.helpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationBar.mas_bottom).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.height.with.mas_equalTo(30);
    }];
    
    // colleciton view
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[WPSDragCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.helpLabel.mas_bottom).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-50);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
    }];
    
    // longpress gesture
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
    self.longPressGesture.minimumPressDuration = 0.5;
    [self.collectionView addGestureRecognizer:self.longPressGesture];
    
    // send button
    
    self.sendDesignationFileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendDesignationFileButton setBackgroundColor:[UIColor colorWithRed:71.0/255 green:164.0/255 blue:71.0/255 alpha:1]];
    [self.sendDesignationFileButton setTitle:@"选取文件并向指定App发送" forState:UIControlStateNormal];
    [self.sendDesignationFileButton.titleLabel setNumberOfLines:0];
    [self.sendDesignationFileButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.sendDesignationFileButton.titleLabel setFont:[UIFont fontWithName:@"Verdana" size:18]];
    [self.sendDesignationFileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendDesignationFileButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.sendDesignationFileButton.layer setCornerRadius:5];
    [self.sendDesignationFileButton addTarget:self action:@selector(sendDesignationFileButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendDesignationFileButton];
    
    [self.sendDesignationFileButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-5);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.with.mas_equalTo(250);
        make.height.with.mas_equalTo(40);
    }];
    
    // tip label
    
    self.fileReceivedTipLabel = [[UILabel alloc] init];
    [self.fileReceivedTipLabel setNumberOfLines:0];
    [self.fileReceivedTipLabel setTextAlignment:NSTextAlignmentCenter];
    [self.fileReceivedTipLabel setText:@"文件已存入沙盒"];
    [self.fileReceivedTipLabel setFont:[UIFont fontWithName:@"Verdana" size:22]];
    [self.fileReceivedTipLabel setBackgroundColor:[UIColor colorWithRed:71.0/255 green:164.0/255 blue:71.0/255 alpha:1]];
    [self.fileReceivedTipLabel setTextColor:[UIColor whiteColor]];
    [self.fileReceivedTipLabel setClipsToBounds:YES];
    [self.fileReceivedTipLabel.layer setCornerRadius:5];
    [self.view addSubview:self.fileReceivedTipLabel];
    
    [self.fileReceivedTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(100);
    }];
    [self.fileReceivedTipLabel setAlpha:0];
}

#pragma mark - Button Action

- (void)sendDesignationFileButtonAction
{
    WPSDragDataModel *fileModel = nil;
    
    if (self.pickCellIndexPath)
    {
        fileModel = self.sendDataAry[self.pickCellIndexPath.item];
    }
    
    if (fileModel.dragDataType != WPSDragDataTypeFile)
    {
        return;
    }
    
    NSURL *fileUrl = [NSURL fileURLWithPath:fileModel.filePath];
    
    __weak typeof(self) weakSelf = self;
    [self.wpsDragDataSDK designationSendFile:fileUrl
                                    delegate:self
                                     openURL:@"SendApp"
                                  completion:^{
                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                      [strongSelf.wpsDragDataSDK closeServer];
                                      strongSelf.pickCellIndexPath = nil;
                                  }];
}

#pragma mark - LongPress Gesture

- (void)longPressGestureAction:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint location = [gesture locationInView:self.collectionView];
            self.currentCellIndexPath = [self.collectionView indexPathForItemAtPoint:location];
            self.currentCell = (WPSDragCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.currentCellIndexPath];
            
            if (self.currentCell)
            {
                self.startPoint = [gesture locationInView:self.currentCell];
                self.currentCell.alpha = 0.5;
                
                if ([self.wpsDragDataSDK canDragFile])
                {
                    [self.wpsDragDataSDK openServerWithDelegate:self];
                    [self.wpsDragDataSDK postNotification:nil];
                    [self.wpsDragDataSDK dragBeganSyncDragIconRect:self.currentCell.frame];
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (self.currentCell)
            {
                CGPoint p = [self.currentCell.superview convertPoint:self.currentCell.frame.origin toView:self.view];
                CGRect rect = CGRectMake(p.x,  p.y, self.currentCell.frame.size.width, self.currentCell.frame.size.height);
                
                if (self.dragImageView == nil)
                {
                    self.dragImageView = [[UIImageView alloc] initWithImage:[UIView generateDragImageWithView:self.currentCell]];
                    [self.dragImageView setFrame:rect];
                    [self.view addSubview:self.dragImageView];
                }
                
                CGPoint newPoint = [gesture locationInView:self.dragImageView];
                CGFloat deltaX = newPoint.x - self.startPoint.x;
                CGFloat deltaY = newPoint.y - self.startPoint.y;
                
                [UIView animateWithDuration:0 animations:^{
                    self.dragImageView.center = CGPointMake(self.dragImageView.center.x + deltaX, self.dragImageView.center.y + deltaY);
                }];
                
                [self.wpsDragDataSDK dragChangedSyncDragIconWithImage:[UIView generateDragImageWithView:self.currentCell] fromRect:self.dragImageView.frame];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if (self.currentCell)
            {
                WPSDragDataModel *model = self.sendDataAry[self.currentCellIndexPath.item];
                
                if (!CGRectContainsPoint(self.view.frame, self.dragImageView.center))
                {
                    __weak typeof(self) weakSelf = self;
                    [self.wpsDragDataSDK dragEndedSyncDragIconRect:self.currentCell.frame completion:^{
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if (model.dragDataType == WPSDragDataTypeFile)
                        {
                            // 发送File
                            
                            [strongSelf.wpsDragDataSDK sendFile:[NSURL fileURLWithPath:model.filePath] completion:^{
                                [strongSelf.wpsDragDataSDK closeServer];
                                [strongSelf resetCurrentCell];
                                [strongSelf refreshCollectionView];
                            }];
                        }
                        else if (model.dragDataType == WPSDragDataTypeString)
                        {
                            // 发送String
                            
                            /*
                            // 无回应发送
                            [self.wpsDragDataSDK send:model.text completion:^{
                                [strongSelf.wpsDragDataSDK closeServer];
                                [strongSelf resetCurrentCell];
                                [strongSelf resetPickCell];
                                [strongSelf.collectionView reloadData];
                            }];
                            */
                            
                            // 有回应发送
                            [strongSelf.wpsDragDataSDK send:model.text replyTimeout:-1 replyHandler:^(id  _Nullable replyObject) {
                                if (replyObject) {
                                    NSLog(@"%@",replyObject);
                                }
                                [strongSelf.wpsDragDataSDK closeServer];
                                [strongSelf resetCurrentCell];
                                [strongSelf refreshCollectionView];
                            }];
                        }
                    }];
                }
                else
                {
                    [self.wpsDragDataSDK closeServer];
                    [self resetCurrentCell];
                    [self refreshCollectionView];
                }
            }
        }
            break;

        default:
            break;
    }
}

#pragma mark - WPSDragDataSDK Delegate

- (void)receive:(id)receiveObject
{
    if ([receiveObject isKindOfClass:[NSString class]])
    {
        WPSDragDataModel *model = [[WPSDragDataModel alloc] init];
        model.dragDataType = WPSDragDataTypeString;
        model.text = receiveObject;
        [self.sendDataAry addObject:model];
        [self.collectionView reloadData];
    }
}

- (void)receive:(id)receiveObject reply:(id  _Nullable __autoreleasing *)replayObject
{
    if ([receiveObject isKindOfClass:[NSString class]])
    {
        WPSDragDataModel *model = [[WPSDragDataModel alloc] init];
        model.dragDataType = WPSDragDataTypeString;
        model.text = receiveObject;
        [self.sendDataAry addObject:model];
        [self.collectionView reloadData];
        
        *replayObject = [NSString stringWithFormat:@"有回调的数据发送接收成功，此为回调"];
    }
}

- (NSString *)designateSaveDirectory
{
    return [NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
}

- (void)receiveFileWithPath:(NSString *)filePath
{
    [self refreshCollectionView];
}

// 有需要时设置拖拽代理
- (void)dragBeganWithIconRect:(CGRect)rect
{
}

- (void)dragChangedWithIconImage:(UIImage *)iconImage toRect:(CGRect)rect
{
}

- (void)dragEndedWithIconRect:(CGRect)rect
{
}

- (void)dragAbortWithIconRect:(CGRect)rect
{
}

#pragma mark - CollectionView Delegate & Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.sendDataAry count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WPSDragCollectionViewCell *cell = (WPSDragCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell configCellWithFileModel:self.sendDataAry[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.pickCellIndexPath = indexPath;
}

#pragma mark - CollectionView FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(140, 170);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - Notificaiton

- (void)receiveDragDataNotification
{
    [self.wpsDragDataSDK connectServerWithDelegate:self];
    // 如果不自动处理拖拽图片则需在 dragChangedWithIconImage:(UIImage *)iconImage 中将接收的图片自行添加
    [self.wpsDragDataSDK autoAddReceiveIconView:YES];
}

- (void)receiveDesignationFileNotification
{
    [self.wpsDragDataSDK connectDesignationSendServerWithDelegate:self];
    [self displayTipLabel];
}

- (void)displayTipLabel
{
    self.fileReceivedTipLabel.alpha = 1;
    [UIView animateWithDuration:2 animations:^{
        self.fileReceivedTipLabel.alpha = 0;
    }];
}

#pragma mark - Other Method

- (void)refreshCollectionView
{
    if (self.sendDataAry.count > 0) {
        [self.sendDataAry removeAllObjects];
    }
    [self.sendDataAry addObjectsFromArray:[WPSDragDataViewModel getDragDataModelList]];
    [self.collectionView reloadData];
    
}

- (void)resetCurrentCell
{
    [self.dragImageView removeFromSuperview];
    self.dragImageView = nil;
    self.currentCell.alpha = 1.0;
    self.currentCell = nil;
}

- (void)serverAbort
{
    [[WPSDragDataSDK shareManager]closeServer];
    [self.collectionView reloadData];
    NSLog(@"========serverAbort========");
}

- (void)clientConnectionSucceed
{
    NSLog(@"========clientConnectionSucceed========");
}

- (void)cannotHandleCurrentlyReceivedData
{
    NSLog(@"========cannotHandleCurrentlyReceivedData========");
}

#pragma mark - Lazy init

- (WPSDragDataSDK *)wpsDragDataSDK
{
    if (!_wpsDragDataSDK)
    {
        _wpsDragDataSDK = [[WPSDragDataSDK alloc] init];
    }
    return _wpsDragDataSDK;
}

@end
