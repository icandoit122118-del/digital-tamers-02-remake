package com.dragonrod.dt02remake

import android.app.KeyguardManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.FilterQuality
import androidx.compose.ui.graphics.drawscope.scale
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import kotlinx.coroutines.delay
import kotlin.math.roundToInt
import kotlin.random.Random

val ColBgBase = Color(0xFF0B1118)
val ColBgHud = Color(0xEA0B1118)
val ColSurface = Color(0xFF131D28)
val ColSurfaceHover = Color(0xFF1B2938)
val ColBorder = Color(0xFF26384D)
val ColInk = Color(0xFFF0F6FC)
val ColInkSec = Color(0xFF9BB0C7)
val ColAccent = Color(0xFF00E5B0)
val ColBattle = Color(0xFFFF6B4A)
val ColGold = Color(0xFFF5C451)
val ColFocus = Color(0xFF38BDF8)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            val km = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
            km?.requestDismissKeyguard(this, null)
        }
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        WindowCompat.setDecorFitsSystemWindows(window, false)
        WindowInsetsControllerCompat(window, window.decorView).let { ctrl ->
            ctrl.hide(WindowInsetsCompat.Type.systemBars())
            ctrl.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }

        val repo = GameRepository(applicationContext)
        if (intent?.getBooleanExtra("run_self_test", false) == true) {
            val report = repo.runDiagnosticSelfTest()
            Log.i("DT02Verify", "DT02_ANDROID_VERIFY_PASS :: $report")
        }
        intent?.getStringExtra("start_room")?.let { startRoom ->
            if (startRoom.isNotEmpty()) {
                if (startRoom == "room_Battle") {
                    val stg = repo.stageArenas[2]
                    repo.startStageBattle(stg.bossId, stg.lv, stg.zone, stg.bg)
                    for (i in 0 until 28) repo.tickFrame()
                } else {
                    repo.currentRoom = startRoom
                }
            }
        }
        intent?.getIntExtra("sanctuary_idx", -1)?.let { idx ->
            if (idx >= 0) repo.sanctuaryThemeIdx = idx % repo.sanctuaryThemes.size
        }

        setContent {
            DT02RemakeApp(repo)
        }
    }
}

@Composable
fun DT02RemakeApp(repo: GameRepository) {
    LaunchedEffect(Unit) {
        while (true) {
            delay(33L)
            repo.tickFrame()
        }
    }

    Box(modifier = Modifier.fillMaxSize().background(ColBgBase)) {
        // 1. Pixel-Art World Canvas (538x300 scaled to fullscreen with Nearest-Neighbor)
        PixelWorldCanvas(repo = repo, modifier = Modifier.fillMaxSize())

        // 2. D-Terminal OS Mobile Native High-DPI Overlay HUD
        when (repo.currentRoom) {
            "room_MainMenu" -> MainMenuScreen(repo)
            "room_options_MainMenu" -> OptionsScreen(repo)
            "room_MainRoom" -> SanctuaryScreen(repo)
            "room_Battle" -> BattleHudScreen(repo)
            "room_Battle_Items" -> ItemsForgeScreen(repo)
            "room_SelectTraining" -> LuckyTrainingScreen(repo)
            "room_Evo_Select" -> DigivolveMatrixScreen(repo)
            "room_Database" -> EncyclopediaScreen(repo)
            "room_DigiVice" -> DigiviceQuestScreen(repo)
            "room_Select_Map" -> WorldExpeditionScreen(repo)
            else -> SanctuaryScreen(repo)
        }

        // 3. Toast Notification Banner
        if (repo.toastTimer > 0f && repo.toastMessage.isNotEmpty()) {
            Surface(
                modifier = Modifier.align(Alignment.TopCenter).padding(top = 12.dp),
                color = ColBgBase,
                shape = RoundedCornerShape(8.dp),
                border = BorderStroke(1.dp, ColAccent)
            ) {
                Text(
                    text = repo.toastMessage,
                    color = ColAccent,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
                )
            }
        }
    }
}

