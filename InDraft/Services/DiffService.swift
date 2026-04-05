import Foundation

enum DiffSegmentType {
    case unchanged
    case inserted
    case removed
}

struct DiffSegment {
    let type: DiffSegmentType
    let text: String
}

protocol DiffServiceProtocol {
    func computeWordDiff(original: String, transformed: String) -> [DiffSegment]?
}

final class LiveDiffService: DiffServiceProtocol {
    private static let maxWordCount = 10_000

    func computeWordDiff(original: String, transformed: String) -> [DiffSegment]? {
        let originalWords = tokenize(original)
        let transformedWords = tokenize(transformed)

        // Performance guard
        if originalWords.count > Self.maxWordCount || transformedWords.count > Self.maxWordCount {
            return nil
        }

        // Edge case: both empty
        if originalWords.isEmpty && transformedWords.isEmpty {
            return []
        }

        let originalTokens = originalWords.map { $0.word }
        let transformedTokens = transformedWords.map { $0.word }

        let diff = transformedTokens.difference(from: originalTokens)

        // Build index sets for removals and insertions
        var removedIndices = Set<Int>()
        var insertedIndices = Set<Int>()
        var insertedValues: [Int: String] = [:]

        for change in diff {
            switch change {
            case .remove(let offset, _, _):
                removedIndices.insert(offset)
            case .insert(let offset, let element, _):
                insertedIndices.insert(offset)
                insertedValues[offset] = element
            }
        }

        var segments: [DiffSegment] = []

        // Walk through original to emit unchanged and removed segments
        // Walk through transformed to emit inserted segments
        // We interleave by replaying the diff on the original sequence

        var origIdx = 0
        var transIdx = 0

        while origIdx < originalWords.count || transIdx < transformedWords.count {
            // Emit insertions at current transformed index
            while transIdx < transformedWords.count && insertedIndices.contains(transIdx) {
                let token = transformedWords[transIdx]
                let text = token.leadingWhitespace + token.word
                appendSegment(to: &segments, type: .inserted, text: text)
                transIdx += 1
            }

            // Process original word
            if origIdx < originalWords.count {
                let token = originalWords[origIdx]
                if removedIndices.contains(origIdx) {
                    let text = token.leadingWhitespace + token.word
                    appendSegment(to: &segments, type: .removed, text: text)
                    origIdx += 1
                } else {
                    // Unchanged - use the whitespace from the transformed side when available
                    let whitespace: String
                    if transIdx < transformedWords.count {
                        whitespace = transformedWords[transIdx].leadingWhitespace
                    } else {
                        whitespace = token.leadingWhitespace
                    }
                    let text = whitespace + token.word
                    appendSegment(to: &segments, type: .unchanged, text: text)
                    origIdx += 1
                    transIdx += 1
                }
            }
        }

        // Remaining insertions at the end
        while transIdx < transformedWords.count && insertedIndices.contains(transIdx) {
            let token = transformedWords[transIdx]
            let text = token.leadingWhitespace + token.word
            appendSegment(to: &segments, type: .inserted, text: text)
            transIdx += 1
        }

        return segments
    }

    // MARK: - Tokenization

    private struct WordToken {
        let leadingWhitespace: String
        let word: String
    }

    /// Splits text into word tokens, each carrying its preceding whitespace.
    private func tokenize(_ text: String) -> [WordToken] {
        var tokens: [WordToken] = []
        var index = text.startIndex
        let whitespaceChars = CharacterSet.whitespacesAndNewlines

        while index < text.endIndex {
            // Collect leading whitespace
            let wsStart = index
            while index < text.endIndex && whitespaceChars.contains(text.unicodeScalars[index]) {
                index = text.index(after: index)
            }
            let leadingWS = String(text[wsStart..<index])

            // Collect the word
            let wordStart = index
            while index < text.endIndex && !whitespaceChars.contains(text.unicodeScalars[index]) {
                index = text.index(after: index)
            }

            if wordStart < index {
                let word = String(text[wordStart..<index])
                tokens.append(WordToken(leadingWhitespace: leadingWS, word: word))
            }
        }

        return tokens
    }

    // MARK: - Segment Coalescing

    private func appendSegment(to segments: inout [DiffSegment], type: DiffSegmentType, text: String) {
        if let last = segments.last, last.type == type {
            segments[segments.count - 1] = DiffSegment(type: type, text: last.text + text)
        } else {
            segments.append(DiffSegment(type: type, text: text))
        }
    }
}

final class MockDiffService: DiffServiceProtocol {
    var resultToReturn: [DiffSegment]? = []

    func computeWordDiff(original: String, transformed: String) -> [DiffSegment]? {
        return resultToReturn
    }
}
