import Foundation

private struct DSDVLine {
    var hops: Int
    var nextHop: NodeID?
    var sequenceNumber: SequenceNumber
}

class DSDVTable {
    private var table: [NodeID: DSDVLine]
    
    init() {
        self.table = [:]
    }
    
    func updateLine(to DestinationID: NodeID, next NextHop: NodeID?, hops: Int, sequenceNumber: SequenceNumber) -> Bool {
        guard let currentLine = self.table[DestinationID] else {
            // no current path to Destination: add it
            self.table[DestinationID] = DSDVLine(
                hops: hops,
                nextHop: NextHop,
                sequenceNumber: sequenceNumber
            )
            return true
        }
        
        guard sequenceNumber >= currentLine.sequenceNumber else {
            // stale update: discard it
            return false
        }
        
        var updatedHops = currentLine.hops
        var updatedNextHop = currentLine.nextHop
        var success = false
        if sequenceNumber > currentLine.sequenceNumber || (sequenceNumber == currentLine.sequenceNumber && hops < currentLine.hops){
            // always prefer fresher routes or routes with less hops
            updatedHops = hops
            updatedNextHop = NextHop
            success = true
        }

        self.table[DestinationID] = DSDVLine(
            hops: updatedHops,
            nextHop: updatedNextHop,
            sequenceNumber: max(currentLine.sequenceNumber, sequenceNumber)
        )
        print(self.table)
        return success
    }
    
    func reset() {
        self.table.removeAll()
    }
    
    func getSequenceNumber(of destination: NodeID) -> SequenceNumber? {
        guard let line = self.table[destination] else {
            return nil
        }
        return line.sequenceNumber
    }
    
    func getNextHop(for destination: NodeID) -> NodeID? {
        guard let line = self.table[destination] else {
            return nil
        }
        return line.nextHop
    }
}
