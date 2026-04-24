#pragma once
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CasanchessEngineBridge : NSObject
+ (void)engineResetGame;
+ (void)engineSetDepth:(int)depth;
+ (int)engineGetDepth;
+ (BOOL)engineApplyMove:(NSString *)uciMove;
+ (float)engineGetScore;
+ (nullable NSString *)engineGetBestMoveUci;
@end

NS_ASSUME_NONNULL_END
