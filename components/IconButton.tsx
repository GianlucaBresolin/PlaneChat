import { Ionicons } from "@expo/vector-icons";
import { Text, TouchableOpacity } from "react-native";

export type IconButtonProps = {
    title?: string;
    onPress: () => void;
    iconName: keyof typeof Ionicons.glyphMap;
}

export default function IconButton({ props } : { props : IconButtonProps }) {
    return (
        <TouchableOpacity
            onPress={props.onPress}
        >
            <Ionicons name={props.iconName} size = {24} />
            {props.title && <Text>{props.title}</Text>}
        </TouchableOpacity>
    )
}