#import "CasanchessEngineBridge.h"
#import <Foundation/Foundation.h>

#include "Attacks.h"
#include "Board.h"
#include "Evaluation.h"
#include "NNUE.h"
#include "Search.h"
#include "Syzygy.h"
#include "Uci.h"
#include "ZobristKeys.h"

#include <algorithm>
#include <cmath>
#include <string>

struct CasanchessEngine {
    Board board;
};

CasanchessEngine g_state;
dispatch_queue_t g_analysisQueue;

namespace {
struct CasanchessSearchResult {
    float normalizedScore;
    std::string bestMoveUci;
};

float NormalizeScore(int score) {
    if(IsMateValue(score)) {
        return (score > 0) ? 1.0f : -1.0f;
    }

    const float normalized = std::tanh(static_cast<float>(score) / 600.0f);
    return std::clamp(normalized, -1.0f, 1.0f);
}

CasanchessSearchResult RunSearch(Search &search, Board board, int depth) {
    search.FixDepth(std::max(1, depth));
    search.IterativeDeepening(board, false);

    return CasanchessSearchResult {
        NormalizeScore(search.BestScore()),
        search.BestMove().Notation()
    };
}

NSBundle *CasanchessModuleBundle() {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    if(resourcePath == nil) {
        return nil;
    }

    NSString *moduleBundlePath = [resourcePath stringByAppendingPathComponent:@"Casanchess_Casanchess.bundle"];
    return [NSBundle bundleWithPath:moduleBundlePath];
}
}

@implementation CasanchessEngineBridge

+ (void)initialize {
    if(self != [CasanchessEngineBridge class]) {
        return;
    }
    Attacks::Init();
    Evaluation::Init();
    ZobristKeys::Init();

    NSString *nnuePath = nil;
    NSString *syzygyPath = nil;
    NSBundle *moduleBundle = CasanchessModuleBundle();
    if(moduleBundle != nil) {
        nnuePath = [moduleBundle pathForResource:@"network-20220625" ofType:@"nnue"];
        syzygyPath = [moduleBundle pathForResource:@"syzygy" ofType:nil];
    }

    if(nnuePath != nil) {
        nnue.Load(std::string([nnuePath UTF8String]));
    } else {
        NSLog(@"ERROR: NNUE file not found in Casanchess module bundle");
        nnue.Load();
    }

    if(syzygyPath != nil) {
        Syzygy::Init(std::string([syzygyPath UTF8String]));
    }

    g_state.board.Init();
    g_analysisQueue = dispatch_queue_create("dev.casanchess.analysis", DISPATCH_QUEUE_SERIAL);
    UCI_OUTPUT = false;
}

+ (BOOL)engineLoadSyzygyAtPath:(NSString *)path probeLimit:(int)probeLimit {
    if(path == nil) {
        return false;
    }

    UCI_SYZYGY_PROBE_LIMIT = std::clamp(probeLimit, 0, 7);
    return Syzygy::Init(std::string([path UTF8String])) > 0;
}

+ (void)engineResetGame {
    g_state.board.Init();
}

+ (void)engineSetPositionFen:(NSString *)fen {
    if(fen == nil) {
        return;
    }

    g_state.board.SetFen(std::string([fen UTF8String]));
}

+ (BOOL)engineApplyMove:(NSString *)uciMove {
    if(uciMove == nil) {
        return false;
    }

    g_state.board.MakeMove(std::string([uciMove UTF8String]));
    return true;
}

+ (void)engineEvaluateWithDepth:(int)depth callback:(CasanchessEvaluationUpdateBlock)callback {
    if(callback == nil) {
        return;
    }

    const int targetDepth = std::max(1, depth);
    const Board boardSnapshot = g_state.board;

    dispatch_async(g_analysisQueue, ^{
        Search localSearch;

        for(int currentDepth = 1; currentDepth <= targetDepth; ++currentDepth) {
            const CasanchessSearchResult result = RunSearch(localSearch, boardSnapshot, currentDepth);
            const BOOL isFinal = (currentDepth == targetDepth);
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(result.normalizedScore, isFinal);
            });
        }
    });
}

+ (void)engineBestMoveWithDepth:(int)depth callback:(CasanchessBestMoveBlock)callback {
    if(callback == nil) {
        return;
    }

    const int targetDepth = std::max(1, depth);
    const Board boardSnapshot = g_state.board;

    dispatch_async(g_analysisQueue, ^{
        Search localSearch;
        const CasanchessSearchResult result = RunSearch(localSearch, boardSnapshot, targetDepth);
        NSString *bestMoveUci = nil;

        if(result.bestMoveUci != "0000" && !result.bestMoveUci.empty()) {
            bestMoveUci = [NSString stringWithUTF8String:result.bestMoveUci.c_str()];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            callback(bestMoveUci);
        });
    });
}

@end
