import CasanchessBridge
import Foundation

@MainActor
public final class CasanchessEngine {
  public static let shared = CasanchessEngine()

  private init() {}

  public var depth: Int {
    get { Int(CasanchessEngineBridge.engineGetDepth()) }
    set { CasanchessEngineBridge.engineSetDepth(Int32(newValue)) }
  }

  public var score: Float { CasanchessEngineBridge.engineGetScore() }
  public var bestMove: String? { CasanchessEngineBridge.engineGetBestMoveUci() }

  public func resetGame() { CasanchessEngineBridge.engineResetGame() }

  public func applyMove(_ uciMove: String) -> Bool {
    CasanchessEngineBridge.engineApplyMove(uciMove)
  }
}
