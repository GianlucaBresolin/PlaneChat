import MultipeerConnectivity
import UIKit

protocol MultipeerManagerDelegate: AnyObject {
    func notifySession(sessionName: String)
    func notifyMessage(sender: String, message: String)
}

class MultipeerManager: NSObject {
    // Singleton
    static let shared = MultipeerManager()
    
    // Delegate
    weak var delegate: MultipeerManagerDelegate?
    
    // Dispatching Queue for thread-safety
    private let isolationQueue: DispatchQueue
    
    // Private Data
    private var PeerID: MCPeerID
    private var Session: MCSession?
    private var SessionName : String?
    private var Browser: MCNearbyServiceBrowser?
    private var Advertiser: MCNearbyServiceAdvertiser?
    private var PendingInvitations: [String: (Bool, MCSession?) -> Void]
    private var Neighbors: [MCPeerID] = []
    
    // Constants
    private let InviteDuration: TimeInterval = 120
        
    override init() {
        // dispatch queue
        self.isolationQueue = DispatchQueue(label: "multipeer-manager-isolation-queue")
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
        // pending invitations
        self.PendingInvitations = [:]
        
        super.init()
        
        // MCNearbyServiceBrowser
        createBrowser()
        startBrowsing()
        // MCNearbyServiceAdvertiser
        createAdvertiser()
        startAdvertising()
    }
    
    deinit {
        self.Session?.disconnect()
        self.Browser?.stopBrowsingForPeers()
        self.Advertiser?.stopAdvertisingPeer()

        // remove delegates
        self.Browser?.delegate = nil
        self.Advertiser?.delegate = nil
        self.Session?.delegate = nil

        // remove pending closures
        self.PendingInvitations.removeAll()
    }
        
    // Multipeer Connectivity Logic
    private func createSession(sessionName: String) -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.Session == nil else {
                print("A session already exists.")
                return
            }
            let newSession = MCSession(
                peer: self.PeerID,
                
            )
            newSession.delegate = self
            self.Session = newSession
            self.SessionName = sessionName
        }
    }
    
    private func disconnectSession() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let session = self.Session else {
                print("No session to disconnect.")
                return
            }
            session.disconnect()
            self.Session = nil
            self.SessionName = ""
        }
    }
    
    private func createBrowser() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
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
    }
    
    private func startBrowsing() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let browser = self.Browser else {
                print("Error: no available browser")
                return
            }
            browser.startBrowsingForPeers()
        }
    }
    
    private func stopBrowsing() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let browser = self.Browser else {
                print("Error: no available browser")
                return
            }
            browser.stopBrowsingForPeers()
        }
    }
    
    private func createAdvertiser() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.Advertiser == nil else {
                print("An advertiser already exists")
                return
            }
            let advertiser = MCNearbyServiceAdvertiser(
                peer: self.PeerID,
                discoveryInfo: nil,
                serviceType: "plane-chat"
            )
            advertiser.delegate = self
            self.Advertiser = advertiser
        }
    }
    
    private func startAdvertising() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let advertiser = self.Advertiser else {
                print("Error: no available advertiser")
                return
            }
            advertiser.startAdvertisingPeer()
        }
    }
    
    private func stopAdvertising() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let advertiser = self.Advertiser else {
                print("Error: no available advertiser")
                return
            }
            advertiser.stopAdvertisingPeer()
        }
    }
    
    private func inviteNeighborsToSession() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let neighbors = self.Neighbors
            if neighbors.isEmpty == false {
                guard let browser = self.Browser else {
                    print("Error: no available browser")
                    return
                }
                guard let session = self.Session else {
                    print("Error: no available session")
                    return
                }
                let sessionName = self.SessionName
                guard sessionName != "" else {
                    print("Invalid session name: can not invite peer")
                    return
                }
                guard let sessionNameData = sessionName?.data(using: .utf8) else {
                    print("Error converting session name to data")
                    return
                }

                for peerID in neighbors {
                    browser.invitePeer(
                        peerID,
                        to: session,
                        withContext: sessionNameData,
                        timeout: self.InviteDuration
                    )
                }
            }
        }
    }
    
    private func sendData(data: Data) -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
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
    }
    
    // module methods
    func launchSession(sessionName: String) -> Void {
        createSession(sessionName: sessionName)
        inviteNeighborsToSession()
    }
    
    func handleInvitationResponse(sessionName: String, accept: Bool) {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let invitationHandler = self.PendingInvitations[sessionName] else {
                print("Error: no invitation found for session: \(sessionName)")
                return
            }
            invitationHandler(accept, self.Session)
            self.PendingInvitations.removeValue(forKey: sessionName)
        }
    }
    
    func leaveSession() -> Void {
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
    // call when a peer change state (connect/disconnect/connecting)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            switch state {
            case .connected:
                guard let peerIndex = self.Neighbors.firstIndex(of: peerID) else {
                    break
                }
                self.Neighbors.remove(at: peerIndex)
            case .notConnected:
                break
            case .connecting:
                break
            @unknown default:
                break
            }
        }
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
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            // save to our peers (if not already present)
            guard self.Neighbors.contains(PeerID) else {
                self.Neighbors.append(peerID)
            }
            
            guard let session = self.Session else {
                // no session available: do nothing
                return
            }
            // send request to join our session
            guard let browser = self.Browser else {
                print("Error: no browser available")
                return
            }
            let sessionName = self.SessionName
            guard sessionName != "" else {
                print("Invalid session name: can not invite peer")
                return
            }
            guard let sessionNameData = sessionName?.data(using: .utf8) else {
                print("Error converting session name to data")
                return
            }
            browser.invitePeer(
                peerID,
                to: session,
                withContext: sessionNameData,
                timeout: self.InviteDuration
            )
        }
    }

    // call when a peer is lost
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            // remove it from saved peers (if present)
            if let index = self.Neighbors.firstIndex(of: peerID) {
                self.Neighbors.remove(at: index)
            }
        }
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    // invitation handler
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // extract session name
        guard let data = context else {
            print("Error: invalid invitation")
            return
        }
        guard let sessionName = String(data: data, encoding: .utf8) else {
            print("Error during session name extraction")
            return
        }
        // notify invitation to session
        DispatchQueue.main.async {
            self.delegate?.notifySession(
                sessionName: sessionName
            )
        }
        // store invitationHandler
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.PendingInvitations[sessionName] = invitationHandler
        }
    }
}
