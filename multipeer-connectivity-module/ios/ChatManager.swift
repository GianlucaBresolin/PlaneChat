import Foundation

class ChatManager {
    private let MyNodeID : NodeID
    weak var NetworkDelegate : ChatManagerNetworkDelegate?
    weak var PresentationDelegate : ChatManagerPresentationDelegate?

    let IsolationQueue: DispatchQueue

    init(
        nodeID: NodeID
    ) {
        self.MyNodeID = nodeID
        self.IsolationQueue = DispatchQueue(label: "ChatManagerIsolationQueue")
    }

    func createGroup(groupName: String) {
        self.IsolationQueue.async {
            guard let networkDelegate = self.NetworkDelegate else {
                print("Application Error: impossible to create group, no network delegate available.")
                return
            }
            networkDelegate.requestControl(
                command: "createGroup",
                groupName: groupName
            )
        }
    }

    func joinGroup(groupName: String) {
        self.IsolationQueue.async {
            guard let networkDelegate = self.NetworkDelegate else {
                print("Application Error: impossibe to join group, no network delegate available.")
                return
            }
            networkDelegate.requestControl(
                command: "joinGroup",
                groupName: groupName
            )
        }
    }

    func leaveGroup(groupName: String) {
        self.IsolationQueue.async {
            guard let networkDelegate = self.NetworkDelegate else {
                print("Application Error: impossibe to leave group. No network delegate available.")
                return
            }
            networkDelegate.requestControl(
                command: "leaveGroup",
                groupName: groupName
            )
        }
    }

    func sendMessage(
        sender: String,
        message: String
    ) {
        guard let networkDelegate = self.NetworkDelegate else {
            print("Application Error: impossibe to send a message. No network delegate available.")
            return
        }
        let applicationPacket = "\(sender)|\(message)"
        guard let applicationPacketPayload = applicationPacket.data(using: .utf8) else {
            print("Application Error: fail to encode application payload.")
            return
        }
        networkDelegate.broadcastMessage(data: applicationPacketPayload)
        guard let presentationDelegate = self.PresentationDelegate else {
            print("Application Error: impossible to send a message. No presentation delegate avaialable.")
            return
        }
        presentationDelegate.notifyMessage(
            sender: sender,
            message: message
        )
    }
}
