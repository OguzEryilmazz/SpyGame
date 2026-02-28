import {
  initConnection,
  endConnection,
  getProducts,
  requestPurchase,
  finishTransaction,
  purchaseUpdatedListener,
  purchaseErrorListener,
  Product,
  Purchase,
  PurchaseError,
  ProductPurchase,
} from 'react-native-iap';
import { Platform } from 'react-native';

const PRODUCT_IDS = {
  category_animals: Platform.select({
    ios: 'com.spy.category.animals',
    android: 'com.spy.category.animals',
  })!,
  category_movies: Platform.select({
    ios: 'com.spy.category.movies',
    android: 'com.spy.category.movies',
  })!,
  category_sports: Platform.select({
    ios: 'com.spy.category.sports',
    android: 'com.spy.category.sports',
  })!,
  remove_ads: Platform.select({
    ios: 'com.spy.removeads',
    android: 'com.spy.removeads',
  })!,
};

export class PurchaseService {
  private static isInitialized = false;
  private static purchaseUpdateSubscription: any = null;
  private static purchaseErrorSubscription: any = null;

  static async initialize(): Promise<void> {
    if (this.isInitialized) return;

    try {
      await initConnection();
      this.isInitialized = true;
      console.log('IAP connection initialized');

      this.purchaseUpdateSubscription = purchaseUpdatedListener(
        async (purchase: ProductPurchase) => {
          console.log('Purchase updated:', purchase);
          const receipt = purchase.transactionReceipt;

          if (receipt) {
            try {
              await finishTransaction({ purchase, isConsumable: false });
              console.log('Transaction finished successfully');
            } catch (error) {
              console.error('Failed to finish transaction:', error);
            }
          }
        }
      );

      this.purchaseErrorSubscription = purchaseErrorListener(
        (error: PurchaseError) => {
          console.error('Purchase error:', error);
        }
      );
    } catch (error) {
      console.error('Failed to initialize IAP connection:', error);
    }
  }

  static async cleanup(): Promise<void> {
    if (this.purchaseUpdateSubscription) {
      this.purchaseUpdateSubscription.remove();
      this.purchaseUpdateSubscription = null;
    }

    if (this.purchaseErrorSubscription) {
      this.purchaseErrorSubscription.remove();
      this.purchaseErrorSubscription = null;
    }

    try {
      await endConnection();
      this.isInitialized = false;
    } catch (error) {
      console.error('Failed to end IAP connection:', error);
    }
  }

  static async getProducts(): Promise<Product[]> {
    try {
      const productIds = Object.values(PRODUCT_IDS);
      const products = await getProducts({ skus: productIds });
      return products;
    } catch (error) {
      console.error('Failed to get products:', error);
      return [];
    }
  }

  static async purchaseProduct(
    productId: string,
    onSuccess: (purchase: Purchase) => void,
    onError: (error: PurchaseError) => void
  ): Promise<void> {
    try {
      const sku = PRODUCT_IDS[productId as keyof typeof PRODUCT_IDS] || productId;

      await requestPurchase({ sku });

      const updateListener = purchaseUpdatedListener(
        async (purchase: ProductPurchase) => {
          if (purchase.productId === sku) {
            try {
              await finishTransaction({ purchase, isConsumable: false });
              onSuccess(purchase as Purchase);
            } catch (error) {
              console.error('Failed to finish transaction:', error);
            } finally {
              updateListener.remove();
            }
          }
        }
      );

      const errorListener = purchaseErrorListener((error: PurchaseError) => {
        onError(error);
        errorListener.remove();
      });
    } catch (error) {
      console.error('Failed to purchase product:', error);
      onError(error as PurchaseError);
    }
  }

  static async restorePurchases(
    onSuccess: (purchases: Purchase[]) => void,
    onError?: (error: any) => void
  ): Promise<void> {
    try {
      console.log('Restoring purchases...');
      onSuccess([]);
    } catch (error) {
      console.error('Failed to restore purchases:', error);
      onError?.(error);
    }
  }

  static getProductId(categoryId: string): string | null {
    const key = `category_${categoryId}` as keyof typeof PRODUCT_IDS;
    return PRODUCT_IDS[key] || null;
  }
}
