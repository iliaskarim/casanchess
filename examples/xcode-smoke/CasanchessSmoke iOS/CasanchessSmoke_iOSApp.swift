//
//  CasanchessSmoke_iOSApp.swift
//  CasanchessSmoke iOS
//
//  Created by Ilias Karim on 4/23/26.
//

import Casanchess
import SwiftUI

@MainActor
private func RunFoolsMateSequence() {
  let engine = CasanchessEngine.shared
  let moves = ["f2f3", "e7e5", "g2g4", "d8h4"]

  engine.resetGame()
  for move in moves {
    if !engine.applyMove(move) {
      NSLog("Failed to apply move %@", move)
      return
    }

    let bestMove = engine.bestMove ?? "<none>"
    NSLog("After move %@: score=%.4f bestmove=%@", move, engine.score, bestMove)
  }
}

@MainActor
private func CasanchessSmokeCheck() -> Bool {
  _ = CasanchessEngine.shared
  NSLog("Casanchess iOS engine initialized")

  let engine = CasanchessEngine.shared
  engine.depth = 5
  NSLog("Casanchess iOS smoke depth=%d", engine.depth)

  RunFoolsMateSequence()
  engine.resetGame()
  RunFoolsMateSequence()
  return true
}

@main
struct CasanchessSmoke_iOSApp: App {
  init() {
    if CasanchessSmokeCheck() {
      NSLog("Casanchess iOS smoke check passed")
    } else {
      NSLog("Casanchess iOS smoke check failed")
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
