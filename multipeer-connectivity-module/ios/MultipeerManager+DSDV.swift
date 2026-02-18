import Foundation

extension MultipeerManager : DSDVManagerDelegate {
    func broadcastUpdate(
        destination: NodeID,
        hops: Int,
        sequenceNumber: Int
    ) {
        let payload = "0|\(destination)|\(hops)|\(sequenceNumber)"
    
        guard let data = payload.data(using: .utf8) else {
            print("Error encoding data.")
            return
        }
        
        sendBroadcastData(data: data)
    }
    
    func unicastApplicationPacket(nextHop: NodeID, destination: NodeID, applicationData: Data) {
        let headerPayload = "1|\(destination)|"
        
        guard let headerData = headerPayload.data(using: .utf8) else {
            print("Error encoding header data.")
            return
        }
        
        sendUnicastData(
            data: headerData + applicationData,
            destination: nextHop
        )
    }
}
