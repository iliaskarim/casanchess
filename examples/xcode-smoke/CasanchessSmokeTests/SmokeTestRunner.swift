import Casanchess
import Combine
import Testing

@MainActor
func runSharedSmokeContractTest() async {
  let engine = CasanchessEngine.shared
  engine.resetGame()

  #expect(engine.applyMove("f2f3"))

  var scores: [Float] = []
  for await score in engine.evaluate(depth: 10).values {
    scores.append(score)
  }

  #expect(scores.count == 10)
  #expect(scores.allSatisfy { (-1.0 ... 1.0).contains($0) })

  var bestMoves: [String?] = []
  for await bestMove in engine.bestMove(depth: 5).values {
    bestMoves.append(bestMove)
  }

  #expect(bestMoves.count == 1)
  let firstBestMove = bestMoves.first ?? nil
  #expect(firstBestMove != nil)
}
