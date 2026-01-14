import Foundation
import MultipeerConnectivity

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    // call when found a peer
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            // do we have a group?
            guard let session = self.Session else {
                // NO: save to our neighbor peers (if not already present)
                if self.Neighbors.contains(PeerID) == false {
                    self.Neighbors.append(peerID)
                }
                return
            }
            
            // is it already in the group?
            if self.Members.contains(peerID) {
                // YES: invite it only if we do not have it in our session and we have space to increase connectivity
                guard session.connectedPeers.count < self.MCSessionSize && (session.connectedPeers.contains(peerID) == false)  else {
                    return
                }
            } else {
                // NO: invite it only if our session is not full
                guard session.connectedPeers.count < self.MCSessionSize else {
                    return
                }
            }
            
            // invite: send request to join our session
            guard let browser = self.Browser else {
                print("Error: no browser available")
                return
            }
            let groupName = self.GroupName
            guard groupName != "" else {
                print("Invalid group name: can not invite peer")
                return
            }
            guard let groupNameData = groupName?.data(using: .utf8) else {
                print("Error converting group name to data")
                return
            }
            browser.invitePeer(
                peerID,
                to: session,
                withContext: groupNameData,
                timeout: self.InviteDuration
            )
        }
    }

    // call when a peer is lost
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            // remove it from saved peers (if present)
            if let index = self.Neighbors.firstIndex(of: peerID) {
                self.Neighbors.remove(at: index)
            }
        }
    }
}
