import Foundation

extension DSDVManager: ChatManagerNetworkDelegate {
    func broadcast(data: Data) {
        guard let linkDelegate = self.LinkDelegate else {
            print("Network Error: impossible to broadcast data, no link delegate available.")
            return
        }
        let packetHeader = "1|"
        guard let packetHeaderPayload = packetHeader.data(using: .utf8) else {
            print("Network Error: fail to encode packet header.")
            return
        }
        let packetPayload = packetHeaderPayload + data
        linkDelegate.broadcastPacket(data: packetPayload)
    }
    
    func requestControl(
        command: String, 
        groupName: String
    ) {
        guard let linkDelegate = self.LinkDelegate else {
            print("Network Error: impossible to execute command, no link delegate available.")
            return
        }
        switch command {
            case "createGroup":
                linkDelegate.launchSession(sessionName: groupName)
            case "joinGroup":
                linkDelegate.handleInvitationResponse(
                    sessionName: groupName,
                    accepted: true
                )
            case "leaveGroup":
                linkDelegate.quitSession(sessionName: groupName)
            default:
                print("Network Error: unkown command received.")
                break
        }
    }
}
