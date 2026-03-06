import MultipeerConnectivity
import UIKit

class MultipeerManager: NSObject {
    // Delegate
    weak var NetworkDelegate: MultipeerManagerNetworkDelegate?
    
    // Dispatching Queue for thread-safety
    private let isolationQueue: DispatchQueue
    
    // Private Field
    private var PeerID: MCPeerID
    private var Session: MCSession?
    private var SessionName : String?
    private var Browser: MCNearbyServiceBrowser?
    private var Advertiser: MCNearbyServiceAdvertiser?
    private var PendingInvitations: [String: (Bool, MCSession?) -> Void]
    private var Neighbors: [MCPeerID] = []
    
    // Constants
    let InviteDuration: TimeInterval = 120
    let MCSessionSize: Int = 8
        
    init(
        peerID: MCPeerID
    ) {
        // dispatch queue
        self.isolationQueue = DispatchQueue(label: "multipeer-manager-isolation-queue")
        // PeerID
        self.PeerID = peerID
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
    
    // Neighbors
    func addNeighbor(neighbor: MCPeerID) -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                !self.Neighbors.contains(neighbor)
            else {
                return
            }
            self.Neighbors.append(neighbor)
        }
    }
    
    func getNeighbors() -> [MCPeerID]? {
        isolationQueue.sync { [weak self] in
            guard let self = self else {
                return nil
            }
            return self.Neighbors
        }
    }
    
    func removeNeighbor(neighbor: MCPeerID) -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let index = self.Neighbors.firstIndex(of: neighbor)
            else {
                return
            }
            self.Neighbors.remove(at: index)
        }
    }
    
    // Pending Invitations
    func addPendingInvitation(sessionName: String, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                self.PendingInvitations[sessionName] == nil
            else {
                // we already have an invitation for that session
                return
            }
            self.PendingInvitations[sessionName] = invitationHandler
        }
    }
    
    func getInvitationHandler(sessionName: String) -> ((Bool, MCSession?) -> Void)? {
        isolationQueue.sync { [weak self] in
            guard
                let self = self,
                let invitation = self.PendingInvitations[sessionName]
            else {
                print("Link Error: no invitation available for this session name.")
                return nil
            }
            return invitation
        }
    }
    
    func removePendingInvitation(sessionName: String) -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.PendingInvitations.removeValue(forKey: sessionName)
        }
    }
    
    func clearPendingInvitations() -> Void {
        isolationQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.PendingInvitations.removeAll()
        }
    }
        
    // Session
    func createSession(sessionName: String) -> MCSession? {
        isolationQueue.sync { [weak self] in
            guard
                let self = self,
                self.Session == nil
            else {
                print("Link Error: A session already exists.")
                return nil
            }
            let newSession = MCSession(
                peer: self.PeerID,
            )
            newSession.delegate = self
            self.Session = newSession
            self.SessionName = sessionName
            return newSession
        }
    }
    
    func getSession() -> MCSession? {
        isolationQueue.sync { [weak self] in
            guard let self = self else {
                return nil
            }
            return self.Session
        }
    }
    
    func sessionAvailable() -> Bool? {
        isolationQueue.sync { [weak self] in
            guard let self = self else {
                return nil
            }
            return self.Session != nil
        }
    }
    
    func checkSessionName(sessionName: String) -> Bool? {
        isolationQueue.sync { [weak self] in
            guard let self = self else {
                return nil
            }
            return sessionName == self.SessionName
        }
    }
    
    func sendData(peers: [MCPeerID], data: Data) -> Void {
        isolationQueue.async { [weak self] in
            do {
                guard
                    let self = self,
                    let session = self.Session
                else {
                    print("Link Error: impossible to send data, no session available.")
                    return
                }
                try session.send(
                    data,
                    toPeers: peers,
                    with: .reliable
                )
            } catch {
                print("Link Error: fail to send data with error: \(error)")
            }
        }
    }
    
    func disconnectSession() -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let session = self.Session
            else {
                print("Link Error: no session to disconnect.")
                return
            }
            session.disconnect()
            self.Session = nil
            self.SessionName = ""
            // handle network layer
            guard let networkDelegate = self.NetworkDelegate else {
                return
            }
            networkDelegate.reset()
        }
    }
    
    func getSessionPeers() -> [MCPeerID]? {
        isolationQueue.sync { [weak self] in
            guard
                let self = self,
                let session = self.Session
            else {
                print("Link Error: impossible to retrieve peers, no available sesion.")
                return nil
            }
            return session.connectedPeers
        }
    }
    
    func getMCIDfrom(displayName: String) -> MCPeerID? {
        isolationQueue.sync { [weak self] in
            guard
                let self = self,
                let session = self.Session
            else {
                print("Link Errror: unable to retrieve peerID, no available session.")
                return nil
            }
            guard let peerID = session.connectedPeers.first(where: { $0.displayName == displayName }) else {
                print("Link Error: no peerID founded with displayName: \(displayName)")
                return nil
            }
            return peerID
        }
    }
    
    // Browser
    private func createBrowser() -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                self.Browser == nil
            else {
                print("Link Error: impossible to create browser, a browser already exists.")
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
    
    func startBrowsing() -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let browser = self.Browser
            else {
                print("Link Error: impossible to start browser, no available browser.")
                return
            }
            browser.startBrowsingForPeers()
        }
    }
    
    func stopBrowsing() -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let browser = self.Browser
            else {
                print("Link Error: impossible to stop browser, no available browser")
                return
            }
            browser.stopBrowsingForPeers()
        }
    }
    
    func invitePeerToSession(peer: MCPeerID) -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let browser = self.Browser,
                let session = self.Session,
                let sessionName = self.SessionName,
                sessionName != ""
            else {
                print("Link Error: impossible to invite peer to session. No session or invalid session name, or no browser available.")
                return
            }
            guard let sessionNameData = sessionName.data(using: .utf8) else {
                print("Link Error: impossible to invite peer to session. Fail to encode session name.")
                return
            }
            browser.invitePeer(
                peer,
                to: session,
                withContext: sessionNameData,
                timeout: self.InviteDuration
            )
        }
    }
    
    func inviteNeighborsToSession() -> Void {
        guard let neighbors = getNeighbors() else {
            print("Link Error: failed to retrieve neighbors, impossible to invite them to the session.")
            return
        }
        for neighbor in neighbors {
            invitePeerToSession(peer: neighbor)
        }
        return
    }
    
    // Advertiser
    private func createAdvertiser() -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                self.Advertiser == nil
            else {
                print("Link Error: impossible to create advertiser, an advertiser already exists.")
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
            guard
                let self = self,
                let advertiser = self.Advertiser
            else {
                print("Link Error: impossible to start advertising, no available advertiser.")
                return
            }
            advertiser.startAdvertisingPeer()
        }
    }
    
    private func stopAdvertising() -> Void {
        isolationQueue.async { [weak self] in
            guard
                let self = self,
                let advertiser = self.Advertiser
            else {
                print("Link Error: impossible to stop advertising, no available advertiser.")
                return
            }
            advertiser.stopAdvertisingPeer()
        }
    }
}
