import ExpoModulesCore

public class MultipeerConnectivityModule: Module {
    public func definition() -> ModuleDefinition {
        Name("MultipeerConnectivityModule")

        Events("foundSession", "receivedMessage")

        OnCreate {
            // init Manager and assign delegate
            MultipeerManager.shared.delegate = self
        }

        Function("createGroup") { (groupName: String) -> Void in
            MultipeerManager.shared.launchGroup(groupName: groupName)
        }
        
        Function("joinGroup") { (groupName: String) -> Void in
            MultipeerManager.shared.handleInvitationResponse(
                groupName: groupName,
                accept: true
            )
        }
        
        Function("leaveGroup") { () -> Void in
            MultipeerManager.shared.leaveGroup()
        }
        
        Function("sendMessage") { (message: String, sender: String) -> Void in
            MultipeerManager.shared.sendMessage(
                sender: sender,
                message: message
            )
        }
    }
}

extension MultipeerConnectivityModule: MultipeerManagerDelegate {
    func notifySession(groupName: String) {
        sendEvent("foundSession", [
            "groupName" : groupName
        ])
    }
    
    func notifyMessage(sender: String, message: String) {
        sendEvent("receivedMessage", [
            "sender" : sender,
            "message": message
        ])
    }
}
