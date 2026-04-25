import Casanchess
import Foundation

@MainActor
final class SmokeViewModel: ObservableObject {
  @Published var uciMoveText = ""
  @Published var shouldGetBestMove = true
  @Published var bestMoveDepthText = "5"
  @Published var scoreDepthText = "10"
  @Published var outputText = ""
  @Published var validationMessage = ""
  @Published var isRunning = false
  @Published var latestScore: Float?
  @Published private(set) var hasPlayedMove = false

  private let engine = CasanchessEngine.shared
  private var analysisTask: Task<Void, Never>?

  func go() {
    guard !isRunning else { return }

    let uciMove = uciMoveText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    let bestMoveDepth = Int(bestMoveDepthText) ?? 0
    let scoreDepth = Int(scoreDepthText) ?? 0

    if uciMove.isEmpty {
      validationMessage = "UCI move cannot be empty."
      return
    }
    if scoreDepth < 1 {
      validationMessage = "Score depth must be at least 1."
      return
    }
    if shouldGetBestMove && bestMoveDepth < 1 {
      validationMessage = "Best move depth must be at least 1."
      return
    }
    if shouldGetBestMove && scoreDepth < bestMoveDepth {
      validationMessage = "Score depth must be greater than or equal to best move depth."
      return
    }
    if !engine.applyMove(uciMove) {
      validationMessage = "Failed to apply UCI move."
      return
    }

    hasPlayedMove = true
    validationMessage = ""
    isRunning = true
    engine.bestMoveDepth = shouldGetBestMove ? bestMoveDepth : scoreDepth
    engine.scoreDepth = scoreDepth
    outputText = ""
    latestScore = nil
    appendLine("apply_move move=\(uciMove)")
    uciMoveText = ""

    analysisTask = Task {
      for await update in engine.analyzeScoreProgressively() {
        latestScore = update.score
        appendLine("score depth=\(update.depth) score=\(update.score)")
        if shouldGetBestMove, let bestMove = update.bestMove {
          appendLine("best_move best_move=\(bestMove)")
        }
      }
      isRunning = false
      analysisTask = nil
    }
  }

  var canReset: Bool {
    hasPlayedMove
  }

  func reset() {
    guard canReset else { return }
    analysisTask?.cancel()
    analysisTask = nil
    isRunning = false
    engine.resetGame()
    hasPlayedMove = false
    validationMessage = ""
    outputText = ""
    latestScore = nil
  }

  private func appendLine(_ line: String) {
    outputText += outputText.isEmpty ? line : "\n" + line
  }
}
