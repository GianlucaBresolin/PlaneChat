import { useRouter } from "expo-router";
import { createGroup } from "multipeer-connectivity-module";
import { useState } from "react";
import { Alert, Text, TextInput, View } from "react-native";
import { Styles } from "../constants/theme";
import IconButton, { IconButtonProps } from "./IconButton";

export default function CreateGroupForm( {closeForm}: { closeForm: () => void }) { 
    const [groupName, setGroupName] = useState("");
    const [username, setUsername] = useState("");
    const router = useRouter();

    return (
        <View
            style={Styles.modalOverlay}
        >
            <View
                style={Styles.modalContent}
            >
                <View
                    style={{
                        position: "absolute",
                        top: 10,
                        right: 10
                    }}
                >
                    <IconButton
                        props={{
                            title: "",
                            onPress: () => {
                                closeForm();
                            },
                            iconName: "close",
                            size: 15,
                            styleSheet: Styles.closeButton
                        } as IconButtonProps}
                    />
                </View>
                <Text 
                    style={Styles.textLabel}
                >
                    Group Name
                </Text>
                <TextInput
                    style={Styles.textInput}
                    placeholder="Group Name"
                    value = {groupName}
                    onChangeText={setGroupName}
                />
                <Text 
                    style={Styles.textLabel}
                >
                    Username
                </Text>
                <TextInput
                    style={Styles.textInput}
                    placeholder="Your Username"
                    value = {username}
                    onChangeText={setUsername}
                />
                <IconButton
                    props={{
                        title: "Create Group",
                        onPress: () => {
                            let trimmedGroupName = groupName.trim();
                            let trimmedUsername = username.trim();
                            if (!trimmedGroupName && !trimmedUsername) {
                                Alert.alert(
                                    "Error", 
                                    "Please enter a valid group name and a username: cannot be empty.", [
                                    {
                                        text: "Close",
                                        onPress: () => {},
                                        style: "cancel"
                                    }],
                                    {
                                        cancelable: true,
                                        userInterfaceStyle: "light"
                                    }
                                );
                                return;
                            } else if (!trimmedGroupName) {
                                Alert.alert(
                                    "Error", 
                                    "Please enter a valid group name: cannot be empty.", [
                                    {
                                        text: "Close",
                                        onPress: () => {},
                                        style: "cancel"
                                    }],
                                    {
                                        cancelable: true,
                                        userInterfaceStyle: "light"
                                    }
                                );
                                return;
                            } else if (!trimmedUsername) {
                                Alert.alert("Error", "Please enter a valid username: cannot be empty.", [
                                    {
                                        text: "Close",
                                        onPress: () => {},
                                        style: "cancel"
                                    }],
                                    {
                                        cancelable: true,
                                        userInterfaceStyle: "light"
                                    }
                                );
                                return;
                            }
                            createGroup(trimmedGroupName);
                            console.log(`Creating group: ${trimmedGroupName}`);
                            closeForm();
                            router.push({
                                pathname: "/chat",
                                params: { 
                                    groupName: trimmedGroupName,
                                    username: trimmedUsername,
                                }
                            });
                        },
                        iconName: "add-circle"
                    } as IconButtonProps}
                />
            </View>
        </View>
    );
}