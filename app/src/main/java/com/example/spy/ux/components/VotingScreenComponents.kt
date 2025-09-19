package com.example.spy.ux.components

import androidx.compose.animation.core.EaseInOutSine
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.HowToVote
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.spy.ux.GamePlayer

@Composable
fun VotingInterface(
    players: List<GamePlayer>,
    currentVoter: GamePlayer,
    selectedPlayerName: String?,
    onPlayerSelect: (String) -> Unit,
    onVoteSubmit: () -> Unit,
    onBack: () -> Unit,
    votingProgress: Pair<Int, Int>,
) {
    // Mevcut oyuncu kendisine oy veremez, o yüzden listeyi filtrele
    val votablePlayers = players.filter { it.name != currentVoter.name }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF1A1A1A))
            .padding(16.dp)
    ) {
        // Header
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(
                onClick = onBack,
                modifier = Modifier
                    .clip(CircleShape)
                    .background(Color.White.copy(alpha = 0.1f))
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowBack,
                    contentDescription = "Geri",
                    tint = Color.White
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.HowToVote,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "OYLAMA ${votingProgress.first}/${votingProgress.second}",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Black,
                    color = Color.White
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Progress bar
        LinearProgressIndicator(
            progress = votingProgress.first.toFloat() / votingProgress.second.toFloat(),
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
                .clip(RoundedCornerShape(3.dp)),
            color = Color.Red,
            trackColor = Color.White.copy(alpha = 0.2f)
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Mevcut oyuncu göstergesi
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = Color.Blue.copy(alpha = 0.3f)
            ),
            shape = RoundedCornerShape(16.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Avatar
                if (currentVoter.selectedCharacter != null) {
                    Image(
                        painter = painterResource(id = currentVoter.selectedCharacter.drawableRes),
                        contentDescription = "${currentVoter.name} avatar",
                        modifier = Modifier.size(50.dp)
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .size(50.dp)
                            .clip(CircleShape)
                            .background(currentVoter.color),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = currentVoter.name.first().toString().uppercase(),
                            fontSize = 24.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }
                }

                Spacer(modifier = Modifier.width(16.dp))

                Column {
                    Text(
                        text = "${currentVoter.name}'ın Sırası",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = "Şüpheli bulduğun oyuncuya oy ver",
                        fontSize = 14.sp,
                        color = Color.White.copy(alpha = 0.8f)
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        Text(
            text = "İMPOSTOR KİM?",
            fontSize = 28.sp,
            fontWeight = FontWeight.Black,
            color = Color.Red,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth(),
            letterSpacing = 2.sp
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Oyuncular listesi (kendisi hariç)
        LazyColumn(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(votablePlayers) { player ->
                PlayerVoteCard(
                    player = player,
                    isSelected = selectedPlayerName == player.name,
                    onClick = { onPlayerSelect(player.name) }
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Oy verme butonu
        Button(
            onClick = onVoteSubmit,
            enabled = selectedPlayerName != null,
            modifier = Modifier
                .fillMaxWidth()
                .height(60.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = if (selectedPlayerName != null) Color(0xFF4CAF50) else Color.Gray,
                contentColor = Color.White
            ),
            shape = RoundedCornerShape(30.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = null,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = if (selectedPlayerName != null) "OY VER" else "BİR OYUNCU SEÇİN",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
fun PlayerVoteCard(
    player: GamePlayer,
    isSelected: Boolean,
    onClick: () -> Unit,
) {
    val animatedScale by animateFloatAsState(
        targetValue = if (isSelected) 1.05f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "cardScale"
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .scale(animatedScale)
            .clickable { onClick() }
            .then(
                if (isSelected) {
                    Modifier.border(3.dp, Color.Red, RoundedCornerShape(16.dp))
                } else {
                    Modifier
                }
            ),
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) Color.Red.copy(alpha = 0.2f) else Color.White.copy(
                alpha = 0.1f
            )
        ),
        shape = RoundedCornerShape(16.dp),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (isSelected) 8.dp else 4.dp
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Avatar
            if (player.selectedCharacter != null) {
                Image(
                    painter = painterResource(id = player.selectedCharacter.drawableRes),
                    contentDescription = "${player.name} avatar",
                    modifier = Modifier.size(50.dp)
                )
            } else {
                Box(
                    modifier = Modifier
                        .size(50.dp)
                        .clip(CircleShape)
                        .background(player.color),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = player.name.first().toString().uppercase(),
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                }
            }

            Spacer(modifier = Modifier.width(16.dp))

            // İsim
            Text(
                text = player.name,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White,
                modifier = Modifier.weight(1f)
            )

            // Seçim göstergesi
            if (isSelected) {
                Icon(
                    imageVector = Icons.Default.Check,
                    contentDescription = null,
                    tint = Color.Red,
                    modifier = Modifier.size(32.dp)
                )
            }
        }
    }
}

@Composable
fun VotingResultsScreen(
    impostor: GamePlayer?,
    mostVotedPlayer: GamePlayer?,
    votes: Map<String, Int>,
    gamePlayers: List<GamePlayer>,
    onPlayAgain: () -> Unit,
    onMainMenu: () -> Unit,
) {
    val isImpostorCaught = mostVotedPlayer?.role == "SPY"

    // Pulsing animation for the result
    val infiniteTransition = rememberInfiniteTransition(label = "result")
    val pulsing by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000, easing = EaseInOutSine),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulsing"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(
                if (isImpostorCaught) Color(0xFF0D5016) else Color(0xFF5D1A1A)
            )
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Sonuç başlığı
        Text(
            text = if (isImpostorCaught) "TEBRİKLER!" else "IMPOSTOR KAZANDI!",
            fontSize = 36.sp,
            fontWeight = FontWeight.Black,
            color = if (isImpostorCaught) Color.Green else Color.Red,
            textAlign = TextAlign.Center,
            letterSpacing = 2.sp,
            modifier = Modifier.scale(pulsing)
        )

        Spacer(modifier = Modifier.height(32.dp))

        // En çok oy alan oyuncu
        if (mostVotedPlayer != null) {

            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "En Çok Oy Alan:",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.White.copy(alpha = 0.8f)
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Avatar
                if (mostVotedPlayer.selectedCharacter != null) {
                    Image(
                        painter = painterResource(id = mostVotedPlayer.selectedCharacter.drawableRes),
                        contentDescription = "${mostVotedPlayer.name} avatar",
                        modifier = Modifier.size(120.dp)
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .size(80.dp)
                            .clip(CircleShape)
                            .background(mostVotedPlayer.color),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = mostVotedPlayer.name.first().toString().uppercase(),
                            fontSize = 32.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    }


                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = mostVotedPlayer.name,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )

                    Text(
                        text = "${votes[mostVotedPlayer.name] ?: 0} oy",
                        fontSize = 16.sp,
                        color = Color.White.copy(alpha = 0.8f)
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    // Rol açıklaması
                    Text(
                        text = if (isImpostorCaught) {
                            "Bu oyuncu gerçekten IMPOSTOR'du!"
                        } else {
                            "Bu oyuncu masumdu..."
                        },
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Medium,
                        color = if (isImpostorCaught) Color.Green else Color.Red,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Gerçek impostor'ı göster
        if (impostor != null && !isImpostorCaught) {
            Text(
                text = "Gerçek IMPOSTOR:",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White.copy(alpha = 0.8f)
            )

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = impostor.name,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Red
            )

            Spacer(modifier = Modifier.height(24.dp))
        }

        // Butonlar
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Button(
                onClick = onPlayAgain,
                modifier = Modifier
                    .width(200.dp)
                    .height(60.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.White,
                    contentColor = Color.Black
                ),
                shape = RoundedCornerShape(30.dp)
            ) {
                Text(
                    text = "Tekrar Oyna",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}
