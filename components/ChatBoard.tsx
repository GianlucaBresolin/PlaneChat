import { sendMessage } from "multipeer-connectivity-module";
import { useState } from "react";
import { TextInput, View } from "react-native";
import { Styles } from "../constants/theme";
import IconButton, { IconButtonProps } from "./IconButton";

export default function ChatBoard({username}: {username: string}) {
    const [message, setMessage] = useState("");

    return (
        <>
            <View
                style={Styles.chatBoard}
            >
                <TextInput
                    placeholder="Type your message..."
                    value = {message}
                    onChangeText={setMessage}
                    style={Styles.chatTextInput}
                />
                <IconButton
                    props={{
                        title: "",
                        onPress: () => {
                            sendMessage(
                                username, 
                                message
                            );
                            console.log("Send message:", message);
                            setMessage("");
                        },
                        iconName: "send",
                    } as IconButtonProps}
                />
            </View>
        </>
    );  
}