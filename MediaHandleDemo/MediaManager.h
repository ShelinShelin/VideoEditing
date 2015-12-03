//
//  MediaManager.h
//  AddBackgroundMusic
//
//  Created by Shelin on 15/11/25.
//  Copyright © 2015年 GreatGate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 添加音乐完成回调的block
 */
typedef void (^MixcompletionBlock)(void);
@interface MediaManager : NSObject
/**
 截取视频并添加背景音乐
 */
+ (void)addBackgroundMiusicWithVideoUrlStr:(NSURL *)videoUrl audioUrl:(NSURL *)audioUrl andCaptureVideoWithRange:(NSRange)videoRange completion:(MixcompletionBlock)completionHandle;

/**
 获取多媒体时长
 */
+ (CGFloat)getMediaDurationWithMediaUrl:(NSString *)mediaUrlStr;

/**
 获取合并后的多媒体文件路径
 */
+ (NSString *)getMediaFilePath;
@end
