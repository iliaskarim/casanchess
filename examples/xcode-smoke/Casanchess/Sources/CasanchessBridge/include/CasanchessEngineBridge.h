#pragma once
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CasanchessEvaluationUpdateBlock)(float score, BOOL isFinal);
typedef void (^CasanchessBestMoveBlock)(NSString * _Nullable bestMoveUci);

@interface CasanchessEngineBridge : NSObject
+ (BOOL)engineLoadSyzygyAtPath:(NSString *)path probeLimit:(int)probeLimit;
+ (void)engineResetGame;
+ (void)engineSetPositionFen:(NSString *)fen;
+ (BOOL)engineApplyMove:(NSString *)uciMove;
+ (void)engineEvaluateWithDepth:(int)depth callback:(CasanchessEvaluationUpdateBlock)callback;
+ (void)engineBestMoveWithDepth:(int)depth callback:(CasanchessBestMoveBlock)callback;
@end

NS_ASSUME_NONNULL_END
