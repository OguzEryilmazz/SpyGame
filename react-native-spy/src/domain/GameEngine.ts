import {
  Player,
  GamePlayer,
  VotingResult,
  GameValidationResult,
} from '../types';

export class GameEngine {
  private static readonly MIN_PLAYERS = 3;
  private static readonly MAX_PLAYERS = 12;
  private static readonly MIN_DURATION_MINUTES = 1;
  private static readonly MAX_DURATION_MINUTES = 15;

  assignRoles(
    players: Player[],
    items: string[],
    hints: string[],
    showHints: boolean
  ): GamePlayer[] {
    if (players.length < GameEngine.MIN_PLAYERS) {
      throw new Error(
        `Minimum ${GameEngine.MIN_PLAYERS} players required`
      );
    }

    if (items.length === 0) {
      throw new Error('Items list cannot be empty');
    }

    const spyIndex = Math.floor(Math.random() * players.length);
    const selectedItem = items[Math.floor(Math.random() * items.length)];
    const selectedHint = showHints && hints.length > 0
      ? hints[Math.floor(Math.random() * hints.length)]
      : null;

    return players.map((player, index) => ({
      ...player,
      role: index === spyIndex ? 'SPY' : selectedItem,
      hint: index === spyIndex ? selectedHint : null,
    }));
  }

  calculateVotingResults(
    votes: Record<string, string>,
    gamePlayers: GamePlayer[]
  ): VotingResult {
    const voteCount: Record<string, number> = {};
    let totalVotes = 0;

    Object.values(votes).forEach((votedPlayerId) => {
      voteCount[votedPlayerId] = (voteCount[votedPlayerId] || 0) + 1;
      totalVotes++;
    });

    let maxVotes = 0;
    let votedOutPlayerId: string | null = null;

    Object.entries(voteCount).forEach(([playerId, count]) => {
      if (count > maxVotes) {
        maxVotes = count;
        votedOutPlayerId = playerId;
      }
    });

    const spyPlayer = gamePlayers.find((p) => p.role === 'SPY') || null;
    const votedOutPlayer = votedOutPlayerId
      ? gamePlayers.find((p) => p.id.toString() === votedOutPlayerId) || null
      : null;

    const isSpyCaught = spyPlayer?.id.toString() === votedOutPlayerId;

    return {
      isSpyCaught,
      spyPlayer,
      votedOutPlayer,
      voteCount,
      totalVotes,
    };
  }

  validateGameSetup(
    playerCount: number,
    durationMinutes: number
  ): GameValidationResult {
    const errors: string[] = [];

    if (playerCount < GameEngine.MIN_PLAYERS) {
      errors.push(`Minimum ${GameEngine.MIN_PLAYERS} players required`);
    }

    if (playerCount > GameEngine.MAX_PLAYERS) {
      errors.push(`Maximum ${GameEngine.MAX_PLAYERS} players allowed`);
    }

    if (durationMinutes < GameEngine.MIN_DURATION_MINUTES) {
      errors.push(
        `Minimum duration is ${GameEngine.MIN_DURATION_MINUTES} minute(s)`
      );
    }

    if (durationMinutes > GameEngine.MAX_DURATION_MINUTES) {
      errors.push(
        `Maximum duration is ${GameEngine.MAX_DURATION_MINUTES} minutes`
      );
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  shuffleArray<T>(array: T[]): T[] {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }

  getRandomItem<T>(array: T[]): T {
    return array[Math.floor(Math.random() * array.length)];
  }
}
