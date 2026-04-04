package com.oguz.spy.ux

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import androidx.navigation.compose.rememberNavController
import com.oguz.spy.billing.PromoCodeManager
import com.oguz.spy.datamanagment.CategoryDataManager
import com.oguz.spy.ux.components.CounterRow
import com.oguz.spy.ux.components.SettingItem
import kotlinx.coroutines.launch

@Composable
fun SetupScreen(
    navController: NavController,
    initialPlayerCount: Int = 4,
    initialGameDuration: Int = 5,
    initialShowHints: Boolean = true,
    onSettingsChange: (Int, Int, Boolean) -> Unit = { _, _, _ -> }
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val categoryManager = remember { CategoryDataManager(context) }

    var playerCount by remember { mutableStateOf(initialPlayerCount) }
    var gameDuration by remember { mutableStateOf(initialGameDuration) }
    var showHints by remember { mutableStateOf(initialShowHints) }
    var showPromoDialog by remember { mutableStateOf(false) }

    val promoUnlocked by PromoCodeManager
        .getPromoUnlockedCategories(context)
        .collectAsState(initial = emptySet())
    val promoActive = promoUnlocked.isNotEmpty()

    LaunchedEffect(playerCount, gameDuration, showHints) {
        onSettingsChange(playerCount, gameDuration, showHints)
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFFE91E63),
                        Color(0xFF9C27B0),
                        Color(0xFFF44336)
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp)
                .padding(bottom = 80.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(40.dp))

            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Spy - Haini Bul",
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    textAlign = TextAlign.Center
                )
                Text(
                    text = "Oyun ayarlarını seç ve başla!",
                    fontSize = 16.sp,
                    color = Color.White.copy(alpha = 0.8f),
                    modifier = Modifier.padding(top = 4.dp),
                    textAlign = TextAlign.Center
                )
            }

            Spacer(modifier = Modifier.height(40.dp))

            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(
                    containerColor = Color.White.copy(alpha = 0.1f)
                )
            ) {
                Column(modifier = Modifier.padding(24.dp)) {

                    SettingItem(
                        icon = Icons.Default.People,
                        title = "Oyuncu Sayısı",
                        subtitle = "Kaç kişi oynayacak?",
                        iconColor = Color(0xFFFF9800)
                    ) {
                        CounterRow(
                            value = playerCount,
                            onDecrease = { if (playerCount > 3) playerCount-- },
                            onIncrease = { if (playerCount < 9) playerCount++ }
                        )
                    }

                    Spacer(modifier = Modifier.height(32.dp))

                    SettingItem(
                        icon = Icons.Default.AccessTime,
                        title = "Oyun Süresi",
                        subtitle = "Kaç dakika oynanacak?",
                        iconColor = Color(0xFF2196F3)
                    ) {
                        CounterRow(
                            value = gameDuration,
                            onDecrease = { if (gameDuration > 1) gameDuration-- },
                            onIncrease = { if (gameDuration < 15) gameDuration++ },
                            suffix = " dk"
                        )
                    }

                    Spacer(modifier = Modifier.height(32.dp))

                    SettingItem(
                        icon = if (showHints) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                        title = "Imposter İpucu",
                        subtitle = "Imposter'a ipucu gösterilsin mi?",
                        iconColor = if (showHints) Color(0xFF4CAF50) else Color(0xFFF44336),
                        onIconClick = { showHints = !showHints }
                    ) {}

                    Spacer(modifier = Modifier.height(12.dp))

                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = Color(0xFF4CAF50).copy(alpha = 0.15f)
                        )
                    ) {
                        Row(
                            modifier = Modifier.padding(12.dp),
                            verticalAlignment = Alignment.Top
                        ) {
                            Icon(
                                imageVector = Icons.Default.Info,
                                contentDescription = null,
                                tint = Color(0xFF4CAF50),
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "İpuçlarını açtığınız takdirde Imposter'a kategori hakkında ipucu verilecektir.",
                                fontSize = 14.sp,
                                color = Color.White.copy(alpha = 0.9f),
                                lineHeight = 18.sp,
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { showPromoDialog = true },
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(
                    containerColor = if (promoActive)
                        Color(0xFF4CAF50).copy(alpha = 0.15f)
                    else
                        Color.White.copy(alpha = 0.1f)
                ),
                border = if (promoActive)
                    BorderStroke(1.dp, Color(0xFF4CAF50).copy(alpha = 0.5f))
                else null
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(14.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(44.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(
                                    if (promoActive)
                                        Color(0xFF4CAF50).copy(alpha = 0.2f)
                                    else
                                        Color.White.copy(alpha = 0.15f)
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (promoActive) Icons.Default.CardGiftcard
                                else Icons.Default.LocalOffer,
                                contentDescription = null,
                                tint = if (promoActive) Color(0xFF4CAF50) else Color.White,
                                modifier = Modifier.size(22.dp)
                            )
                        }

                        Column {
                            Text(
                                text = if (promoActive) "Promosyon Aktif" else "Promosyon Kodu",
                                fontSize = 15.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = if (promoActive) Color(0xFF4CAF50) else Color.White
                            )
                            Text(
                                text = if (promoActive)
                                    "${promoUnlocked.size} kategori ücretsiz açıldı"
                                else
                                    "Kodunuz varsa buraya girin",
                                fontSize = 13.sp,
                                color = if (promoActive)
                                    Color(0xFF4CAF50).copy(alpha = 0.8f)
                                else
                                    Color.White.copy(alpha = 0.6f)
                            )
                        }
                    }

                    Icon(
                        imageVector = Icons.Default.ChevronRight,
                        contentDescription = null,
                        tint = if (promoActive)
                            Color(0xFF4CAF50).copy(alpha = 0.7f)
                        else
                            Color.White.copy(alpha = 0.4f),
                        modifier = Modifier.size(20.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(40.dp))
        }

        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.3f))
                    )
                )
                .padding(24.dp)
        ) {
            Button(
                onClick = { navController.navigate("playerSetUpScreen/$playerCount") },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color.White),
                shape = RoundedCornerShape(16.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.PlayArrow,
                    contentDescription = null,
                    tint = Color(0xFFE91E63),
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Devam Et",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFFE91E63)
                )
            }
        }
    }

    if (showPromoDialog) {
        PromoCodeDialog(
            isCodeAlreadyUsed = promoActive,
            unlockedCategories = promoUnlocked,
            onDismiss = { showPromoDialog = false },
            onApply = { code, selectedIds ->
                if (PromoCodeManager.isValidCode(code)) {
                    scope.launch { PromoCodeManager.savePromoUnlocks(context, selectedIds) }
                    true
                } else false
            }
        )
    }
}

