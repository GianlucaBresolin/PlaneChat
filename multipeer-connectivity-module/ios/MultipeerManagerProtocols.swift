import Foundation

protocol MultipeerManagerDelegate: AnyObject {
    func notifySession(groupName: String)
    func notifyMessage(sender: String, message: String)
}
