export interface Category {
  id: string;
  name: string;
  emoji: string;
  isLocked: boolean;
  priceTL?: number;
  hasSubcategories: boolean;
  subcategories?: Subcategory[];
  items?: string[];
  hints?: string[];
}

export interface Subcategory {
  id: string;
  name: string;
  isLocked: boolean;
  requiresAd: boolean;
  items: string[];
  hints: string[];
}

export interface CategoryFilter {
  searchQuery: string;
  showOnlyFavorites: boolean;
  showOnlyUnlocked: boolean;
}

export interface PurchaseInfo {
  productId: string;
  categoryId: string;
  purchaseDate: number;
  transactionId: string;
}
