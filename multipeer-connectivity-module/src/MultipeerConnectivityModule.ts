import { NativeModule, requireNativeModule } from 'expo';
import { ReceivedMessage } from './MultipeerConnectivityModule.types';

type MultipeerConnectivityModuleEvents = {
  onReceivedMessage: (event: ReceivedMessage) => void;
};

declare class MultipeerConnectivityModule extends NativeModule<MultipeerConnectivityModuleEvents> {
  initialize(): void;
  createRoom(): void;
  leaveRoom(): void;
  sendMessage(
    sender: string,
    message: string
  ): void;
}

export default requireNativeModule<MultipeerConnectivityModule>('MultipeerConnectivityModule');
