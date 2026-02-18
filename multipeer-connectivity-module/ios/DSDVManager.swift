import Foundation
typealias NodeID = String

class DSDVManager {
    private let MyNodeID : NodeID
    private var MySequenceNumber : SequenceNumber
    private var Table : DSDVTable
    private var Members : [NodeID]
    
    weak var delegate : DSDVManagerDelegate?
    
    init(nodeID: NodeID) {
        self.MyNodeID = nodeID
        self.MySequenceNumber = SequenceNumber(value: 0, destination: self.MyNodeID)
        self.Table = DSDVTable()
        self.Members = [NodeID]()
    }
    
    func notifyNewLink(
        newNode: NodeID
    ) {
        // update our table
        guard self.Table.updateLine(
            to: newNode,
            next: newNode,
            hops: 1,
            sequenceNumber: self.MySequenceNumber.increment()
        ) else {
            // fail update
            return
        }
        // broadcast update to other nodes
        broadcastUpdate(
            destination: self.MyNodeID,
            hops: 1,
            sequenceNumber: self.MySequenceNumber
        )
        if !self.Members.contains(newNode) {
            self.Members.append(newNode)
        }
    }
    
    func notifyBrokenLink(
        brokenNode: NodeID
    ) {
        // obtain brokenNode sequence number
        guard let destinationSequenceNumber = self.Table.getSequenceNumber(of: brokenNode) else {
            // no brokenNode in table: exit
            return
        }
        
        // update our table
        guard self.Table.updateLine(
            to: brokenNode,
            next: nil,
            hops: -1,
            sequenceNumber: destinationSequenceNumber.generateError()
        ) else {
            // fail update
            return
        }
        // broadcast update to other nodes
        broadcastUpdate(
            destination: brokenNode,
            hops: -1,
            sequenceNumber: destinationSequenceNumber
        )
        if let index = self.Members.firstIndex(of: brokenNode) {
            self.Members.remove(at: index)
        }
    }
    
    func reset() {
        self.Members = []
        self.Table.reset()
        self.MySequenceNumber.reset()
    }
    
    func handleUpdate(
        from: NodeID,
        destination: NodeID,
        hops: Int,
        sequenceNumber: SequenceNumber
    ) {
        guard destination != self.MyNodeID else {
            // discard updates regarding us as destination
            return
        }
        // update our table
        guard self.Table.updateLine(
            to: destination,
            next: from,
            hops: hops,
            sequenceNumber: sequenceNumber
        ) else {
            // fail update
            return
        }
        // propagate our updates via broadcast
        var updatedHops = hops
        if updatedHops != -1 {
            // update only if different from unreachable hops (-1)
            updatedHops += 1
        }
        broadcastUpdate(
            destination: destination,
            hops: updatedHops,
            sequenceNumber: sequenceNumber
        )
        if updatedHops == -1 {
            if let index = self.Members.firstIndex(of: destination) {
                self.Members.remove(at: index)
            }
        } else {
            if !self.Members.contains(destination) {
                self.Members.append(destination)
            }
        }
    }
    
    func broadcastUpdate(
        destination: NodeID,
        hops: Int,
        sequenceNumber: SequenceNumber
    ) {
        guard let delegate = self.delegate else {
            print("Error: no delegate available")
            return
        }
        
        delegate.broadcastUpdate(
            destination: destination,
            hops: hops,
            sequenceNumber: sequenceNumber.value
        )
    }
    
    func broadcastMessage(
        data: Data
    ) {
        guard let delegate = self.delegate else {
            print("Error: no delegate available")
            return
        }
        // broadcast message to all the members
        for member in self.Members {
            // retrieve next hop for member
            guard let nextHop = self.Table.getNextHop(for: member) else {
                // fail nextHop retrieve
                continue
            }
            delegate.unicastApplicationPacket(
                nextHop: nextHop,
                destination: member,
                applicationData: data
            )
        }
    }
    
    func forwardMessage(
        to destination: NodeID,
        applicationData data: Data
    ) {
        guard let delegate = self.delegate else {
            print("Error: no delegate available")
            return
        }
        // retrieve nextHop
        guard let nextHop = self.Table.getNextHop(for: destination) else {
            // fail nextHop retrieve
            return
        }
        delegate.unicastApplicationPacket(
            nextHop: nextHop,
            destination: destination,
            applicationData: data
        )
    }
}
