import { View } from "react-native";
import AvailableSessions from "../components/AvailableSessions";
import LaunchRoom from "../components/LaunchRoom";
import { Styles } from "../constants/theme";

export default function Index() {
  return (
    <View
      style={Styles.container}
    >
      <AvailableSessions/>
      <LaunchRoom/>
    </View>
  );
}
