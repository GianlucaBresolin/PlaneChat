import { useLocalSearchParams } from "expo-router";
import { View } from "react-native";
import ChatBoard from "../components/ChatBoard";
import ChatHeader from "../components/ChatHeader";
import ChatThread from "../components/ChatThread";
import { Styles } from "../constants/theme";

export default function Chat() {
    const { groupName, username } = useLocalSearchParams();

    return (
        <>
            <View
                style={Styles.container}
            >
                <ChatHeader
                    groupName={groupName as string}
                />
                <ChatThread 
                    username = {username as string}    
                />
                <ChatBoard 
                    username = {username as string}    
                />
            </View>
        </>
    );
}