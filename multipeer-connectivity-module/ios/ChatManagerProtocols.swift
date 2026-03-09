import Foundation

protocol ChatManagerNetworkDelegate: AnyObject {
    func requestControl(command: String, groupName: String)
    func broadcastMessage(data: Data)
}

protocol ChatManagerPresentationDelegate: AnyObject {
    func notifyGroup(groupName: String)
    func notifyMessage(sender: String, message: String)
}
