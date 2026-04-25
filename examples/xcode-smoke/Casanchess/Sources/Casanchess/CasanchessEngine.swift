import CasanchessBridge
import Combine
import Foundation

@MainActor
public final class CasanchessEngine {
  public static let shared = CasanchessEngine()

  private init() {}

  public func resetGame() { CasanchessEngineBridge.engineResetGame() }

  public func applyMove(_ uciMove: String) -> Bool {
    CasanchessEngineBridge.engineApplyMove(uciMove)
  }

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
