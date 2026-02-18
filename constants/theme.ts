import { Dimensions, StyleSheet } from "react-native";

const ScreenHeight = Dimensions.get("window").height;
const ScreenWidth = Dimensions.get("window").width;

export const Styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
        backgroundColor: "#E3E3E3"
    },

    // TEXT STYLES
    textPrimary: {
        color: "#1B3C53"
    },

    textDefault: {
        color: "#7d7d7dff"
    },

    textLabel: {
        fontSize: 16,
        color: "#1B3C53",
        fontWeight: "600",
        width: "80%",
        textAlign: "left",
    },

    textHeader: {
        fontSize: 20,
        color: "#E3E3E3",
        fontWeight: "bold",
        position: "absolute",
        left: 0,
        right: 0,
        textAlign: "center",
        bottom: 19
    },

    textHeaderModal: {
        fontSize: 16,
        color: "#1B3C53",
        fontWeight: "600",
        width: "80%",
        textAlign: "center",
        paddingBottom: 25
    },

    heading: {
        fontSize: 24,
        color: "#1B3C53",
        fontWeight: "bold",
        marginBottom: 10
    },

    // BUTTON STYLES
    button: {
        backgroundColor: "#456882",
        borderRadius: 8,
        padding: 10,
        flexDirection: "row",
        alignItems: "center",
        marginTop: 10
    }, 

    buttonHeader: {
        backgroundColor: "#1B3C53",
        color: "#FFFFFF",
        borderRadius: 8,
        padding: 10,
        marginRight: ScreenWidth * 0.03,
        flexDirection: "row",
        alignItems: "center",
    },

    buttonText: {
        color: "#FFFFFF",
        alignSelf: "center",
        margin: 5,
        fontWeight: "bold"
    }, 

    closeButton: {
        backgroundColor: "#FF0000",
        color: "#FFFFFF",
        borderRadius: 20,
        margin: 6,
        flexDirection: "row",
        alignItems: "center",
    },

    joinGroupButton: {
        backgroundColor: "#456882",
        color: "#FFFFFF",
        borderRadius: 8,
        padding: 5,
        flexDirection: "row",
        alignItems: "center",
    },

    textInput: {
        borderWidth: 1,
        borderColor: "#456882",
        borderRadius: 4,
        paddingHorizontal: 8,
        paddingVertical: 4,
        width: "80%",
        marginTop: 5,
        marginBottom: 20,
        color: "#1B3C53",
        backgroundColor: "#FFFFFF"
    },

    launchRoom: {
        position: "absolute",
        bottom: ScreenHeight * 0.20,
    },

    // MODAL STYLES
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        justifyContent: "center",
        alignItems: "center"
    },

    modalContent: {
        width: ScreenWidth * 0.7,
        height: ScreenHeight * 0.4,
        backgroundColor: "#FFFFFF",
        padding: 20,
        borderRadius: 10,
        alignItems: "center",
        justifyContent: "center",
    },

    header: {
        position: "absolute",
        top: 0,
        paddingTop: ScreenHeight * 0.07,
        width: "100%",
        flexDirection: "row",
        backgroundColor: "#234C6A",
        alignItems: "center",
        justifyContent: "flex-end",
        paddingBottom: 10
    }, 

    // AVAILABLE GROUP
    GroupItem: {
        flexDirection: "row",
        justifyContent: "space-between",
        alignItems: "center",
        padding: 5,
        paddingHorizontal: 8,
        paddingLeft: 15,
        backgroundColor: "#FFFFFF",
        borderRadius: 8,
        marginBottom: 5,
        width: "80%"
    },

    // CHATBOARD STYLES
    chatBoard: {
        flex: 1,
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center",
        position: "absolute",
        bottom: 0,
        width: "100%",
        height: ScreenHeight * 0.1,
        backgroundColor: "#234C6A",
    },

    underChatboard: {
        height: ScreenHeight * 0.2,
        position: "absolute",
        bottom: -(ScreenHeight * 0.2),
        width: "100%",
        backgroundColor: "#234C6A",
    },

    chatTextInput: {
        borderWidth: 1,
        borderColor: "#456882",
        borderRadius: 8,
        paddingHorizontal: 8,
        paddingVertical: 8,
        marginRight: ScreenWidth * 0.03,
        marginLeft: ScreenWidth * 0.03,
        width: "75%",
        color: "#1B3C53",
        backgroundColor: "#FFFFFF"
    },

    // CHATTHREAD STYLE
    chatThread: {
        flex: 1,
        marginTop: (ScreenHeight * 0.07) + 55,
        width: "100%",
    },

    // MESSAGE STYLES
    messageContainer: {
        flexDirection: "column",
        width: "auto",
        marginVertical: 5,
        marginHorizontal: 10,
        borderRadius: 10,
        padding: 10,
    },

    messageContainerMe: {
        alignSelf: "flex-end",
        backgroundColor: "#f7f6f6",
    },

    messageContainerOther: {
        alignSelf: "flex-start",
        backgroundColor: "#FFFFFF",
    }, 

    messageHeader: {
        alignSelf: "flex-start",
        marginBottom: 5
    },

    sender: {
        fontSize: 14,
        fontWeight: "bold",
    },

    senderMe: {
        color: "#1c5937",
    },

    senderOther: {
        color: "#234C6A",
    },

    messageContentContainer: {
        alignSelf: "flex-start",
        width: "80%"
    },

    messageContent: {
        fontSize: 14,
        color: "#1e1f1f",
    }
});

