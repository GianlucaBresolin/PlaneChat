import { addFoundGroupListener, FoundGroupEvent, joinGroup } from "multipeer-connectivity-module";
import { useEffect, useState } from "react";
import { Text, View } from "react-native";
import { Styles } from "../constants/theme";
import { Group } from "../types/planeChat.types";
import IconButton from "./IconButton";

export default function AvailableGroups() {
    const [availableGroups, setAvailableGroups] = useState<Group[]>([]);

    useEffect(() => {
        const subscription = addFoundGroupListener((event: FoundGroupEvent) => {
            setAvailableGroups((prevGroups) => {
                if (!prevGroups.includes(event.groupName)) {
                    return [...prevGroups, event.groupName];
                }
                return prevGroups;
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
                    Available Groups
                </Text>
            </View>
            <View>
                {availableGroups.length === 0 && (
                    <Text
                        style={Styles.textDefault}
                    >
                        No available groups
                    </Text>
                )}
                {availableGroups.length > 0 && availableGroups.map((groupName, index) => (
                    <View key={index}>
                        <Text>{groupName}</Text>
                        <IconButton
                            props={{
                                title: "Join Group",
                                onPress: () => {
                                    joinGroup(groupName);
                                    console.log(`Joining group: ${groupName}`);
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