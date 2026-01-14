import Foundation
import MultipeerConnectivity

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    // invitation handler
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // extract session name
        guard let data = context else {
            print("Error: invalid invitation")
            return
        }
        guard let groupName = String(data: data, encoding: .utf8) else {
            print("Error during group name extraction")
            return
        }
        
        isolationQueue.async { [weak self] in
            guard let self else {
                return
            }
            // are we in a group?
            if let session = self.Session {
                // YES: is this our group?
                guard
                    self.GroupName == groupName &&
                    session.connectedPeers.count < self.MCSessionSize &&
                    session.connectedPeers.contains(peerID) == false
                else {
                    // NO: discard invitation: impossible to join another group or our session is full/already connected to peer
                    invitationHandler(false, nil)
                    return
                }
                // YES: accept invitation to increase connectivity
                invitationHandler(true, session)
            } else {
                // NO: send event to the user to notify invitation to session
                DispatchQueue.main.async {
                    self.delegate?.notifySession(
                        groupName: groupName
                    )
                }
                // store invitationHandler
                self.PendingInvitations[groupName] = invitationHandler
            }
        }
    }
}
