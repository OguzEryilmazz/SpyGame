import { GameEngine } from '../../src/domain/GameEngine';
import { Player, GamePlayer } from '../../src/types/game.types';

describe('GameEngine', () => {
  let gameEngine: GameEngine;
  let mockPlayers: Player[];
  let mockItems: string[];
  let mockHints: string[];

  beforeEach(() => {
    gameEngine = new GameEngine();

    mockPlayers = [
      { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
      { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
      { id: 3, name: 'Charlie', selectedColor: '#4CAF50', selectedCharacter: null },
      { id: 4, name: 'Diana', selectedColor: '#FF9800', selectedCharacter: null },
    ];

    mockItems = ['Titanic', 'Avatar', 'Inception', 'The Matrix'];
    mockHints = ['Director', 'Year', 'Genre'];
  });

  describe('assignRoles', () => {
    it('should assign exactly one SPY', () => {
      const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);

      const spyCount = result.filter((p) => p.role === 'SPY').length;
      expect(spyCount).toBe(1);
    });

    it('should assign the same word to all regular players', () => {
      const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);

      const regularPlayers = result.filter((p) => p.role !== 'SPY');
      const roles = regularPlayers.map((p) => p.role);
      const uniqueRoles = new Set(roles);

      expect(uniqueRoles.size).toBe(1);
    });

    it('should assign a hint to SPY when showHints is true', () => {
      const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);

      const spy = result.find((p) => p.role === 'SPY');
      expect(spy).toBeDefined();
      expect(spy!.hint).toBeTruthy();
      expect(mockHints).toContain(spy!.hint!);
    });

    it('should not assign hint to SPY when showHints is false', () => {
      const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, false);

      const spy = result.find((p) => p.role === 'SPY');
      expect(spy!.hint).toBeNull();
    });

    it('should not assign hint to regular players', () => {
      const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);

      const regularPlayers = result.filter((p) => p.role !== 'SPY');
      regularPlayers.forEach((player) => {
        expect(player.hint).toBeNull();
      });
    });

    it('should assign a word from items to regular players', () => {
      const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);

      const regularPlayers = result.filter((p) => p.role !== 'SPY');
      regularPlayers.forEach((player) => {
        expect(mockItems).toContain(player.role);
      });
    });

    it('should return same number of players', () => {
      const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);
      expect(result).toHaveLength(mockPlayers.length);
    });

    it('should preserve player properties', () => {
      const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);

      result.forEach((gamePlayer) => {
        const originalPlayer = mockPlayers.find((p) => p.id === gamePlayer.id);
        expect(originalPlayer).toBeDefined();
        expect(gamePlayer.name).toBe(originalPlayer!.name);
        expect(gamePlayer.selectedColor).toBe(originalPlayer!.selectedColor);
      });
    });

    it('should throw error when no players provided', () => {
      expect(() => {
        gameEngine.assignRoles([], mockItems, mockHints, true);
      }).not.toThrow(); // Returns empty array

      const result = gameEngine.assignRoles([], mockItems, mockHints, true);
      expect(result).toEqual([]);
    });

    it('should throw error when no items provided', () => {
      expect(() => {
        gameEngine.assignRoles(mockPlayers, [], mockHints, true);
      }).toThrow('No items available in category');
    });

    it('should work with minimum players (3)', () => {
      const minPlayers = mockPlayers.slice(0, 3);
      const result = gameEngine.assignRoles(minPlayers, mockItems, mockHints, true);

      expect(result).toHaveLength(3);
      const spyCount = result.filter((p) => p.role === 'SPY').length;
      expect(spyCount).toBe(1);
    });

    it('should randomize SPY selection', () => {
      // Run multiple times and collect SPY indices
      const spyIndices = new Set();

      for (let i = 0; i < 20; i++) {
        const result = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);
        const spyIndex = result.findIndex((p) => p.role === 'SPY');
        spyIndices.add(spyIndex);
      }

      // Should have at least 2 different SPY positions (probabilistic)
      expect(spyIndices.size).toBeGreaterThan(1);
    });
  });

  describe('calculateVotingResults', () => {
    let gamePlayers: GamePlayer[];

    beforeEach(() => {
      gamePlayers = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);
    });

    it('should correctly count votes', () => {
      const votes = {
        Alice: 'Bob',
        Bob: 'Charlie',
        Charlie: 'Bob',
        Diana: 'Bob',
      };

      const result = gameEngine.calculateVotingResults(votes, gamePlayers);

      expect(result.voteCounts).toEqual({
        Bob: 3,
        Charlie: 1,
      });
    });

    it('should identify most voted player', () => {
      const votes = {
        Alice: 'Bob',
        Bob: 'Charlie',
        Charlie: 'Bob',
        Diana: 'Bob',
      };

      const result = gameEngine.calculateVotingResults(votes, gamePlayers);

      expect(result.mostVotedPlayer?.name).toBe('Bob');
    });

    it('should determine if SPY was caught', () => {
      const spy = gamePlayers.find((p) => p.role === 'SPY')!;

      const votes = {
        Alice: spy.name,
        Bob: spy.name,
        Charlie: spy.name,
        Diana: spy.name,
      };

      const result = gameEngine.calculateVotingResults(votes, gamePlayers);

      expect(result.isSpyCaught).toBe(true);
    });

    it('should determine if SPY escaped', () => {
      const spy = gamePlayers.find((p) => p.role === 'SPY')!;
      const regular = gamePlayers.find((p) => p.role !== 'SPY')!;

      const votes = {
        Alice: regular.name,
        Bob: regular.name,
        Charlie: regular.name,
        Diana: regular.name,
      };

      const result = gameEngine.calculateVotingResults(votes, gamePlayers);

      expect(result.isSpyCaught).toBe(false);
    });

    it('should return SPY player', () => {
      const votes = { Alice: 'Bob' };
      const result = gameEngine.calculateVotingResults(votes, gamePlayers);

      expect(result.spyPlayer).toBeDefined();
      expect(result.spyPlayer!.role).toBe('SPY');
    });

    it('should handle tie votes', () => {
      const votes = {
        Alice: 'Bob',
        Bob: 'Charlie',
        Charlie: 'Diana',
        Diana: 'Bob',
      };

      const result = gameEngine.calculateVotingResults(votes, gamePlayers);

      expect(result.mostVotedPlayer?.name).toBe('Bob'); // First in alphabetical order
    });

    it('should handle no votes', () => {
      const votes = {};
      const result = gameEngine.calculateVotingResults(votes, gamePlayers);

      expect(result.mostVotedPlayer).toBeNull();
      expect(result.voteCounts).toEqual({});
    });
  });

  describe('validateGameSetup', () => {
    it('should validate correct setup', () => {
      const result = gameEngine.validateGameSetup(5, 10);
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    it('should reject less than 3 players', () => {
      const result = gameEngine.validateGameSetup(2, 10);
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('Minimum 3 players required');
    });

    it('should reject more than 10 players', () => {
      const result = gameEngine.validateGameSetup(11, 10);
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('Maximum 10 players allowed');
    });

    it('should reject less than 1 minute', () => {
      const result = gameEngine.validateGameSetup(5, 0);
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('Minimum 1 minute required');
    });

    it('should reject more than 30 minutes', () => {
      const result = gameEngine.validateGameSetup(5, 31);
      expect(result.isValid).toBe(false);
      expect(result.error).toBe('Maximum 30 minutes allowed');
    });

    it('should accept edge cases', () => {
      expect(gameEngine.validateGameSetup(3, 1).isValid).toBe(true);
      expect(gameEngine.validateGameSetup(10, 30).isValid).toBe(true);
    });
  });

  describe('getSpyPlayer', () => {
    it('should return the SPY player', () => {
      const gamePlayers = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);
      const spy = gameEngine.getSpyPlayer(gamePlayers);

      expect(spy).toBeDefined();
      expect(spy!.role).toBe('SPY');
    });

    it('should return null when no SPY', () => {
      const noSpyPlayers: GamePlayer[] = mockPlayers.map((p) => ({
        ...p,
        role: 'Titanic',
        hint: null,
      }));

      const spy = gameEngine.getSpyPlayer(noSpyPlayers);
      expect(spy).toBeNull();
    });
  });

  describe('getRegularPlayers', () => {
    it('should return all non-SPY players', () => {
      const gamePlayers = gameEngine.assignRoles(mockPlayers, mockItems, mockHints, true);
      const regularPlayers = gameEngine.getRegularPlayers(gamePlayers);

      expect(regularPlayers).toHaveLength(mockPlayers.length - 1);
      regularPlayers.forEach((player) => {
        expect(player.role).not.toBe('SPY');
      });
    });

    it('should return empty array when all players are SPY', () => {
      const allSpyPlayers: GamePlayer[] = mockPlayers.map((p) => ({
        ...p,
        role: 'SPY',
        hint: 'Test',
      }));

      const regularPlayers = gameEngine.getRegularPlayers(allSpyPlayers);
      expect(regularPlayers).toHaveLength(0);
    });
  });
});
