import { View } from "react-native";
import { LaunchRoom } from "../components/LaunchRoom";

export default function Index() {
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
