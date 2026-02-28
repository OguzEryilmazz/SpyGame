import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  TextInput,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import LinearGradient from 'react-native-linear-gradient';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { RootStackParamList } from '../navigation/types';
import { useGameStore } from '../store/gameStore';
import { GameEngine } from '../domain/GameEngine';
import { VibrationHelper } from '../platform/VibrationHelper';
import { AdService } from '../services/AdService';
import { PurchaseService } from '../services/PurchaseService';
import { Category, Subcategory } from '../types/game.types';
import AsyncStorage from '@react-native-async-storage/async-storage';

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'Category'>;

// Mock categories - Replace with actual data loading
const MOCK_CATEGORIES: Category[] = [
  {
    id: 'movies',
    name: 'Filmler',
    iconName: 'movie',
    color: '#E91E63',
    items: ['Titanic', 'Avatar', 'Inception', 'The Matrix', 'Interstellar'],
    hints: ['Yönetmen', 'Oyuncu', 'Yıl', 'Tür'],
    isLocked: false,
    priceTL: 0,
    isFavorite: false,
    hasSubcategories: false,
    subcategories: [],
  },
  {
    id: 'animals',
    name: 'Hayvanlar',
    iconName: 'pets',
    color: '#4CAF50',
    items: ['Aslan', 'Kaplan', 'Fil', 'Zürafa', 'Zebra'],
    hints: ['Yaşam alanı', 'Beslenme', 'Özellik'],
    isLocked: false,
    priceTL: 0,
    isFavorite: false,
    hasSubcategories: false,
    subcategories: [],
  },
  {
    id: 'sports',
    name: 'Spor',
    iconName: 'sports-soccer',
    color: '#FF9800',
    items: ['Futbol', 'Basketbol', 'Tenis', 'Yüzme', 'Voleybol'],
    hints: ['Oyuncu sayısı', 'Alan', 'Ekipman'],
    isLocked: true,
    priceTL: 9.99,
    isFavorite: false,
    hasSubcategories: false,
    subcategories: [],
  },
  {
    id: 'professions',
    name: 'Meslekler',
    iconName: 'work',
    color: '#2196F3',
    items: ['Doktor', 'Öğretmen', 'Mühendis', 'Avukat', 'Hemşire'],
    hints: ['İş yeri', 'Araç gereç', 'Eğitim'],
    isLocked: false,
    priceTL: 0,
    isFavorite: false,
    hasSubcategories: true,
    subcategories: [
      {
        id: 'medical',
        name: 'Tıp',
        items: ['Cerrah', 'Diş Hekimi', 'Psikolog', 'Fizyoterapist'],
        hints: ['Uzmanlık', 'Hastane'],
        unlockedByAd: true,
        isUnlocked: false,
      },
      {
        id: 'tech',
        name: 'Teknoloji',
        items: ['Yazılımcı', 'Veri Analisti', 'UX Designer', 'DevOps'],
        hints: ['Programlama', 'Araçlar'],
        unlockedByAd: true,
        isUnlocked: false,
      },
    ],
  },
];

