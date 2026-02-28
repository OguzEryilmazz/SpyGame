import {
  GameState,
  GamePhase,
  GameSettings,
  Player,
  GamePlayer,
  Category,
  Subcategory,
} from '../types';

export class GameStateManager {
  private state: GameState;

  constructor(initialState?: Partial<GameState>) {
    this.state = {
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
      timerStartTime: null,
      votes: {},
      ...initialState,
    };
  }

  getState(): GameState {
    return { ...this.state };
  }

  updateSettings(settings: Partial<GameSettings>): GameState {
    this.state = {
      ...this.state,
      settings: {
        ...this.state.settings,
        ...settings,
      },
    };
    return this.getState();
  }

  setPlayers(players: Player[]): GameState {
    this.state = {
      ...this.state,
      players,
    };
    return this.getState();
  }

  setGamePlayers(gamePlayers: GamePlayer[]): GameState {
    this.state = {
      ...this.state,
      gamePlayers,
    };
    return this.getState();
  }

  selectCategory(
    category: Category,
    subcategory?: Subcategory
  ): GameState {
    this.state = {
      ...this.state,
      selectedCategory: category,
      selectedSubcategory: subcategory || null,
    };
    return this.getState();
  }

  startGame(category: Category, gamePlayers: GamePlayer[]): GameState {
    this.state = {
      ...this.state,
      currentPhase: 'game',
      selectedCategory: category,
      gamePlayers,
      timerStartTime: null,
      votes: {},
    };
    return this.getState();
  }

  startTimer(): GameState {
    this.state = {
      ...this.state,
      currentPhase: 'timer',
      timerStartTime: Date.now(),
    };
    return this.getState();
  }

  startVoting(): GameState {
    this.state = {
      ...this.state,
      currentPhase: 'voting',
      votes: {},
    };
    return this.getState();
  }

  recordVote(voterId: string, votedPlayerId: string): GameState {
    this.state = {
      ...this.state,
      votes: {
        ...this.state.votes,
        [voterId]: votedPlayerId,
      },
    };
    return this.getState();
  }

  moveToPhase(phase: GamePhase): GameState {
    this.state = {
      ...this.state,
      currentPhase: phase,
    };
    return this.getState();
  }

  resetGame(): GameState {
    this.state = {
      ...this.state,
      currentPhase: 'setup',
      gamePlayers: [],
      selectedCategory: null,
      selectedSubcategory: null,
      timerStartTime: null,
      votes: {},
    };
    return this.getState();
  }

  canStartGame(): boolean {
    return (
      this.state.players.length >= 3 &&
      this.state.selectedCategory !== null
    );
  }

  canStartTimer(): boolean {
    return this.state.gamePlayers.length >= 3;
  }

  canStartVoting(): boolean {
    return this.state.gamePlayers.length >= 3;
  }

  getElapsedTime(): number {
    if (!this.state.timerStartTime) return 0;
    return Math.floor((Date.now() - this.state.timerStartTime) / 1000);
  }
}