@Composable
fun PromoCodeDialog(
    isCodeAlreadyUsed: Boolean,
    unlockedCategories: Set<String>,
    onDismiss: () -> Unit,
    onApply: (code: String, selectedIds: List<String>) -> Boolean
) {
    val keyboardController = LocalSoftwareKeyboardController.current

    val lockedCategoryOptions = listOf(
        "animals"   to "Hayvanlar",
        "singers"   to "Şarkıcılar",
        "sports"    to "Sporlar",
        "countries" to "Ülkeler",
        "actors"    to "Oyuncular",
        "streamers" to "Yayıncılar",
        "youtubers" to "Youtuberlar"
    )

    var promoCode by remember { mutableStateOf("") }
    var promoError by remember { mutableStateOf<String?>(null) }
    var showCategoryPicker by remember { mutableStateOf(false) }
    var promoSuccess by remember { mutableStateOf(false) }
    val selectedIds = remember { mutableStateListOf<String>() }

    AlertDialog(
        onDismissRequest = { if (!promoSuccess) onDismiss() },
        containerColor = Color(0xFF1E1E2E),
        shape = RoundedCornerShape(24.dp),
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.LocalOffer,
                    contentDescription = null,
                    tint = Color(0xFFE91E63),
                    modifier = Modifier.size(22.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = when {
                        isCodeAlreadyUsed  -> "Aktif Promosyon"
                        showCategoryPicker -> "Kategori Seç"
                        else               -> "Promosyon Kodu"
                    },
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp
                )
            }
        },
        text = {
            Column {
                when {
                    isCodeAlreadyUsed -> {
                        Text(
                            text = "Promosyon kodunuz aktif! Açık kategoriler:",
                            color = Color.White.copy(alpha = 0.75f),
                            fontSize = 14.sp,
                            lineHeight = 20.sp
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        unlockedCategories.forEach { id ->
                            val name = lockedCategoryOptions.find { it.first == id }?.second ?: id
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.padding(vertical = 5.dp)
                            ) {
                                Icon(
                                    Icons.Default.CheckCircle,
                                    null,
                                    tint = Color(0xFF4CAF50),
                                    modifier = Modifier.size(18.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(name, color = Color.White, fontSize = 15.sp)
                            }
                        }
                    }

                    showCategoryPicker -> {
                        if (promoSuccess) {
                            Card(
                                shape = RoundedCornerShape(12.dp),
                                colors = CardDefaults.cardColors(
                                    containerColor = Color(0xFF4CAF50).copy(alpha = 0.15f)
                                )
                            ) {
                                Row(
                                    modifier = Modifier.padding(14.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(
                                        Icons.Default.CheckCircle,
                                        null,
                                        tint = Color(0xFF4CAF50),
                                        modifier = Modifier.size(20.dp)
                                    )
                                    Spacer(modifier = Modifier.width(10.dp))
                                    Text(
                                        "Kategoriler başarıyla açıldı!",
                                        color = Color(0xFF4CAF50),
                                        fontSize = 14.sp,
                                        fontWeight = FontWeight.Medium
                                    )
                                }
                            }
                            Spacer(modifier = Modifier.height(12.dp))
                            selectedIds.forEach { id ->
                                val name = lockedCategoryOptions.find { it.first == id }?.second ?: id
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    modifier = Modifier.padding(vertical = 4.dp)
                                ) {
                                    Icon(
                                        Icons.Default.CheckCircle,
                                        null,
                                        tint = Color(0xFF4CAF50),
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text(
                                        name,
                                        color = Color.White.copy(alpha = 0.85f),
                                        fontSize = 14.sp
                                    )
                                }
                            }
                        } else {
                            Text(
                                "Açmak istediğin 3 kategoriyi seç:",
                                color = Color.White.copy(alpha = 0.75f),
                                fontSize = 14.sp
                            )
                            Spacer(modifier = Modifier.height(10.dp))

                            lockedCategoryOptions.forEach { (id, name) ->
                                val isSelected = selectedIds.contains(id)
                                val isDisabled = !isSelected && selectedIds.size >= 3

                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(vertical = 3.dp)
                                        .clip(RoundedCornerShape(10.dp))
                                        .background(
                                            when {
                                                isSelected -> Color(0xFFE91E63).copy(alpha = 0.2f)
                                                isDisabled -> Color.White.copy(alpha = 0.03f)
                                                else       -> Color.White.copy(alpha = 0.07f)
                                            }
                                        )
                                        .clickable(enabled = !isDisabled) {
                                            if (isSelected) selectedIds.remove(id)
                                            else selectedIds.add(id)
                                        }
                                        .padding(horizontal = 14.dp, vertical = 12.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = name,
                                        color = if (isDisabled) Color.White.copy(alpha = 0.3f)
                                        else Color.White,
                                        fontSize = 15.sp
                                    )
                                    if (isSelected) {
                                        Icon(
                                            Icons.Default.CheckCircle,
                                            null,
                                            tint = Color(0xFFE91E63),
                                            modifier = Modifier.size(20.dp)
                                        )
                                    }
                                }
                            }

                            Spacer(modifier = Modifier.height(6.dp))
                            Text(
                                text = "${selectedIds.size}/3 kategori seçildi",
                                color = Color(0xFFE91E63).copy(alpha = 0.85f),
                                fontSize = 13.sp,
                                modifier = Modifier.fillMaxWidth(),
                                textAlign = TextAlign.End
                            )
                        }
                    }

                    else -> {
                        Text(
                            text = "Promosyon kodunu girerek 3 kategoriyi ücretsiz aç.",
                            color = Color.White.copy(alpha = 0.75f),
                            fontSize = 14.sp,
                            lineHeight = 20.sp
                        )
                        Spacer(modifier = Modifier.height(16.dp))

                        OutlinedTextField(
                            value = promoCode,
                            onValueChange = { promoCode = it.uppercase(); promoError = null },
                            placeholder = {
                                Text("Kodu gir...", color = Color.White.copy(alpha = 0.4f))
                            },
                            singleLine = true,
                            isError = promoError != null,
                            keyboardOptions = KeyboardOptions(
                                capitalization = KeyboardCapitalization.Characters,
                                imeAction = ImeAction.Done
                            ),
                            keyboardActions = KeyboardActions(
                                onDone = {
                                    keyboardController?.hide()
                                    if (PromoCodeManager.isValidCode(promoCode)) showCategoryPicker = true
                                    else promoError = "Geçersiz promosyon kodu."
                                }
                            ),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White,
                                focusedBorderColor = Color(0xFFE91E63),
                                unfocusedBorderColor = Color.White.copy(alpha = 0.3f),
                                errorBorderColor = Color(0xFFFF5252),
                                cursorColor = Color(0xFFE91E63)
                            ),
                            shape = RoundedCornerShape(12.dp),
                            modifier = Modifier.fillMaxWidth()
                        )

                        if (promoError != null) {
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(promoError!!, color = Color(0xFFFF5252), fontSize = 13.sp)
                        }
                    }
                }
            }
        },
        confirmButton = {
            when {
                isCodeAlreadyUsed -> {
                    TextButton(onClick = onDismiss) {
                        Text("Tamam", color = Color(0xFFE91E63), fontWeight = FontWeight.Bold)
                    }
                }
                showCategoryPicker && promoSuccess -> {
                    TextButton(onClick = onDismiss) {
                        Text("Kapat", color = Color(0xFFE91E63), fontWeight = FontWeight.Bold)
                    }
                }
                showCategoryPicker -> {
                    Button(
                        onClick = {
                            val ok = onApply(promoCode, selectedIds.toList())
                            if (ok) promoSuccess = true
                        },
                        enabled = selectedIds.size == 3,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFE91E63),
                            disabledContainerColor = Color.White.copy(alpha = 0.1f)
                        ),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text(
                            "Uygula",
                            color = if (selectedIds.size == 3) Color.White
                            else Color.White.copy(alpha = 0.4f),
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
                else -> {
                    Button(
                        onClick = {
                            keyboardController?.hide()
                            if (PromoCodeManager.isValidCode(promoCode)) {
                                showCategoryPicker = true
                                promoError = null
                            } else {
                                promoError = "Geçersiz promosyon kodu."
                            }
                        },
                        enabled = promoCode.isNotBlank(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFE91E63),
                            disabledContainerColor = Color.White.copy(alpha = 0.1f)
                        ),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text("Doğrula", color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }
        },
        dismissButton = {
            if (!isCodeAlreadyUsed && !promoSuccess) {
                TextButton(onClick = onDismiss) {
                    Text("İptal", color = Color.White.copy(alpha = 0.5f))
                }
            }
        }
    )
}

@Composable
@Preview(showBackground = true)
fun Pre() {
    SetupScreen(navController = rememberNavController())
}