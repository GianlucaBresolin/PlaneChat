import Foundation

struct SequenceNumber: Comparable {
    var value: Int
    var destination: NodeID
    
    mutating func increment() -> SequenceNumber {
        // set to even
        if value.isMultiple(of: 2) {
            value += 2
        } else {
            value += 1
        }
        return self
    }
    
    func generateError() -> SequenceNumber {
        var newSeqeunceNumber = self
        guard value.isMultiple(of: 2) else {
            return newSeqeunceNumber
        }
        // set to odd
        newSeqeunceNumber.value += 1
        return newSeqeunceNumber
    }
    
    mutating func reset() {
        value = 0
    }
    
    static func < (lhs: SequenceNumber, rhs: SequenceNumber) -> Bool {
        return lhs.value < rhs.value
    }
    
    static func == (lhs: SequenceNumber, rhs: SequenceNumber) -> Bool {
        return lhs.value == rhs.value
    }
}
