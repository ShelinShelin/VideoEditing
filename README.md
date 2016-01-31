# VideoEditing
视频处理之视频截取及添加背景音乐
Video processing of the video capture and add background music

这段时间由于工作需要，了解了一些关于iOS中视频处理功能，发现AVFoundation功能强大，今天聊一聊视频截取和添加背景音乐的一些功能，这里面涉及到得一些类类名和方法都比较长，但是用法还是相对简单，主要是能理解多媒体的一些概念，先来介绍一下常用到的几个AVFoundation下得类：
- AVURLAsset：AVAsset的子类，此类主要用于获取多媒体的信息，包括视频、音频的类型、时长、每秒帧数，其实还可以用来获取视频的指定位置的缩略图。
- AVMutableCompositionTrack：视频和音频的采集都需要通过这个类，我觉得可以理解为采集的一个视频或音频资源对应一个track对象。
- AVMutableComposition：这个类点进去你会发现其实它也是AVAsset的子类，对应有一个方法[AVMutableComposition composition]，返回一个nil的AVMutableComposition对象。
- CMTime：这个时间并不是平时我们说到的分秒的时间，后面用到的时候会再说。
- AVAssetExportSession：用于合并你采集的视频和音频，最终会保存为一个新文件，可以设置文件的输出类型、路径，以及合并的一个状态AVAssetExportSessionStatus。

这里单独创建了一个工具类MediaManager来做操作
#####下面是MediaManager.h的方法接口：
```
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

```
#####MediaManager.m中方法实现：
在添加背景音乐的方法中先创建视频和音频对应的AVURLAsset对象
```
//AVURLAsset此类主要用于获取媒体信息，包括视频、声音等
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    
    //创建AVMutableComposition对象来添加视频音频资源的AVMutableCompositionTrack
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
```
我们要截取一段视频就一定涉及到截取的时间点和长度，下面来具体介绍一下CMTime和CMTimeRange。
- CMTime一个用于描述多媒体帧数和播放速率的结构体，可以通过  CMTimeMake(int64_t value, int32_t timescale)  来生成一个CMTime变量，value视频的总帧数，timescale是指每秒视频播放的帧数，视频播放速率，（value / timescale）才是视频实际的秒数时长，timescale一般情况下不改变，截取视频长度通过改变value的值。
或者通过 CMTimeMakeWithSeconds(Float64 seconds, int32_t preferredTimeScale)  方法也可以，这里的seconds对应的是平时说的秒数，preferredTimeScale是每秒播放的帧数。
- CMTimeRange有点类似NSRange，只不过它对应的是视频的起始时间点和视频的长度，可以通过方法CMTimeRangeMake(start, duration)创建变量，start起始时间，duration时长，都是CMTime类型。方法中我直接传入NSRange，在内部做了一些转换。

了解完这些就可以开始采集视频音频了，下面是对视频的采集，如果需要也可以去获取视频原有的音轨。
这里经常会遇到到tracksWithMediaType方法返回empty的数组，导致程序奔溃，我从Stack Overflow弄下来的一段解释：

![屏幕快照 2015-12-02 下午2.25.17.png](http://upload-images.jianshu.io/upload_images/1121012-00e5015d6fb4431c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```
//开始位置startTime
    CMTime startTime = CMTimeMakeWithSeconds(videoRange.location, videoAsset.duration.timescale);
    //截取长度videoDuration
    CMTime videoDuration = CMTimeMakeWithSeconds(videoRange.length, videoAsset.duration.timescale);
    CMTimeRange videoTimeRange = CMTimeRangeMake(startTime, videoDuration);
    //视频采集compositionVideoTrack
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

#warning 避免数组越界 tracksWithMediaType 找不到对应的文件时候返回空数组
    //TimeRange截取的范围长度
    //ofTrack来源
    //atTime插放在视频的时间位置
    [compositionVideoTrack insertTimeRange:videoTimeRange ofTrack:([videoAsset tracksWithMediaType:AVMediaTypeVideo].count>0) ? [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject : nil atTime:kCMTimeZero error:nil];
```
对背景音频的采集
```
//声音长度截取范围==视频长度
    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration);
    
    //音频采集compositionCommentaryTrack
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:audioTimeRange ofTrack:([audioAsset tracksWithMediaType:AVMediaTypeAudio].count > 0) ? [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil atTime:kCMTimeZero error:nil];

```
然后就是合并获取的视频和背景音频，这里需要对输出的文件设置保存路径以及文件类型。
```
//AVAssetExportSession用于合并文件，导出合并后文件，presetName文件的输出类型
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    
    NSString *outPutPath = [NSTemporaryDirectory() stringByAppendingPathComponent:MediaFileName];
    //混合后的视频输出路径
    NSURL *outPutPath = [NSURL fileURLWithPath:outPutPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutPath error:nil];
    }
    
    //输出视频格式 AVFileTypeMPEG4 AVFileTypeQuickTimeMovie...
    assetExportSession.outputFileType = AVFileTypeQuickTimeMovie;
//    NSArray *fileTypes = assetExportSession.
    
    assetExportSession.outputURL = outPutPath;
    //输出文件是否网络优化
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        completionHandle();
    }];
```
这是获取多媒体文件时长的方法实现。
```
+ (CGFloat)getMediaDurationWithMediaUrl:(NSString *)mediaUrlStr {
    
    NSURL *mediaUrl = [NSURL URLWithString:mediaUrlStr];
    AVURLAsset *mediaAsset = [[AVURLAsset alloc] initWithURL:mediaUrl options:nil];
    CMTime duration = mediaAsset.duration;
    
    return duration.value / duration.timescale;    
}
```
最后只要在外部添加背景音乐的方法简单的调用即可。

```
- (IBAction)addBackgroundmusic:(id)sender {
    
    if (_videoUrl && _audioUrl && self.endTextField.text && self.startTextField.text) {
        
        [MediaManager addBackgroundMiusicWithVideoUrlStr:_videoUrl audioUrl:_audioUrl andCaptureVideoWithRange:NSMakeRange([self.startTextField.text floatValue], [self.endTextField.text floatValue] - [self.startTextField.text floatValue]) completion:^{
            NSLog(@"视频合并完成");
        }];
    }
}
```
