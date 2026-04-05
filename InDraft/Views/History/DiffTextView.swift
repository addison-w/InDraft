import SwiftUI

struct DiffTextView: View {
    let segments: [DiffSegment]

    var body: some View {
        segments.reduce(Text("")) { result, segment in
            result + styledText(for: segment)
        }
    }

    private func styledText(for segment: DiffSegment) -> Text {
        switch segment.type {
        case .unchanged:
            return Text(segment.text)
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.textPrimary)

        case .inserted:
            return Text(segment.text)
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.diffInsertedText)

        case .removed:
            return Text(segment.text)
                .font(Theme.Typography.body())
                .foregroundColor(Theme.Colors.diffRemovedText)
                .strikethrough(true, color: Theme.Colors.diffRemovedText)
        }
    }
}
