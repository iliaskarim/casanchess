import Casanchess
import Combine
import Foundation

enum SmokeAnalysisMode: String, CaseIterable, Identifiable {
  case evaluation
  case bestMove

  var id: String { rawValue }

  var title: String {
    switch self {
    case .evaluation:
      "Evaluation"
    case .bestMove:
      "Best Move"
    }
  }
}

@MainActor
final class SmokeViewModel: ObservableObject {
  @Published var uciMoveText = ""
  @Published var mode: SmokeAnalysisMode = .evaluation
  @Published var depthText = "10"
  @Published var outputText = ""
  @Published var validationMessage = ""
  @Published var isRunning = false
  @Published var latestScore: Float?
  @Published private(set) var hasPlayedMove = false

  private let engine = CasanchessEngine.shared
  private var cancellables = Set<AnyCancellable>()

  func go() {
    guard !isRunning else { return }

    let uciMove = uciMoveText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    let depth = Int(depthText) ?? 0

    if uciMove.isEmpty {
      validationMessage = "UCI move cannot be empty."
      return
    }
    if depth < 1 {
      validationMessage = "Depth must be at least 1."
      return
    }
    if !engine.applyMove(uciMove) {
      validationMessage = "Failed to apply UCI move."
      return
    }

    hasPlayedMove = true
    validationMessage = ""
    isRunning = true
    outputText = ""
    latestScore = nil
    cancellables.removeAll()
    appendLine("apply_move move=\(uciMove)")
    uciMoveText = ""

    switch mode {
    case .evaluation:
      runEvaluation(depth: depth)
    case .bestMove:
      runBestMove(depth: depth)
    }
  }

  private func runEvaluation(depth: Int) {
    engine.evaluate(depth: depth)
      .sink(
        receiveCompletion: { [weak self] _ in
          self?.isRunning = false
          self?.cancellables.removeAll()
        },
        receiveValue: { [weak self] score in
          self?.latestScore = score
          self?.appendLine("score score=\(score)")
        }
      )
      .store(in: &cancellables)
  }

  private func runBestMove(depth: Int) {
    engine.bestMove(depth: depth)
      .sink { [weak self] bestMove in
        if let bestMove {
          self?.appendLine("best_move best_move=\(bestMove)")
        } else {
          self?.appendLine("best_move best_move=nil")
        }
        self?.isRunning = false
        self?.cancellables.removeAll()
      }
      .store(in: &cancellables)
  }

  var canReset: Bool {
    hasPlayedMove
  }

  func reset() {
    guard canReset else { return }
    cancellables.removeAll()
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
