import Foundation

extension MultipeerManager : DSDVManagerLinkDelegate {
    func launchSession(sessionName: String) -> Void {
        guard createSession(sessionName: sessionName) != nil else {
            print("Link Error: impossible to launch session. Session already exist.")
            return
        }
        inviteNeighborsToSession()
    }
    
    func quitSession(sessionName: String) {
        guard checkSessionName(sessionName: sessionName) else {
            print("Link Error: impossible to leave session. Different session name provided.")
            return
        }
        disconnectSession()
    }
    
    func handleInvitationResponse(sessionName: String, accepted: Bool) {
        guard let invitation = getInvitationHandler(sessionName: sessionName) else {
            return
        }
        if accepted {
            // accept to join session
            guard let session = createSession(sessionName: sessionName) else {
                print("Link Error: impossible to accept invitation, an error occur while creating session.")
                removeInvitation(sessionName: sessionName)
                return
            }
            invitation(accepted, session)
            clearInvitations()
            // propagate invitations to our neighbors
            inviteNeighborsToSession()
        } else {
            // reject to join session
            invitation(accepted, nil)
            removeInvitation(sessionName: sessionName)
        }
    }
    
    func broadcastPacket(
        data: Data
    ) {
        guard let peers = getSessionPeers() else {
            return
        }
        guard !peers.isEmpty else {
            return
        }
        sendData(peers: peers, data: data)
    }
    
    func unicastPacket(
        destination: NodeID, 
        data: Data
    ) {
        guard let MCDestinationID = getMCIDfrom(displayName: destination) else {
            return
        }
        sendData(peers: [MCDestinationID], data: data)
    }
}
