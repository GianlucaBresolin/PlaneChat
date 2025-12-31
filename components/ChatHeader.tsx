import { useRouter } from "expo-router";
import { leaveSession } from "multipeer-connectivity-module";
import { Text, View } from "react-native";
import { Styles } from "../constants/theme";
import IconButton, { IconButtonProps } from "./IconButton";

export default function ChatHeader({sessionName}: {sessionName: string}) {
    const router = useRouter();
    return (
        <>
            <View
                style={Styles.header}
            >
                <Text
                    style={Styles.textHeader}
                >
                    {sessionName}
                </Text>
                <IconButton 
                    props={{
                        title: "",
                        onPress: () => {
                            console.log("Leaving chat");
                            leaveSession();
                            router.replace("/");
                        },
                        iconName: "log-out", 
                        styleSheet: Styles.buttonHeader,
                        size: 18
                    } as IconButtonProps}
                />      
            </View>
        </>
    )
}