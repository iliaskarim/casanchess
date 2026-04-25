import SwiftUI

struct OutputLogView: View {
  let outputText: String

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        Text(outputText.isEmpty ? " " : outputText)
          .font(.system(.footnote, design: .monospaced))
          .frame(maxWidth: .infinity, alignment: .leading)
          .textSelection(.enabled)
          .id("outputBottom")
      }
      .padding(8)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(.secondary.opacity(0.25))
      )
      .onChange(of: outputText) {
        proxy.scrollTo("outputBottom", anchor: .bottom)
      }
    }
  }
}
