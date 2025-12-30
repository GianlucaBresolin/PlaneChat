import ExpoModulesCore

public class MultipeerConnectivityModule: Module {
    public func definition() -> ModuleDefinition {
        Name("MultipeerConnectivityModule")

        Events("foundSession", "receivedMessage")

        Function("initialize") {() -> Void in
            // init Manager and assign delegate
            MultipeerManager.shared.delegate = self
        }

        Function("createRoom") { (sessionName: String) -> Void in
            MultipeerManager.shared.launchRoom()
        }

        Function("leaveRoom") { () -> Void in
            MultipeerManager.shared.leaveRoom()
        }
        
        Function("joinSession") { (sessionName: String) -> Void in
            MultipeerManager.shared.handleInvitationResponse(
                sessionName: sessionName,
                accept: true
            )
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
    func notifySession(sessionName: String) {
        sendEvent("foundSession", [
            "sessionName" : sessionName
        ])
    }
    
    func notifyMessage(sender: String, message: String) {
        sendEvent("receivedMessage", [
            "sender" : sender,
            "message": message
        ])
    }
}
