import { NativeModule, requireNativeModule } from 'expo';
import { NewRoomEvent } from './MultipeerConnectivityModule.types';

type MultipeerConnectivityModuleEvents = {
  onNewRoom: (event: NewRoomEvent) => void;
};

declare class MultipeerConnectivityModule extends NativeModule<MultipeerConnectivityModuleEvents> {
  getPeerID(): string;
}

export default requireNativeModule<MultipeerConnectivityModule>('MultipeerConnectivityModule');
