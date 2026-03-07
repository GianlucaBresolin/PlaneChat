import Foundation

protocol MultipeerManagerNetworkDelegate: AnyObject {
    func notifyNewLink(newNode: String)
    func notifyBrokenLink(brokenNode: String)
    func notifySession(sessionName: String)
    func handleMessage(data: Data)
    func reset()
}
