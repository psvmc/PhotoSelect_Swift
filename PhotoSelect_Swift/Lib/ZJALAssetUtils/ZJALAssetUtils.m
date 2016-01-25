//
//  ZJALAssetUtils.m
//
//  Created by 张剑 on 16/1/14.
//  Copyright © 2016年 PSVMC. All rights reserved.
//

#import "ZJALAssetUtils.h"

@implementation ZJALAssetUtils


// 将原始图片的URL转化为NSData数据,写入沙盒
+ (void)imageWithURL:(NSURL *)url withBlock:(ZJ_ALAssetFileSaveBlock) block
{
    // 如何判断已经转化了,通过是否存在文件路径
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KOriginalPhotoImagePath]) {
        [fileManager createDirectoryAtPath:KOriginalPhotoImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            // 主要方法
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                if(asset != nil){
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                    NSString *fileName = [rep filename];
                    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                    NSString * imagePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:fileName];
                    [data writeToFile:imagePath atomically:YES];
                    block([NSURL fileURLWithPath:imagePath]);
                }else{
                    //iOS8.1系统的bug asset会为nil
                    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            if([result.defaultRepresentation.url isEqual:url]){
                                ALAssetRepresentation *rep = [result defaultRepresentation];
                                Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                                NSString *fileName = [rep filename];
                                NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                                NSString * imagePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:fileName];
                                [data writeToFile:imagePath atomically:YES];
                                block([NSURL fileURLWithPath:imagePath]);
                                *stop = YES;
                            }
                        }];
                    } failureBlock:^(NSError *error) {
                        
                    }];
                }
            } failureBlock:nil];
        }
    });
}

+ (void)imagesWithURLs:(NSArray *)urls withBlock:(ZJ_ALAssetFilesSaveBlock)block{
    // 如何判断已经转化了,通过是否存在文件路径
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    // 创建存放原始图的文件夹--->OriginalPhotoImages
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KOriginalPhotoImagePath]) {
        [fileManager createDirectoryAtPath:KOriginalPhotoImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    for (NSURL *url in urls) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (url) {
                // 主要方法
                [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                    if(asset !=nil){
                        ALAssetRepresentation *rep = [asset defaultRepresentation];
                        Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                        NSString *fileName = [rep filename];
                        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                        NSString * imagePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:fileName];
                        [data writeToFile:imagePath atomically:YES];
                        [imageURLs addObject:[NSURL fileURLWithPath:imagePath]];
                        if(imageURLs.count == urls.count){
                            block(imageURLs);
                        }
                    }else{
                        //iOS8.1系统的bug asset会为nil
                        [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                if([result.defaultRepresentation.url isEqual:url]){
                                    ALAssetRepresentation *rep = [result defaultRepresentation];
                                    Byte *buffer = (Byte*)malloc((unsigned long)rep.size);
                                    NSString *fileName = [rep filename];
                                    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:((unsigned long)rep.size) error:nil];
                                    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                                    NSString * imagePath = [KOriginalPhotoImagePath stringByAppendingPathComponent:fileName];
                                    [data writeToFile:imagePath atomically:YES];
                                    [imageURLs addObject:[NSURL fileURLWithPath:imagePath]];
                                    if(imageURLs.count == urls.count){
                                        block(imageURLs);
                                    }
                                    *stop = YES;
                                }
                            }];
                        } failureBlock:^(NSError *error) {
                            
                        }];
                    }
                    
                    
                } failureBlock:nil];
            }
        });
    }
}


// 将原始视频的URL转化为NSData数据,写入沙盒
+ (void)videoWithURL:(NSURL *)url withBlock:(ZJ_ALAssetFileSaveBlock) block
{
    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                if(asset != nil){
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    NSString *fileName = [rep filename];
                    NSString * videoPath = [KCachesPath stringByAppendingPathComponent:fileName];
                    char const *cvideoPath = [videoPath UTF8String];
                    FILE *file = fopen(cvideoPath, "a+");
                    if (file) {
                        const int bufferSize = 1024 * 1024;
                        // 初始化一个1M的buffer
                        Byte *buffer = (Byte*)malloc(bufferSize);
                        NSUInteger read = 0, offset = 0, written = 0;
                        NSError* err = nil;
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
                    
                    block([NSURL fileURLWithPath:videoPath]);
                }else{
                    //iOS8.1系统的bug asset会为nil
                    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            if([result.defaultRepresentation.url isEqual:url]){
                                ALAssetRepresentation *rep = [result defaultRepresentation];
                                NSString *fileName = [rep filename];
                                NSString * videoPath = [KCachesPath stringByAppendingPathComponent:fileName];
                                char const *cvideoPath = [videoPath UTF8String];
                                FILE *file = fopen(cvideoPath, "a+");
                                if (file) {
                                    const int bufferSize = 1024 * 1024;
                                    // 初始化一个1M的buffer
                                    Byte *buffer = (Byte*)malloc(bufferSize);
                                    NSUInteger read = 0, offset = 0, written = 0;
                                    NSError* err = nil;
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
                                
                                block([NSURL fileURLWithPath:videoPath]);
                                *stop = YES;
                            }
                        }];
                    } failureBlock:^(NSError *error) {
                        
                    }];
                }
                
            } failureBlock:nil];
        }
    });
}

+ (void)aLAssetWithURL:(NSURL *)url withBlock:(ZJ_ALAssetBlock) block{
    // 如何判断已经转化了,通过是否存在文件路径
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
                
                
            } failureBlock:nil];
        }
    });
}



@end
