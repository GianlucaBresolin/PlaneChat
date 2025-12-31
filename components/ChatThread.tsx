import { addReceivedMessageListener, ReceivedMessageEvent } from "multipeer-connectivity-module";
import { useEffect, useState } from "react";
import { Text, View } from "react-native";
import { Message } from "../types/planeChat.types";

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
            <View>
                {messageThread.map((msg, index) => (
                    <View key={index}>
                        <Text>{msg.sender}: {msg.message}</Text>
                    </View>
                ))}
            </View>
        </>
    );
}