import Foundation

extension DSDVManager: MultipeerManagerNetworkDelegate {
    func notifyNewLink(
        newNode: NodeID
    ) {
        let myNodeID = getMyNodeID()
        handleUpdate(
            from: myNodeID,
            destination: myNodeID,
            hops: 0,
            sequenceNumber: incrementMySequenceNumber()
        )
    }
    
    func notifyBrokenLink(
        brokenNode: NodeID
    ) {
        guard let destinationSequenceNumber = getSequenceNumber(of: brokenNode) else {
            // no brokenNode in table: exit
            return
        }
        handleUpdate(
            from: getMyNodeID(),
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
            guard components.count == 5 else {
                print("Network Error: unknown network packet format.")
                return
            }
            let from = String(components[1])
            let destination = String(components[2])
            guard
                let hops = Int(components[3]),
                let sequenceNumberValue = Int(components[4])
            else {
                print("Network Error: error during hops and/or sequence number parsing.")
                return
            }
            handleUpdate(
                from: from,
                destination: destination,
                hops: hops,
                sequenceNumber: SequenceNumber(
                    value: sequenceNumberValue,
                    destination: destination
                )
            )
        case 1:
            // application packet
            let destination = String(components[1])
            let applicationMessage = "\(components[2])|\(components[3])"
            guard let applicationData = applicationMessage.data(using: .utf8) else {
                print("Network Error: impossible to forward message, an error occur during application data encoding.")
                return
            }
            guard destination == getMyNodeID() else {
                // we are not the destination: forward packet
                forwardMessage(
                    to: destination,
                    applicationData: applicationData
                )
                return
            }
            // consume message: notify application layer
            guard let applicationDelegate = self.ApplicationDelegate else {
                print("Network Error: impossible to handle message, no application delegate available.")
                return
            }
            applicationDelegate.handleMessage(data: applicationData)
        default:
            print("Network Error: unkown packet type.")
            return
        }
    }
    
    func reset() {
        handleReset()
    }
}
