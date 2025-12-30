import MultipeerConnectivity
import UIKit

protocol MultipeerManagerDelegate: AnyObject {
    func notifyMessage(sender: String, message: String)
}

class MultipeerManager: NSObject {
    // Singleton
    static let shared = MultipeerManager()
    
    // Delegate
    weak var delegate: MultipeerManagerDelegate?
    
    // Private Data
    private var PeerID: MCPeerID
    private var Session: MCSession?
        
    override init() {
        // PeerID
        if let data = UserDefaults.standard.data(forKey: "mc-peer-id"),
           let savedPeerID = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            // restore existing PeerID
            self.PeerID = savedPeerID
        } else {
            // create new PeerID
            let newPeerID = MCPeerID(displayName: UIDevice.current.name)
            self.PeerID = newPeerID
            
            // save the PeerID
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: newPeerID, requiringSecureCoding: true) {
                UserDefaults.standard.set(data, forKey: "mc-peer-id")
            }
        }
        super.init()
    }
        
    // Multipeer Connectivity Logic
    private func createSession(sessionName: String) -> Void {
        guard self.Session == nil else {
            print("A session already exists.")
            return
        }
        let newSession = MCSession(peer: self.PeerID)
        newSession.delegate = self
        self.Session = newSession
    }
    
    private func disconnectSession() -> Void {
        guard let session = self.Session else {
            print("No session to disconnect.")
            return
        }
        session.disconnect()
        self.Session = nil
    }
    
    func getAvailableSessions() -> [MCSession] {
        // implement
        return []
    }
    
    func advertiseSession() -> Void {
        // implement
    }
    
    func stopAdvertisingSession() -> Void {
        // implement
    }
    
    func sendData(data: Data) -> Void {
        guard let peers = self.Session?.connectedPeers else {
            print("No session found.")
            return
        }
        guard !peers.isEmpty else {
            return
        }
        do {
            try self.Session?.send(
                data,
                toPeers: peers,
                with: .reliable
            )
        } catch {
            print("Error sending data: \(error)")
        }
    }
    
    // module methods
    func launchRoom() -> Void {
        createSession(sessionName: "default-session")
    }
    
    func leaveRoom() -> Void {
        disconnectSession()
    }
    
    func sendMessage(sender: String, message: String) -> Void {
        let payload = "\(sender)|\(message)"
            
        guard let data = payload.data(using: .utf8) else {
            print("Error encoding data.")
            return
        }
        
        sendData(data: data)
    }
}

extension MultipeerManager: MCSessionDelegate {
    
    // 1. Chiamato quando un peer cambia stato (si connette/disconnette)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Qui puoi gestire i cambiamenti di stato
    }

    // call when a message is received
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // decode message
        guard let receivedString = String(data: data, encoding: .utf8) else {
            print("Error decoding data.")
            return
        }
        let components = receivedString.split(separator: "|", maxSplits: 1)
        if components.count == 2 {
            let sender = String(components[0])
            let message = String(components[1])
            // notify
            DispatchQueue.main.async {
                self.delegate?.notifyMessage(
                    sender: sender,
                    message: message
                )
            }
        } else {
            print("Unkown message format.")
            return
        }
        
    }

    // 3. Metodi obbligatori (anche se vuoti, vanno dichiarati)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) { }
}
