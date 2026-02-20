import Foundation
import MultipeerConnectivity

extension MultipeerManager: MCSessionDelegate {
    // call when a peer change state (connect/disconnect/connecting)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            switch state {
            case .connected:
                // notify network manager
                self.NetworkManager.notifyNewLink(newNode: peerID.displayName)
                // remove it from neighbors
                guard let peerIndex = self.Neighbors.firstIndex(of: peerID) else {
                    break
                }
                self.Neighbors.remove(at: peerIndex)
            case .notConnected:
                // notify network manager
                self.NetworkManager.notifyBrokenLink(brokenNode: peerID.displayName)
                // remove it from members
                if let peerIndex = self.Members.firstIndex(of: peerID) {
                    self.Members.remove(at: peerIndex)
                }
                // add it back to our neighbors
                if !self.Neighbors.contains(peerID) {
                    self.Neighbors.append(peerID)
                }
                // try to invite it back (if we have a valid session)
                guard let browser = self.Browser else {
                    break
                }
                guard let session = self.Session else {
                    break
                }
                let groupName = self.GroupName
                guard groupName != "" else {
                    break
                }
                guard let groupNameData = groupName?.data(using: .utf8) else {
                    print("Error converting group name to data")
                    break
                }
                browser.invitePeer(
                    peerID,
                    to: session,
                    withContext: groupNameData,
                    timeout: self.InviteDuration
                )
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }

    // call when a message is received
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // decode message
        guard let receivedString = String(data: data, encoding: .utf8) else {
            print("Error decoding data.")
            return
        }
        let components = receivedString.split(separator: "|")
        switch Int(components[0]) {
        case 0:
            // network packet:
            guard components.count == 4 else {
                print("Unknown network packet format.")
                break
            }
            let destination = String(components[1])
            guard let hops = Int(components[2]) else {
                print("Error during hops parsing.")
                break
            }
            guard let sequenceNumberValue = Int(components[3]) else {
                print("Error during sequence number parsing.")
                break
            }
            let sequenceNumber = SequenceNumber(
                value: sequenceNumberValue,
                destination: destination
            )
        
            NetworkManager.handleUpdate(
                from: peerID.displayName,
                destination: destination,
                hops: hops,
                sequenceNumber: sequenceNumber
            )
        case 1:
            // application packet: message received
            if components.count == 4 {
                let destination = String(components[1])
                let sender = String(components[2])
                let message = String(components[3])
                if destination == self.PeerID.displayName {
                    // destination reach: notify front
                    DispatchQueue.main.async {
                        self.delegate?.notifyMessage(
                            sender: sender,
                            message: message
                        )
                    }
                } else {
                    // reconstruct applicationData
                    let applicationPayload = "\(sender)|\(message)"
                    guard let applicationData = applicationPayload.data(using: .utf8) else {
                        print("Error during application data encoding.")
                        return
                    }
                    // forward to destination
                    self.NetworkManager.forwardMessage(
                        to: destination,
                        applicationData: applicationData
                    )
                }
            } else {
                print("Unkown message format.")
            }
        default:
            print("Unkown packet type.")
            break
        }
    }

    // not relevant for our application
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) { }
}
