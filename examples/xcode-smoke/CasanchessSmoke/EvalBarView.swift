import SwiftUI

struct EvalBarView: View {
  let score: Float?

  private var whiteShare: CGFloat {
    let clampedScore = max(-1, min(1, CGFloat(score ?? 0)))
    return (clampedScore + 1) / 2
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("Evaluation")
        .font(.caption.weight(.semibold))
      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          Rectangle()
            .fill(.black)
          Rectangle()
            .fill(.white)
            .frame(width: geometry.size.width * whiteShare)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
          RoundedRectangle(cornerRadius: 6)
            .stroke(.secondary.opacity(0.35))
        )
      }
      .frame(height: 24)
      Text("score \(score.map { String(format: "%.4f", $0) } ?? "--")")
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.secondary)
    }
  }
}
