import ExpoModulesCore

public class MultipeerConnectivityModule: Module, MultipeerManagerDelegate {
    public func definition() -> ModuleDefinition {
        Name("MultipeerConnectivityModule")

        Events("receivedMessage")

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
        
        Function("sendMessage") { (message: String, sender: String) -> Void in
            MultipeerManager.shared.sendMessage(
                sender: sender,
                message: message
            )
        }
    }

    func notifyMessage(sender: String, message: String) {
        sendEvent("receivedMessage", [
            "sender" : sender,
            "message": message
        ])
    }
}
