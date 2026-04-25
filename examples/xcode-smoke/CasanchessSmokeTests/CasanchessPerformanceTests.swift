import Casanchess
import XCTest

final class CasanchessPerformanceTests: XCTestCase {

  func testScoreAnalysisPerformance() {
    measure(metrics: [XCTClockMetric()]) {
      let completion = expectation(description: "score analysis completes")

      Task { @MainActor in
        let engine = CasanchessEngine.shared
        engine.resetGame()
        engine.scoreDepth = 10
        engine.bestMoveDepth = 5
        _ = engine.applyMove("f2f3")

        for await _ in engine.analyzeScoreProgressively() {}

        completion.fulfill()
      }

      wait(for: [completion], timeout: 30)
    }
  }

}
