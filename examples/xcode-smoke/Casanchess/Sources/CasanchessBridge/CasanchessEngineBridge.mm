#import "CasanchessEngineBridge.h"
#import <Foundation/Foundation.h>

#include "Attacks.h"
#include "Board.h"
#include "Evaluation.h"
#include "NNUE.h"
#include "Search.h"
#include "Uci.h"
#include "ZobristKeys.h"

#include <algorithm>
#include <cmath>
#include <string>

struct CasanchessEngine {
    Board board;
    Search search;
    int scoreDepth = 5;
    int bestMoveDepth = 5;
    float normalizedScore = 0.0f;
    std::string bestMoveBuffer;
};

CasanchessEngine g_state;
dispatch_queue_t g_analysisQueue;

@implementation CasanchessEngineBridge

+ (void)initialize {
    if(self != [CasanchessEngineBridge class]) {
        return;
    }
    Attacks::Init();
    Evaluation::Init();
    ZobristKeys::Init();

    NSString *nnuePath = [[NSBundle mainBundle] pathForResource:@"network-20220625" ofType:@"nnue"];
    if(nnuePath != nil) {
        nnue.Load(std::string([nnuePath UTF8String]));
    } else {
        NSLog(@"ERROR: bundled NNUE file not found");
        nnue.Load();
    }

    g_state.board.Init();
    g_state.scoreDepth = 5;
    g_state.bestMoveDepth = 5;
    g_state.normalizedScore = 0.0f;
    g_state.bestMoveBuffer.clear();
    g_state.search.FixDepth(g_state.bestMoveDepth);
    g_analysisQueue = dispatch_queue_create("dev.casanchess.analysis", DISPATCH_QUEUE_SERIAL);
    UCI_OUTPUT = false;
}

+ (void)engineResetGame {
    g_state.board.Init();
    g_state.normalizedScore = 0.0f;
    g_state.bestMoveBuffer.clear();
}

+ (void)engineSetDepth:(int)depth {
    const int sanitizedDepth = std::max(1, depth);
    g_state.scoreDepth = sanitizedDepth;
    g_state.bestMoveDepth = sanitizedDepth;
}

+ (int)engineGetDepth {
    return g_state.bestMoveDepth;
}

+ (void)engineSetScoreDepth:(int)depth {
    g_state.scoreDepth = std::max(1, depth);
}

+ (int)engineGetScoreDepth {
    return g_state.scoreDepth;
}

+ (void)engineSetBestMoveDepth:(int)depth {
    g_state.bestMoveDepth = std::max(1, depth);
}

+ (int)engineGetBestMoveDepth {
    return g_state.bestMoveDepth;
}

+ (BOOL)engineApplyMove:(NSString *)uciMove {
    if(uciMove == nil) {
        return false;
    }

    g_state.board.MakeMove(std::string([uciMove UTF8String]));
    g_state.normalizedScore = 0.0f;
    g_state.bestMoveBuffer.clear();
    return true;
}

+ (float)engineGetScore {
    return g_state.normalizedScore;
}

+ (NSString * _Nullable)engineGetBestMoveUci {
    if(g_state.bestMoveBuffer == "0000" || g_state.bestMoveBuffer.empty()) {
        return nil;
    }
    return [NSString stringWithUTF8String:g_state.bestMoveBuffer.c_str()];
}

+ (float)normalizeScore:(int)score {
    if(IsMateValue(score)) {
        return (score > 0) ? 1.0f : -1.0f;
    }

    const float normalized = std::tanh(static_cast<float>(score) / 600.0f);
    return std::clamp(normalized, -1.0f, 1.0f);
}

+ (void)engineAnalyzeScoreAsyncWithCallback:(CasanchessScoreUpdateBlock)callback {
    if(callback == nil) {
        return;
    }

    const int targetDepth = std::max(1, g_state.scoreDepth);
    const int bestMoveDepth = std::max(1, g_state.bestMoveDepth);
    const Board boardSnapshot = g_state.board;

    dispatch_async(g_analysisQueue, ^{
        Search localSearch;
        localSearch.FixDepth(1);
        bool bestMoveEmitted = false;

        for(int depth = 1; depth <= targetDepth; ++depth) {
            Board workingBoard = boardSnapshot;
            localSearch.FixDepth(depth);
            localSearch.IterativeDeepening(workingBoard, false);

            const int bestScore = localSearch.BestScore();
            const float normalized = [self normalizeScore:bestScore];
            const BOOL isFinal = (depth == targetDepth);

            g_state.normalizedScore = normalized;

            NSString *bestMoveUci = nil;
            if(!bestMoveEmitted && depth >= bestMoveDepth) {
                const std::string bestMoveText = localSearch.BestMove().Notation();
                g_state.bestMoveBuffer = bestMoveText;

                if(bestMoveText != "0000" && !bestMoveText.empty()) {
                    bestMoveUci = [NSString stringWithUTF8String:bestMoveText.c_str()];
                }

                bestMoveEmitted = true;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                callback(depth, normalized, bestMoveUci, isFinal);
            });
        }
    });
}

@end
