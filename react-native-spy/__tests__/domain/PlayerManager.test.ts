import { PlayerManager } from '../../src/domain/PlayerManager';
import { Player, CharacterAvatar } from '../../src/types/game.types';

describe('PlayerManager', () => {
  let playerManager: PlayerManager;

  beforeEach(() => {
    playerManager = new PlayerManager();
  });

  describe('createDefaultPlayers', () => {
    it('should create correct number of players', () => {
      const players = playerManager.createDefaultPlayers(5);
      expect(players).toHaveLength(5);
    });

    it('should assign sequential IDs', () => {
      const players = playerManager.createDefaultPlayers(3);

      expect(players[0].id).toBe(1);
      expect(players[1].id).toBe(2);
      expect(players[2].id).toBe(3);
    });

    it('should assign default names', () => {
      const players = playerManager.createDefaultPlayers(3);

      expect(players[0].name).toBe('Player 1');
      expect(players[1].name).toBe('Player 2');
      expect(players[2].name).toBe('Player 3');
    });

    it('should assign unique colors', () => {
      const players = playerManager.createDefaultPlayers(5);
      const colors = players.map((p) => p.selectedColor);
      const uniqueColors = new Set(colors);

      expect(uniqueColors.size).toBe(5);
    });

    it('should assign characters when available', () => {
      const players = playerManager.createDefaultPlayers(3);

      expect(players[0].selectedCharacter).toBeTruthy();
      expect(players[1].selectedCharacter).toBeTruthy();
      expect(players[2].selectedCharacter).toBeTruthy();
    });

    it('should reuse existing players', () => {
      const existingPlayers: Player[] = [
        {
          id: 99,
          name: 'Alice',
          selectedColor: '#FF0000',
          selectedCharacter: CharacterAvatar.PIC_1,
        },
      ];

      const players = playerManager.createDefaultPlayers(3, existingPlayers);

      expect(players[0].id).toBe(1); // ID reassigned
      expect(players[0].name).toBe('Alice');
      expect(players[0].selectedColor).toBe('#FF0000');
      expect(players[0].selectedCharacter).toBe(CharacterAvatar.PIC_1);
    });

    it('should handle more existing players than needed', () => {
      const existingPlayers: Player[] = [
        {
          id: 1,
          name: 'Alice',
          selectedColor: '#FF0000',
          selectedCharacter: null,
        },
        {
          id: 2,
          name: 'Bob',
          selectedColor: '#00FF00',
          selectedCharacter: null,
        },
        {
          id: 3,
          name: 'Charlie',
          selectedColor: '#0000FF',
          selectedCharacter: null,
        },
      ];

      const players = playerManager.createDefaultPlayers(2, existingPlayers);

      expect(players).toHaveLength(2);
      expect(players[0].name).toBe('Alice');
      expect(players[1].name).toBe('Bob');
    });

    it('should fill in missing players', () => {
      const existingPlayers: Player[] = [
        {
          id: 1,
          name: 'Alice',
          selectedColor: '#FF0000',
          selectedCharacter: null,
        },
      ];

      const players = playerManager.createDefaultPlayers(3, existingPlayers);

      expect(players).toHaveLength(3);
      expect(players[0].name).toBe('Alice');
      expect(players[1].name).toBe('Player 2');
      expect(players[2].name).toBe('Player 3');
    });
  });

  describe('validatePlayers', () => {
    it('should validate correct player setup', () => {
      const players: Player[] = [
        {
          id: 1,
          name: 'Alice',
          selectedColor: '#E91E63',
          selectedCharacter: null,
        },
        { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
      ];

      const result = playerManager.validatePlayers(players);

      expect(result.isValid).toBe(true);
      expect(result.errors).toHaveLength(0);
    });

    it('should reject empty player names', () => {
      const players: Player[] = [
        { id: 1, name: '', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
      ];

      const result = playerManager.validatePlayers(players);

      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('All players must have names');
    });

    it('should reject whitespace-only names', () => {
      const players: Player[] = [
        { id: 1, name: '   ', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
      ];

      const result = playerManager.validatePlayers(players);

      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('All players must have names');
    });

    it('should reject duplicate names (case-insensitive)', () => {
      const players: Player[] = [
        { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 2, name: 'alice', selectedColor: '#2196F3', selectedCharacter: null },
      ];

      const result = playerManager.validatePlayers(players);

      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Player names must be unique');
    });

    it('should reject duplicate colors', () => {
      const players: Player[] = [
        { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 2, name: 'Bob', selectedColor: '#E91E63', selectedCharacter: null },
      ];

      const result = playerManager.validatePlayers(players);

      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Each player must have a unique color');
    });

    it('should reject duplicate characters', () => {
      const players: Player[] = [
        {
          id: 1,
          name: 'Alice',
          selectedColor: '#E91E63',
          selectedCharacter: CharacterAvatar.PIC_1,
        },
        {
          id: 2,
          name: 'Bob',
          selectedColor: '#2196F3',
          selectedCharacter: CharacterAvatar.PIC_1,
        },
      ];

      const result = playerManager.validatePlayers(players);

      expect(result.isValid).toBe(false);
      expect(result.errors).toContain('Each player must have a unique character');
    });

    it('should allow null characters', () => {
      const players: Player[] = [
        { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
      ];

      const result = playerManager.validatePlayers(players);

      expect(result.isValid).toBe(true);
    });

    it('should return multiple errors', () => {
      const players: Player[] = [
        { id: 1, name: '', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 2, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 3, name: 'Alice', selectedColor: '#2196F3', selectedCharacter: null },
      ];

      const result = playerManager.validatePlayers(players);

      expect(result.isValid).toBe(false);
      expect(result.errors.length).toBeGreaterThan(0);
    });
  });

  describe('isPlayerSetupValid', () => {
    it('should return true for valid setup', () => {
      const players: Player[] = [
        { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
      ];

      expect(playerManager.isPlayerSetupValid(players)).toBe(true);
    });

    it('should return false for invalid setup', () => {
      const players: Player[] = [
        { id: 1, name: '', selectedColor: '#E91E63', selectedCharacter: null },
      ];

      expect(playerManager.isPlayerSetupValid(players)).toBe(false);
    });
  });

  describe('getAvailableColor', () => {
    it('should return first available color', () => {
      const usedColors: string[] = [];
      const color = playerManager.getAvailableColor(usedColors);

      const allColors = playerManager.getAllColors();
      expect(allColors).toContain(color);
    });

    it('should skip used colors', () => {
      const allColors = playerManager.getAllColors();
      const usedColors = [allColors[0], allColors[1]];

      const color = playerManager.getAvailableColor(usedColors);

      expect(usedColors).not.toContain(color);
    });

    it('should cycle through colors when all used', () => {
      const allColors = playerManager.getAllColors();
      const color = playerManager.getAvailableColor(allColors);

      expect(allColors).toContain(color);
    });
  });

  describe('getAvailableCharacter', () => {
    it('should return first available character', () => {
      const usedCharacters: CharacterAvatar[] = [];
      const character = playerManager.getAvailableCharacter(usedCharacters);

      expect(character).toBeTruthy();
      expect(Object.values(CharacterAvatar)).toContain(character);
    });

    it('should skip used characters', () => {
      const usedCharacters = [CharacterAvatar.PIC_1, CharacterAvatar.PIC_2];
      const character = playerManager.getAvailableCharacter(usedCharacters);

      expect(usedCharacters).not.toContain(character);
    });

    it('should return null when all characters used', () => {
      const allCharacters = Object.values(CharacterAvatar);
      const character = playerManager.getAvailableCharacter(allCharacters);

      expect(character).toBeNull();
    });
  });

  describe('getAllColors', () => {
    it('should return array of colors', () => {
      const colors = playerManager.getAllColors();

      expect(Array.isArray(colors)).toBe(true);
      expect(colors.length).toBeGreaterThan(0);
      expect(typeof colors[0]).toBe('string');
    });

    it('should return at least 10 colors', () => {
      const colors = playerManager.getAllColors();
      expect(colors.length).toBeGreaterThanOrEqual(10);
    });
  });

  describe('getAllCharacters', () => {
    it('should return array of characters', () => {
      const characters = playerManager.getAllCharacters();

      expect(Array.isArray(characters)).toBe(true);
      expect(characters.length).toBeGreaterThan(0);
    });

    it('should return all CharacterAvatar enum values', () => {
      const characters = playerManager.getAllCharacters();
      const enumValues = Object.values(CharacterAvatar);

      expect(characters).toEqual(enumValues);
    });
  });

  describe('updatePlayer', () => {
    it('should update player properties', () => {
      const players: Player[] = [
        { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
        { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
      ];

      const updated = playerManager.updatePlayer(players, 1, { name: 'Alicia' });

      expect(updated[0].name).toBe('Alicia');
      expect(updated[1].name).toBe('Bob');
    });

    it('should not mutate original array', () => {
      const players: Player[] = [
        { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
      ];

      const updated = playerManager.updatePlayer(players, 1, { name: 'Alicia' });

      expect(players[0].name).toBe('Alice');
      expect(updated[0].name).toBe('Alicia');
    });
  });

  describe('isNameUnique', () => {
    const players: Player[] = [
      { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
      { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
    ];

    it('should return true for unique name', () => {
      expect(playerManager.isNameUnique(players, 'Charlie')).toBe(true);
    });

    it('should return false for duplicate name', () => {
      expect(playerManager.isNameUnique(players, 'Alice')).toBe(false);
    });

    it('should be case-insensitive', () => {
      expect(playerManager.isNameUnique(players, 'alice')).toBe(false);
      expect(playerManager.isNameUnique(players, 'ALICE')).toBe(false);
    });

    it('should trim whitespace', () => {
      expect(playerManager.isNameUnique(players, '  Alice  ')).toBe(false);
    });

    it('should exclude specific player ID', () => {
      expect(playerManager.isNameUnique(players, 'Alice', 1)).toBe(true);
    });
  });

  describe('isColorUnique', () => {
    const players: Player[] = [
      { id: 1, name: 'Alice', selectedColor: '#E91E63', selectedCharacter: null },
      { id: 2, name: 'Bob', selectedColor: '#2196F3', selectedCharacter: null },
    ];

    it('should return true for unique color', () => {
      expect(playerManager.isColorUnique(players, '#4CAF50')).toBe(true);
    });

    it('should return false for duplicate color', () => {
      expect(playerManager.isColorUnique(players, '#E91E63')).toBe(false);
    });

    it('should exclude specific player ID', () => {
      expect(playerManager.isColorUnique(players, '#E91E63', 1)).toBe(true);
    });
  });
});
