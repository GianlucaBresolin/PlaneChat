import { useRouter } from "expo-router";
import { joinGroup } from "multipeer-connectivity-module";
import { useState } from "react";
import { Alert, Text, TextInput, View } from "react-native";
import { Styles } from "../constants/theme";
import IconButton, { IconButtonProps } from "./IconButton";

export default function JoinGroupForm({closeForm, groupName}: { closeForm: () => void, groupName: string }) {
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
                <Text style={Styles.textHeaderModal}>
                    {`Joining ${groupName}`}
                </Text>
                <TextInput
                    style={Styles.textInput}
                    placeholder="Username"
                    value = {username}
                    onChangeText={setUsername}
                />
                <IconButton
                    props={{
                        title: "Join Group",
                        onPress: () => {
                            let trimmedUsername = username.trim();
                            if (!trimmedUsername) {
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
                            joinGroup(groupName);
                            closeForm();
                            router.push({
                                pathname: "/chat",
                                params: {
                                    groupName: groupName,
                                    username: trimmedUsername,
                                }
                            });
                        },
                        iconName: "log-in"
                    } as IconButtonProps}
                />
            </View>
        </View>
    );
}