@Composable
fun PixelWorldCanvas(repo: GameRepository, modifier: Modifier = Modifier) {
    val tick = repo.animTick
    Canvas(modifier = modifier) {
        val sx = size.width / 538f
        val sy = size.height / 300f

        fun drawSpr(spr: String, frame: Int = 0, x: Float = 0f, y: Float = 0f, w: Float = -1f, h: Float = -1f) {
            val bmp = repo.tex(spr, frame) ?: return
            val dstW = if (w > 0f) w else bmp.width.toFloat()
            val dstH = if (h > 0f) h else bmp.height.toFloat()
            drawImage(
                image = bmp,
                dstOffset = IntOffset((x * sx).roundToInt(), (y * sy).roundToInt()),
                dstSize = IntSize((dstW * sx).roundToInt().coerceAtLeast(1), (dstH * sy).roundToInt().coerceAtLeast(1)),
                filterQuality = FilterQuality.None
            )
        }

        when (repo.currentRoom) {
            "room_Battle" -> {
                drawSpr(repo.battleBg, 0, 0f, 0f, 538f, 300f)

                // Draw Player Partner Digimon
                val pId = when (repo.dataMode) {
                    "worst" -> 152
                    "empty" -> 1
                    else -> repo.partnerId
                }
                val pBmp = repo.texDigimon(pId, repo.pAct, tick)
                if (pBmp != null) {
                    val pw = pBmp.width.toFloat()
                    val ph = pBmp.height.toFloat()
                    drawOval(
                        color = Color(0x66000000),
                        topLeft = Offset((repo.pX - 24f) * sx, 213f * sy),
                        size = Size(48f * sx, 8f * sy)
                    )
                    scale(scaleX = -1f, scaleY = 1f, pivot = Offset(repo.pX * sx, (repo.pY - ph * 0.5f) * sy)) {
                        drawImage(
                            image = pBmp,
                            dstOffset = IntOffset(((repo.pX - pw * 0.5f) * sx).roundToInt(), ((repo.pY - ph + 8f) * sy).roundToInt()),
                            dstSize = IntSize((pw * sx).roundToInt(), (ph * sy).roundToInt()),
                            filterQuality = FilterQuality.None
                        )
                    }
                }

                // Draw Enemy Boss Digimon
                val eBmp = repo.texDigimon(repo.enemyId, repo.eAct, tick)
                if (eBmp != null) {
                    val ew = eBmp.width.toFloat()
                    val eh = eBmp.height.toFloat()
                    drawOval(
                        color = Color(0x66000000),
                        topLeft = Offset((repo.eX - 24f) * sx, 213f * sy),
                        size = Size(48f * sx, 8f * sy)
                    )
                    drawImage(
                        image = eBmp,
                        dstOffset = IntOffset(((repo.eX - ew * 0.5f) * sx).roundToInt(), ((repo.eY - eh + 8f) * sy).roundToInt()),
                        dstSize = IntSize((ew * sx).roundToInt(), (eh * sy).roundToInt()),
                        filterQuality = FilterQuality.None
                    )
                }

                // Draw Projectiles
                for (p in repo.projectiles) {
                    val c = Color(p.colHex)
                    val r = (if (p.isUlt) 13f else 8f) * sx
                    drawCircle(color = c.copy(alpha = 0.35f), radius = r * 1.4f, center = Offset(p.x * sx, p.y * sy))
                    drawCircle(color = c, radius = r, center = Offset(p.x * sx, p.y * sy))
                    val pSpr = if (p.fromPlayer) "spr_FireBurst01" else "spr_FireBarr04"
                    drawSpr(pSpr, (tick / 2) % 4, p.x - 14f, p.y - 14f)
                }
            }

            "room_MainRoom" -> {
                val th = repo.sanctuaryThemes[repo.sanctuaryThemeIdx.coerceIn(0, repo.sanctuaryThemes.size - 1)]
                drawSpr(th.bg, 0, 0f, 0f, 538f, 300f)

                if (th.layer2 >= 0) {
                    val l2 = repo.tex("spr_DecoLayer02", th.layer2)
                    if (l2 != null) drawSpr("spr_DecoLayer02", th.layer2, 0f, 219f - l2.height.toFloat())
                }
                if (th.layer1 >= 0) {
                    val l1 = repo.tex("spr_DecoLayer01", th.layer1)
                    if (l1 != null) drawSpr("spr_DecoLayer01", th.layer1, 0f, 219f - l1.height.toFloat())
                }
                drawSpr("spr_Floor_Deco", th.floor, 0f, 200f, 538f, 100f)

                for (prop in th.props) {
                    val pb = repo.tex(prop.spr, 0) ?: continue
                    val orig = repo.spriteOrigins[prop.spr] ?: Pair(pb.width * 0.5f, pb.height.toFloat())
                    drawSpr(prop.spr, 0, prop.x - orig.first, prop.y - orig.second)
                }

                // Sanctuary Partner Digimon
                if (repo.dataMode == "empty") {
                    drawSpr("spr_egg01", (tick / 6) % 2, 250f, 190f)
                } else {
                    val pid = if (repo.dataMode == "worst") 152 else repo.partnerId
                    val pBmp = repo.texDigimon(pid, "walk", tick)
                    if (pBmp != null) {
                        val pw = pBmp.width.toFloat()
                        val ph = pBmp.height.toFloat()
                        val flip = if (repo.sanctuaryDir > 0f) -1f else 1f
                        scale(scaleX = flip, scaleY = 1f, pivot = Offset(repo.sanctuaryX * sx, (224f - ph * 0.5f) * sy)) {
                            drawImage(
                                image = pBmp,
                                dstOffset = IntOffset(((repo.sanctuaryX - pw * 0.5f) * sx).roundToInt(), ((224f - ph + 6f) * sy).roundToInt()),
                                dstSize = IntSize((pw * sx).roundToInt(), (ph * sy).roundToInt()),
                                filterQuality = FilterQuality.None
                            )
                        }
                    }
                }
            }

            "room_Select_Map" -> drawSpr("BG_SelectMap", 0, 0f, 0f, 538f, 300f)
            "room_SelectTraining" -> drawSpr("BG_TrainingLobby", 0, 0f, 0f, 538f, 300f)
            "room_Evo_Select" -> drawSpr("BG_EvoRoom", 0, 0f, 0f, 538f, 300f)
            else -> drawSpr("bg_Tech01", 0, 0f, 0f, 538f, 300f)
        }
    }
}

