import { addFoundSessionListener, FoundSessionEvent, joinSession } from "multipeer-connectivity-module";
import { useEffect, useState } from "react";
import { Text, View } from "react-native";
import { Styles } from "../constants/theme";
import { Session } from "../types/planeChat.types";
import IconButton from "./IconButton";

export default function AvailableSessions() {
    const [availableSessions, setAvailableSessions] = useState<Session[]>([]);

    useEffect(() => {
        const subscription = addFoundSessionListener((event: FoundSessionEvent) => {
            setAvailableSessions((prevSessions) => {
                if (!prevSessions.includes(event.sessionName)) {
                    return [...prevSessions, event.sessionName];
                }
                return prevSessions;
            });
        });

        return () => subscription.remove();
    }, []);
    
    return (
        <>
            <View>
                <Text 
                    style={Styles.heading}
                >
                    Available Sessions
                </Text>
            </View>
            <View>
                {availableSessions.length === 0 && (
                    <Text
                        style={Styles.textDefault}
                    >
                        No available sessions
                    </Text>
                )}
                {availableSessions.length > 0 && availableSessions.map((sessionName, index) => (
                    <View key={index}>
                        <Text>{sessionName}</Text>
                        <IconButton
                            props={{
                                title: "Join Session",
                                onPress: () => {
                                    joinSession(sessionName);
                                    console.log(`Joining session: ${sessionName}`);
                                },
                                iconName: "log-in"
                            }}
                        />
                    </View>
                ))}
            </View>
        </>
    );
}