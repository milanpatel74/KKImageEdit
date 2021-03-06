//
//  KKPuzzImageSelectController.m
//  
//
//  Created by finger on 17/2/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPuzzImageSelectController.h"
#import "UIView+Extension.h"
#import "KKImageCollectionCellView.h"
#import "KKSelectImageItemView.h"
#import "LoadingIndicatorView.h"
#import <Photos/Photos.h>
#import "KKPhotoManager.h"
#import "CommDevice.h"
#import "UIImage+Extension.h"

#define MAX_SELECT_COUMT 5
#define SELECT_ITEM_WIDTH 90

static NSString * CellIdentifier = @"GradientCell";

@interface KKPuzzImageSelectController ()<KKImageCollectionCellViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,KKSelectImageItemViewDelegate>
{
    __weak IBOutlet UICollectionView *photoCollectionView;
    
    __weak IBOutlet UIView *selectView;
    __weak IBOutlet UIButton *startPuzzBtn;
    __weak IBOutlet UIScrollView *imageScrollView;
    
    PHCachingImageManager *imageManager;
    PHFetchResult *assetResult;
    
    NSMutableArray *seletedIndexArray;
    
    LoadingIndicatorView *indicatorView;
    
    UIStatusBarStyle style;
}
@end

@implementation KKPuzzImageSelectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen]bounds];
    self.title = @"相片选择";
    self.navigationItem.leftBarButtonItem = [self navLeftBarButtonItem];
    
    seletedIndexArray = [[NSMutableArray alloc]init];
    
    imageManager = [[PHCachingImageManager alloc] init];
    
    style = [[UIApplication sharedApplication]statusBarStyle];
    
    [self layoutUI];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication]setStatusBarStyle:style];
}

#pragma mark -- 导航栏

- (UIBarButtonItem *)navLeftBarButtonItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 12, 20)];
    [button setImage:[UIImage imageNamed:@"backItem"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"backItem"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(popupController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return barButton;
}

- (void)popupController
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -- 界面布局

- (void)layoutUI
{
    photoCollectionView.frame = CGRectMake(0, 0, self.view.width, self.view.height - selectView.height - 64);
    photoCollectionView.delegate = self ;
    photoCollectionView.dataSource = self ;
    [photoCollectionView registerNib:[UINib nibWithNibName:@"KKImageCollectionCellView" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
    
    selectView.frame = CGRectMake(0, photoCollectionView.height, self.view.width, selectView.height);
    
    imageScrollView.frame = CGRectMake(0, 0, selectView.width, selectView.height - startPuzzBtn.height);
    imageScrollView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.3];
    imageScrollView.bounces = YES ;
    imageScrollView.showsVerticalScrollIndicator = NO ;
    imageScrollView.showsHorizontalScrollIndicator = NO ;
    
    startPuzzBtn.frame = CGRectMake(0, imageScrollView.height, selectView.width, startPuzzBtn.height);
    [startPuzzBtn setTitle:@"开始拼图" forState:UIControlStateNormal];
    [startPuzzBtn addTarget:self action:@selector(startPuzzle) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- 数据加载

- (void)loadData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *albumId = [[KKPhotoManager shareInstance]getCameraRollAlbumId];
        
        assetResult = [[KKPhotoManager shareInstance]getAlbumAssetsWithAlbunId:albumId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [photoCollectionView reloadData];
        });
        
    });
}

#pragma mark - UICollectionViewDataSource UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return assetResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    KKImageCollectionCellView *cellView = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PHAsset *asset = assetResult[indexPath.item];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.synchronous = YES ;
    options.networkAccessAllowed = YES ;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    [imageManager requestImageForAsset:asset
                            targetSize:CGSizeMake(CGRectGetWidth(cellView.frame)*scale, CGRectGetHeight(cellView.frame)*scale)
                           contentMode:PHImageContentModeAspectFit
                               options:options
                         resultHandler:^(UIImage *result, NSDictionary *info)
    {
        
        bool downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        
        if(downloadFinined){
            cellView.image = result;
        }
        
    }];
    
    [cellView setIndexPath:indexPath];
    [cellView setDelegate:self];
    [cellView setSeletedMode:YES];
    [cellView setSeletedImage:[seletedIndexArray containsObject:indexPath]];
    
    return cellView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark --UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize _cellSize = CGSizeMake(74, 74);
    
    switch ([CommDevice getDeviceType])
    {
        case iPhoneType_4:
        case iPhoneType_5:
        {
            _cellSize = CGSizeMake(78, 78);
            break;
        }
        case iPhoneType_6:
        {
            _cellSize = CGSizeMake(92, 92);
            break;
        }
        case iPhoneType_6_plus:
        {
            _cellSize = CGSizeMake(102, 102);
            break;
        }
        default:
        {
            _cellSize = CGSizeMake(74, 74);
            break;
        }
    }
    
    return _cellSize;
}

#pragma mark -- KKImageCollectionCellViewDelegate

