import { useLocalSearchParams } from "expo-router";
import { KeyboardAvoidingView } from "react-native";
import ChatBoard from "../components/ChatBoard";
import ChatHeader from "../components/ChatHeader";
import ChatThread from "../components/ChatThread";
import { Styles } from "../constants/theme";

export default function Chat() {
    const { groupName, username } = useLocalSearchParams();

    return (
        <KeyboardAvoidingView
            style={[Styles.container, { backgroundColor: "#E3E3E3" }]}
            behavior="height"
            keyboardVerticalOffset={0}
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
        </KeyboardAvoidingView>
    );
}