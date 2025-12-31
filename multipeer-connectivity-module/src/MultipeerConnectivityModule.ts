import { NativeModule, requireNativeModule } from 'expo';
import { FoundSessionEvent, ReceivedMessageEvent } from './MultipeerConnectivityModule.types';

type MultipeerConnectivityModuleEvents = {
  onFoundSession: (event: FoundSessionEvent) => void;
  onReceivedMessage: (event: ReceivedMessageEvent) => void;
};

declare class MultipeerConnectivityModule extends NativeModule<MultipeerConnectivityModuleEvents> {
  createSession(
    sessionName: string,
  ): void;
  joinSession(
    sessionName: string,
  ): void;
  leaveSession(): void;
  sendMessage(
    sender: string,
    message: string
  ): void;
}

export default requireNativeModule<MultipeerConnectivityModule>('MultipeerConnectivityModule');
