import {
  Player,
  PlayerValidationResult,
  CharacterAvatar,
  PLAYER_COLORS,
  CHARACTER_AVATARS,
} from '../types';

export class PlayerManager {
  createDefaultPlayers(
    count: number,
    existingPlayers?: Player[]
  ): Player[] {
    const players: Player[] = [];
    const usedColors = new Set<string>();
    const usedCharacters = new Set<number>();

    if (existingPlayers) {
      existingPlayers.forEach((p) => {
        usedColors.add(p.selectedColor);
        if (p.selectedCharacter) {
          usedCharacters.add(p.selectedCharacter.id);
        }
      });
    }

    for (let i = 0; i < count; i++) {
      const existingPlayer = existingPlayers?.[i];

      if (existingPlayer) {
        players.push(existingPlayer);
      } else {
        const color = this.getNextAvailableColor(usedColors);
        const character = this.getNextAvailableCharacter(usedCharacters);

        players.push({
          id: i + 1,
          name: `Player ${i + 1}`,
          selectedColor: color,
          selectedCharacter: character,
        });

        usedColors.add(color);
        if (character) {
          usedCharacters.add(character.id);
        }
      }
    }

    return players;
  }

  validatePlayers(players: Player[]): PlayerValidationResult {
    const errors: string[] = [];

    const emptyNames = players.filter((p) => !p.name.trim());
    if (emptyNames.length > 0) {
      errors.push('All players must have a name');
    }

    const names = players.map((p) => p.name.trim().toLowerCase());
    const duplicateNames = names.filter(
      (name, index) => names.indexOf(name) !== index
    );
    if (duplicateNames.length > 0) {
      errors.push('Player names must be unique');
    }

    const colors = players.map((p) => p.selectedColor);
    const duplicateColors = colors.filter(
      (color, index) => colors.indexOf(color) !== index
    );
    if (duplicateColors.length > 0) {
      errors.push('Each player must have a unique color');
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  isPlayerSetupValid(players: Player[]): boolean {
    return this.validatePlayers(players).isValid;
  }

  private getNextAvailableColor(usedColors: Set<string>): string {
    const availableColors = PLAYER_COLORS.filter(
      (color) => !usedColors.has(color)
    );

    if (availableColors.length > 0) {
      return availableColors[0];
    }

    return PLAYER_COLORS[usedColors.size % PLAYER_COLORS.length];
  }

  private getNextAvailableCharacter(
    usedCharacters: Set<number>
  ): CharacterAvatar | null {
    const availableCharacters = CHARACTER_AVATARS.filter(
      (char) => !usedCharacters.has(char.id)
    );

    if (availableCharacters.length > 0) {
      return availableCharacters[0];
    }

    return null;
  }

  getAvailableColors(
    currentColor: string,
    allPlayers: Player[]
  ): string[] {
    const usedColors = new Set(
      allPlayers
        .filter((p) => p.selectedColor !== currentColor)
        .map((p) => p.selectedColor)
    );

    return PLAYER_COLORS.filter((color) => !usedColors.has(color));
  }

  getAvailableCharacters(
    currentCharacterId: number | null,
    allPlayers: Player[]
  ): CharacterAvatar[] {
    const usedCharacterIds = new Set(
      allPlayers
        .filter((p) => p.selectedCharacter?.id !== currentCharacterId)
        .map((p) => p.selectedCharacter?.id)
        .filter((id): id is number => id !== null && id !== undefined)
    );

    return CHARACTER_AVATARS.filter(
      (char) => !usedCharacterIds.has(char.id)
    );
  }
}
