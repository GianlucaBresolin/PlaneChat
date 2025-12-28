import ExpoModulesCore

public class MultipeerConnectivityModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MultipeerConnectivityModule")

    Events("onNewRoom")

    Function("initialize") {() -> Void in
        // init Manager
        _ = MultipeerManager.shared
    }
      
    Function("getPeerID") { () -> String in
        return MultipeerManager.shared.getPeerIDAsString()
    }
      
    Function("createSession") { (sessionName: String) -> Void in
        return MultipeerManager.shared.createSession(sessionName: sessionName)
    }
  }
}
