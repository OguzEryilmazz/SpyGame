import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  GameSettings,
  Player,
  GamePlayer,
  Category,
  Subcategory,
  GamePhase,
} from '../types';
import { GameEngine } from '../domain/GameEngine';

interface GameStore {
  currentPhase: GamePhase;
  settings: GameSettings;
  players: Player[];
  gamePlayers: GamePlayer[];
  selectedCategory: Category | null;
  selectedSubcategory: Subcategory | null;
  votes: Record<string, string>;

  updateSettings: (settings: Partial<GameSettings>) => void;
  setPlayers: (players: Player[]) => void;
  setGamePlayers: (gamePlayers: GamePlayer[]) => void;
  selectCategory: (category: Category, subcategory?: Subcategory) => void;
  startGame: (category: Category, subcategory?: Subcategory) => void;
  moveToPhase: (phase: GamePhase) => void;
  recordVote: (voterId: string, votedPlayerId: string) => void;
  resetGame: () => void;
}

export const useGameStore = create<GameStore>()(
  persist(
    (set, get) => ({
      currentPhase: 'setup',
      settings: {
        playerCount: 4,
        gameDurationMinutes: 5,
        showHints: true,
      },
      players: [],
      gamePlayers: [],
      selectedCategory: null,
      selectedSubcategory: null,
      votes: {},

      updateSettings: (newSettings) =>
        set((state) => ({
          settings: { ...state.settings, ...newSettings },
        })),

      setPlayers: (players) => set({ players }),

      setGamePlayers: (gamePlayers) => set({ gamePlayers }),

      selectCategory: (category, subcategory) =>
        set({
          selectedCategory: category,
          selectedSubcategory: subcategory || null,
        }),

      startGame: (category, subcategory) => {
        const { players, settings } = get();
        const gameEngine = new GameEngine();

        const items = subcategory
          ? subcategory.items
          : category.items || [];
        const hints = subcategory
          ? subcategory.hints
          : category.hints || [];

        const gamePlayers = gameEngine.assignRoles(
          players,
          items,
          hints,
          settings.showHints
        );

        set({
          currentPhase: 'game',
          selectedCategory: category,
          selectedSubcategory: subcategory || null,
          gamePlayers,
          votes: {},
        });
      },

      moveToPhase: (phase) => set({ currentPhase: phase }),

      recordVote: (voterId, votedPlayerId) =>
        set((state) => ({
          votes: { ...state.votes, [voterId]: votedPlayerId },
        })),

      resetGame: () =>
        set({
          currentPhase: 'setup',
          gamePlayers: [],
          selectedCategory: null,
          selectedSubcategory: null,
          votes: {},
        }),
    }),
    {
      name: 'game-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        settings: state.settings,
        players: state.players,
      }),
    }
  )
);
