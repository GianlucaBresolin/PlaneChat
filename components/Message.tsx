import { Text, View } from "react-native";
import { Styles } from "../constants/theme";

export default function MessageComponent({sender, message, isMe} : {sender:string, message:string, isMe: boolean}) {
    return (
        <View style={[Styles.messageContainer, isMe ? Styles.messageContainerMe : Styles.messageContainerOther]}>
            <View style={Styles.messageHeader}>
                <Text style={[Styles.sender, isMe? Styles.senderMe : Styles.senderOther]}>
                    {sender}
                </Text>
            </View>
            <View style={Styles.messageContentContainer}>
                <Text style={Styles.messageContent}>
                    {message}
                </Text>
            </View>
        </View>
    )
}