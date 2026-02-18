import { EventSubscription } from 'expo-modules-core';
import MultipeerConnectivityModule from './MultipeerConnectivityModule';
import { FoundGroupEvent, ReceivedMessageEvent } from './MultipeerConnectivityModule.types';

export function createGroup(
    groupName: string,
): void {
    return MultipeerConnectivityModule.createGroup(groupName);
}

export function joinGroup(
    groupName: string,
): void {
    return MultipeerConnectivityModule.joinGroup(groupName);
}

export function leaveGroup(): void {
    return MultipeerConnectivityModule.leaveGroup();
}

export function sendMessage(
    sender: string,
    message: string
): void {
    return MultipeerConnectivityModule.sendMessage(sender, message);
}

// Listener for events
export function addFoundGroupListener(
    listener: (event: FoundGroupEvent) => void
): EventSubscription {
    return MultipeerConnectivityModule.addListener("foundSession", listener);
}

export function addReceivedMessageListener(
    listener: (event: ReceivedMessageEvent) => void 
): EventSubscription {
    return MultipeerConnectivityModule.addListener("receivedMessage", listener);
}

export type {
    FoundGroupEvent,
    ReceivedMessageEvent
};

