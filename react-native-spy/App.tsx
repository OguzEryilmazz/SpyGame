import React, { useEffect } from 'react';
import { StatusBar } from 'react-native';
import { RootNavigator } from './src/navigation/RootNavigator';
import { AdService } from './src/services/AdService';
import { PurchaseService } from './src/services/PurchaseService';

const App: React.FC = () => {
  useEffect(() => {
    const initializeServices = async () => {
      try {
        await AdService.initialize();
        await AdService.loadInterstitialAd();
        await PurchaseService.initialize();
      } catch (error) {
        console.error('Failed to initialize services:', error);
      }
    };

    initializeServices();

    return () => {
      PurchaseService.cleanup();
    };
  }, []);

  return (
    <>
      <StatusBar barStyle="light-content" backgroundColor="transparent" translucent />
      <RootNavigator />
    </>
  );
};

export default App;
