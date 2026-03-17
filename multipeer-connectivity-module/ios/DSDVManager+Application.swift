import Foundation

extension DSDVManager: ChatManagerNetworkDelegate {
    func broadcastMessage(data: Data) {
        guard let linkDelegate = self.LinkDelegate else {
            print("Network Error: impossible to broadcast data, no link delegate available.")
            return
        }
        for member in getMembers() {
            guard let member != MyNodeID else {
                // skip broadcasting to self
                continue
            }
            forwardMessage(
                to: member,
                applicationData: data
            )
        }
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
