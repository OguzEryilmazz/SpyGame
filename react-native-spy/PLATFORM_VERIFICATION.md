# Platform Verification Guide

This guide provides step-by-step instructions for verifying that AdMob ads and In-App Purchases work correctly on both iOS and Android platforms.

## Table of Contents

1. [AdMob Verification](#admob-verification)
2. [In-App Purchase Verification](#in-app-purchase-verification)
3. [Common Issues & Troubleshooting](#common-issues--troubleshooting)
4. [Platform-Specific Notes](#platform-specific-notes)

---

## AdMob Verification

### Setup: Test vs Production Ad Units

The app uses different Ad Unit IDs for development and production:

**Development (Test Ads)**:
```typescript
// src/services/AdService.ts
const AD_UNIT_IDS = {
  banner: __DEV__
    ? TestIds.BANNER
    : Platform.OS === 'ios' ? 'ca-app-pub-YOUR_ID/banner' : 'ca-app-pub-YOUR_ID/banner',
  interstitial: __DEV__
    ? TestIds.INTERSTITIAL
    : Platform.OS === 'ios' ? 'ca-app-pub-YOUR_ID/interstitial' : 'ca-app-pub-YOUR_ID/interstitial',
  rewarded: __DEV__
    ? TestIds.REWARDED
    : Platform.OS === 'ios' ? 'ca-app-pub-YOUR_ID/rewarded' : 'ca-app-pub-YOUR_ID/rewarded',
};
```

### iOS AdMob Verification

#### Prerequisites
1. Add `GADApplicationIdentifier` to `Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_ADMOB_APP_ID</string>
```

2. Install CocoaPods dependencies:
```bash
cd ios && pod install && cd ..
```

#### Testing Steps

**1. Banner Ads (CategoryScreen)**
- Open the app in iOS simulator or device
- Navigate to Category screen
- Verify banner appears at bottom of screen
- Expected: White "Test Ad" banner with sample content
- Behavior: Should not cover category grid

**2. Interstitial Ads (After Category Selection)**
- Select a category 3 times (frequency control: every 3rd time)
- On 3rd selection, verify full-screen ad appears
- Expected: Test interstitial with "Test Ad" label and close button
- Behavior: After closing, should navigate to Game screen
- Verify AdService.interstitialShowCount increments correctly

**3. Rewarded Ads (Unlock Subcategory)**
- Select a category with locked subcategories
- Tap "Watch Ad to Unlock" button
- Verify rewarded ad loads and plays
- Expected: Full-screen video or interactive ad
- Behavior: After completion, subcategory should unlock
- Verify reward callback fires with amount > 0

#### iOS Verification Checklist
- [ ] Banner loads without errors in console
- [ ] Banner respects safe area (no notch overlap)
- [ ] Interstitial shows every 3rd navigation
- [ ] Interstitial close button works
- [ ] Rewarded ad video plays completely
- [ ] Reward callback unlocks content
- [ ] No crashes or memory leaks
- [ ] Ads work on both simulator and physical device

### Android AdMob Verification

#### Prerequisites
1. Add AdMob App ID to `AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_ADMOB_APP_ID"/>
```

2. Ensure Google Play Services is up to date on device/emulator

#### Testing Steps

**1. Banner Ads**
- Open app on Android emulator or device
- Navigate to Category screen
- Verify banner appears at bottom
- Expected: "Test Ad" banner with sample content
- Behavior: Should adapt to screen width

**2. Interstitial Ads**
- Select a category 3 times
- Verify ad shows on 3rd selection
- Expected: Full-screen test ad
- Behavior: Back button should close ad (not navigate away)
- Verify navigation occurs after dismiss

**3. Rewarded Ads**
- Tap "Watch Ad to Unlock" for locked subcategory
- Verify ad loads and shows video
- Expected: Video ad with countdown timer
- Behavior: User must watch to completion for reward
- Verify early close does NOT grant reward

#### Android Verification Checklist
- [ ] Banner loads without Play Services errors
- [ ] Banner doesn't overlap navigation bar
- [ ] Interstitial shows on correct frequency
- [ ] Back button closes interstitial properly
- [ ] Rewarded ad cannot be skipped early
- [ ] Reward only granted after completion
- [ ] Ads work on both emulator and physical device
- [ ] No ANR (Application Not Responding) during ad load

### Cross-Platform Ad Verification

Test the following scenarios on BOTH platforms:

**Frequency Control**:
```typescript
// Verify this logic works identically
AdService.showInterstitialWithFrequency(() => navigation.navigate('Game'));
```
- Navigate between screens multiple times
- Confirm ad shows every 3rd time, not every time
- Counter should persist across app sessions (if implemented)

**Ad Loading States**:
- Test with airplane mode (no network)
- Verify graceful fallback when ads fail to load
- Check that failed ad load doesn't block navigation
- Ensure error callbacks fire correctly

**Ad Lifecycle**:
- App backgrounding during ad display
- App foregrounding after ad shown
- Rapidly dismissing multiple interstitials
- Memory usage during repeated ad loads

---

## In-App Purchase Verification

### iOS IAP Verification (StoreKit)

#### Prerequisites

1. **App Store Connect Setup**:
   - Create app in App Store Connect
   - Add In-App Purchases (Consumable or Non-Consumable)
   - Create product IDs matching PRODUCT_IDS in PurchaseService.ts
   - Submit IAPs for review (can test before approval)

2. **Sandbox Tester Account**:
   - Go to App Store Connect > Users and Access > Sandbox Testers
   - Create test account (use fake email)
   - DO NOT sign in to real App Store with this account

3. **Xcode Configuration**:
   - Enable In-App Purchase capability
   - Add StoreKit configuration file for local testing (optional)

#### Testing Steps

**1. Product Retrieval**:
```typescript
// This should return products without errors
const products = await PurchaseService.getProducts();
console.log('Available products:', products);
```
- Open app and navigate to locked category
- Verify product price displays correctly (e.g., "19.99 TL")
- Price should be in local currency based on App Store region

**2. Purchase Flow**:
- Tap "Unlock for 19.99 TL" button
- System payment sheet should appear
- Sign in with Sandbox Tester account when prompted
- Confirm purchase with password/Face ID
- Verify success callback fires
- Verify category unlocks immediately

**3. Purchase Restoration** (iOS-specific):
```typescript
await PurchaseService.restorePurchases(
  (purchases) => {
    // Verify previously purchased items restore
  }
);
```
- Delete app and reinstall
- Tap "Restore Purchases" button
- Sign in with same Sandbox account
- Verify all previous purchases restore
- No duplicate charges should occur

**4. Subscription Testing** (if applicable):
- Sandbox subscriptions renew at accelerated rate (5 min = 1 month)
- Test renewal, expiration, and cancellation
- Verify receipt validation

#### iOS IAP Verification Checklist
- [ ] Products load with correct prices
- [ ] Payment sheet appears on purchase
- [ ] Sandbox account login works
- [ ] Purchase completes successfully
- [ ] Success callback unlocks content
- [ ] Receipt validation passes
- [ ] Restore purchases works after reinstall
- [ ] No duplicate purchases allowed (non-consumable)
- [ ] Error handling works (user cancels, insufficient funds)
- [ ] Works on both simulator (iOS 15+) and device

### Android IAP Verification (Google Play Billing)

#### Prerequisites

1. **Google Play Console Setup**:
   - Upload app to Google Play Console (alpha/internal test track)
   - Create In-App Products in Monetization section
   - Product IDs must match PRODUCT_IDS in PurchaseService.ts
   - Publish products (don't need to publish app)

2. **Test Account Setup**:
   - Add tester email to license testing list
   - Alternatively, create closed/open testing track
   - Testers can make purchases without being charged

3. **App Configuration**:
   - Use signed APK/AAB (debug builds may not work for IAP)
   - Version code must match upload

#### Testing Steps

**1. Product Retrieval**:
```typescript
const products = await PurchaseService.getProducts();
```
- Launch app on test device
- Navigate to locked category
- Verify "Unlock for ₺19.99" button shows correct price
- Price format should match Google Play locale

**2. Purchase Flow**:
- Tap purchase button
- Google Play purchase dialog appears
- If test account: Shows "(Test)" badge and "You won't be charged"
- Confirm purchase
- Verify success callback fires
- Verify category unlocks

**3. Pending Transactions**:
- Test slow/offline purchase confirmation
- Verify pending purchases complete when online
- Check acknowledgement flow works correctly

**4. Subscription Testing** (if applicable):
- Use test mode for instant renewals
- Test upgrade/downgrade flows
- Verify proration works correctly

#### Android IAP Verification Checklist
- [ ] Products load from Google Play
- [ ] Prices display in local currency
- [ ] Purchase dialog shows test badge
- [ ] Purchase completes without charge (test account)
- [ ] Success callback unlocks content
- [ ] Purchase acknowledgement succeeds
- [ ] Pending transactions handled gracefully
- [ ] Error handling works (user cancels, network error)
- [ ] Works with signed APK only
- [ ] No duplicate purchases (non-consumable)

### Cross-Platform IAP Verification

Test the following on BOTH platforms:

**1. Purchase State Persistence**:
```typescript
// After purchase, category should remain unlocked
const unlockedCategories = await AsyncStorage.getItem('unlockedCategories');
```
- Purchase a category
- Force close app
- Reopen app
- Verify category still unlocked
- Test across app updates

**2. Error Handling**:
```typescript
PurchaseService.purchaseProduct(
  'category_animals',
  (purchase) => { /* success */ },
  (error) => {
    // Test these error scenarios
    console.log('Purchase error:', error);
  }
);
```

Test these error scenarios:
- User cancels purchase
- Network error during purchase
- Invalid product ID
- Item already owned (non-consumable)
- Billing service unavailable

**3. Purchase Validation**:
- Verify receipt/token validation works
- Test with revoked purchases (refunds)
- Ensure server-side validation if implemented
- Check purchase signature verification (Android)

**4. Edge Cases**:
- Rapid repeated purchase attempts
- App killed during purchase flow
- Purchase while offline (should queue)
- Multiple simultaneous purchases

---

## Common Issues & Troubleshooting

### AdMob Issues

**Issue**: "Ad failed to load" error
- **iOS**: Check Info.plist has correct GADApplicationIdentifier
- **Android**: Verify AndroidManifest.xml has meta-data tag
- **Both**: Ensure device has internet connection
- **Both**: Wait a few seconds between ad requests (rate limiting)

**Issue**: Ads not showing in production
- Check Ad Unit IDs are correct (not using TestIds)
- Verify AdMob account is approved and active
- Check ad placement policies compliance
- Wait 24-48 hours after creating new Ad Units

**Issue**: App crashes on ad load
- Update react-native-google-mobile-ads to latest version
- iOS: Run `pod update GoogleMobileAds`
- Android: Sync Gradle and update Google Play Services

**Issue**: Rewarded ad doesn't grant reward
- Verify onRewarded callback is registered before ad.show()
- Check ad fully completes (not closed early)
- Test with rewarded ad test ID first

### IAP Issues

**Issue**: Products not loading (iOS)
- Verify product IDs match App Store Connect exactly
- Check app bundle ID matches App Store Connect
- Ensure IAP products are "Ready to Submit" status
- Wait 24 hours after creating products
- Check device is signed in to Sandbox account

**Issue**: Products not loading (Android)
- App must be uploaded to Google Play Console
- Product IDs must match exactly (case-sensitive)
- Ensure using signed APK with matching version code
- License testing account must be added
- Wait 24 hours after publishing products

**Issue**: "Cannot connect to iTunes Store" (iOS)
- Sign OUT of real App Store account on device
- Sign in with Sandbox account only when prompted
- Check internet connection
- Try different Sandbox account

**Issue**: "Item already owned" error
- iOS: Call restorePurchases() to restore transaction
- Android: Consume or acknowledge previous purchase
- For testing, use different Sandbox/test account

**Issue**: Purchase completes but content doesn't unlock
- Check success callback is actually called
- Verify AsyncStorage or state update works
- Check for race conditions in unlock logic
- Ensure purchase is acknowledged (Android)

---

## Platform-Specific Notes

### iOS-Specific Behavior

**AdMob**:
- Ads may not show in iOS Simulator on M1/M2 Macs (known issue)
- Test on physical device for accurate results
- SKAdNetwork for attribution tracking

**IAP**:
- Sandbox purchases don't charge real money
- Receipts are automatically generated
- Family Sharing affects purchase restoration
- App Review will test IAP during submission

### Android-Specific Behavior

**AdMob**:
- Requires Google Play Services on device
- Test ads work on emulators without Play Store
- Production ads require real device with Play Store

**IAP**:
- Must use signed APK (debug builds don't work)
- Version code must match uploaded version
- Internal test track is easiest for testing
- Purchase tokens expire after 3 days (test mode)

---

## Testing Checklist Summary

### Complete Verification (Both Platforms)

AdMob:
- [ ] Banner ads load and display correctly
- [ ] Interstitial ads show with correct frequency
- [ ] Rewarded ads grant rewards after completion
- [ ] Ads handle network errors gracefully
- [ ] No crashes or memory leaks during ad lifecycle

IAP:
- [ ] Products load with correct prices
- [ ] Purchase flow completes successfully
- [ ] Content unlocks after purchase
- [ ] Error handling works (cancel, network error)
- [ ] Purchase state persists across app restarts
- [ ] iOS: Restore purchases works
- [ ] Android: Pending transactions handled

Platform Helpers:
- [ ] VibrationHelper works on both platforms
- [ ] ScreenHelper keeps screen awake during timer
- [ ] Vibration patterns match expected behavior
- [ ] No platform-specific crashes

### Final Integration Test

1. **Complete Game Flow**:
   - Setup game with 5 players
   - View banner ad on category screen
   - Purchase locked category (IAP)
   - Watch rewarded ad to unlock subcategory
   - Start game (interstitial ad may show)
   - Reveal roles (vibration feedback)
   - Run timer (screen stays awake)
   - Vote and see results

2. **Verify on Both Platforms**:
   - iOS physical device
   - Android physical device
   - Test all monetization points
   - Check for platform-specific issues
   - Verify identical behavior

---

## Production Checklist

Before releasing to App Store / Play Store:

**AdMob**:
- [ ] Replace TestIds with production Ad Unit IDs
- [ ] Test production ads with real impressions
- [ ] Verify ad policies compliance
- [ ] Add ads.txt file to website (if applicable)

**IAP**:
- [ ] iOS: Submit IAP products for review
- [ ] Android: Publish IAP products
- [ ] Implement server-side receipt validation
- [ ] Add refund/chargeback handling
- [ ] Update privacy policy to mention payments

**General**:
- [ ] Test on multiple device sizes
- [ ] Verify performance on older devices
- [ ] Check memory usage during extended play
- [ ] Review analytics integration
- [ ] Ensure GDPR/CCPA compliance for ads

---

## Additional Resources

**AdMob Documentation**:
- [react-native-google-mobile-ads](https://docs.page/invertase/react-native-google-mobile-ads)
- [AdMob Policy Center](https://support.google.com/admob/answer/6128543)

**IAP Documentation**:
- [react-native-iap](https://github.com/dooboolab/react-native-iap)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Google Play Billing](https://developer.android.com/google/play/billing)

**Testing Tools**:
- [iOS Sandbox Testing](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)
- [Google Play Console Testing](https://developer.android.com/google/play/billing/test)
