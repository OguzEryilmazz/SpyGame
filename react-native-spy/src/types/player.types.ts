export interface PlayerValidationResult {
  isValid: boolean;
  errors: string[];
}

export interface PlayerCreationOptions {
  count: number;
  existingPlayers?: Player[];
  preserveNames?: boolean;
}

export interface Player {
  id: number;
  name: string;
  selectedColor: string;
  selectedCharacter: CharacterAvatar | null;
}

export interface CharacterAvatar {
  id: number;
  imageUri: string;
  name: string;
}

export const PLAYER_COLORS = [
  '#E91E63',
  '#2196F3',
  '#4CAF50',
  '#FF9800',
  '#9C27B0',
  '#00BCD4',
  '#FFEB3B',
  '#F44336',
  '#3F51B5',
  '#8BC34A',
  '#FF5722',
  '#009688',
];

export const CHARACTER_AVATARS: CharacterAvatar[] = [
  { id: 1, imageUri: 'avatar_1', name: 'Detective' },
  { id: 2, imageUri: 'avatar_2', name: 'Agent' },
  { id: 3, imageUri: 'avatar_3', name: 'Spy' },
  { id: 4, imageUri: 'avatar_4', name: 'Officer' },
  { id: 5, imageUri: 'avatar_5', name: 'Inspector' },
  { id: 6, imageUri: 'avatar_6', name: 'Secret Agent' },
  { id: 7, imageUri: 'avatar_7', name: 'Investigator' },
  { id: 8, imageUri: 'avatar_8', name: 'Operative' },
  { id: 9, imageUri: 'avatar_9', name: 'Shadow' },
];
