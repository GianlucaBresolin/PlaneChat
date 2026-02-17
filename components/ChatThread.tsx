import { addReceivedMessageListener, ReceivedMessageEvent } from "multipeer-connectivity-module";
import { useEffect, useState } from "react";
import { View } from "react-native";
import { Styles } from "../constants/theme";
import { Message } from "../types/planeChat.types";
import MessageComponent from "./Message";

export default function ChatThread({username} : {username: string}) {
    const [messageThread, setMessageThread] = useState<Message[]>([]); 

    useEffect(() => {
            const subscription = addReceivedMessageListener((event: ReceivedMessageEvent) => {
                setMessageThread((prevMessages) => [
                    ...prevMessages,
                    { sender: event.sender, message: event.message } as Message,
                ]);
            });
        
            return () => subscription.remove();
          }, []);

    return (
        <>
            <View style={Styles.chatThread}>
                {messageThread.map((msg, index) => (
                    <View key={index}>
                        <MessageComponent 
                            sender = {msg.sender}
                            message = {msg.message}
                            isMe = {msg.sender === username}
                        />
                    </View>
                ))}
            </View>
        </>
    );
}