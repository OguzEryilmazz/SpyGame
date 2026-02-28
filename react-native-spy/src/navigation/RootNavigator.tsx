import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SetupScreen } from '../screens/SetupScreen';
import { PlayerSetupScreen } from '../screens/PlayerSetupScreen';
import CategoryScreen from '../screens/CategoryScreen';
import GameScreen from '../screens/GameScreen';
import { TimerScreen } from '../screens/TimerScreen';
import { VotingScreen } from '../screens/VotingScreen';

export type RootStackParamList = {
  Setup: undefined;
  PlayerSetup: undefined;
  Category: undefined;
  Game: undefined;
  Timer: undefined;
  Voting: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export const RootNavigator: React.FC = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          animation: 'slide_from_right',
        }}
        initialRouteName="Setup"
      >
        <Stack.Screen name="Setup" component={SetupScreen} />
        <Stack.Screen name="PlayerSetup" component={PlayerSetupScreen} />
        <Stack.Screen name="Category" component={CategoryScreen} />
        <Stack.Screen name="Game" component={GameScreen} />
        <Stack.Screen name="Timer" component={TimerScreen} />
        <Stack.Screen name="Voting" component={VotingScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
};