export default function CategoryScreen() {
  const navigation = useNavigation<NavigationProp>();
  const { players, startGame } = useGameStore();

  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<Category | null>(null);
  const [selectedSubcategory, setSelectedSubcategory] = useState<Subcategory | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterFavorites, setFilterFavorites] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [showSubcategoryDialog, setShowSubcategoryDialog] = useState(false);
  const [purchasingId, setPurchasingId] = useState<string | null>(null);

  useEffect(() => {
    loadCategories();
  }, []);

  const loadCategories = async () => {
    try {
      setIsLoading(true);
      // Load favorites from AsyncStorage
      const favoritesJson = await AsyncStorage.getItem('favorites');
      const favorites: string[] = favoritesJson ? JSON.parse(favoritesJson) : [];

      // Load purchased categories
      const purchasedJson = await AsyncStorage.getItem('purchased');
      const purchased: string[] = purchasedJson ? JSON.parse(purchasedJson) : [];

      // Update categories with favorites and purchases
      const updatedCategories = MOCK_CATEGORIES.map((cat) => ({
        ...cat,
        isFavorite: favorites.includes(cat.id),
        isLocked: cat.isLocked && !purchased.includes(cat.id),
      }));

      setCategories(updatedCategories);
    } catch (error) {
      console.error('Failed to load categories:', error);
      Alert.alert('Hata', 'Kategoriler yüklenemedi');
    } finally {
      setIsLoading(false);
    }
  };

  const toggleFavorite = async (categoryId: string) => {
    try {
      VibrationHelper.vibrateLight();

      const favoritesJson = await AsyncStorage.getItem('favorites');
      let favorites: string[] = favoritesJson ? JSON.parse(favoritesJson) : [];

      if (favorites.includes(categoryId)) {
        favorites = favorites.filter((id) => id !== categoryId);
      } else {
        favorites.push(categoryId);
      }

      await AsyncStorage.setItem('favorites', JSON.stringify(favorites));

      setCategories((prev) =>
        prev.map((cat) =>
          cat.id === categoryId ? { ...cat, isFavorite: !cat.isFavorite } : cat
        )
      );
    } catch (error) {
      console.error('Failed to toggle favorite:', error);
    }
  };

  const handleCategorySelect = (category: Category) => {
    if (category.isLocked) {
      VibrationHelper.vibrateWarning();
      Alert.alert(
        'Kilitli Kategori',
        `Bu kategoriyi açmak için ${category.priceTL} TL ödeme yapabilirsiniz.`,
        [
          { text: 'İptal', style: 'cancel' },
          { text: 'Satın Al', onPress: () => purchaseCategory(category.id) },
        ]
      );
      return;
    }

    if (category.hasSubcategories) {
      setSelectedCategory(category);
      setShowSubcategoryDialog(true);
    } else {
      VibrationHelper.vibrateSuccess();
      handleStartGame(category);
    }
  };

  const handleSubcategorySelect = (subcategory: Subcategory) => {
    if (!subcategory.isUnlocked && subcategory.unlockedByAd) {
      Alert.alert(
        'Kilitli Alt Kategori',
        'Bu alt kategoriyi açmak için reklam izleyebilirsiniz.',
        [
          { text: 'İptal', style: 'cancel' },
          { text: 'Reklam İzle', onPress: () => unlockWithAd(subcategory.id) },
        ]
      );
      return;
    }

    if (selectedCategory) {
      VibrationHelper.vibrateSuccess();
      setSelectedSubcategory(subcategory);
      setShowSubcategoryDialog(false);
      handleStartGame(selectedCategory, subcategory);
    }
  };

  const handleStartGame = (category: Category, subcategory?: Subcategory) => {
    // Use GameEngine to assign roles
    const gameEngine = new GameEngine();
    const items = subcategory?.items || category.items;
    const hints = subcategory?.hints || category.hints;

    try {
      // Call Zustand store's startGame which uses GameEngine internally
      startGame(category, subcategory);

      // Show interstitial ad with frequency control
      AdService.showInterstitialWithFrequency(() => {
        navigation.navigate('Game');
      });
    } catch (error) {
      console.error('Failed to start game:', error);
      Alert.alert('Hata', 'Oyun başlatılamadı');
    }
  };

  const purchaseCategory = async (categoryId: string) => {
    try {
      setPurchasingId(categoryId);
      VibrationHelper.vibrateLight();

      await PurchaseService.purchaseProduct(
        categoryId,
        async (purchase) => {
          // Mark as purchased
          const purchasedJson = await AsyncStorage.getItem('purchased');
          const purchased: string[] = purchasedJson ? JSON.parse(purchasedJson) : [];
          purchased.push(categoryId);
          await AsyncStorage.setItem('purchased', JSON.stringify(purchased));

          setCategories((prev) =>
            prev.map((cat) =>
              cat.id === categoryId ? { ...cat, isLocked: false } : cat
            )
          );

          VibrationHelper.vibrateSuccess();
          Alert.alert('Başarılı', 'Kategori başarıyla satın alındı!');
          setPurchasingId(null);
        },
        (error) => {
          console.error('Purchase failed:', error);
          Alert.alert('Hata', 'Satın alma işlemi başarısız oldu');
          setPurchasingId(null);
        }
      );
    } catch (error) {
      console.error('Purchase error:', error);
      setPurchasingId(null);
    }
  };

  const unlockWithAd = async (subcategoryId: string) => {
    try {
      await AdService.showRewardedAd(
        (amount) => {
          // Unlock subcategory
          setCategories((prev) =>
            prev.map((cat) => ({
              ...cat,
              subcategories: cat.subcategories.map((sub) =>
                sub.id === subcategoryId ? { ...sub, isUnlocked: true } : sub
              ),
            }))
          );

          VibrationHelper.vibrateSuccess();
          Alert.alert('Başarılı', 'Alt kategori başarıyla açıldı!');
        },
        () => {
          console.log('Rewarded ad dismissed');
        }
      );
    } catch (error) {
      console.error('Rewarded ad error:', error);
      Alert.alert('Hata', 'Reklam gösterilemedi');
    }
  };

  const filteredCategories = categories.filter((cat) => {
    const matchesSearch = cat.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesFilter = !filterFavorites || cat.isFavorite;
    return matchesSearch && matchesFilter;
  });

  if (isLoading) {
    return (
      <LinearGradient colors={['#E91E63', '#9C27B0', '#F44336']} style={styles.container}>
        <ActivityIndicator size="large" color="#fff" />
        <Text style={styles.loadingText}>Kategoriler yükleniyor...</Text>
      </LinearGradient>
    );
  }

  return (
    <LinearGradient colors={['#E91E63', '#9C27B0', '#F44336']} style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={() => navigation.goBack()}>
          <Icon name="arrow-back" size={24} color="#fff" />
        </TouchableOpacity>
        <View style={styles.headerTextContainer}>
          <Text style={styles.title}>Kategori Seç</Text>
          <Text style={styles.subtitle}>{players.length} oyuncu için kategori</Text>
        </View>
        <TouchableOpacity
          style={styles.favoriteFilterButton}
          onPress={() => {
            VibrationHelper.vibrateLight();
            setFilterFavorites(!filterFavorites);
          }}
        >
          <Icon
            name={filterFavorites ? 'star' : 'star-border'}
            size={24}
            color="#fff"
          />
        </TouchableOpacity>
      </View>

      {/* Search Bar */}
      <View style={styles.searchContainer}>
        <Icon name="search" size={20} color="rgba(255, 255, 255, 0.7)" />
        <TextInput
          style={styles.searchInput}
          placeholder="Kategori ara..."
          placeholderTextColor="rgba(255, 255, 255, 0.5)"
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
        {searchQuery.length > 0 && (
          <TouchableOpacity onPress={() => setSearchQuery('')}>
            <Icon name="close" size={20} color="rgba(255, 255, 255, 0.7)" />
          </TouchableOpacity>
        )}
      </View>

      {/* Category Grid */}
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {filteredCategories.length === 0 ? (
          <View style={styles.emptyContainer}>
            <Icon name="category" size={64} color="rgba(255, 255, 255, 0.5)" />
            <Text style={styles.emptyText}>
              {filterFavorites ? 'Favori kategori bulunamadı' : 'Kategori bulunamadı'}
            </Text>
          </View>
        ) : (
          filteredCategories.map((category) => (
            <TouchableOpacity
              key={category.id}
              style={styles.categoryCard}
              onPress={() => handleCategorySelect(category)}
              disabled={purchasingId === category.id}
            >
              <View style={styles.categoryHeader}>
                <View
                  style={[styles.categoryIcon, { backgroundColor: category.color }]}
                >
                  <Icon name={category.iconName} size={28} color="#fff" />
                </View>
                <View style={styles.categoryInfo}>
                  <Text style={styles.categoryName}>{category.name}</Text>
                  <Text style={styles.categoryCount}>
                    {category.hasSubcategories
                      ? `${category.subcategories.length} alt kategori`
                      : `${category.items.length} öğe`}
                  </Text>
                </View>
                <TouchableOpacity
                  onPress={() => toggleFavorite(category.id)}
                  style={styles.favoriteButton}
                >
                  <Icon
                    name={category.isFavorite ? 'star' : 'star-border'}
                    size={24}
                    color={category.isFavorite ? '#FFD700' : '#999'}
                  />
                </TouchableOpacity>
              </View>

              {category.isLocked && (
                <View style={styles.lockedOverlay}>
                  <Icon name="lock" size={20} color="#E91E63" />
                  <Text style={styles.priceText}>{category.priceTL} TL</Text>
                </View>
              )}

              {purchasingId === category.id && (
                <View style={styles.loadingOverlay}>
                  <ActivityIndicator size="small" color="#E91E63" />
                </View>
              )}
            </TouchableOpacity>
          ))
        )}
      </ScrollView>

      {/* Subcategory Dialog */}
      {showSubcategoryDialog && selectedCategory && (
        <View style={styles.dialogOverlay}>
          <View style={styles.dialogContainer}>
            <View style={styles.dialogHeader}>
              <Text style={styles.dialogTitle}>{selectedCategory.name}</Text>
              <TouchableOpacity onPress={() => setShowSubcategoryDialog(false)}>
                <Icon name="close" size={24} color="#212121" />
              </TouchableOpacity>
            </View>

            <ScrollView style={styles.dialogContent}>
              {selectedCategory.subcategories.map((sub) => (
                <TouchableOpacity
                  key={sub.id}
                  style={styles.subcategoryItem}
                  onPress={() => handleSubcategorySelect(sub)}
                >
                  <View style={styles.subcategoryIcon}>
                    <Icon
                      name={sub.isUnlocked ? 'check-circle' : 'lock'}
                      size={24}
                      color={sub.isUnlocked ? '#4CAF50' : '#999'}
                    />
                  </View>
                  <View style={styles.subcategoryInfo}>
                    <Text style={styles.subcategoryName}>{sub.name}</Text>
                    <Text style={styles.subcategoryCount}>
                      {sub.items.length} öğe
                    </Text>
                  </View>
                  {!sub.isUnlocked && (
                    <Icon name="play-circle-outline" size={20} color="#E91E63" />
                  )}
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>
        </View>
      )}
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 60,
    paddingBottom: 16,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerTextContainer: { flex: 1, marginLeft: 16 },
  title: { fontSize: 24, fontWeight: 'bold', color: '#fff' },
  subtitle: { fontSize: 14, color: 'rgba(255, 255, 255, 0.8)', marginTop: 4 },
  favoriteFilterButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    marginHorizontal: 16,
    marginBottom: 16,
    paddingHorizontal: 12,
    borderRadius: 12,
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: '#fff',
    paddingVertical: 12,
    marginLeft: 8,
  },
  scrollView: { flex: 1 },
  scrollContent: { padding: 16, paddingBottom: 32 },
  categoryCard: {
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
  },
  categoryHeader: { flexDirection: 'row', alignItems: 'center' },
  categoryIcon: {
    width: 56,
    height: 56,
    borderRadius: 28,
    alignItems: 'center',
    justifyContent: 'center',
  },
  categoryInfo: { flex: 1, marginLeft: 16 },
  categoryName: { fontSize: 18, fontWeight: '600', color: '#212121' },
  categoryCount: { fontSize: 13, color: '#757575', marginTop: 4 },
  favoriteButton: { padding: 8 },
  lockedOverlay: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 12,
    paddingTop: 12,
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
  },
  priceText: { fontSize: 14, fontWeight: '600', color: '#E91E63', marginLeft: 8 },
  loadingOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 16,
  },
  emptyContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 60,
  },
  emptyText: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.7)',
    marginTop: 16,
  },
  loadingText: { fontSize: 16, color: '#fff', marginTop: 16 },
  dialogOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  dialogContainer: {
    width: '100%',
    maxHeight: '80%',
    backgroundColor: '#fff',
    borderRadius: 20,
    overflow: 'hidden',
  },
  dialogHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  dialogTitle: { fontSize: 20, fontWeight: 'bold', color: '#212121' },
  dialogContent: { maxHeight: 400 },
  subcategoryItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  subcategoryIcon: { marginRight: 16 },
  subcategoryInfo: { flex: 1 },
  subcategoryName: { fontSize: 16, fontWeight: '600', color: '#212121' },
  subcategoryCount: { fontSize: 13, color: '#757575', marginTop: 4 },
});
