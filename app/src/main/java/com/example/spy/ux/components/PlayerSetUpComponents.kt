// =====================================
// 3. PLAYERCARD DOSYASINI GÜNCELLEYİN
// =====================================

// 📁 app/src/main/java/com/example/spy/ux/components/PlayerCard.kt
// MEVCUT DOSYANIZI TAMAMEN DEĞİŞTİRİN:

package com.example.spy.ux.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.spy.ux.Player
import com.example.spy.models.CharacterAvatar // YENİ IMPORT

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PlayerCard(
    player: Player,
    availableColors: List<Color>,
    usedColors: List<Color>,
    usedCharacters: List<CharacterAvatar> = emptyList(), // YENİ PARAMETRE
    onNameChange: (String) -> Unit,
    onColorChange: (Color) -> Unit,
    onCharacterChange: (CharacterAvatar) -> Unit = {} // YENİ PARAMETRE
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = Color.White.copy(alpha = 0.15f)
        )
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            // Player Header - GÜNCELLENDİ
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(player.selectedColor),
                    contentAlignment = Alignment.Center
                ) {
                    // Karakter seçilmişse onu göster, yoksa ikon göster
                    if (player.selectedCharacter != null) {
                        Image(
                            painter = painterResource(id = player.selectedCharacter!!.drawableRes),
                            contentDescription = "Karakter ${player.selectedCharacter!!.ordinal + 1}",
                            modifier = Modifier.size(40.dp),
                            contentScale = ContentScale.Crop
                        )
                    } else {
                        Icon(
                            imageVector = Icons.Default.Person,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(24.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.width(16.dp))

                Text(
                    text = "Oyuncu ${player.id}",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.White
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Name Input (aynı kalacak)
            OutlinedTextField(
                value = player.name,
                onValueChange = onNameChange,
                label = {
                    Text(
                        "İsim",
                        color = Color.White.copy(alpha = 0.7f)
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedTextColor = Color.White,
                    unfocusedTextColor = Color.White,
                    focusedIndicatorColor = Color.White,
                    unfocusedIndicatorColor = Color.White.copy(alpha = 0.5f),
                    cursorColor = Color.White
                ),
                singleLine = true,
                shape = RoundedCornerShape(12.dp)
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Color Selection (aynı kalacak)
            Text(
                text = "Renk Seç:",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(availableColors) { color ->
                    val isSelected = player.selectedColor == color
                    val isUsed = color in usedColors
                    val isClickable = !isUsed || isSelected

                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(color.copy(alpha = if (isUsed && !isSelected) 0.3f else 1f))
                            .then(
                                if (isSelected) {
                                    Modifier.border(3.dp, Color.White, CircleShape)
                                } else {
                                    Modifier
                                }
                            )
                            .clickable(enabled = isClickable) {
                                if (isClickable) {
                                    onColorChange(color)
                                }
                            }
                    ) {
                        if (isSelected) {
                            Icon(
                                imageVector = Icons.Default.Person,
                                contentDescription = null,
                                tint = Color.White,
                                modifier = Modifier
                                    .align(Alignment.Center)
                                    .size(20.dp)
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // YENİ: Character Selection
            Text(
                text = "Karakter Seç:",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                contentPadding = PaddingValues(horizontal = 4.dp)
            ) {
                items(CharacterAvatar.values()) { character ->
                    val isSelected = player.selectedCharacter == character
                    val isUsed = character in usedCharacters
                    val isClickable = !isUsed || isSelected

                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(
                                when {
                                    isSelected -> Color.White
                                    isUsed && !isSelected -> Color.White.copy(alpha = 0.2f)
                                    else -> Color.White.copy(alpha = 0.4f)
                                }
                            )
                            .then(
                                if (isSelected) {
                                    Modifier.border(3.dp, player.selectedColor, CircleShape)
                                } else {
                                    Modifier
                                }
                            )
                            .clickable(enabled = isClickable) {
                                if (isClickable) {
                                    onCharacterChange(character)
                                }
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Image(
                            painter = painterResource(id = character.drawableRes),
                            contentDescription = "Karakter ${character.ordinal + 1}",
                            modifier = Modifier.size(40.dp),
                            contentScale = ContentScale.Crop
                        )
                    }
                }
            }
        }
    }
}