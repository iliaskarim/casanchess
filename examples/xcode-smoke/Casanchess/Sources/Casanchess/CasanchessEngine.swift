import CasanchessBridge
import Foundation

@MainActor
public final class CasanchessEngine {
  public struct ScoreUpdate: Sendable {
    public let depth: Int
    public let score: Float
    public let bestMove: String?
    public let isFinal: Bool
  }

  public static let shared = CasanchessEngine()

  private init() {}

  public var depth: Int {
    get { Int(CasanchessEngineBridge.engineGetDepth()) }
    set { CasanchessEngineBridge.engineSetDepth(Int32(newValue)) }
  }

  public var scoreDepth: Int {
    get { Int(CasanchessEngineBridge.engineGetScoreDepth()) }
    set { CasanchessEngineBridge.engineSetScoreDepth(Int32(newValue)) }
  }

  public var bestMoveDepth: Int {
    get { Int(CasanchessEngineBridge.engineGetBestMoveDepth()) }
    set { CasanchessEngineBridge.engineSetBestMoveDepth(Int32(newValue)) }
  }

  public var score: Float { CasanchessEngineBridge.engineGetScore() }
  public var bestMove: String? { CasanchessEngineBridge.engineGetBestMoveUci() }

  public func resetGame() { CasanchessEngineBridge.engineResetGame() }

  public func applyMove(_ uciMove: String) -> Bool {
    CasanchessEngineBridge.engineApplyMove(uciMove)
  }

  public func analyzeScoreProgressively() -> AsyncStream<ScoreUpdate> {
    AsyncStream { continuation in
      CasanchessEngineBridge.engineAnalyzeScoreAsync { depth, score, bestMove, isFinal in
        continuation.yield(
          ScoreUpdate(
            depth: Int(depth),
            score: score,
            bestMove: bestMove,
            isFinal: isFinal
          )
        )

        if isFinal {
          continuation.finish()
        }
      }
    }
  }
}
