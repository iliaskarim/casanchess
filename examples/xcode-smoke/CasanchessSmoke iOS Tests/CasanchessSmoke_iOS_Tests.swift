//
//  CasanchessSmoke_iOS_Tests.swift
//  CasanchessSmoke iOS Tests
//
//  Created by Ilias Karim on 4/24/26.
//

import Testing

struct CasanchessSmoke_iOS_Tests {
  @Test func smokeContract() async throws {
    await runSharedSmokeContractTest()
  }
}
