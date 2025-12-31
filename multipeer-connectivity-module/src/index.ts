import { EventSubscription } from 'expo-modules-core';
import MultipeerConnectivityModule from './MultipeerConnectivityModule';
import { FoundSessionEvent, ReceivedMessageEvent } from './MultipeerConnectivityModule.types';

export function createSession(
    sessionName: string,
): void {
    return MultipeerConnectivityModule.createSession(sessionName);
}

export function joinSession(
    sessionName: string,
): void {
    return MultipeerConnectivityModule.joinSession(sessionName);
}

export function leaveSession(): void {
    return MultipeerConnectivityModule.leaveSession();
}

export function sendMessage(
    sender: string,
    message: string
): void {
    return MultipeerConnectivityModule.sendMessage(sender, message);
}

// Listener for events
export function addFoundSessionListener(
    listener: (event: FoundSessionEvent) => void
): EventSubscription {
    return MultipeerConnectivityModule.addListener("onFoundSession", listener);
}

export function addReceivedMessageListener(
    listener: (event: ReceivedMessageEvent) => void 
): EventSubscription {
    return MultipeerConnectivityModule.addListener("onReceivedMessage", listener);
}

export type {
    FoundSessionEvent,
    ReceivedMessageEvent
};

