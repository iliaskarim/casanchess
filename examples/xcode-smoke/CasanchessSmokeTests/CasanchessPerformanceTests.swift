import Casanchess
import Combine
import XCTest

final class CasanchessPerformanceTests: XCTestCase {

  func testScoreAnalysisPerformance() {
    measure(metrics: [XCTClockMetric()]) {
      let completion = expectation(description: "score analysis completes")

      Task { @MainActor in
        let engine = CasanchessEngine.shared
        engine.resetGame()
        _ = engine.applyMove("f2f3")

        for await _ in engine.evaluate(depth: 10).values {}

        completion.fulfill()
      }

      wait(for: [completion], timeout: 30)
    }
  }

}
