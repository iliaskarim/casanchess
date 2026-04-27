//
//  CasanchessSmoke_macOS_Tests.swift
//  CasanchessSmoke macOS Tests
//
//  Created by Ilias Karim on 4/24/26.
//

import Testing

@Suite(.serialized)
struct CasanchessSmoke_macOS_Tests {
  @Test func smokeContract() async throws {
    await runSharedSmokeContractTest()
  }

  @Test func syzygyBestMoveRegression() async throws {
    await runSharedSyzygyBestMoveRegressionTest()
  }
}
