package com.oguz.spy.billing

import android.app.Activity
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.android.billingclient.api.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class BillingManager(
    private val context: Context,
    private val coroutineScope: CoroutineScope
) : PurchasesUpdatedListener {

    private val TAG = "BillingManager"

    private var billingClient: BillingClient? = null
    private var isClientReady = false

    private val prefs: SharedPreferences = context.getSharedPreferences("purchases", Context.MODE_PRIVATE)

    // ✅ StateFlow yerine SharedFlow kullan
    private val _purchaseState = MutableSharedFlow<PurchaseState>(replay = 0)
    val purchaseState: SharedFlow<PurchaseState> = _purchaseState

    // Ürün fiyatlarını saklamak için StateFlow kullanmaya devam et
    private val _productDetails = MutableStateFlow<Map<String, ProductDetails>>(emptyMap())
    val productDetails: StateFlow<Map<String, ProductDetails>> = _productDetails

    sealed class PurchaseState {
        object Idle : PurchaseState()
        object Loading : PurchaseState()
        data class Success(val categoryId: String) : PurchaseState()
        data class Error(val message: String) : PurchaseState()
    }

    init {
        setupBillingClient()
    }

    private fun setupBillingClient() {
        billingClient = BillingClient.newBuilder(context)
            .setListener(this)
            .enablePendingPurchases()
            .build()

        startConnection()
    }

    private fun startConnection() {
        billingClient?.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    Log.d(TAG, "Billing client bağlantısı başarılı")
                    isClientReady = true
                    queryProducts()
                    queryPurchases()
                } else {
                    Log.e(TAG, "Billing client bağlantı hatası: ${billingResult.debugMessage}")
                    isClientReady = false
                    coroutineScope.launch {
                        _purchaseState.emit(PurchaseState.Error("Play Store bağlantısı kurulamadı"))
                    }
                }
            }

            override fun onBillingServiceDisconnected() {
                Log.w(TAG, "Billing servis bağlantısı kesildi")
                isClientReady = false
                coroutineScope.launch {
                    kotlinx.coroutines.delay(3000)
                    startConnection()
                }
            }
        })
    }

    private fun queryProducts() {
        coroutineScope.launch {
            val mainCategories = listOf(
                "singers", "places", "animals", "vehicles", "sports",
                "electronics", "clothing", "school_subjects", "games",
                "books", "weather", "emotions", "household_items", "countries", "youtubers",
                "streamers","actors"
            )

            val subcategoryIds = listOf(
                "athletes_active_football_domestic",
                "athletes_active_football_foreign",
                "athletes_retired_football_domestic",
                "athletes_retired_football_foreign",
                "athletes_basketball_nba",
                "athletes_basketball_euroleague",
                "athletes_basketball_legends",
                "athletes_volleyball_female",
                "athletes_ufc",
                "athletes_wwe",
                "athletes_boxing",
                "athletes_f1",
                "singers_domestic_pop",
                "singers_domestic_rap_trap",
                "singers_domestic_arabesque",
                "singers_domestic_rock",
                "singers_domestic_alternative",
                "singers_foreign_pop",
                "singers_foreign_hiphop",
                "singers_foreign_latin",
                "singers_foreign_rock",
                "actors_domestic_male",
                "actors_domestic_female",
                "actors_foreign_male",
                "actors_foreign_female",
                "youtubers_male",
                "youtubers_female"
            )

            val allProductIds = mainCategories + subcategoryIds

            val productList = allProductIds.map { id ->
                QueryProductDetailsParams.Product.newBuilder()
                    .setProductId(id)
                    .setProductType(BillingClient.ProductType.INAPP)
                    .build()
            }

            val params = QueryProductDetailsParams.newBuilder()
                .setProductList(productList)
                .build()

            withContext(Dispatchers.IO) {
                billingClient?.queryProductDetailsAsync(params) { billingResult, productDetailsList ->
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                        val detailsMap = productDetailsList.associateBy { it.productId }
                        _productDetails.value = detailsMap
                        Log.d(TAG, "Ürün detayları alındı: ${productDetailsList.size} ürün")
                    } else {
                        Log.e(TAG, "Ürün sorgu hatası: ${billingResult.debugMessage}")
                    }
                }
            }
        }
    }

    fun queryPurchases() {
        coroutineScope.launch {
            withContext(Dispatchers.IO) {
                val params = QueryPurchasesParams.newBuilder()
                    .setProductType(BillingClient.ProductType.INAPP)
                    .build()

                billingClient?.queryPurchasesAsync(params) { billingResult, purchases ->
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                        Log.d(TAG, "Toplam ${purchases.size} satın alma bulundu")
                        purchases.forEach { purchase ->
                            if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                                handlePurchase(purchase)
                            }
                        }
                    }
                }
            }
        }
    }

    fun launchPurchaseFlow(activity: Activity, productId: String) {
        if (!isClientReady) {
            Log.e(TAG, "Billing client hazır değil")
            coroutineScope.launch {
                _purchaseState.emit(PurchaseState.Error("Play Store bağlantısı kurulamadı. Lütfen tekrar deneyin."))
            }
            return
        }

        val productDetails = _productDetails.value[productId]

        if (productDetails == null) {
            Log.e(TAG, "Ürün bulunamadı: $productId")
            coroutineScope.launch {
                _purchaseState.emit(PurchaseState.Error("Ürün bilgileri yüklenemedi. Lütfen uygulamayı yeniden başlatın."))
            }
            return
        }

        coroutineScope.launch {
            _purchaseState.emit(PurchaseState.Loading)
        }
        Log.d(TAG, "Satın alma başlatılıyor: $productId")

        val productDetailsParamsList = listOf(
            BillingFlowParams.ProductDetailsParams.newBuilder()
                .setProductDetails(productDetails)
                .build()
        )

        val billingFlowParams = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(productDetailsParamsList)
            .build()

        val billingResult = billingClient?.launchBillingFlow(activity, billingFlowParams)

        if (billingResult?.responseCode != BillingClient.BillingResponseCode.OK) {
            Log.e(TAG, "Billing flow başlatılamadı: ${billingResult?.debugMessage}")
            coroutineScope.launch {
                _purchaseState.emit(PurchaseState.Error("Satın alma ekranı açılamadı: ${billingResult?.debugMessage}"))
            }
        }
    }

    override fun onPurchasesUpdated(billingResult: BillingResult, purchases: List<Purchase>?) {
        Log.d(TAG, "onPurchasesUpdated: ${billingResult.responseCode}")

        coroutineScope.launch {
            when (billingResult.responseCode) {
                BillingClient.BillingResponseCode.OK -> {
                    purchases?.forEach { purchase ->
                        Log.d(TAG, "Satın alma başarılı: ${purchase.products}")
                        handlePurchase(purchase)
                    }
                }
                BillingClient.BillingResponseCode.USER_CANCELED -> {
                    Log.d(TAG, "Kullanıcı satın almayı iptal etti")
                    _purchaseState.emit(PurchaseState.Error("Satın alma iptal edildi"))
                }
                BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> {
                    Log.d(TAG, "Ürün zaten satın alınmış")
                    queryPurchases()
                    _purchaseState.emit(PurchaseState.Error("Bu kategori zaten satın alınmış"))
                }
                else -> {
                    Log.e(TAG, "Satın alma hatası: ${billingResult.debugMessage}")
                    _purchaseState.emit(PurchaseState.Error("Satın alma hatası: ${billingResult.debugMessage}"))
                }
            }
        }
    }

    private fun handlePurchase(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
            if (!purchase.isAcknowledged) {
                acknowledgePurchase(purchase)
            }

            purchase.products.forEach { productId ->
                prefs.edit().putBoolean(productId, true).apply()

                coroutineScope.launch {
                    _purchaseState.emit(PurchaseState.Success(productId))
                }
                Log.d(TAG, "Kategori kilidi açıldı ve kaydedildi: $productId")
            }
        }
    }

    fun getAllPurchasedProducts(): Set<String> {
        return prefs.all.keys.filter { key ->
            prefs.getBoolean(key, false)
        }.toSet()
    }

    private fun acknowledgePurchase(purchase: Purchase) {
        coroutineScope.launch {
            withContext(Dispatchers.IO) {
                val params = AcknowledgePurchaseParams.newBuilder()
                    .setPurchaseToken(purchase.purchaseToken)
                    .build()

                billingClient?.acknowledgePurchase(params) { billingResult ->
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                        Log.d(TAG, "Satın alma onaylandı")
                    } else {
                        Log.e(TAG, "Satın alma onaylama hatası: ${billingResult.debugMessage}")
                    }
                }
            }
        }
    }

    suspend fun isCategoryPurchased(categoryId: String): Boolean {
        val cachedPurchase = prefs.getBoolean(categoryId, false)
        if (cachedPurchase) {
            Log.d(TAG, "Kategori cache'de bulundu: $categoryId")
            return true
        }

        return withContext(Dispatchers.IO) {
            val params = QueryPurchasesParams.newBuilder()
                .setProductType(BillingClient.ProductType.INAPP)
                .build()

            var isPurchased = false
            billingClient?.queryPurchasesAsync(params) { billingResult, purchases ->
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    isPurchased = purchases.any { purchase ->
                        purchase.purchaseState == Purchase.PurchaseState.PURCHASED &&
                                purchase.products.contains(categoryId)
                    }

                    if (isPurchased) {
                        prefs.edit().putBoolean(categoryId, true).apply()
                        Log.d(TAG, "Kategori Play Store'da bulundu ve cache'e kaydedildi: $categoryId")
                    }
                }
            }
            isPurchased
        }
    }

    fun getProductPrice(categoryId: String): String? {
        val productDetails = _productDetails.value[categoryId]
        Log.d("price", productDetails.toString())
        return productDetails?.oneTimePurchaseOfferDetails?.formattedPrice
    }

    fun getSubcategoryPrice(subcategoryId: String): String? {
        val productDetails = _productDetails.value[subcategoryId]
        Log.d("subcategory_price", productDetails.toString())
        return productDetails?.oneTimePurchaseOfferDetails?.formattedPrice
    }

    fun destroy() {
        billingClient?.endConnection()
        billingClient = null
        isClientReady = false
    }
}