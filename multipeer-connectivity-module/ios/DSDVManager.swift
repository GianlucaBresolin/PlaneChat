import Foundation
typealias NodeID = String

class DSDVManager {
    private let MyNodeID : NodeID
    private var MySequenceNumber : SequenceNumber
    private var Table : DSDVTable
    
    weak var LinkDelegate : DSDVManagerLinkDelegate?
    weak var ApplicationDelegate : DSDVManagerApplicationDelegate?
    
    let IsolationQueue: DispatchQueue
    
    init(
        nodeID: NodeID
    ) {
        MyNodeID = nodeID
        MySequenceNumber = SequenceNumber(value: 0, destination: self.MyNodeID)
        Table = DSDVTable()
        IsolationQueue = DispatchQueue(label: "DSDVManagerIsolationQueue")
    }
    
    func handleReset() -> Void {
        self.IsolationQueue.async {
            self.Table.reset()
            self.MySequenceNumber.reset()
        }
    }
    
    func getMyNodeID() -> NodeID {
        return IsolationQueue.sync {
            return self.MyNodeID
        }
    }
    
    // Table
    func updateLine(
        destination: NodeID,
        next: NodeID?,
        hops: Int,
        sequenceNumber: SequenceNumber
    ) -> Bool {
        return IsolationQueue.sync {
            return
                self.Table.updateLine(
                    to: destination,
                    next: next,
                    hops: hops,
                    sequenceNumber: sequenceNumber
                )
        }
    }
    
    func getSequenceNumber(of: NodeID) -> SequenceNumber? {
        return IsolationQueue.sync {
            return self.Table.getSequenceNumber(of: of)
        }
    }
    
    func getNextHop(for destination: NodeID) -> NodeID? {
        return IsolationQueue.sync {
            return self.Table.getNextHop(for: destination)
        }
    }
    
    func getMembers() -> [NodeID] {
        return IsolationQueue.sync {
            return self.Table.getMembers()
        }
    }
    
    // Sequence Number
    func incrementMySequenceNumber() -> SequenceNumber {
        return IsolationQueue.sync {
            return self.MySequenceNumber.increment()
        }
    }
    
    // Update
    func handleUpdate(
        from: NodeID,
        destination: NodeID,
        hops: Int,
        sequenceNumber: SequenceNumber
    ) {
        guard
            updateLine(
                destination: destination,
                next: from,
                hops: hops,
                sequenceNumber: sequenceNumber
            )
        else {
            // no significant update
            return
        }
        // broadcast update
        var updatedHops = hops
        if updatedHops != -1 {
            // update only if different from unreachable hops (-1)
            updatedHops += 1
        }
        let packetUpdate = "0|\(self.MyNodeID)|\(destination)|\(updatedHops)|\(sequenceNumber.value)"
        guard let packetUpdatePayload = packetUpdate.data(using: .utf8) else {
            print("Network Error: fail to encode update packet.")
            return
        }
        guard let linkDelegate = self.LinkDelegate else {
            print("Network Error: impossible to broadcast update, no link delegate available.")
            return
        }
        linkDelegate.broadcastPacket(data: packetUpdatePayload)
    }

    
    // Forward
    func forwardMessage(
        to destination: NodeID,
        applicationData: Data
    ) {
        IsolationQueue.async {
            guard let linkDelegate = self.LinkDelegate else {
                print("Network Error: impossible to forward message, no link delegate available")
                return
            }
            guard let nextHop = self.Table.getNextHop(for: destination) else {
                print("Network Error: impossible to forward message, impossible to retrieve next hop.")
                return
            }
            let networkPacketHeader = "1|\(destination)|"
            guard let networkPacketHeaderPayload = networkPacketHeader.data(using: .utf8) else {
                print("Network Error: impossible to forward message, an error occur during network packet header encoding.")
                return
            }
            linkDelegate.unicastPacket(
                destination: nextHop,
                data: networkPacketHeaderPayload + applicationData
            )
        }
    }
}
