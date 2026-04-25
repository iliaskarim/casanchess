//
//  ContentView.swift
//  CasanchessSmoke macOS
//
//  Created by Ilias Karim on 4/23/26.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = SmokeViewModel()

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("UCI Move")
        .font(.caption.weight(.semibold))
      TextField("e2e4", text: $viewModel.uciMoveText)

      Text("Operation")
        .font(.caption.weight(.semibold))
      Picker("Operation", selection: $viewModel.mode) {
        ForEach(SmokeAnalysisMode.allCases) { mode in
          Text(mode.title).tag(mode)
        }
      }
      .pickerStyle(.segmented)
      .labelsHidden()

      Text("Depth")
        .font(.caption.weight(.semibold))
      TextField("10", text: $viewModel.depthText)

      HStack(spacing: 10) {
        Button(viewModel.isRunning ? "Running..." : "Go") {
          viewModel.go()
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isRunning)

        Button("Reset") {
          viewModel.reset()
        }
        .buttonStyle(.bordered)
        .disabled(!viewModel.canReset)
      }

      if !viewModel.validationMessage.isEmpty {
        Text(viewModel.validationMessage)
          .foregroundStyle(.red)
      }

      Text("Output")
        .font(.caption.weight(.semibold))
      OutputLogView(outputText: viewModel.outputText)
        .frame(minHeight: 220, maxHeight: .infinity)

      if viewModel.mode == .evaluation {
        EvalBarView(score: viewModel.latestScore)
      }
    }
    .padding()
    .background(.background)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    .frame(width: 760, height: 620)
  }
}

#Preview {
  ContentView()
}
