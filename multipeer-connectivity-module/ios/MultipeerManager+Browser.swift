import Foundation
import MultipeerConnectivity

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    // call when found a peer
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // are we in a session?
        guard sessionAvailable() else {
            // NO: save to our neighbor peers (if not already present).
            addNeighbor(neighbor: peerID)
            return
        }
        // YES: is it already in our session?
        guard let sessionPeers = getSessionPeers(), !sessionPeers.contains(peerID) else {
            // YES: do not invite it.
            return
        }
        // NO: do we have space?
        guard sessionPeers.count < self.MCSessionSize else {
            // NO: do not invite it.
            return
        }
        // YES: invite it.
        invitePeerToSession(peer: peerID)
}

    // call when a peer is lost (we were not connected)
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        removeNeighbor(neighbor: peerID)
    }
}
