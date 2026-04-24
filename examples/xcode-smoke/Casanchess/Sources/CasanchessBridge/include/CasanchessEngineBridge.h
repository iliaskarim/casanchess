#pragma once
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CasanchessScoreUpdateBlock)(int depth, float score, NSString * _Nullable bestMoveUci, BOOL isFinal);

@interface CasanchessEngineBridge : NSObject
+ (void)engineResetGame;
+ (void)engineSetDepth:(int)depth;
+ (int)engineGetDepth;
+ (void)engineSetScoreDepth:(int)depth;
+ (int)engineGetScoreDepth;
+ (void)engineSetBestMoveDepth:(int)depth;
+ (int)engineGetBestMoveDepth;
+ (BOOL)engineApplyMove:(NSString *)uciMove;
+ (float)engineGetScore;
+ (nullable NSString *)engineGetBestMoveUci;
+ (void)engineAnalyzeScoreAsyncWithCallback:(CasanchessScoreUpdateBlock)callback;
@end

NS_ASSUME_NONNULL_END
