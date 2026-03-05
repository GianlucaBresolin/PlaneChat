import Foundation
import MultipeerConnectivity

extension MultipeerManager: MCSessionDelegate {
    // call when a peer change state (connect/disconnect/connecting)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard let networkDelegate = self.NetworkDelegate else {
            print("Link Error: impossibe to notify peer's state change. No network delegate available.")
            return
        }
        switch state {
        case .connected:
            networkDelegate.notifyNewLink(newNode: peerID.displayName)
            removeNeighbor(neighbor: peerID)
        case .notConnected:
            networkDelegate.notifyBrokenLink(brokenNode: peerID.displayName)
            removeMember(member: peerID)
            addNeighbor(neighbor: peerID)
            // try to invite it back
            invitePeerToSession(peer: peerID)
        case .connecting:
            break
        @unknown default:
            break
        }
    }

    // call when a message is received
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // decode message
        guard let networkDelegate = self.NetworkDelegate else {
            print("Link Error: impossibe to handle incoming message. No network delegate available.")
            return
        }
        networkDelegate.handleMessage(
            from: peerID.displayName,
            data: data
        )
    }

    // not relevant for our application
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) { }
}
