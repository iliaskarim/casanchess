import Casanchess
import Combine
import Foundation

@MainActor
enum CasanchessSmokeRunner {
  struct Configuration {
    let moves: [String]
    let depth: Int
    let mode: SmokeAnalysisMode
  }

  static func parseMoves(from text: String) -> [String] {
    text
      .split(whereSeparator: { $0 == "," || $0.isWhitespace || $0.isNewline })
      .map(String.init)
      .filter { !$0.isEmpty }
  }

  static func validateInput(moves: [String], depth: Int) -> String? {
    if moves.isEmpty {
      return "UCI moves cannot be empty."
    }
    if depth < 1 {
      return "Depth must be at least 1."
    }
    return nil
  }

  static func run(
    configuration: Configuration,
    log: @escaping (String) -> Void
  ) async {
    _ = CasanchessEngine.shared

    await runMoveSequence(
      passName: "white-pass",
      analyzeAfterWhiteMove: true,
      depth: configuration.depth,
      mode: configuration.mode,
      moves: configuration.moves,
      log: log
    )
    await runMoveSequence(
      passName: "black-pass",
      analyzeAfterWhiteMove: false,
      depth: configuration.depth,
      mode: configuration.mode,
      moves: configuration.moves,
      log: log
    )
  }

  private static func runMoveSequence(
    passName: String,
    analyzeAfterWhiteMove: Bool,
    depth: Int,
    mode: SmokeAnalysisMode,
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

      switch mode {
      case .evaluation:
        for await score in engine.evaluate(depth: depth).values {
          log("score pass=\(passName) move=\(move) score=\(score)")
        }
      case .bestMove:
        guard isWhiteMove == analyzeAfterWhiteMove else { continue }
        for await bestMove in engine.bestMove(depth: depth).values {
          log("best_move pass=\(passName) move=\(move) best_move=\(bestMove ?? "nil")")
          break
        }
      }
    }
  }
}
