import Casanchess
import Darwin

@MainActor
enum CasanchessSmokeRunner {
  private static func logLine(_ line: String) {
    print(line)
    fflush(stdout)
  }

  static func run(scoreDepth: Int = 10, bestMoveDepth: Int = 5) async {
    _ = CasanchessEngine.shared

    let engine = CasanchessEngine.shared
    engine.scoreDepth = scoreDepth
    engine.bestMoveDepth = bestMoveDepth

    await runFoolsMateSequence(passName: "white-pass", analyzeAfterWhiteMove: true)
    await runFoolsMateSequence(passName: "black-pass", analyzeAfterWhiteMove: false)
  }

  private static func runFoolsMateSequence(
    passName: String,
    analyzeAfterWhiteMove: Bool
  ) async {
    let engine = CasanchessEngine.shared
    let moves = ["f2f3", "e7e5", "g2g4", "d8h4"]

    engine.resetGame()
    for (index, move) in moves.enumerated() {
      logLine("\napply_move pass=\(passName) move=\(move)")
      if !engine.applyMove(move) {
        return
      }

      let isWhiteMove = index % 2 == 0
      var didLogBestMove = false

      for await update in engine.analyzeScoreProgressively() {
        logLine("score pass=\(passName) move=\(move) depth=\(update.depth) score=\(update.score)")
        if !didLogBestMove, isWhiteMove == analyzeAfterWhiteMove, let bestMove = update.bestMove {
          logLine("best_move pass=\(passName) move=\(move) best_move=\(bestMove)")
          didLogBestMove = true
        }
      }
    }
  }
}
