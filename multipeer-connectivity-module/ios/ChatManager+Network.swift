import Foundation

extension ChatManager: DSDVManagerApplicationDelegate {
    func notifyGroup(groupName: String) {
        guard let presentationDelegate = self.PresentationDelegate else {
            print("Application Error: impossible to notify group, no presentation delegate available.")
            return
        }
        presentationDelegate.notifyGroup(groupName: groupName)
    }
    
    func handleMessage(data: Data) {
        guard let applicationContent = String(data: data, encoding: .utf8) else {
            print("Application Error: fail to decode application data.")
            return
        }
        let components = applicationContent.split(separator: "|")
        if components.count != 2 {
            print("Application Error: invalid message format.")
            return
        }
        let sender = String(components[0])
        let message = String(components[1])
        guard let presentationDelegate = self.PresentationDelegate else {
            print("Application Error: impossible to handle message, no presentation delegate available.")
            return
        }
        presentationDelegate.notifyMessage(
            sender: sender,
            message: message
        )
    }
}
