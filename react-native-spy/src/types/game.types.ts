export interface Player {
  id: number;
  name: string;
  selectedColor: string;
  selectedCharacter: CharacterAvatar | null;
}

export interface GamePlayer extends Player {
  role: 'SPY' | string;
  hint: string | null;
}

export interface CharacterAvatar {
  id: number;
  imageUri: string;
  name: string;
}

export interface GameSettings {
  playerCount: number;
  gameDurationMinutes: number;
  showHints: boolean;
}

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

export interface VotingResult {
  isSpyCaught: boolean;
  spyPlayer: GamePlayer | null;
  votedOutPlayer: GamePlayer | null;
  voteCount: Record<string, number>;
  totalVotes: number;
}

export interface GameValidationResult {
  isValid: boolean;
  errors: string[];
}

export type GamePhase =
  | 'setup'
  | 'playerSetup'
  | 'category'
  | 'game'
  | 'timer'
  | 'voting'
  | 'results';

export interface GameState {
  currentPhase: GamePhase;
  settings: GameSettings;
  players: Player[];
  gamePlayers: GamePlayer[];
  selectedCategory: Category | null;
  selectedSubcategory: Subcategory | null;
  timerStartTime: number | null;
  votes: Record<string, string>;
}

export enum WarningLevel {
  NORMAL = 'NORMAL',
  WARNING = 'WARNING',
  CRITICAL = 'CRITICAL',
  FINISHED = 'FINISHED',
}

export interface TimerState {
  timeLeft: number;
  isRunning: boolean;
  warningLevel: WarningLevel;
  formattedTime: string;
}
