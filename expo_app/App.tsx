import {
  PlusJakartaSans_400Regular, PlusJakartaSans_500Medium, PlusJakartaSans_600SemiBold, PlusJakartaSans_700Bold,
  PlusJakartaSans_800ExtraBold, useFonts,
} from '@expo-google-fonts/plus-jakarta-sans';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { TableFill } from './src/components/Surfaces';
import { useBelot } from './src/game/useBelot';
import { useLayout } from './src/layout';
import { GameScreen } from './src/screens/GameScreen';
import { HomeScreen } from './src/screens/HomeScreen';
import { colors } from './src/theme';

export default function App() {
  const [fontsLoaded] = useFonts({
    PlusJakartaSans_400Regular, PlusJakartaSans_500Medium, PlusJakartaSans_600SemiBold, PlusJakartaSans_700Bold, PlusJakartaSans_800ExtraBold,
  });
  return (
    <SafeAreaProvider>
      <StatusBar hidden />
      <View style={styles.root}>{fontsLoaded && <Belot />}</View>
    </SafeAreaProvider>
  );
}

function Belot() {
  const layout = useLayout();
  const game = useBelot();
  const { state } = game;
  return (
    <View style={styles.root}>
      <TableFill />
      {state.screen === 'home' ? (
        <HomeScreen layout={layout} onPlay={() => game.startRound(1)} />
      ) : (
        <GameScreen
          layout={layout}
          state={state}
          onCall={game.call}
          onPass={game.pass}
          onCard={game.tapCard}
          onMenu={game.goHome}
          onNextRound={() => game.startRound(state.round + 1)}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg, overflow: 'hidden' },
});
