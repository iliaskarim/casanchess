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
    int searchDepth = 5;
    float normalizedScore = 0.0f;
    std::string bestMoveBuffer;
};

CasanchessEngine g_state;

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
    g_state.searchDepth = 5;
    g_state.normalizedScore = 0.0f;
    g_state.bestMoveBuffer.clear();
    g_state.search.FixDepth(g_state.searchDepth);
    UCI_OUTPUT = false;
}

+ (void)engineResetGame {
    g_state.board.Init();
    g_state.normalizedScore = 0.0f;
    g_state.bestMoveBuffer.clear();
}

+ (void)engineSetDepth:(int)depth {
    g_state.searchDepth = std::max(1, depth);
}

+ (int)engineGetDepth {
    return g_state.searchDepth;
}

+ (BOOL)engineApplyMove:(NSString *)uciMove {
    if(uciMove == nil) {
        return false;
    }

    g_state.board.MakeMove(std::string([uciMove UTF8String]));
    [self refreshAnalysis];
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

+ (void)refreshAnalysis {
    g_state.search.FixDepth(g_state.searchDepth);
    g_state.search.IterativeDeepening(g_state.board, true);

    const Move bestMove = g_state.search.BestMove();
    const int bestScore = g_state.search.BestScore();
    g_state.normalizedScore = [self normalizeScore:bestScore];
    g_state.bestMoveBuffer = bestMove.Notation();
}

@end
