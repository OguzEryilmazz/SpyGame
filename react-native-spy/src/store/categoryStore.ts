import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Category } from '../types';

interface CategoryStore {
  favoriteCategories: Set<string>;
  unlockedCategories: Set<string>;
  unlockedSubcategories: Set<string>;

  toggleFavorite: (categoryId: string) => void;
  isFavorite: (categoryId: string) => boolean;
  unlockCategory: (categoryId: string) => void;
  isUnlocked: (categoryId: string) => boolean;
  unlockSubcategory: (subcategoryId: string) => void;
  isSubcategoryUnlocked: (subcategoryId: string) => boolean;
}

export const useCategoryStore = create<CategoryStore>()(
  persist(
    (set, get) => ({
      favoriteCategories: new Set<string>(),
      unlockedCategories: new Set<string>(),
      unlockedSubcategories: new Set<string>(),

      toggleFavorite: (categoryId) =>
        set((state) => {
          const newFavorites = new Set(state.favoriteCategories);
          if (newFavorites.has(categoryId)) {
            newFavorites.delete(categoryId);
          } else {
            newFavorites.add(categoryId);
          }
          return { favoriteCategories: newFavorites };
        }),

      isFavorite: (categoryId) => get().favoriteCategories.has(categoryId),

      unlockCategory: (categoryId) =>
        set((state) => ({
          unlockedCategories: new Set(state.unlockedCategories).add(
            categoryId
          ),
        })),

      isUnlocked: (categoryId) => get().unlockedCategories.has(categoryId),

      unlockSubcategory: (subcategoryId) =>
        set((state) => ({
          unlockedSubcategories: new Set(state.unlockedSubcategories).add(
            subcategoryId
          ),
        })),

      isSubcategoryUnlocked: (subcategoryId) =>
        get().unlockedSubcategories.has(subcategoryId),
    }),
    {
      name: 'category-storage',
      storage: createJSONStorage(() => AsyncStorage),
      serialize: (state) =>
        JSON.stringify({
          ...state,
          state: {
            ...state.state,
            favoriteCategories: Array.from(state.state.favoriteCategories),
            unlockedCategories: Array.from(state.state.unlockedCategories),
            unlockedSubcategories: Array.from(
              state.state.unlockedSubcategories
            ),
          },
        }),
      deserialize: (str) => {
        const parsed = JSON.parse(str);
        return {
          ...parsed,
          state: {
            ...parsed.state,
            favoriteCategories: new Set(parsed.state.favoriteCategories),
            unlockedCategories: new Set(parsed.state.unlockedCategories),
            unlockedSubcategories: new Set(
              parsed.state.unlockedSubcategories
            ),
          },
        };
      },
    }
  )
);
