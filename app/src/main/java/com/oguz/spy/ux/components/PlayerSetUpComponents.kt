package com.oguz.spy.ux.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.oguz.spy.ux.Player
import com.oguz.spy.models.CharacterAvatar

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PlayerCard(
    player: Player,
    availableColors: List<Color>,
    usedColors: List<Color>,
    usedCharacters: List<CharacterAvatar> = emptyList(),
    onNameChange: (String) -> Unit,
    onColorChange: (Color) -> Unit,
    onCharacterChange: (CharacterAvatar?) -> Unit
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

            // 🔹 HEADER
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
                    player.selectedCharacter?.let { character ->
                        Image(
                            painter = painterResource(id = character.drawableRes),
                            contentDescription = null,
                            modifier = Modifier.size(40.dp),
                            contentScale = ContentScale.Crop
                        )
                    } ?: Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(24.dp)
                    )
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

            // 🔹 İSİM
            OutlinedTextField(
                value = player.name,
                onValueChange = onNameChange,
                label = { Text("İsim", color = Color.White.copy(alpha = 0.7f)) },
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

            // 🔹 RENK SEÇİMİ
            Text(
                text = "Renk Seç:",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                items(availableColors) { color ->
                    val isSelected = player.selectedColor == color
                    val isUsed = color in usedColors
                    val isClickable = !isUsed || isSelected

                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(
                                color.copy(alpha = if (isUsed && !isSelected) 0.3f else 1f)
                            )
                            .then(
                                if (isSelected)
                                    Modifier.border(3.dp, Color.White, CircleShape)
                                else Modifier
                            )
                            .clickable(enabled = isClickable) {
                                if (isClickable) onColorChange(color)
                            }
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // 🔹 KARAKTER SEÇİMİ
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

                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(
                                when {
                                    isSelected -> Color.White
                                    isUsed -> Color.Gray.copy(alpha = 0.4f)
                                    else -> Color.White.copy(alpha = 0.4f)
                                }
                            )
                            .then(
                                if (isSelected)
                                    Modifier.border(3.dp, player.selectedColor, CircleShape)
                                else Modifier
                            )
                            .clickable {
                                when {
                                    isSelected -> onCharacterChange(null) // bırak
                                    !isUsed -> onCharacterChange(character)
                                }
                            },
                        contentAlignment = Alignment.Center
                    ) {

                        Image(
                            painter = painterResource(id = character.drawableRes),
                            contentDescription = null,
                            modifier = Modifier
                                .size(40.dp)
                                .alpha(if (isUsed && !isSelected) 0.3f else 1f),
                            contentScale = ContentScale.Crop
                        )


                        if (isUsed && !isSelected) {
                            Icon(
                                imageVector = Icons.Default.Close,
                                contentDescription = null,
                                tint = Color.Red,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    }
                }
            }
        }
    }
}