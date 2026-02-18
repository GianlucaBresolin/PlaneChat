import { addFoundGroupListener, FoundGroupEvent } from "multipeer-connectivity-module";
import { useEffect, useState } from "react";
import { Modal, Text, View } from "react-native";
import { Styles } from "../constants/theme";
import { Group } from "../types/planeChat.types";
import IconButton from "./IconButton";
import JoinGroupForm from "./JoinGroupForm";

export default function AvailableGroups() {
    const [availableGroups, setAvailableGroups] = useState<Group[]>([]);
    const [isModalVisible, setIsModalVisible] = useState(false);
    const [selectedGroup, setSelectedGroup] = useState<Group | null>(null);

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
                    <View key={index} style={Styles.GroupItem}>
                        <Text style={[Styles.textPrimary, { fontWeight : "bold"}]}>
                            {groupName}
                        </Text>
                        <IconButton
                            props={{
                                title: "Join",
                                onPress: () => {
                                    setSelectedGroup(groupName);
                                    setIsModalVisible(true);
                                },
                                iconName: "log-in", 
                                styleSheet: Styles.joinGroupButton
                            }}
                        />
                    </View>
                ))}
            </View>
            <Modal
            animationType ="fade"
            transparent={true}
            visible={isModalVisible}
            onRequestClose={() => {
                setIsModalVisible(false);
            }}>
                <JoinGroupForm
                    closeForm={() => setIsModalVisible(false)}
                    groupName={selectedGroup as string}
                />
            </Modal>
        </>
    );
}