- (void)selectedImage:(bool)selected indexPath:(NSIndexPath *)indexPath block:(void (^)(NSInteger))handler
{
    if(selected){
        
        bool bExist = false ;
        
        for(NSIndexPath *path in seletedIndexArray){
            
            if(path.section == indexPath.section &&
               path.row == indexPath.row){
                
                bExist = true ;
                
                break ;
                
            }
        }
        
        if(!bExist){
            
            if(seletedIndexArray.count < MAX_SELECT_COUMT){
                
                [seletedIndexArray addObject:indexPath];
                
                KKImageCollectionCellView *cell = (KKImageCollectionCellView *)[photoCollectionView cellForItemAtIndexPath:indexPath];
                [cell setSeletedImage:true];
                
                [self addPuzzleImageWithIndex:indexPath.row];
                
            }else{
                
                KKImageCollectionCellView *cell = (KKImageCollectionCellView *)[photoCollectionView cellForItemAtIndexPath:indexPath];
                [cell setSeletedImage:false];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"最多只能选择5张" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
                [alert show];
                
            }
            
        }
        
    }else{
        
        [seletedIndexArray removeObject:indexPath];
        
        KKImageCollectionCellView *cell = (KKImageCollectionCellView *)[photoCollectionView cellForItemAtIndexPath:indexPath];
        [cell setSeletedImage:false];
        
        [self removeImageWithIndex:indexPath.row];
    }
    
}

#pragma mark -- 开始拼图

- (void)startPuzzle
{
    if(seletedIndexArray.count <= 1){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请至少选择2张图片" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        [alert show];
        
    }else{
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(startPuzzleWithImageAssets:)]){
            
            NSMutableArray *array = [[NSMutableArray alloc]init];
            for(NSIndexPath *indexPath in seletedIndexArray){
                PHAsset *asset = assetResult[indexPath.row];
                [array addObject:asset];
            }
            
            [self.delegate startPuzzleWithImageAssets:array];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }
}

#pragma mark -- 添加删除选择的图片

- (void)addPuzzleImageWithIndex:(NSInteger)index
{
    [self showIndicatorView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        PHAsset *asset = assetResult[index];
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.synchronous = YES ;
        options.networkAccessAllowed = YES ;
        
        [imageManager requestImageForAsset:asset
                                targetSize:[[UIScreen mainScreen]bounds].size
                               contentMode:PHImageContentModeAspectFit
                                   options:options
                             resultHandler:^(UIImage *result, NSDictionary *info)
         {
             
             bool downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
             
             if(downloadFinined){
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     KKSelectImageItemView *lastItem = nil ;
                     for(UIView *view in imageScrollView.subviews){
                         if([view isKindOfClass:[KKSelectImageItemView class]]){
                             lastItem = (KKSelectImageItemView *)view ;
                         }
                     }
                     
                     NSInteger padding = 15;
                     NSInteger startX = padding ;
                     if(lastItem){
                         startX = lastItem.x + lastItem.width + padding;
                     }
                     
                     UIImage *image = [result scaleToWidth:SELECT_ITEM_WIDTH];
                     
                     KKSelectImageItemView *itemView = [[KKSelectImageItemView alloc]initWithFrame:CGRectMake(startX, 0, SELECT_ITEM_WIDTH, imageScrollView.height)];
                     itemView.delegate = self ;
                     itemView.image = image ;
                     itemView.imageIndex = index ;
                     [imageScrollView addSubview:itemView];
                     
                     NSInteger offsetX = itemView.x + itemView.width + padding;
                     imageScrollView.contentSize = CGSizeMake(MAX(offsetX, imageScrollView.frame.size.width+1), 0);
                     
                     if(offsetX > imageScrollView.width){
                         [UIView animateWithDuration:0.3 animations:^{
                             [imageScrollView setContentOffset:CGPointMake(offsetX - imageScrollView.width, 0) animated:YES];
                         }];
                     }
                     
                     [self hideIndicatorView];
                     
                 });
                 
             }
             
         }];
        
    });
}

- (void)deletePuzzleImageWithIndex:(NSInteger)index
{
    for(UIView *itemView in imageScrollView.subviews){
        if([itemView isKindOfClass:[KKSelectImageItemView class]]){
            KKSelectImageItemView *item = (KKSelectImageItemView *)itemView ;
            if(item.imageIndex == index){
                [item removeFromSuperview];
                break ;
            }
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        NSInteger padding = 5;
        NSInteger startX = padding ;
        for(UIView *itemView in imageScrollView.subviews){
            if([itemView isKindOfClass:[KKSelectImageItemView class]]){
                KKSelectImageItemView *item = (KKSelectImageItemView *)itemView ;
                item.x = startX ;
                startX = (item.x + item.width + padding);
            }
        }
        imageScrollView.contentSize = CGSizeMake(MAX(startX, imageScrollView.frame.size.width+1), 0);
    }];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [seletedIndexArray removeObject:indexPath];
    
    KKImageCollectionCellView *cell = (KKImageCollectionCellView *)[photoCollectionView cellForItemAtIndexPath:indexPath];
    [cell setSeletedImage:false];
}

#pragma mark -- KKSelectImageItemViewDelegate

- (void)removeImageWithIndex:(NSInteger)index
{
    [self deletePuzzleImageWithIndex:index];
}

#pragma mark -- 显示进度

- (void)showIndicatorView
{
    [self hideIndicatorView];
    
    indicatorView = [[LoadingIndicatorView alloc]init];
    [indicatorView startAnimateWithTimeOut:8.0];
}

- (void)hideIndicatorView
{
    if(indicatorView){
        [indicatorView removeFromSuperview];
        indicatorView = nil ;
    }
}

#pragma mark -- 屏幕旋转

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO ;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait ;
}

@end
