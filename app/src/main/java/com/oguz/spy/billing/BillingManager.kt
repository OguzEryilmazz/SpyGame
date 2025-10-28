package com.oguz.spy.billing

import android.app.Activity
import android.content.Context
import android.util.Log
import com.android.billingclient.api.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
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

    // Satın alma durumunu izlemek için
    private val _purchaseState = MutableStateFlow<PurchaseState>(PurchaseState.Idle)
    val purchaseState: StateFlow<PurchaseState> = _purchaseState

    // Ürün fiyatlarını saklamak için
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
                    _purchaseState.value = PurchaseState.Error("Play Store bağlantısı kurulamadı")
                }
            }

            override fun onBillingServiceDisconnected() {
                Log.w(TAG, "Billing servis bağlantısı kesildi")
                isClientReady = false
                // 3 saniye sonra yeniden bağlanmayı dene
                coroutineScope.launch {
                    kotlinx.coroutines.delay(3000)
                    startConnection()
                }
            }
        })
    }

    // Ürünleri sorgula (fiyatları almak için)
    private fun queryProducts() {
        coroutineScope.launch {
            val productList = listOf(
                "singers", "places", "animals", "vehicles", "sports",
                "electronics", "clothing", "school_subjects", "games",
                "books", "weather", "emotions", "household_items", "countries"
            ).map { categoryId ->
                QueryProductDetailsParams.Product.newBuilder()
                    .setProductId("category_$categoryId")
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

    // Mevcut satın almaları kontrol et
    private fun queryPurchases() {
        coroutineScope.launch {
            withContext(Dispatchers.IO) {
                val params = QueryPurchasesParams.newBuilder()
                    .setProductType(BillingClient.ProductType.INAPP)
                    .build()

                billingClient?.queryPurchasesAsync(params) { billingResult, purchases ->
                    if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
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

    // Satın alma başlat
    fun launchPurchaseFlow(activity: Activity, productId: String) {
        // Önce bağlantı kontrolü
        if (!isClientReady) {
            Log.e(TAG, "Billing client hazır değil")
            _purchaseState.value = PurchaseState.Error("Play Store bağlantısı kurulamadı. Lütfen tekrar deneyin.")
            return
        }

        val productDetails = _productDetails.value[productId]

        if (productDetails == null) {
            Log.e(TAG, "Ürün bulunamadı: $productId")
            _purchaseState.value = PurchaseState.Error("Ürün bilgileri yüklenemedi. Lütfen uygulamayı yeniden başlatın.")
            return
        }

        _purchaseState.value = PurchaseState.Loading
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
            _purchaseState.value = PurchaseState.Error("Satın alma ekranı açılamadı: ${billingResult?.debugMessage}")
        }
    }

    // Satın alma güncellemelerini dinle
    override fun onPurchasesUpdated(billingResult: BillingResult, purchases: List<Purchase>?) {
        Log.d(TAG, "onPurchasesUpdated: ${billingResult.responseCode}")

        when (billingResult.responseCode) {
            BillingClient.BillingResponseCode.OK -> {
                purchases?.forEach { purchase ->
                    Log.d(TAG, "Satın alma başarılı: ${purchase.products}")
                    handlePurchase(purchase)
                }
            }
            BillingClient.BillingResponseCode.USER_CANCELED -> {
                Log.d(TAG, "Kullanıcı satın almayı iptal etti")
                _purchaseState.value = PurchaseState.Error("Satın alma iptal edildi")
            }
            BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> {
                Log.d(TAG, "Ürün zaten satın alınmış")
                _purchaseState.value = PurchaseState.Error("Bu kategori zaten satın alınmış")
                // Mevcut satın almaları yeniden kontrol et
                queryPurchases()
            }
            else -> {
                Log.e(TAG, "Satın alma hatası: ${billingResult.debugMessage}")
                _purchaseState.value = PurchaseState.Error("Satın alma hatası: ${billingResult.debugMessage}")
            }
        }
    }

    private fun handlePurchase(purchase: Purchase) {
        if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
            if (!purchase.isAcknowledged) {
                acknowledgePurchase(purchase)
            }

            // Kategoriyi kilitsiz yap
            purchase.products.forEach { productId ->
                val categoryId = productId.removePrefix("category_")
                _purchaseState.value = PurchaseState.Success(categoryId)
                Log.d(TAG, "Kategori kilidi açıldı: $categoryId")
            }
        }
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

    // Kategori satın alınmış mı kontrol et
    suspend fun isCategoryPurchased(categoryId: String): Boolean {
        return withContext(Dispatchers.IO) {
            val params = QueryPurchasesParams.newBuilder()
                .setProductType(BillingClient.ProductType.INAPP)
                .build()

            var isPurchased = false
            billingClient?.queryPurchasesAsync(params) { billingResult, purchases ->
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    isPurchased = purchases.any { purchase ->
                        purchase.purchaseState == Purchase.PurchaseState.PURCHASED &&
                                purchase.products.contains("category_$categoryId")
                    }
                }
            }
            isPurchased
        }
    }

    // Fiyat bilgisini al
    fun getProductPrice(categoryId: String): String? {
        val productDetails = _productDetails.value["category_$categoryId"]
        return productDetails?.oneTimePurchaseOfferDetails?.formattedPrice
    }

    fun destroy() {
        billingClient?.endConnection()
        billingClient = null
        isClientReady = false
    }
}