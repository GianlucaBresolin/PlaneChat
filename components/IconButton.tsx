import { Ionicons } from "@expo/vector-icons";
import { Text, TextStyle, TouchableOpacity, ViewStyle } from "react-native";
import { Styles } from "../constants/theme";

export type IconButtonProps = {
    title?: string;
    onPress: () => void;
    iconName: keyof typeof Ionicons.glyphMap;
    styleSheet?: ViewStyle & TextStyle;
    size?: number;
}

export default function IconButton({ props } : { props : IconButtonProps }) {
    return (
        <TouchableOpacity
            onPress={props.onPress}
            style={props.styleSheet ? props.styleSheet : Styles.button}
        >
            <Ionicons 
                name={props.iconName} 
                size = {props.size ? props.size : 24}
                color = {props.styleSheet? props.styleSheet.color : Styles.buttonText.color}
            />
            {props.title && <Text
                style = {Styles.buttonText}
            >
                {props.title}
            </Text>}
        </TouchableOpacity>
    )
}