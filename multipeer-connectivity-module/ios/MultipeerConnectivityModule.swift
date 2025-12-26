import ExpoModulesCore

public class MultipeerConnectivityModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MultipeerConnectivityModule")

    Events("onNewRoom")

    Function("getPeerID") { () -> String in
      let roomName = UIDevice.current.name
      self.sendEvent("onNewRoom", [
        "roomName" : roomName
      ])
      return "PeerID"
    }
  }
}
