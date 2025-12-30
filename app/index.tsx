import { MultipeerConnectivityModule, ReceivedMessage } from "multipeer-connectivity-module";
import { useEffect } from "react";
import { View } from "react-native";
import { LaunchRoom } from "../components/LaunchRoom";

export default function Index() {
  useEffect(() => {
    const subscription = MultipeerConnectivityModule.addReceivedMessageListener((event: ReceivedMessage) => {
      // Handle received message
      console.log(`Message from ${event.sender}: ${event.message}`);
    });

    return () => subscription.remove();
  }, []);

  return (
    <View
      style={{
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <LaunchRoom />
    </View>
  );
}
