package com.example.spy.ux.components


import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarBorder
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun EmptyFavoritesComponent(
    onAddFavoriteClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Large star icon
        Icon(
            imageVector = Icons.Default.StarBorder,
            contentDescription = null,
            tint = Color.White.copy(alpha = 0.6f),
            modifier = Modifier.size(80.dp)
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Title
        Text(
            text = "Henüz favori yok",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(12.dp))

        // Description
        Text(
            text = "Beğendiğiniz kategorileri favorilerinize ekleyin. Kategorilerin üzerindeki yıldız ikonuna basarak favori ekleyebilirsiniz.",
            fontSize = 16.sp,
            color = Color.White.copy(alpha = 0.8f),
            textAlign = TextAlign.Center,
            lineHeight = 22.sp
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Add favorite button
        OutlinedButton(
            onClick = onAddFavoriteClick,
            colors = ButtonDefaults.outlinedButtonColors(
                contentColor = Color.White
            ),
            border = androidx.compose.foundation.BorderStroke(
                width = 2.dp,
                color = Color.White.copy(alpha = 0.7f)
            ),
            shape = RoundedCornerShape(16.dp),
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Star,
                contentDescription = null,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "Kategori Keşfet",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Helper text
        Text(
            text = "Tüm kategorilere göz atın ve beğendiğinizi favorilerinize ekleyin",
            fontSize = 14.sp,
            color = Color.White.copy(alpha = 0.6f),
            textAlign = TextAlign.Center
        )
    }
}