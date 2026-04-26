import CasanchessBridge
import Combine
import Foundation

@MainActor
public final class CasanchessEngine {
  /// The shared engine instance for managing a single Casanchess game.
  public static let shared = CasanchessEngine()

  private init() {}

  /// Resets the current game to its initial position.
  public func resetGame() { CasanchessEngineBridge.engineResetGame() }

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
