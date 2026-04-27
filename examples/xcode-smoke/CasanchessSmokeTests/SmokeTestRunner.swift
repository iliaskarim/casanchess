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

@MainActor
func runSharedSyzygyBestMoveRegressionTest() async {
  let engine = CasanchessEngine.shared

  // Saavedra position. With Syzygy WDL loaded, depth-5 search should keep the
  // only winning tablebase result by advancing the pawn.
  engine.setPosition(fen: "8/8/1KP5/3r4/8/8/8/k7 w - - 0 1")

  var bestMoves: [String?] = []
  for await bestMove in engine.bestMove(depth: 5).values {
    bestMoves.append(bestMove)
  }

  #expect(bestMoves.count == 1)
  let firstBestMove = bestMoves.first ?? nil
  #expect(firstBestMove == "c6c7")
}
