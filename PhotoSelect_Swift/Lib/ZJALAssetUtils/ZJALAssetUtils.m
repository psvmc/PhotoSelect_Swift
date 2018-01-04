//
//  ZJALAssetUtils.m
//
//  Created by 张剑 on 16/1/14.
//  Copyright © 2016年 PSVMC. All rights reserved.
//

#import "ZJALAssetUtils.h"

@implementation ZJALAssetUtils
// 将原始图片的URL转化为NSData数据,写入沙盒
+ (void)imageWithURL:(NSURL *)url withBlock:(ZJ_ALAssetFileSaveBlock) block{
    // 如何判断已经转化了,通过是否存在文件路径
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KOriginalPhotoImagePath]) {
        [fileManager createDirectoryAtPath:KOriginalPhotoImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [ZJALAssetUtils aLAssetWithURL:url withBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSString * imagePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:[rep filename]];
        [ZJALAssetUtils fileSaveWithFilePath:imagePath withRep:rep withBlock:^(NSURL *fileUrl) {
            block(fileUrl);
        }];
        
    }];
}

+ (void)imagesWithURLs:(NSArray *)urls withBlock:(ZJ_ALAssetFilesSaveBlock)block{
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KOriginalPhotoImagePath]) {
        [fileManager createDirectoryAtPath:KOriginalPhotoImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    for (NSURL *url in urls) {
        [ZJALAssetUtils aLAssetWithURL:url withBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            NSString * imagePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:[rep filename]];
            [ZJALAssetUtils fileSaveWithFilePath:imagePath withRep:rep withBlock:^(NSURL *fileUrl) {
                [imageURLs addObject:fileUrl];
                if(imageURLs.count == urls.count){
                    block(imageURLs);
                }
            }];
            
        }];
    }
}


// 将原始视频的URL转化为NSData数据,写入沙盒
+ (void)videoWithURL:(NSURL *)url withBlock:(ZJ_ALAssetFileSaveBlock) block{
    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
    [ZJALAssetUtils aLAssetWithURL:url withBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSString * videoPath = [KCachesPath stringByAppendingPathComponent:[rep filename]];
        [ZJALAssetUtils fileSaveWithFilePath:videoPath withRep:rep withBlock:^(NSURL *fileUrl) {
            block(fileUrl);
        }];
    }];
}


///获取ALAsset 兼容iOS8.1
+ (void)aLAssetWithURL:(NSURL *)url withBlock:(ZJ_ALAssetBlock) block{
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    if (url) {
        // 主要方法
        [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
            if(asset !=nil){
                block(asset);
            }else{
                //iOS8.1系统的bug asset会为nil
                [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if([result.defaultRepresentation.url isEqual:url]){
                            block(result);
                            *stop = YES;
                        }
                    }];
                } failureBlock:^(NSError *error) {
                    
                }];
            }
        } failureBlock:^(NSError *error) {
            
        }];
    }
}


///保存文件
+ (void)fileSaveWithFilePath:(NSString *)filePath withRep:(ALAssetRepresentation *)rep withBlock:(ZJ_ALAssetFileSaveBlock) block{
    NSError* err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]){
        [fileManager removeItemAtPath:filePath error:&err];
    }
    char const *cvideoPath = [filePath UTF8String];
    FILE *file = fopen(cvideoPath, "a+");
    if (file) {
        const int bufferSize = 1024 * 1024;
        // 初始化一个1M的buffer
        Byte *buffer = (Byte*)malloc(bufferSize);
        NSUInteger read = 0, offset = 0, written = 0;
        
        if (rep.size != 0)
        {
            do {
                read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                written = fwrite(buffer, sizeof(char), read, file);
                offset += read;
            } while (read != 0 && !err);//没到结尾，没出错，ok继续
        }
        // 释放缓冲区，关闭文件
        free(buffer);
        buffer = NULL;
        fclose(file);
        file = NULL;
    }
    block([NSURL fileURLWithPath:filePath]);
}

@end
