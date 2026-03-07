import Foundation

protocol DSDVManagerLinkDelegate: AnyObject {
    func launchSession(sessionName: String)
    func handleInvitationResponse(sessionName: String, accepted: Bool)
    func quitSession(sessionName: String)
    func broadcastPacket(data: Data)
    func unicastPacket(destination: NodeID, data: Data)
}

protocol DSDVManagerApplicationDelegate: AnyObject {
    func notifyGroup(groupName: String)
    func handleMessage(data: Data)
}
