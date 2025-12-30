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
    private var Browser: MCNearbyServiceBrowser?
    private var Neighbors: [MCPeerID] = []
        
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
        // MCNearbyServiceBrowser
        createBrowser()
        startBrowsing()
    }
    
    deinit {
        // to do
        stopBrowsing()
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
    
    private func createBrowser() -> Void {
        guard self.Browser == nil else {
            print("A browser already exists.")
            return
        }
        let browser = MCNearbyServiceBrowser(
            peer: self.PeerID,
            serviceType: "plane-chat"
        )
        browser.delegate = self
        self.Browser = browser
    }
    
    private func startBrowsing() -> Void {
        guard let browser = self.Browser else {
            print("Error: no available browser")
            return
        }
        browser.startBrowsingForPeers()
    }
    
    private func stopBrowsing() -> Void {
        guard let browser = self.Browser else {
            print("Error: no available browser")
            return
        }
        browser.stopBrowsingForPeers()
    }
    
    func getAvailableSessions() -> [MCSession] {
        // to do
        return []
    }
    
    func advertiseSession() -> Void {
        // to do
    }
    
    func stopAdvertisingSession() -> Void {
        // to do
    }
    
    private func sendData(data: Data) -> Void {
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
    
    // call when a peer change state (connect/disconnect)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // to do
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

    // not relevant for our application
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) { }
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    // call when found a peer
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        // save to our peers
        self.Neighbors.append(peerID)
        
        guard let session = self.Session else {
            return
        }
        // send request to join our session
        guard let browser = self.Browser else {
            print("Error: no browser available")
            return
        }
        browser.invitePeer(
            self.PeerID,
            to: session,
            withContext: session.description.data(using: .utf8),
            timeout: 60
        )
    }

    // call when a peer is lost
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // remove it from saved peers (if present)
        if let index = self.Neighbors.firstIndex(of: peerID) {
            self.Neighbors.remove(at: index)
        }
    }
}
