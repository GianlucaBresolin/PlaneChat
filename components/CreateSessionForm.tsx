import { useRouter } from "expo-router";
import { createSession } from "multipeer-connectivity-module";
import { useState } from "react";
import { Alert, Text, TextInput, View } from "react-native";
import { Styles } from "../constants/theme";
import IconButton, { IconButtonProps } from "./IconButton";

export default function CreateSessionForm( {closeForm}: { closeForm: () => void }) { 
    const [sessionName, setSessionName] = useState("");
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
                    Session Name
                </Text>
                <TextInput
                    style={Styles.textInput}
                    placeholder="Session Name"
                    value = {sessionName}
                    onChangeText={setSessionName}
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
                        title: "Create Session",
                        onPress: () => {
                            let trimmedSession = sessionName.trim();
                            let trimmedUsername = username.trim();
                            if (!trimmedSession && !trimmedUsername) {
                                Alert.alert(
                                    "Error", 
                                    "Please enter a valid session name and a username: cannot be empty.", [
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
                            } else if (!trimmedSession) {
                                Alert.alert(
                                    "Error", 
                                    "Please enter a valid session name: cannot be empty.", [
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
                            createSession(trimmedSession);
                            console.log(`Creating session: ${trimmedSession}`);
                            closeForm();
                            router.push({
                                pathname: "/chat",
                                params: { 
                                    sessionName: trimmedSession,
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