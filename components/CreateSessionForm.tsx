import { useRouter } from "expo-router";
import { createSession } from "multipeer-connectivity-module";
import { useState } from "react";
import { Text, TextInput, View } from "react-native";
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
                            createSession(sessionName);
                            console.log(`Creating session: ${sessionName}`);
                            closeForm();
                            router.push({
                                pathname: "/chat",
                                params: { 
                                    sessionName: sessionName,
                                    username: username
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