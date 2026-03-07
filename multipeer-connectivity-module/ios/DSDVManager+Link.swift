import Foundation

extension DSDVManager: MultipeerManagerNetworkDelegate {
    func notifyNewLink(
        newNode: NodeID
    ) {
        guard let myNodeID = getMyNodeID() else {
            print("Network Error: impossible to notify new link, fail to retrieve node ID.")
            return
        }
        handleUpdate(
            from: myNodeID,
            destination: myNodeID,
            hops: 0,
            sequenceNumber: incrementSequenceNumber()
        )
    }
    
    func notifyBrokenLink(
        brokenNode: NodeID
    ) {
        // obtain brokenNode sequence number
        guard let destinationSequenceNumber = getSequenceNumber(of: brokenNode) else {
            // no brokenNode in table: exit
            return
        }
        guard let myNodeID = getMyNodeID() else {
            print("Network Error: impossible to notify broken link, fail to retrieve node ID.")
            return
        }
        handleUpdate(
            from: myNodeID,
            destination: brokenNode,
            hops: -1,
            sequenceNumber: destinationSequenceNumber
        )
    }
    
    func notifySession(sessionName: String) {
        guard let applicationDelegate = self.ApplicationDelegate else {
            print("Network Error: impossible to notify session, no ApplicationDelegate available.")
            return
        }
        applicationDelegate.notifyGroup(groupName: sessionName)
    }
    
    func handleMessage(data: Data) {
        guard let receivedString = String(data: data, encoding: .utf8) else {
            print("Network Error: fail to decode data.")
            return
        }
        let components = receivedString.split(separator: "|")
        switch Int(components[0]) {
        case 0:
            // network packet:
            guard components.count == 4 else {
                print("Network Error: unknown network packet format.")
                break
            }
            let from = String(components[1])
            let destination = String(components[2])
            guard let hops = Int(components[3]) else {
                print("Network Error: error during hops parsing.")
                break
            }
            guard let sequenceNumberValue = Int(components[4]) else {
                print("Error during sequence number parsing.")
                break
            }
            let sequenceNumber = SequenceNumber(
                value: sequenceNumberValue,
                destination: destination
            )
            handleUpdate(
                from: from,
                destination: destination,
                hops: hops,
                sequenceNumber: sequenceNumber
            )
        case 1:
            // application packet
            guard let applicationDelegate = self.ApplicationDelegate else {
                print("Network Error: impossible to handle message, no application delegate available.")
                return
            }
            applicationDelegate.handleMessage(data: data)
        default:
            print("Network Error: unkown packet type.")
            break
        }
    }
    
    func reset() {
        handleReset()
    }
}
