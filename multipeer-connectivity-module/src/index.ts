import { EventSubscription } from 'expo-modules-core';
import MultipeerConnectivityModule from './MultipeerConnectivityModule';
import { ReceivedMessage } from './MultipeerConnectivityModule.types';

export function addReceivedMessageListener(
    listener: (event: ReceivedMessage) => void 
): EventSubscription {
    return MultipeerConnectivityModule.addListener("onReceivedMessage", listener);
}

export function createRoom(): void {
    return MultipeerConnectivityModule.createRoom();
}

export function leaveRoom(): void {
    return MultipeerConnectivityModule.leaveRoom();
}

export function sendMessage(
    sender: string,
    message: string
): void {
    return MultipeerConnectivityModule.sendMessage(sender, message);
}

export { MultipeerConnectivityModule };
export type { ReceivedMessage };

