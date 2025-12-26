import { EventSubscription } from 'expo-modules-core';
import MultipeerConnectivityModule from './MultipeerConnectivityModule';
import { NewRoomEvent } from './MultipeerConnectivityModule.types';

export function addNewRoomListener(
    listener: (event: NewRoomEvent) => void 
): EventSubscription {
    return MultipeerConnectivityModule.addListener("onNewRoom", listener);
}

export function getPeerID(): string {
    return MultipeerConnectivityModule.getPeerID();
}

export { MultipeerConnectivityModule, NewRoomEvent };
