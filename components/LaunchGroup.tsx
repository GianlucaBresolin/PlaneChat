import { Styles } from "@/constants/theme";
import { useState } from "react";
import { Modal, View } from "react-native";
import CreateGroupForm from "./CreateGroupForm";
import IconButton, { IconButtonProps } from "./IconButton";

export default function LaunchGroup() {
    const [isModalVisible, setIsModalVisible] = useState(false);

    return (
        <View
            style={Styles.launchRoom}    
        >
            <IconButton 
                props={{
                    title: "Launch Group",
                    onPress: () => {
                        setIsModalVisible(true);
                        console.log("Launch Group Pressed");
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
                <CreateGroupForm 
                    closeForm={() => setIsModalVisible(false)}    
                />
            </Modal>
        </View>
    );
}