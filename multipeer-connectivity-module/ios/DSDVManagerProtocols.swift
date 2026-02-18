import Foundation

protocol DSDVManagerDelegate: AnyObject {
    func broadcastUpdate(destination: NodeID, hops: Int, sequenceNumber: Int)
    func unicastApplicationPacket(nextHop: NodeID, destination: NodeID, applicationData: Data)
}
