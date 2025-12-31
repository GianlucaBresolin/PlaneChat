import { Styles } from "@/constants/theme";
import { useState } from "react";
import { Modal, View } from "react-native";
import CreateSessionForm from "./CreateSessionForm";
import IconButton, { IconButtonProps } from "./IconButton";

export default function LaunchRoom() {
    const [isModalVisible, setIsModalVisible] = useState(false);

    return (
        <View
            style={Styles.launchRoom}    
        >
            <IconButton 
                props={{
                    title: "Launch Session",
                    onPress: () => {
                        setIsModalVisible(true);
                        console.log("Launch Session Pressed");
                    },
                    iconName: "airplane"
                } as IconButtonProps}
            />
            <Modal
            animationType ="fade"
            transparent={true}
            visible={isModalVisible}
            onRequestClose={() => {
                setIsModalVisible(false);
            }}>
                <CreateSessionForm 
                    closeForm={() => setIsModalVisible(false)}    
                />
            </Modal>
        </View>
    );
}