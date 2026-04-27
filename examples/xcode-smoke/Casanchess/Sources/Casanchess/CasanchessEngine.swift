import CasanchessBridge
import Combine
import Foundation

@MainActor
public final class CasanchessEngine {
  /// The shared engine instance for managing a single Casanchess game.
  public static let shared = CasanchessEngine()

  private init() {}

  /// Loads Syzygy WDL tablebases from a directory.
  /// - Parameters:
  ///   - path: Directory containing `.rtbw` files.
  ///   - probeLimit: Maximum piece count to probe, usually 5, 6, or 7.
  /// - Returns: `true` when tablebase files were found and initialized.
  public func loadSyzygy(path: String, probeLimit: Int = 7) -> Bool {
    CasanchessEngineBridge.engineLoadSyzygy(
      atPath: path,
      probeLimit: Int32(probeLimit)
    )
  }

  /// Resets the current game to its initial position.
  public func resetGame() { CasanchessEngineBridge.engineResetGame() }

  /// Sets the current game position from a FEN string.
  /// - Parameter fen: Full or simplified FEN accepted by the engine.
  public func setPosition(fen: String) {
    CasanchessEngineBridge.engineSetPositionFen(fen)
  }

  /// Applies a move to the current game.
  /// - Parameter uciMove: The move to apply, encoded in UCI notation.
  /// - Returns: `true` when the move was applied successfully; otherwise,
  ///   `false`.
  public func applyMove(_ uciMove: String) -> Bool {
    CasanchessEngineBridge.engineApplyMove(uciMove)
  }

  /// Evaluates the current position.
  /// - Parameter depth: The engine search depth to use for the evaluation.
  /// - Returns: A publisher that emits evaluation scores and then completes.
  public func evaluate(depth: Int) -> AnyPublisher<Float, Never> {
    Deferred {
      let subject = PassthroughSubject<Float, Never>()
      Task { @MainActor in
        CasanchessEngineBridge.engineEvaluate(withDepth: Int32(depth)) { score, isFinal in
          subject.send(score)

          if isFinal {
            subject.send(completion: .finished)
          }
        }
      }
      return subject
    }
    .eraseToAnyPublisher()
  }

  /// Searches for the best move in the current position.
  /// - Parameter depth: The engine search depth to use for the search.
  /// - Returns: A publisher that emits the best move in UCI notation, or `nil`
  ///   when the engine does not return a move.
  public func bestMove(depth: Int) -> AnyPublisher<String?, Never> {
    Deferred {
      Future { promise in
        Task { @MainActor in
          CasanchessEngineBridge.engineBestMove(withDepth: Int32(depth)) { bestMove in
            promise(.success(bestMove))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
