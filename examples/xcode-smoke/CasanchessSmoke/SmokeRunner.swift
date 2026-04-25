import Casanchess
import Foundation

@MainActor
enum CasanchessSmokeRunner {
  struct Configuration {
    let moves: [String]
    let scoreDepth: Int
    let bestMoveDepth: Int
  }

  static func parseMoves(from text: String) -> [String] {
    text
      .split(whereSeparator: { $0 == "," || $0.isWhitespace || $0.isNewline })
      .map(String.init)
      .filter { !$0.isEmpty }
  }

  static func validateInput(moves: [String], scoreDepth: Int, bestMoveDepth: Int) -> String? {
    if moves.isEmpty {
      return "UCI moves cannot be empty."
    }
    if bestMoveDepth < 1 {
      return "Best move depth must be at least 1."
    }
    if scoreDepth < bestMoveDepth {
      return "Score depth must be greater than or equal to best move depth."
    }
    return nil
  }

  static func run(
    configuration: Configuration,
    log: @escaping (String) -> Void
  ) async {
    _ = CasanchessEngine.shared

    let engine = CasanchessEngine.shared
    engine.scoreDepth = configuration.scoreDepth
    engine.bestMoveDepth = configuration.bestMoveDepth

    await runMoveSequence(
      passName: "white-pass",
      analyzeAfterWhiteMove: true,
      moves: configuration.moves,
      log: log
    )
    await runMoveSequence(
      passName: "black-pass",
      analyzeAfterWhiteMove: false,
      moves: configuration.moves,
      log: log
    )
  }

  private static func runMoveSequence(
    passName: String,
    analyzeAfterWhiteMove: Bool,
    moves: [String],
    log: @escaping (String) -> Void
  ) async {
    let engine = CasanchessEngine.shared

    engine.resetGame()
    for (index, move) in moves.enumerated() {
      log("\napply_move pass=\(passName) move=\(move)")
      if !engine.applyMove(move) {
        log("error pass=\(passName) move=\(move) reason=apply_move_failed")
        return
      }

      let isWhiteMove = index % 2 == 0
      var didLogBestMove = false

      for await update in engine.analyzeScoreProgressively() {
        log("score pass=\(passName) move=\(move) depth=\(update.depth) score=\(update.score)")
        if !didLogBestMove, isWhiteMove == analyzeAfterWhiteMove, let bestMove = update.bestMove {
          log("best_move pass=\(passName) move=\(move) best_move=\(bestMove)")
          didLogBestMove = true
        }
      }
    }
  }
}
