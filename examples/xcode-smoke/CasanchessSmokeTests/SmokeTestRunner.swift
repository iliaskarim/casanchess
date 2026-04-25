import Casanchess
import Testing

@MainActor
func runSharedSmokeContractTest() async {
  let engine = CasanchessEngine.shared
  engine.resetGame()
  engine.bestMoveDepth = 5
  engine.scoreDepth = 10

  #expect(engine.applyMove("f2f3"))

  var updates: [CasanchessEngine.ScoreUpdate] = []
  for await update in engine.analyzeScoreProgressively() {
    updates.append(update)
  }

  #expect(updates.count == 10)
  #expect(updates.last?.depth == 10)
  #expect(updates.first?.depth == 1)

  let bestMoveUpdates = updates.filter { $0.bestMove != nil }
  #expect(bestMoveUpdates.count == 1)
  #expect(bestMoveUpdates.first?.depth == 5)
}
