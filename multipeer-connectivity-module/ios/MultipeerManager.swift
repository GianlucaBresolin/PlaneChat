import MultipeerConnectivity
import UIKit

class MultipeerManager: NSObject {
    // Singleton
    static let shared = MultipeerManager()
    
    // Private Data
    private var PeerID: MCPeerID
    private var Session: MCSession?
        
    override init() {
        // PeerID
        if let data = UserDefaults.standard.data(forKey: "multiconnectivity-peer-id"),
           let savedPeerID = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            // restore existing PeerID
            self.PeerID = savedPeerID
        } else {
            // create new PeerID
            let newPeerID = MCPeerID(displayName: UIDevice.current.name)
            self.PeerID = newPeerID
            
            // save the PeerID
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: newPeerID, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "multiconnectivity-peer-id")
            }
        }
        super.init()
    }
    
    func getPeerIDAsString() -> String {
        return self.PeerID.displayName
    }
    
    func createSession(sessionName: String) -> Void {
        if self.Session == nil {
            self.Session = MCSession(peer: self.PeerID)
        }
    }
}
