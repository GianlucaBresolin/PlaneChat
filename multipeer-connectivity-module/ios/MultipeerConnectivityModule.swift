import ExpoModulesCore
import MultipeerConnectivity

public class MultipeerConnectivityModule: Module {
    private var ApplicationManager: ChatManager?
    private var NetworkManager: DSDVManager?
    private var LinkManager: MultipeerManager?

    public func definition() -> ModuleDefinition {
        Name("MultipeerConnectivityModule")

        Events("foundGroup", "receivedMessage")

        OnCreate {
            // retrieve device ID
            var deviceID: MCPeerID? = nil
            if
                let data = UserDefaults.standard.data(forKey: "mc-peer-id"),
                let savedID = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data)
            {
                // restore existing device ID
                deviceID = savedID
            } else {
                // create new PeerID
                deviceID = MCPeerID(displayName: UIDevice.current.name)
                
                // save the PeerID
                if let data = try? NSKeyedArchiver.archivedData(withRootObject: deviceID!, requiringSecureCoding: true) {
                    UserDefaults.standard.set(data, forKey: "mc-peer-id")
                }
            }
            
            guard deviceID != nil else {
                print("Module Error: an error occured during deviceID creation.")
                return
            }
            // create protocol managers
            self.ApplicationManager = ChatManager(nodeID: deviceID!.displayName)
            self.NetworkManager = DSDVManager(nodeID: deviceID!.displayName)
            self.LinkManager = MultipeerManager(peerID: deviceID!)
            
            // assign delegates
            self.ApplicationManager?.PresentationDelegate = self
            self.ApplicationManager?.NetworkDelegate = self.NetworkManager
            self.NetworkManager?.ApplicationDelegate = self.ApplicationManager
            self.NetworkManager?.LinkDelegate = self.LinkManager
            self.LinkManager?.NetworkDelegate = self.NetworkManager
        }

        Function("createGroup") { (groupName: String) -> Void in
            guard let applicationManager = self.ApplicationManager else {
                return
            }
            applicationManager.createGroup(groupName: groupName)
        }
        
        Function("joinGroup") { (groupName: String) -> Void in
            guard let applicationManager = self.ApplicationManager else {
                return
            }
            applicationManager.joinGroup(
                groupName: groupName
            )
        }
        
        Function("leaveGroup") { (groupName: String) -> Void in
            guard let applicationManager = self.ApplicationManager else {
                return
            }
            applicationManager.leaveGroup(groupName: groupName)
        }
        
        Function("sendMessage") { (sender: String, message: String) -> Void in
            guard let applicationManager = self.ApplicationManager else {
                return
            }
            applicationManager.sendMessage(
                sender: sender,
                message: message
            )
        }
    }
}

extension MultipeerConnectivityModule: ChatManagerPresentationDelegate {
    func notifyGroup(groupName: String) {
        sendEvent("foundGroup", [
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