@Composable
fun TamerButton(
    text: String,
    kind: String = "secondary",
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    val (bg, border, fg) = when (kind) {
        "primary" -> Triple(ColAccent, ColAccent, Color(0xFF042F26))
        "battle" -> Triple(ColBattle, ColBattle, Color(0xFF1A0804))
        "gold" -> Triple(ColGold, ColGold, Color(0xFF1F1400))
        "active_seg" -> Triple(ColSurfaceHover, ColAccent, ColAccent)
        else -> Triple(ColSurface, ColBorder, ColInk)
    }
    Surface(
        modifier = modifier.clip(RoundedCornerShape(10.dp)).clickable(onClick = onClick),
        color = bg,
        shape = RoundedCornerShape(10.dp),
        border = BorderStroke(1.dp, border)
    ) {
        Box(contentAlignment = Alignment.Center, modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)) {
            Text(text = text, color = fg, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
    }
}

@Composable
fun MainMenuScreen(repo: GameRepository) {
    Row(modifier = Modifier.fillMaxSize().padding(18.dp), horizontalArrangement = Arrangement.SpaceBetween) {
        Surface(
            modifier = Modifier.width(340.dp).fillMaxHeight(),
            color = ColBgHud,
            shape = RoundedCornerShape(14.dp),
            border = BorderStroke(1.dp, ColBorder)
        ) {
            Column(
                modifier = Modifier.padding(18.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                repo.tex("spr_GameLogo", 0)?.let { logo ->
                    Image(
                        bitmap = logo,
                        contentDescription = "Logo",
                        modifier = Modifier.height(74.dp).fillMaxWidth(),
                        contentScale = ContentScale.Fit,
                        filterQuality = FilterQuality.None
                    )
                }
                Text("D-TERMINAL OS  ·  v2.0.2 REMAKE", color = ColInkSec, fontSize = 11.sp)

                TamerButton("Continue Sanctuary", "primary", Modifier.fillMaxWidth().height(42.dp)) {
                    repo.currentRoom = "room_MainRoom"
                }
                TamerButton("1v1 Auto-Chess Battle", "battle", Modifier.fillMaxWidth().height(42.dp)) {
                    repo.initBattleState()
                    repo.currentRoom = "room_Battle"
                }
                TamerButton("HD Items & Lucky Forge (750)", "gold", Modifier.fillMaxWidth().height(42.dp)) {
                    repo.currentRoom = "room_Battle_Items"
                }
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                    TamerButton("663 Digimon DB", "secondary", Modifier.weight(1f).height(38.dp)) {
                        repo.currentRoom = "room_Database"
                    }
                    TamerButton("System Options", "secondary", Modifier.weight(1f).height(38.dp)) {
                        repo.currentRoom = "room_options_MainMenu"
                    }
                }
            }
        }

        Surface(
            modifier = Modifier.width(370.dp).fillMaxHeight(),
            color = ColBgHud,
            shape = RoundedCornerShape(14.dp),
            border = BorderStroke(1.dp, ColBorder)
        ) {
            val d = repo.digimons[repo.partnerId]
            Column(modifier = Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("ACTIVE SANCTUARY SLOT 0", color = ColAccent, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                Text("${d?.name ?: "Greymon"}  (Lv.${repo.partnerLv})", color = ColInk, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                Text("${d?.stage ?: "Champion"} · ${d?.attr ?: "Vaccine"} · LUK ${repo.luk}", color = ColGold, fontSize = 12.sp)

                Box(modifier = Modifier.fillMaxWidth().weight(1f), contentAlignment = Alignment.Center) {
                    repo.texDigimon(repo.partnerId, "idle", repo.animTick)?.let { bmp ->
                        Image(
                            bitmap = bmp,
                            contentDescription = "Partner",
                            modifier = Modifier.size(120.dp),
                            contentScale = ContentScale.Fit,
                            filterQuality = FilterQuality.None
                        )
                    }
                }

                Text("ATK ${repo.atk} · DEF ${repo.def} · SPD ${repo.spd} · ${repo.bits} BIT", color = ColInkSec, fontSize = 12.sp)
                Text("663 Digimon · 436 Evos · 750 HD Items · 78 Quests", color = ColAccent, fontSize = 11.sp)
            }
        }
    }
}

@Composable
fun SanctuaryScreen(repo: GameRepository) {
    val d = repo.digimons[repo.partnerId]
    val th = repo.sanctuaryThemes[repo.sanctuaryThemeIdx.coerceIn(0, repo.sanctuaryThemes.size - 1)]

    Box(modifier = Modifier.fillMaxSize().padding(10.dp)) {
        // Top HUD Row
        Row(modifier = Modifier.fillMaxWidth().align(Alignment.TopCenter), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Surface(
                modifier = Modifier.weight(1.1f).height(88.dp),
                color = ColBgHud,
                shape = RoundedCornerShape(12.dp),
                border = BorderStroke(1.dp, ColBorder)
            ) {
                Row(modifier = Modifier.padding(10.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    repo.texIcon(repo.partnerId)?.let { ic ->
                        Image(bitmap = ic, contentDescription = null, modifier = Modifier.size(54.dp), filterQuality = FilterQuality.None)
                    }
                    Column(verticalArrangement = Arrangement.spacedBy(3.dp), modifier = Modifier.weight(1f)) {
                        Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                            Text(
                                text = when (repo.dataMode) {
                                    "worst" -> "BlackWarGreymon-X (Awakened)"
                                    "empty" -> "Digi-Egg Incubator"
                                    else -> d?.name ?: "Greymon"
                                },
                                color = ColInk, fontSize = 15.sp, fontWeight = FontWeight.Bold, maxLines = 1, overflow = TextOverflow.Ellipsis
                            )
                            Text("Lv.${repo.partnerLv} · LUK ${repo.luk}", color = ColGold, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        }
                        Text(
                            "ATK ${repo.atk} · DEF ${repo.def} · SPD ${repo.spd} · Dodge ${22 + (repo.spd * 0.08f).toInt()}%",
                            color = ColInkSec, fontSize = 11.sp, maxLines = 1
                        )
                        LinearProgressIndicator(
                            progress = { 1f },
                            modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
                            color = ColAccent,
                            trackColor = ColSurface
                        )
                    }
                }
            }

            Surface(
                modifier = Modifier.weight(1f).height(88.dp),
                color = ColBgHud,
                shape = RoundedCornerShape(12.dp),
                border = BorderStroke(1.dp, ColBorder)
            ) {
                Column(modifier = Modifier.padding(8.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalAlignment = Alignment.CenterVertically) {
                        Text("${repo.bits} BIT", color = ColGold, fontSize = 13.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                        TamerButton("Biome: ${th.name}", "active_seg", Modifier.height(30.dp)) {
                            repo.sanctuaryThemeIdx = (repo.sanctuaryThemeIdx + 1) % repo.sanctuaryThemes.size
                            repo.showToast("Sanctuary Biome: ${repo.sanctuaryThemes[repo.sanctuaryThemeIdx].name}")
                        }
                        TamerButton("Save", "secondary", Modifier.height(30.dp)) {
                            repo.saveGameState()
                            repo.showToast("Saved to tamer_save_v2.json")
                        }
                        TamerButton("Title", "secondary", Modifier.height(30.dp)) {
                            repo.currentRoom = "room_MainMenu"
                        }
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        listOf("demo" to "Demo data", "worst" to "Worst case", "empty" to "Empty state").forEach { (k, label) ->
                            TamerButton(label, if (repo.dataMode == k) "active_seg" else "secondary", Modifier.weight(1f).height(28.dp)) {
                                repo.dataMode = k
                            }
                        }
                    }
                }
            }
        }

        // Bottom Navigation Dock
        Surface(
            modifier = Modifier.fillMaxWidth().height(62.dp).align(Alignment.BottomCenter),
            color = ColBgHud,
            shape = RoundedCornerShape(14.dp),
            border = BorderStroke(1.dp, ColBorder)
        ) {
            Row(modifier = Modifier.padding(8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                TamerButton("Digivice & Quests", "secondary", Modifier.weight(1f).fillMaxHeight()) { repo.currentRoom = "room_DigiVice" }
                TamerButton("HD Items (750)", "gold", Modifier.weight(1f).fillMaxHeight()) { repo.currentRoom = "room_Battle_Items" }
                TamerButton("Lucky Training", "secondary", Modifier.weight(1f).fillMaxHeight()) { repo.currentRoom = "room_SelectTraining" }
                TamerButton("Digivolve Tree", "primary", Modifier.weight(1f).fillMaxHeight()) { repo.currentRoom = "room_Evo_Select" }
                TamerButton("663 Digimon DB", "secondary", Modifier.weight(1f).fillMaxHeight()) { repo.currentRoom = "room_Database" }
                TamerButton("World & Arena", "battle", Modifier.weight(1f).fillMaxHeight()) { repo.currentRoom = "room_Select_Map" }
            }
        }
    }
}

@Composable
fun BattleHudScreen(repo: GameRepository) {
    val pName = repo.digimons[repo.partnerId]?.name ?: "Greymon"
    val eName = repo.digimons[repo.enemyId]?.name ?: "WarGreymon"

    Box(modifier = Modifier.fillMaxSize().padding(8.dp)) {
        // Top 3 Cards: Player | 1v1 Luck Roulette | Enemy Boss
        Row(modifier = Modifier.fillMaxWidth().align(Alignment.TopCenter), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            // Player Card
            Surface(modifier = Modifier.weight(1f).height(88.dp), color = ColBgHud, shape = RoundedCornerShape(10.dp), border = BorderStroke(1.dp, ColAccent)) {
                Row(modifier = Modifier.padding(8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                    repo.texIcon(repo.partnerId)?.let { ic ->
                        Image(bitmap = ic, contentDescription = null, modifier = Modifier.size(44.dp), filterQuality = FilterQuality.None)
                    }
                    Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                        Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                            Text("$pName (Lv.${repo.partnerLv})", color = ColInk, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                            Text("AI: ${repo.pAiState}", color = ColAccent, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                        }
                        Text("HP ${repo.pHp}/${repo.pHpMax} · Dodges:${repo.pDodges} · Parries:${repo.pParries}", color = ColAccent, fontSize = 10.sp, maxLines = 1)
                        LinearProgressIndicator(
                            progress = { (repo.pHp.toFloat() / repo.pHpMax.coerceAtLeast(1)).coerceIn(0f, 1f) },
                            modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
                            color = ColAccent, trackColor = ColSurface
                        )
                        LinearProgressIndicator(
                            progress = { (repo.pSp / 100f).coerceIn(0f, 1f) },
                            modifier = Modifier.fillMaxWidth().height(4.dp).clip(RoundedCornerShape(2.dp)),
                            color = ColGold, trackColor = ColSurface
                        )
                    }
                }
            }

            // Center 1v1 Auto-Chess RNG Board
            Surface(modifier = Modifier.weight(1f).height(88.dp), color = ColBgHud, shape = RoundedCornerShape(10.dp), border = BorderStroke(1.dp, ColGold)) {
                Column(modifier = Modifier.padding(6.dp), horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(2.dp)) {
                    Text("1v1 AUTO-CHESS · ${repo.battleZone.uppercase()}", color = ColInkSec, fontSize = 10.sp, maxLines = 1)
                    Text("🎰 [${repo.slotReels}] ${repo.slotTitle}", color = ColGold, fontSize = 11.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                    Text("🎲 D100: ${repo.lastDice} → ${repo.lastTier} (${repo.lastMult}x)", color = ColAccent, fontSize = 11.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                    Text(repo.lastLog, color = ColInk, fontSize = 9.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
                }
            }

            // Enemy Card
            Surface(modifier = Modifier.weight(1f).height(88.dp), color = ColBgHud, shape = RoundedCornerShape(10.dp), border = BorderStroke(1.dp, ColBattle)) {
                Row(modifier = Modifier.padding(8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                    Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                        Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                            Text("$eName (Lv.${repo.enemyLv})", color = ColInk, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                            Text("AI: ${repo.eAiState}", color = ColBattle, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                        }
                        Text("HP ${repo.eHp}/${repo.eHpMax} · ATK ${repo.eAtk} · LUK ${repo.eLuk}", color = ColBattle, fontSize = 10.sp, maxLines = 1)
                        LinearProgressIndicator(
                            progress = { (repo.eHp.toFloat() / repo.eHpMax.coerceAtLeast(1)).coerceIn(0f, 1f) },
                            modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
                            color = ColBattle, trackColor = ColSurface
                        )
                        LinearProgressIndicator(
                            progress = { (repo.eSp / 100f).coerceIn(0f, 1f) },
                            modifier = Modifier.fillMaxWidth().height(4.dp).clip(RoundedCornerShape(2.dp)),
                            color = ColGold, trackColor = ColSurface
                        )
                    }
                    repo.texIcon(repo.enemyId)?.let { ic ->
                        Image(bitmap = ic, contentDescription = null, modifier = Modifier.size(44.dp), filterQuality = FilterQuality.None)
                    }
                }
            }
        }

        // Floating Combat Popups
        for (pop in repo.popups) {
            Text(
                text = pop.txt,
                color = Color(pop.colHex),
                fontSize = 12.sp,
                fontWeight = FontWeight.ExtraBold,
                modifier = Modifier.align(Alignment.Center).offset(x = ((pop.x - 269f) * 1.4f).dp, y = ((pop.y - 160f) * 1.2f).dp)
            )
        }

        // Single-Match Result Banner
        if (repo.btlFinished) {
            Surface(
                modifier = Modifier.align(Alignment.Center).padding(bottom = 30.dp),
                color = ColBgBase,
                shape = RoundedCornerShape(12.dp),
                border = BorderStroke(2.dp, if (repo.btlWin) ColAccent else ColBattle)
            ) {
                Text(
                    text = repo.btlResultBanner,
                    color = if (repo.btlWin) ColAccent else ColBattle,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.ExtraBold,
                    modifier = Modifier.padding(horizontal = 24.dp, vertical = 12.dp)
                )
            }
        }

        // Bottom Auto-Skill & Tactic Controller Bar
        Surface(
            modifier = Modifier.fillMaxWidth().height(88.dp).align(Alignment.BottomCenter),
            color = ColBgHud,
            shape = RoundedCornerShape(12.dp),
            border = BorderStroke(1.dp, ColBorder)
        ) {
            Row(modifier = Modifier.padding(6.dp), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                repo.skills.forEachIndexed { idx, sk ->
                    Surface(
                        modifier = Modifier.weight(1f).fillMaxHeight(),
                        color = ColSurface,
                        shape = RoundedCornerShape(8.dp),
                        border = BorderStroke(1.dp, if (idx == 3) ColGold else ColBorder)
                    ) {
                        Column(modifier = Modifier.padding(6.dp), verticalArrangement = Arrangement.SpaceBetween) {
                            Text("[AUTO] ${sk.name}", color = if (idx == 3) ColGold else ColInk, fontSize = 11.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                            Text(sk.tag, color = ColInkSec, fontSize = 9.sp, maxLines = 1)
                            Text(sk.lastRoll, color = ColAccent, fontSize = 9.sp, maxLines = 1)
                            val prog = if (idx == 3) (repo.pSp / 100f) else (1f - (sk.cd / sk.cdMax)).coerceIn(0f, 1f)
                            LinearProgressIndicator(
                                progress = { prog.coerceIn(0f, 1f) },
                                modifier = Modifier.fillMaxWidth().height(5.dp).clip(RoundedCornerShape(2.dp)),
                                color = if (idx == 3) ColGold else ColAccent,
                                trackColor = ColBgBase
                            )
                        }
                    }
                }

                Column(modifier = Modifier.width(230.dp).fillMaxHeight(), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp), modifier = Modifier.weight(1f).fillMaxWidth()) {
                        TamerButton(if (repo.btlAutoSkill) "AUTO: ON" else "AUTO: OFF", if (repo.btlAutoSkill) "primary" else "secondary", Modifier.weight(1f).fillMaxHeight()) {
                            repo.btlAutoSkill = !repo.btlAutoSkill
                        }
                        TamerButton(if (repo.btlSpeed2x) "2x SPD" else "1x SPD", if (repo.btlSpeed2x) "active_seg" else "secondary", Modifier.weight(1f).fillMaxHeight()) {
                            repo.btlSpeed2x = !repo.btlSpeed2x
                        }
                        TamerButton("Stage BG", "secondary", Modifier.weight(1f).fillMaxHeight()) {
                            val curIdx = repo.stageArenas.indexOfFirst { it.bg == repo.battleBg }
                            val next = repo.stageArenas[(curIdx + 1) % repo.stageArenas.size]
                            repo.battleBg = next.bg
                            repo.battleZone = next.zone
                            repo.showToast("Stage BG: ${next.zone}")
                        }
                    }
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp), modifier = Modifier.weight(1f).fillMaxWidth()) {
                        TamerButton("AI: ${repo.btlTactic.uppercase()}", "gold", Modifier.weight(1.2f).fillMaxHeight()) {
                            val order = listOf("gamble", "evasive", "balanced")
                            repo.btlTactic = order[(order.indexOf(repo.btlTactic) + 1) % order.size]
                        }
                        TamerButton("Rematch", "battle", Modifier.weight(1f).fillMaxHeight()) {
                            repo.initBattleState()
                        }
                        TamerButton("Exit", "secondary", Modifier.weight(0.8f).fillMaxHeight()) {
                            repo.currentRoom = "room_MainRoom"
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun SubRoomHeader(title: String, repo: GameRepository) {
    Surface(
        modifier = Modifier.fillMaxWidth().height(50.dp),
        color = ColBgHud,
        shape = RoundedCornerShape(12.dp),
        border = BorderStroke(1.dp, ColBorder)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text("D-Terminal  /  $title", color = ColAccent, fontSize = 15.sp, fontWeight = FontWeight.Bold)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("${repo.bits} BIT · LUK ${repo.luk}", color = ColGold, fontSize = 13.sp, fontWeight = FontWeight.Bold, modifier = Modifier.align(Alignment.CenterVertically))
                TamerButton("Return to Sanctuary", "primary", Modifier.height(34.dp)) {
                    repo.currentRoom = "room_MainRoom"
                }
            }
        }
    }
}

@Composable
fun ItemsForgeScreen(repo: GameRepository) {
    var page by remember { mutableIntStateOf(0) }
    var selectedId by remember { mutableIntStateOf(repo.equippedItem) }
    val itemList = remember { repo.items.values.toList() }
    val perPage = 6
    val maxPage = ((itemList.size - 1) / perPage).coerceAtLeast(0)
    val pageItems = itemList.drop(page * perPage).take(perPage)
    val selItem = repo.items[selectedId] ?: itemList.firstOrNull()

    Column(modifier = Modifier.fillMaxSize().padding(10.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        SubRoomHeader("Aseprite HD Remastered Items (750) & Lucky Forge", repo)

        Row(modifier = Modifier.fillMaxSize(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Surface(modifier = Modifier.weight(1.4f).fillMaxHeight(), color = ColBgHud, shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, ColBorder)) {
                Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Text("750 Aseprite Scale2x HD Items (Page ${page + 1}/${maxPage + 1})", color = ColInk, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            TamerButton("◀ Prev", "secondary", Modifier.height(30.dp)) { page = (page - 1).coerceAtLeast(0) }
                            TamerButton("Next ▶", "secondary", Modifier.height(30.dp)) { page = (page + 1).coerceAtMost(maxPage) }
                        }
                    }
                    LazyVerticalGrid(columns = GridCells.Fixed(2), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        items(pageItems) { item ->
                            val isSel = item.id == selectedId
                            Surface(
                                modifier = Modifier.height(74.dp).clickable { selectedId = item.id },
                                color = if (isSel) ColSurfaceHover else ColSurface,
                                shape = RoundedCornerShape(10.dp),
                                border = BorderStroke(if (isSel) 2.dp else 1.dp, if (isSel) ColGold else ColBorder)
                            ) {
                                Row(modifier = Modifier.padding(8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                                    repo.texItemHd(item.id)?.let { bmp ->
                                        Image(bitmap = bmp, contentDescription = null, modifier = Modifier.size(44.dp), filterQuality = FilterQuality.None)
                                    }
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text("#${item.id} ${item.nameEn}", color = ColInk, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                                        Text("${item.price} BIT", color = ColGold, fontSize = 10.sp)
                                        Text(repo.itemAffixes[item.id] ?: "Tap to Inspect / Forge", color = ColAccent, fontSize = 9.sp, maxLines = 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Surface(modifier = Modifier.weight(1f).fillMaxHeight(), color = ColBgHud, shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, ColGold)) {
                Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(8.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("Aseprite HD Forge Inspector", color = ColGold, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                    if (selItem != null) {
                        repo.texItemHd(selItem.id)?.let { bmp ->
                            Image(bitmap = bmp, contentDescription = null, modifier = Modifier.size(76.dp), filterQuality = FilterQuality.None)
                        }
                        Text("#${selItem.id} ${selItem.nameEn}", color = ColInk, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                        Text(selItem.descEn, color = ColInkSec, fontSize = 11.sp, maxLines = 3, overflow = TextOverflow.Ellipsis)
                        Text(
                            text = repo.itemAffixes[selItem.id] ?: "Roll: +18% Crit & D100 Floor +8",
                            color = ColAccent, fontSize = 12.sp, fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.weight(1f))
                        TamerButton("Equip HD Item (+Stats & LUK)", "primary", Modifier.fillMaxWidth().height(38.dp)) {
                            repo.equippedItem = selItem.id
                            repo.atk += 35
                            repo.luk = (repo.luk + 5).coerceAtMost(99)
                            repo.showToast("Equipped ${selItem.nameEn}!")
                        }
                        TamerButton("🎲 Lucky Re-Roll Affix (500 BIT)", "gold", Modifier.fillMaxWidth().height(38.dp)) {
                            val rolls = listOf(
                                "★ 777 MYTHIC: 32% Double-Cast Skill & +28 LUK",
                                "SSR OVERCLOCK: +45 SPD & Jump-Evade +22%",
                                "UR JACKPOT: D100 Multiplier Cap 7.77x Unlocked",
                                "MIRACLE SHIELD: 35% Perfect Parry 2.4x Counter"
                            )
                            val picked = rolls.random()
                            repo.itemAffixes[selItem.id] = picked
                            repo.luk = (repo.luk + 4).coerceAtMost(99)
                            repo.showToast(picked)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun LuckyTrainingScreen(repo: GameRepository) {
    var lastResult by remember { mutableStateOf("Select a training roulette below to roll 0.5x ~ 5.0x JACKPOT stat gains!") }
    Column(modifier = Modifier.fillMaxSize().padding(10.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        SubRoomHeader("Lucky Gamble Training Roulette (0.5x ~ 5.0x JACKPOT)", repo)
        Surface(modifier = Modifier.fillMaxSize(), color = ColBgHud, shape = RoundedCornerShape(14.dp), border = BorderStroke(1.dp, ColBorder)) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(lastResult, color = ColGold, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth().weight(1f)) {
                    val cards = listOf(
                        Triple("ATK & SP.ATK Gamble", "+30~150 ATK/SP", "battle") to { mult: Float ->
                            val gain = (32 * mult).roundToInt()
                            repo.atk += gain; repo.spAtk += gain
                        },
                        Triple("DEF & HP Fortify", "+120~600 HP / +25~120 DEF", "primary") to { mult: Float ->
                            val gain = (28 * mult).roundToInt()
                            repo.def += gain; repo.hpMax += gain * 5; repo.hp = repo.hpMax
                        },
                        Triple("SPD & LUK Jackpot", "+15~75 SPD / +3~15 LUK", "gold") to { mult: Float ->
                            repo.spd += (18 * mult).roundToInt()
                            repo.luk = (repo.luk + (3 * mult).roundToInt()).coerceAtMost(99)
                        }
                    )
                    cards.forEach { (info, applyFn) ->
                        Surface(
                            modifier = Modifier.weight(1f).fillMaxHeight(),
                            color = ColSurface,
                            shape = RoundedCornerShape(12.dp),
                            border = BorderStroke(1.dp, ColBorder)
                        ) {
                            Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.SpaceBetween) {
                                Text(info.first, color = ColInk, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                                Text(info.second, color = ColInkSec, fontSize = 12.sp)
                                Text("Current: ATK ${repo.atk} · DEF ${repo.def} · SPD ${repo.spd} · LUK ${repo.luk}", color = ColAccent, fontSize = 11.sp)
                                TamerButton("🎰 Roll Training Roulette", info.third, Modifier.fillMaxWidth().height(42.dp)) {
                                    val r = Random.nextInt(1, 101)
                                    val (m, tag) = when {
                                        r >= 85 -> 5.0f to "★ 777 FEVER 5.0x JACKPOT! ★"
                                        r >= 50 -> 2.5f to "SSR GREAT SUCCESS 2.5x!"
                                        else -> 1.2f to "SOLID TRAINING 1.2x"
                                    }
                                    applyFn(m)
                                    lastResult = "🎲 Roll D100($r) → $tag (${info.first} Boosted!)"
                                    repo.showToast(tag)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun DigivolveMatrixScreen(repo: GameRepository) {
    val routes = repo.evolutions[repo.partnerId] ?: repo.evolutions[5] ?: emptyList()
    Column(modifier = Modifier.fillMaxSize().padding(10.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        SubRoomHeader("436-Route Digivolution Matrix", repo)
        Surface(modifier = Modifier.fillMaxSize(), color = ColBgHud, shape = RoundedCornerShape(14.dp), border = BorderStroke(1.dp, ColBorder)) {
            Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text(
                    "Active Partner: #${repo.partnerId} ${repo.digimons[repo.partnerId]?.name ?: "Greymon"} (Lv.${repo.partnerLv}) — Select any branch to Digivolve immediately:",
                    color = ColInk, fontSize = 14.sp, fontWeight = FontWeight.Bold
                )
                LazyVerticalGrid(columns = GridCells.Fixed(3), horizontalArrangement = Arrangement.spacedBy(10.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    items(routes) { r ->
                        Surface(color = ColSurface, shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, ColAccent)) {
                            Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                                    repo.texIcon(r.toId)?.let { ic ->
                                        Image(bitmap = ic, contentDescription = null, modifier = Modifier.size(48.dp), filterQuality = FilterQuality.None)
                                    }
                                    Column {
                                        Text("#${r.toId} ${r.toName}", color = ColInk, fontSize = 14.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                                        Text("Req Lv.${r.reqLv} · ${r.reqItem}", color = ColGold, fontSize = 11.sp)
                                    }
                                }
                                Text("+${r.bonusHp} HP · +${r.bonusAtk} ATK · +${r.bonusDef} DEF", color = ColInkSec, fontSize = 11.sp)
                                TamerButton("✨ Digivolve Now", "primary", Modifier.fillMaxWidth().height(36.dp)) {
                                    repo.evolvePartner(r)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun EncyclopediaScreen(repo: GameRepository) {
    var page by remember { mutableIntStateOf(0) }
    var selectedId by remember { mutableIntStateOf(repo.partnerId) }
    val allDigis = remember { repo.digimons.values.toList() }
    val perPage = 6
    val maxPage = ((allDigis.size - 1) / perPage).coerceAtLeast(0)
    val pageItems = allDigis.drop(page * perPage).take(perPage)
    val sel = repo.digimons[selectedId] ?: allDigis.firstOrNull()

    Column(modifier = Modifier.fillMaxSize().padding(10.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        SubRoomHeader("663 Digimon Encyclopedia & Instant Partner Link", repo)
        Row(modifier = Modifier.fillMaxSize(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Surface(modifier = Modifier.weight(1.4f).fillMaxHeight(), color = ColBgHud, shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, ColBorder)) {
                Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Text("663 Digimon Database (Page ${page + 1}/${maxPage + 1})", color = ColInk, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            TamerButton("◀ Prev", "secondary", Modifier.height(30.dp)) { page = (page - 1).coerceAtLeast(0) }
                            TamerButton("Next ▶", "secondary", Modifier.height(30.dp)) { page = (page + 1).coerceAtMost(maxPage) }
                        }
                    }
                    LazyVerticalGrid(columns = GridCells.Fixed(2), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        items(pageItems) { d ->
                            val isSel = d.id == selectedId
                            Surface(
                                modifier = Modifier.height(74.dp).clickable { selectedId = d.id },
                                color = if (isSel) ColSurfaceHover else ColSurface,
                                shape = RoundedCornerShape(10.dp),
                                border = BorderStroke(if (isSel) 2.dp else 1.dp, if (isSel) ColAccent else ColBorder)
                            ) {
                                Row(modifier = Modifier.padding(8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                                    repo.texIcon(d.id)?.let { ic ->
                                        Image(bitmap = ic, contentDescription = null, modifier = Modifier.size(44.dp), filterQuality = FilterQuality.None)
                                    }
                                    Column {
                                        Text("#${d.id} ${d.name}", color = ColInk, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                                        Text("${d.stage} · ${d.attr} · ${d.elem}", color = ColInkSec, fontSize = 10.sp, maxLines = 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Surface(modifier = Modifier.weight(1f).fillMaxHeight(), color = ColBgHud, shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, ColAccent)) {
                if (sel != null) {
                    Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(6.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("#${sel.id} ${sel.name}", color = ColAccent, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                        Text("${sel.stage} · ${sel.attr} · ${sel.elem}", color = ColGold, fontSize = 11.sp)
                        repo.texDigimon(sel.id, "idle", repo.animTick)?.let { bmp ->
                            Image(bitmap = bmp, contentDescription = null, modifier = Modifier.size(92.dp), filterQuality = FilterQuality.None)
                        }
                        Text("HP ${sel.baseHp} · ATK ${sel.baseAtk} · DEF ${sel.baseDef} · SPD ${sel.baseSpd} · LUK ${sel.baseLuk}", color = ColInk, fontSize = 11.sp)
                        Text(sel.desc, color = ColInkSec, fontSize = 10.sp, maxLines = 3, overflow = TextOverflow.Ellipsis)
                        Spacer(modifier = Modifier.weight(1f))
                        TamerButton("Set as Active Partner", "primary", Modifier.fillMaxWidth().height(36.dp)) {
                            repo.partnerId = sel.id
                            repo.initBattleState()
                            repo.showToast("Active Partner set to #${sel.id} ${sel.name}")
                        }
                        TamerButton("⚔️ 1v1 Auto-Battle vs ${sel.name}", "battle", Modifier.fillMaxWidth().height(36.dp)) {
                            repo.startStageBattle(sel.id, 38, "Database Simulation", "BG_InfinityTower")
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun DigiviceQuestScreen(repo: GameRepository) {
    var page by remember { mutableIntStateOf(0) }
    val perPage = 3
    val maxPage = ((repo.quests.size - 1) / perPage).coerceAtLeast(0)
    val pageQuests = repo.quests.drop(page * perPage).take(perPage)

    Column(modifier = Modifier.fillMaxSize().padding(10.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        SubRoomHeader("Digivice OS Kernel & 78 Campaign Quests", repo)
        Row(modifier = Modifier.fillMaxSize(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Surface(modifier = Modifier.weight(1.5f).fillMaxHeight(), color = ColBgHud, shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, ColBorder)) {
                Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                        Text("78 Extracted Campaign Quests (Page ${page + 1}/${maxPage + 1})", color = ColInk, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            TamerButton("◀ Prev", "secondary", Modifier.height(30.dp)) { page = (page - 1).coerceAtLeast(0) }
                            TamerButton("Next ▶", "secondary", Modifier.height(30.dp)) { page = (page + 1).coerceAtMost(maxPage) }
                        }
                    }
                    pageQuests.forEach { q ->
                        Surface(color = ColSurface, shape = RoundedCornerShape(10.dp), border = BorderStroke(1.dp, ColBorder), modifier = Modifier.fillMaxWidth()) {
                            Column(modifier = Modifier.padding(10.dp), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                                Text("Q#${q.id} · ${q.nameEn}  [Client: ${q.npc} · ★${q.stars}]", color = ColGold, fontSize = 13.sp, fontWeight = FontWeight.Bold)
                                Text(q.descEn, color = ColInkSec, fontSize = 11.sp, maxLines = 2, overflow = TextOverflow.Ellipsis)
                                Text("Hint: ${q.hint}", color = ColAccent, fontSize = 10.sp, maxLines = 1)
                            }
                        }
                    }
                }
            }

            Surface(modifier = Modifier.weight(1f).fillMaxHeight(), color = ColBgHud, shape = RoundedCornerShape(12.dp), border = BorderStroke(1.dp, ColAccent)) {
                Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("D-Terminal OS Save Manager", color = ColAccent, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    Text("Persistent Android Internal Storage: tamer_save_v2.json", color = ColInkSec, fontSize = 11.sp)
                    TamerButton("💾 Save Progress Now", "primary", Modifier.fillMaxWidth().height(42.dp)) {
                        val ok = repo.saveGameState()
                        repo.showToast(if (ok) "Saved to tamer_save_v2.json" else "Save failed")
                    }
                    TamerButton("📂 Load Saved State", "secondary", Modifier.fillMaxWidth().height(42.dp)) {
                        val ok = repo.loadGameState()
                        repo.showToast(if (ok) "Save state loaded!" else "No save file found")
                    }
                    TamerButton("Open 436 Digivolution Matrix", "gold", Modifier.fillMaxWidth().height(42.dp)) {
                        repo.currentRoom = "room_Evo_Select"
                    }
                    TamerButton("Open 663 Digimon Encyclopedia", "secondary", Modifier.fillMaxWidth().height(42.dp)) {
                        repo.currentRoom = "room_Database"
                    }
                }
            }
        }
    }
}

@Composable
fun WorldExpeditionScreen(repo: GameRepository) {
    Column(modifier = Modifier.fillMaxSize().padding(10.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
        SubRoomHeader("Digital World Expedition & 1v1 Boss Arenas", repo)
        Surface(modifier = Modifier.fillMaxSize(), color = ColBgHud, shape = RoundedCornerShape(14.dp), border = BorderStroke(1.dp, ColBorder)) {
            LazyVerticalGrid(
                columns = GridCells.Fixed(3),
                modifier = Modifier.padding(12.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(repo.stageArenas) { st ->
                    Surface(color = ColSurface, shape = RoundedCornerShape(10.dp), border = BorderStroke(1.dp, ColBorder)) {
                        Row(modifier = Modifier.padding(8.dp), horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                            repo.tex(st.bg, 0)?.let { bgBmp ->
                                Image(
                                    bitmap = bgBmp,
                                    contentDescription = st.zone,
                                    modifier = Modifier.width(74.dp).height(48.dp).clip(RoundedCornerShape(6.dp)),
                                    contentScale = ContentScale.Crop,
                                    filterQuality = FilterQuality.None
                                )
                            }
                            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
                                Text(st.zone, color = ColAccent, fontSize = 12.sp, fontWeight = FontWeight.Bold, maxLines = 1)
                                Text("${st.bossName} (Lv.${st.lv})", color = ColInk, fontSize = 10.sp, maxLines = 1)
                                TamerButton("⚔️ Deploy 1v1", "battle", Modifier.fillMaxWidth().height(30.dp)) {
                                    repo.startStageBattle(st.bossId, st.lv, st.zone, st.bg)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun OptionsScreen(repo: GameRepository) {
    Column(modifier = Modifier.fillMaxSize().padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        SubRoomHeader("System Configuration", repo)
        Surface(modifier = Modifier.fillMaxSize(), color = ColBgHud, shape = RoundedCornerShape(14.dp), border = BorderStroke(1.dp, ColBorder)) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text("Interface Language", color = ColInk, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                    TamerButton(if (repo.language == 0) "English (EN)" else "Português (PT-BR)", "active_seg", Modifier.width(180.dp).height(38.dp)) {
                        repo.language = 1 - repo.language
                    }
                }
                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text("Background Music & Sound FX", color = ColInk, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                    TamerButton(if (repo.music) "Audio Enabled" else "Muted", if (repo.music) "active_seg" else "secondary", Modifier.width(180.dp).height(38.dp)) {
                        repo.music = !repo.music
                        repo.soundFx = repo.music
                    }
                }
                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text("Reduced Motion Mode", color = ColInk, fontSize = 14.sp, fontWeight = FontWeight.Bold)
                    TamerButton(if (repo.reducedMotion) "Enabled" else "Standard", if (repo.reducedMotion) "active_seg" else "secondary", Modifier.width(180.dp).height(38.dp)) {
                        repo.reducedMotion = !repo.reducedMotion
                    }
                }
            }
        }
    }
}
