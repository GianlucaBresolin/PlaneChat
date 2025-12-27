import * as MultipeerConnectivityModule from "multipeer-connectivity-module";
import { useEffect, useState } from "react";
import { Text, View } from "react-native";
import { LaunchRoom } from "../components/LaunchRoom";

export default function Index() {
  const [availableRooms, setAvailableRooms]  = useState<string[]>([]);

  useEffect(() => {
    const subscription = MultipeerConnectivityModule.addNewRoomListener(({ roomName }) => {
      setAvailableRooms(( prevRooms ) => [...prevRooms, roomName]);
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
      <Text>{MultipeerConnectivityModule.getPeerID()}</Text>
    </View>
  );
}
