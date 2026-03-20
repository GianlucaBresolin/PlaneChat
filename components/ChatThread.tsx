import { addReceivedMessageListener, ReceivedMessageEvent } from "multipeer-connectivity-module";
import { useEffect, useRef, useState } from "react";
import { ScrollView, View } from "react-native";
import { Styles } from "../constants/theme";
import { Message } from "../types/planeChat.types";
import MessageComponent from "./Message";

export default function ChatThread({username} : {username: string}) {
    const [messageThread, setMessageThread] = useState<Message[]>([]); 
    const scrollViewRef = useRef<ScrollView>(null);

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
        <ScrollView 
            style={Styles.chatThread}
            ref={scrollViewRef}
            onContentSizeChange={() => scrollViewRef.current?.scrollToEnd({ animated: true })}
        >
            {messageThread.map((msg, index) => (
                <View key={index}>
                    <MessageComponent 
                        sender = {msg.sender}
                        message = {msg.message}
                        isMe = {msg.sender === username}
                    />
                </View>
            ))}
            <View style={{ height: 100 }} />
        </ScrollView>
    );
}