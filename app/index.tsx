import { View } from "react-native";
import AvailableGroups from "../components/AvailableGroups";
import LaunchGroup from "../components/LaunchGroup";
import { Styles } from "../constants/theme";

export default function Index() {
  return (
    <View
      style={Styles.container}
    >
      <AvailableGroups/>
      <LaunchGroup/>
    </View>
  );
}
