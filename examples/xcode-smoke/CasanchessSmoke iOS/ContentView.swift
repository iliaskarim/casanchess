//
//  ContentView.swift
//  CasanchessSmoke iOS
//
//  Created by Ilias Karim on 4/23/26.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = SmokeViewModel()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 12) {
        Text("UCI Move")
          .font(.caption.weight(.semibold))
        TextField("e2e4", text: $viewModel.uciMoveText)
          .textFieldStyle(.roundedBorder)
          .textInputAutocapitalization(.never)

        Toggle("Get Best Move", isOn: $viewModel.shouldGetBestMove)

        Text("Best Move Depth")
          .font(.caption.weight(.semibold))
        TextField("5", text: $viewModel.bestMoveDepthText)
          .keyboardType(.numberPad)
          .textFieldStyle(.roundedBorder)
          .disabled(!viewModel.shouldGetBestMove)

        Text("Score Depth")
          .font(.caption.weight(.semibold))
        TextField("10", text: $viewModel.scoreDepthText)
          .keyboardType(.numberPad)
          .textFieldStyle(.roundedBorder)

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
            .font(.footnote)
        }

        Text("Output")
          .font(.caption.weight(.semibold))
        OutputLogView(outputText: viewModel.outputText)
          .frame(minHeight: 280)

        EvalBarView(score: viewModel.latestScore)
      }
      .padding()
      .background(.background)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
    .scrollDismissesKeyboard(.interactively)
  }
}

#Preview {
  ContentView()
}
