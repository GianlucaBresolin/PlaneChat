import { NativeModule, requireNativeModule } from 'expo';
import { FoundGroupEvent, ReceivedMessageEvent } from './MultipeerConnectivityModule.types';

type MultipeerConnectivityModuleEvents = {
  foundSession: (event: FoundGroupEvent) => void;
  receivedMessage: (event: ReceivedMessageEvent) => void;
};

declare class MultipeerConnectivityModule extends NativeModule<MultipeerConnectivityModuleEvents> {
  createGroup(
    groupName: string,
  ): void;
  joinGroup(
    groupName: string,
  ): void;
  leaveGroup(): void;
  sendMessage(
    sender: string,
    message: string
  ): void;
}

export default requireNativeModule<MultipeerConnectivityModule>('MultipeerConnectivityModule');
