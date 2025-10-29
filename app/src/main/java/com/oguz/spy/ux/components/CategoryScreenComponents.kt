package com.oguz.spy.ux.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.oguz.spy.ux.Category
import com.oguz.spy.ux.GamePlayer
import com.oguz.spy.ux.Player
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.style.TextOverflow


@Composable
fun CategoryCard(
    category: Category,
    isSelected: Boolean,
    onClick: () -> Unit,
    onUnlockClick: () -> Unit,
    onFavoriteClick: () -> Unit,
    productPrice: String?,
    isLoading: Boolean,
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .animateContentSize(
                animationSpec = spring(
                    dampingRatio = Spring.DampingRatioMediumBouncy,
                    stiffness = Spring.StiffnessMedium
                )
            )
            .clickable(enabled = !category.isLocked) { onClick() },
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) {
                Color.White.copy(alpha = 1f)
            } else {
                Color.White.copy(alpha = 0.85f)
            }
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (isSelected) 12.dp else 6.dp
        )
    ) {
        Box {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(20.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Icon ve başlık
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.weight(1f)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(56.dp)
                                .clip(RoundedCornerShape(16.dp))
                                .background(
                                    if (category.isLocked) {
                                        Color.Gray.copy(alpha = 0.3f)
                                    } else {
                                        category.color.copy(alpha = 0.2f)

                                    }
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (category.isLocked) Icons.Default.Lock else category.icon,
                                contentDescription = null,
                                tint = if (category.isLocked) Color.Gray else category.color,
                                modifier = Modifier.size(28.dp)
                            )
                        }

                        Spacer(modifier = Modifier.width(16.dp))

                        Column {
                            Text(
                                text = category.name,
                                fontSize = 20.sp,
                                fontWeight = FontWeight.Bold,
                                color = if (category.isLocked) Color.Gray else Color.Black,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )

                            Row(
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Category,
                                    contentDescription = null,
                                    tint = if (category.isLocked) Color.Gray.copy(alpha = 0.6f)
                                    else category.color.copy(alpha = 0.7f),
                                    modifier = Modifier.size(16.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(
                                    text = if (category.hasSubcategories) {
                                        "${category.subcategories.size} alt kategori"
                                    } else {
                                        if (category.id != "random_all") "${category.items.size} öğe" else "Akışına bırak."
                                    },
                                    fontSize = 14.sp,
                                    color = if (category.isLocked) Color.Gray.copy(alpha = 0.6f)
                                    else category.color.copy(alpha = 0.7f)
                                )
                            }
                        }
                    }

                    // Favori butonu
                    IconButton(
                        onClick = onFavoriteClick,
                        modifier = Modifier
                            .size(40.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(
                                if (category.isFavorite) {
                                    category.color.copy(alpha = 0.2f)
                                } else {
                                    Color.Transparent
                                }
                            )
                    ) {
                        Icon(
                            imageVector = if (category.isFavorite) Icons.Default.Star else Icons.Default.StarBorder,
                            contentDescription = "Favori",
                            tint = if (category.isFavorite) category.color else Color.Gray.copy(
                                alpha = 0.5f
                            ),
                            modifier = Modifier.size(24.dp)
                        )
                    }
                }

                // Kilitli kategori için satın alma butonu
                if (category.isLocked) {
                    Spacer(modifier = Modifier.height(16.dp))

                    HorizontalDivider(
                        color = Color.Gray.copy(alpha = 0.3f),
                        thickness = 1.dp
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    Button(
                        onClick = onUnlockClick,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = category.color,
                            contentColor = Color.White
                        ),
                        shape = RoundedCornerShape(12.dp),
                        enabled = !isLoading
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(24.dp),
                                color = Color.White,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Row(
                                horizontalArrangement = Arrangement.Center,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.ShoppingCart,
                                    contentDescription = null,
                                    modifier = Modifier.size(20.dp)
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = if (productPrice != null) {
                                        "Kilidi Aç - $productPrice"
                                    } else {
                                        "Kilidi Aç - ${String.format("%.2f", category.priceTL)} TL"
                                    },
                                    fontSize = 16.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    Text(
                        text = "Bu kategoriyi oynamak için satın alın",
                        fontSize = 12.sp,
                        color = Color.Gray.copy(alpha = 0.7f),
                        modifier = Modifier.fillMaxWidth(),
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }

                // Seçili kategori için detaylar
                if (isSelected && !category.isLocked) {
                    Spacer(modifier = Modifier.height(16.dp))

                    Divider(
                        color = category.color.copy(alpha = 0.3f),
                        thickness = 1.dp
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // İpuçları
                    Text(
                        text = "İpuçları",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = category.color
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    category.hints.take(3).forEach { hint ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(vertical = 4.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(6.dp)
                                    .clip(RoundedCornerShape(3.dp))
                                    .background(category.color.copy(alpha = 0.5f))
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = hint,
                                fontSize = 13.sp,
                                color = Color.Black.copy(alpha = 0.7f)
                            )
                        }
                    }

                    if (category.hints.size > 3) {
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "+ ${category.hints.size - 3} ipucu daha",
                            fontSize = 12.sp,
                            color = category.color.copy(alpha = 0.7f),
                            fontWeight = FontWeight.Medium
                        )
                    }
                }
            }

            // Seçim göstergesi
            if (isSelected && !category.isLocked) {
                Box(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .padding(12.dp)
                        .size(32.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(category.color),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = "Seçili",
                        tint = Color.White,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }
    }
}

// Rolleri ata function'ı
fun assignRoles(players: List<Player>, category: Category): List<GamePlayer> {
    val shuffledPlayers = players.shuffled()
    val spyIndex = shuffledPlayers.indices.random()

    val chosenItem = if (category.items.isNotEmpty()) {
        category.items.random()
    } else {
        "PLAYER"
    }

    return shuffledPlayers.mapIndexed { index, player ->
        if (index == spyIndex) {
            // Spy oyuncusu
            GamePlayer(
                id = player.id,
                name = player.name,
                color = player.selectedColor,
                selectedCharacter = player.selectedCharacter,
                role = "SPY",
                hint = if (category.hints.isNotEmpty()) category.hints.random() else null
            )
        } else {
            // Normal oyuncu
            GamePlayer(
                id = player.id,
                name = player.name,
                color = player.selectedColor,
                selectedCharacter = player.selectedCharacter,
                role = chosenItem,
                hint = null
            )
        }
    }
}
