//
//  ZJALAssetUtils.h
//
//  Created by 张剑 on 16/1/14.
//  Copyright © 2016年 PSVMC. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>  // 必须导入

// 照片原图路径
#define KOriginalPhotoImagePath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OriginalPhotoImages"]

// 视频URL路径
#define KVideoUrlPath [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"VideoURL"]

// caches路径
#define KCachesPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
typedef void (^ZJ_ALAssetFileSaveBlock)(NSURL *url);
typedef void (^ZJ_ALAssetBlock)(ALAsset *asset);
typedef void (^ZJ_ALAssetFilesSaveBlock)(NSArray *urls);
@interface ZJALAssetUtils : NSObject
///获取多张图片的路径
+ (void)imagesWithURLs:(NSArray *)urls withBlock:(ZJ_ALAssetFilesSaveBlock) block;
///获取单张视频的路径
+ (void)imageWithURL:(NSURL *)url withBlock:(ZJ_ALAssetFileSaveBlock) block;
///获取单个图片的路径
+ (void)videoWithURL:(NSURL *)url withBlock:(ZJ_ALAssetFileSaveBlock) block;
///根据url获取ALAsset
+ (void)aLAssetWithURL:(NSURL *)url withBlock:(ZJ_ALAssetBlock) block;
@end
