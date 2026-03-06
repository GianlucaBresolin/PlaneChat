import Foundation
import MultipeerConnectivity

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    // invitation handler
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // extract session name
        guard
            let data = context,
            let sessionName = String(data: data, encoding: .utf8)
        else {
            print("Link Error: fail to extract information from invitation.")
            return
        }
        // are we in a session?
        guard let sessionAvailable = sessionAvailable() else {
            return
        }
        if sessionAvailable {
            // YES: append invitation only if it is our group and we have space
            guard
                let checkSessionName = checkSessionName(sessionName: sessionName),
                checkSessionName,
                let sessionPeers = getSessionPeers(),
                sessionPeers.count < self.MCSessionSize,
                !sessionPeers.contains(peerID)
            else {
                invitationHandler(false, nil)
                return
            }
            // by default, accept invitation to increase connectivity
            invitationHandler(true, getSession())
        } else {
            // NO: append invitation and notify upper layers
            guard let networkDelegate = self.NetworkDelegate else {
                print("Link Error: impossible to notify invitation, no network delegate available.")
                return
            }
            addPendingInvitation(sessionName: sessionName, invitationHandler: invitationHandler)
            networkDelegate.notifySession(sessionName: sessionName)
        }
    }
}
