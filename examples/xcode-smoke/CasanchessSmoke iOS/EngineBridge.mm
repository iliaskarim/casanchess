#import "EngineBridge.h"

#include "Attacks.h"
#include "ZobristKeys.h"

bool CasanchessSmokeCheck(void) {
    Attacks::Init();
    ZobristKeys::Init();
    return true;
}
