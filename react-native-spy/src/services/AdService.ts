import { Platform } from 'react-native';
import mobileAds, {
  BannerAd,
  BannerAdSize,
  TestIds,
  InterstitialAd,
  RewardedAd,
  AdEventType,
  RewardedAdEventType,
} from 'react-native-google-mobile-ads';

const AD_UNIT_IDS = {
  banner:
    __DEV__ || true
      ? TestIds.BANNER
      : Platform.OS === 'ios'
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
  interstitial:
    __DEV__ || true
      ? TestIds.INTERSTITIAL
      : Platform.OS === 'ios'
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
  rewarded:
    __DEV__ || true
      ? TestIds.REWARDED
      : Platform.OS === 'ios'
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
};

export class AdService {
  private static interstitialAd: InterstitialAd | null = null;
  private static rewardedAd: RewardedAd | null = null;
  private static interstitialShowCount = 0;
  private static readonly SHOW_AD_EVERY_N_TIMES = 3;
  private static isInitialized = false;

  static async initialize(): Promise<void> {
    if (this.isInitialized) return;

    try {
      await mobileAds().initialize();
      this.isInitialized = true;
      console.log('AdMob initialized successfully');
    } catch (error) {
      console.error('Failed to initialize AdMob:', error);
    }
  }

  static getBannerAdUnitId(): string {
    return AD_UNIT_IDS.banner;
  }

  static async loadInterstitialAd(): Promise<void> {
    try {
      this.interstitialAd = InterstitialAd.createForAdRequest(
        AD_UNIT_IDS.interstitial
      );

      await new Promise<void>((resolve, reject) => {
        const unsubscribe = this.interstitialAd?.addAdEventListener(
          AdEventType.LOADED,
          () => {
            unsubscribe?.();
            resolve();
          }
        );

        const errorUnsubscribe = this.interstitialAd?.addAdEventListener(
          AdEventType.ERROR,
          (error) => {
            errorUnsubscribe?.();
            reject(error);
          }
        );

        this.interstitialAd?.load();
      });

      console.log('Interstitial ad loaded');
    } catch (error) {
      console.error('Failed to load interstitial ad:', error);
    }
  }

  static async showInterstitialAd(
    onDismissed?: () => void
  ): Promise<void> {
    if (!this.interstitialAd) {
      console.log('Interstitial ad not loaded, loading now...');
      await this.loadInterstitialAd();
    }

    if (this.interstitialAd) {
      try {
        const unsubscribe = this.interstitialAd.addAdEventListener(
          AdEventType.CLOSED,
          () => {
            unsubscribe?.();
            this.loadInterstitialAd();
            onDismissed?.();
          }
        );

        this.interstitialAd.show();
      } catch (error) {
        console.error('Failed to show interstitial ad:', error);
        onDismissed?.();
      }
    } else {
      onDismissed?.();
    }
  }

  static async showInterstitialWithFrequency(
    onDismissed?: () => void
  ): Promise<void> {
    this.interstitialShowCount++;

    if (this.interstitialShowCount % this.SHOW_AD_EVERY_N_TIMES !== 0) {
      onDismissed?.();
      return;
    }

    await this.showInterstitialAd(onDismissed);
  }

  static async showRewardedAd(
    onRewarded: (amount: number) => void,
    onDismissed?: () => void
  ): Promise<void> {
    try {
      this.rewardedAd = RewardedAd.createForAdRequest(
        AD_UNIT_IDS.rewarded
      );

      await new Promise<void>((resolve, reject) => {
        const loadedUnsubscribe = this.rewardedAd?.addAdEventListener(
          RewardedAdEventType.LOADED,
          () => {
            loadedUnsubscribe?.();
            resolve();
          }
        );

        const errorUnsubscribe = this.rewardedAd?.addAdEventListener(
          AdEventType.ERROR,
          (error) => {
            errorUnsubscribe?.();
            reject(error);
          }
        );

        this.rewardedAd?.load();
      });

      const earnedUnsubscribe = this.rewardedAd.addAdEventListener(
        RewardedAdEventType.EARNED_REWARD,
        (reward) => {
          console.log('User earned reward:', reward);
          onRewarded(reward.amount);
        }
      );

      const closedUnsubscribe = this.rewardedAd.addAdEventListener(
        AdEventType.CLOSED,
        () => {
          earnedUnsubscribe?.();
          closedUnsubscribe?.();
          onDismissed?.();
        }
      );

      this.rewardedAd.show();
    } catch (error) {
      console.error('Failed to show rewarded ad:', error);
      onDismissed?.();
    }
  }

  static resetInterstitialCounter(): void {
    this.interstitialShowCount = 0;
  }
}
