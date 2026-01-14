import MultipeerConnectivity
import UIKit

class MultipeerManager: NSObject {
    // Singleton
    static let shared = MultipeerManager()
    
    // Delegate
    weak var delegate: MultipeerManagerDelegate?
    
    // Dispatching Queue for thread-safety
    let isolationQueue: DispatchQueue
    
    // Private Data
    var PeerID: MCPeerID
    var Session: MCSession?
    var GroupName : String?
    var Browser: MCNearbyServiceBrowser?
    var Advertiser: MCNearbyServiceAdvertiser?
    var PendingInvitations: [String: (Bool, MCSession?) -> Void]
    
    var Neighbors: [MCPeerID] = []
    var Members: [MCPeerID] = []
    
    // Constants
    let InviteDuration: TimeInterval = 120
    let MCSessionSize: Int = 8
        
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
    private func createSession(groupName: String) -> Void {
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
            self.GroupName = groupName
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
            self.GroupName = ""
            self.Members = []
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
                let groupName = self.GroupName
                guard groupName != "" else {
                    print("Invalid group name: can not invite peer")
                    return
                }
                guard let groupNameData = groupName?.data(using: .utf8) else {
                    print("Error converting group name to data")
                    return
                }

                for peerID in neighbors {
                    browser.invitePeer(
                        peerID,
                        to: session,
                        withContext: groupNameData,
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
    func launchGroup(groupName: String) -> Void {
        createSession(groupName: groupName)
        inviteNeighborsToSession()
    }
    
    func handleInvitationResponse(groupName: String, accept: Bool) {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard let invitationHandler = self.PendingInvitations[groupName] else {
                print("Error: no invitation found for session: \(groupName)")
                return
            }
            guard self.Session == nil && self.GroupName == nil else {
                print("Error during invitation handling: a session is already up.")
                self.PendingInvitations.removeValue(forKey: groupName)
                return
            }
            // create Session
            self.createSession(groupName: groupName)
            invitationHandler(accept, self.Session)
            // propagate invitations to our neighbors
            inviteNeighborsToSession()
            self.PendingInvitations.removeValue(forKey: groupName)
        }
    }
    
    func leaveGroup() -> Void {
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
