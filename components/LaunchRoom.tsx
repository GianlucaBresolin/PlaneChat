import { View } from "react-native";
import IconButton, { IconButtonProps } from "./IconButton";

export function LaunchRoom() {
    return (
        <View>
            <IconButton 
                props={{
                    title: "Launch",
                    onPress: () => {
                        console.log("Launch Room Pressed");
                    },
                    iconName: "airplane"
                } as IconButtonProps}
            />
        </View>
    );
}