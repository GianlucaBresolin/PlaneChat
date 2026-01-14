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
                guard let peerIndex = self.Neighbors.firstIndex(of: peerID) else {
                    break
                }
                self.Neighbors.remove(at: peerIndex)
            case .notConnected:
                break
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
        let components = receivedString.split(separator: "|", maxSplits: 1)
        if components.count == 2 {
            let sender = String(components[0])
            let message = String(components[1])
            // notify
            DispatchQueue.main.async {
                self.delegate?.notifyMessage(
                    sender: sender,
                    message: message
                )
            }
        } else {
            print("Unkown message format.")
            return
        }
        
    }

    // not relevant for our application
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) { }
}
