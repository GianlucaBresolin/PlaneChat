import ExpoModulesCore

public class MultipeerConnectivityModule: Module {
    public func definition() -> ModuleDefinition {
        Name("MultipeerConnectivityModule")

        Events("foundSession", "receivedMessage")

        Function("initialize") {() -> Void in
            // init Manager and assign delegate
            MultipeerManager.shared.delegate = self
        }

        Function("createSession") { (sessionName: String) -> Void in
            MultipeerManager.shared.launchSession(sessionName: sessionName)
        }
        
        Function("joinSession") { (sessionName: String) -> Void in
            MultipeerManager.shared.handleInvitationResponse(
                sessionName: sessionName,
                accept: true
            )
        }
        
        Function("leaveSession") { () -> Void in
            MultipeerManager.shared.leaveSession()
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
