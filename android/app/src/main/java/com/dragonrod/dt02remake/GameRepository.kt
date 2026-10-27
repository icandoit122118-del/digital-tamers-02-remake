package com.dragonrod.dt02remake

import android.content.Context
import android.graphics.BitmapFactory
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableDoubleStateOf
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import kotlin.math.abs
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.random.Random

data class DigimonEntry(
    val id: Int,
    val name: String,
    val stage: String,
    val attr: String,
    val elem: String,
    val baseHp: Int,
    val baseAtk: Int,
    val baseDef: Int,
    val baseSpAtk: Int,
    val baseSpd: Int,
    val baseLuk: Int,
    val desc: String
)

data class EvoRoute(
    val fromId: Int,
    val toId: Int,
    val toName: String,
    val reqLv: Int,
    val reqItem: String,
    val bonusHp: Int,
    val bonusAtk: Int,
    val bonusDef: Int,
    val bonusSp: Int
)

data class ItemEntry(
    val id: Int,
    val nameEn: String,
    val namePt: String,
    val price: Int,
    val descEn: String,
    val descPt: String
)

data class QuestEntry(
    val id: Int,
    val nameEn: String,
    val namePt: String,
    val npc: String,
    val stars: Int,
    val descEn: String,
    val descPt: String,
    val hint: String
)

data class SanctuaryProp(val spr: String, val x: Float, val y: Float)

data class SanctuaryTheme(
    val name: String,
    val bg: String,
    val layer2: Int,
    val layer1: Int,
    val floor: Int,
    val props: List<SanctuaryProp>
)

data class StageArena(
    val zone: String,
    val bg: String,
    val bossId: Int,
    val bossName: String,
    val lv: Int,
    val reward: String
)

data class SkillSlot(
    val name: String,
    val tag: String,
    val cdMax: Float,
    val power: Float,
    val spGain: Float,
    var cd: Float = 0.5f,
    var lastRoll: String = "READY",
    var lastMult: Float = 1.0f
)

data class Projectile(
    val fromPlayer: Boolean,
    var x: Float,
    var y: Float,
    val vx: Float,
    val dmg: Int,
    val tier: String,
    val mult: Float,
    val colHex: Long,
    val isUlt: Boolean
)

data class FloatingPopup(
    var x: Float,
    var y: Float,
    val txt: String,
    val colHex: Long,
    var ttl: Float = 1.25f
)

class GameRepository(private val context: Context) {
    private val bmpCache = HashMap<String, ImageBitmap?>()
    val digimons = LinkedHashMap<Int, DigimonEntry>()
    val evolutions = HashMap<Int, MutableList<EvoRoute>>()
    val items = LinkedHashMap<Int, ItemEntry>()
    val quests = ArrayList<QuestEntry>()
    val spriteFrames = HashMap<String, Int>()
    val spriteOrigins = HashMap<String, Pair<Float, Float>>()

    var currentRoom by mutableStateOf("room_MainMenu")
    var language by mutableIntStateOf(0)
    var soundFx by mutableStateOf(true)
    var music by mutableStateOf(true)
    var digimonVoice by mutableStateOf(true)
    var reducedMotion by mutableStateOf(false)
    var dataMode by mutableStateOf("demo")
    var zoom2x by mutableStateOf(false)

    var partnerId by mutableIntStateOf(5)
    var partnerLv by mutableIntStateOf(28)
    var bits by mutableIntStateOf(24500)
    var hp by mutableIntStateOf(2200)
    var hpMax by mutableIntStateOf(2200)
    var en by mutableIntStateOf(88)
    var xp by mutableIntStateOf(74)
    var atk by mutableIntStateOf(384)
    var def by mutableIntStateOf(310)
    var spAtk by mutableIntStateOf(340)
    var spd by mutableIntStateOf(265)
    var luk by mutableIntStateOf(48)
    var equippedItem by mutableIntStateOf(10)

    var sanctuaryThemeIdx by mutableIntStateOf(0)
    var enemyId by mutableIntStateOf(151)
    var enemyLv by mutableIntStateOf(48)
    var battleZone by mutableStateOf("Magma Mountain")
    var battleBg by mutableStateOf("bg_Btl_Magma_Mountain")

    var toastMessage by mutableStateOf("")
    var toastTimer by mutableFloatStateOf(0f)

    // Sanctuary walking state
    var sanctuaryX by mutableFloatStateOf(269f)
    var sanctuaryDir by mutableFloatStateOf(1f)
    var animTick by mutableIntStateOf(0)

    // 1v1 Single-Match Auto-Chess Battle State
    var btlAutoSkill by mutableStateOf(true)
    var btlSpeed2x by mutableStateOf(true)
    var btlTactic by mutableStateOf("gamble")
    var btlFinished by mutableStateOf(false)
    var btlWin by mutableStateOf(true)
    var btlResultBanner by mutableStateOf("")

    var pX by mutableFloatStateOf(124f)
    var pY by mutableFloatStateOf(216f)
    var pVx by mutableFloatStateOf(0f)
    var pVy by mutableFloatStateOf(0f)
    var pAct by mutableStateOf("idle")
    var pAnimTimer by mutableIntStateOf(0)
    var pAiState by mutableStateOf("APPROACH")
    var pHp by mutableIntStateOf(2200)
    var pHpMax by mutableIntStateOf(2200)
    var pSp by mutableFloatStateOf(45f)
    var pDodges by mutableIntStateOf(0)
    var pParries by mutableIntStateOf(0)
    var jackpotCount by mutableIntStateOf(0)
    var shieldActive by mutableStateOf(false)

    var eX by mutableFloatStateOf(414f)
    var eY by mutableFloatStateOf(216f)
    var eVx by mutableFloatStateOf(0f)
    var eVy by mutableFloatStateOf(0f)
    var eAct by mutableStateOf("idle")
    var eAnimTimer by mutableIntStateOf(0)
    var eAiState by mutableStateOf("STALKING")
    var eHp by mutableIntStateOf(5200)
    var eHpMax by mutableIntStateOf(5200)
    var eSp by mutableFloatStateOf(30f)
    var eAtk by mutableIntStateOf(680)
    var eDef by mutableIntStateOf(520)
    var eSpd by mutableIntStateOf(310)
    var eLuk by mutableIntStateOf(52)

    var slotReels by mutableStateOf("7 · 7 · 7")
    var slotTitle by mutableStateOf("LUCK OVERDRIVE")
    var slotTimer by mutableFloatStateOf(2.5f)
    var feverTimer by mutableFloatStateOf(0f)
    var lastDice by mutableIntStateOf(97)
    var lastTier by mutableStateOf("★ 777 JACKPOT ★")
    var lastMult by mutableDoubleStateOf(7.77)
    var lastLog by mutableStateOf("[AI COMBAT] Autonomous Jump/Evade & Skill RNG Ready!")

    val skills = mutableStateListOf(
        SkillSlot("Nova Blast", "Ranged · 125% SP.ATK", 2.4f, 1.25f, 24f, 0.3f, "D100:84 → 4.0x SSR", 4.0f),
        SkillSlot("Aerial Horn Dive", "Jump Strike · 155% ATK", 3.2f, 1.55f, 28f, 0.7f, "D100:68 → 2.2x CRIT", 2.2f),
        SkillSlot("Miracle Guard", "Parry & Counter · LUK%", 4.2f, 1.20f, 25f, 1.2f, "COUNTER READY", 2.2f),
        SkillSlot("Mega Burst", "Ultimate · 260% × RNG", 1.0f, 2.60f, 0f, 0.0f, "SP 100% AUTO FIRE", 7.77f)
    )
    val projectiles = mutableStateListOf<Projectile>()
    val popups = mutableStateListOf<FloatingPopup>()

    // Item Lucky Forge Roll Map
    val itemAffixes = mutableStateMapOf<Int, String>()

    val sanctuaryThemes = listOf(
        SanctuaryTheme(
            "File Island Coast", "BG26", 1, 5, 3,
            listOf(
                SanctuaryProp("spr_DecoTree03", 76f, 220f),
                SanctuaryProp("spr_DecoStatue03", 438f, 220f),
                SanctuaryProp("spr_DecoMeatField", 200f, 222f)
            )
        ),
        SanctuaryTheme(
            "Toy Town Sanctuary", "BG28", 2, 2, 0,
            listOf(
                SanctuaryProp("spr_DecoFossil01", 92f, 220f),
                SanctuaryProp("spr_DecoStatue02", 442f, 220f),
                SanctuaryProp("spr_DecoMeatField", 212f, 222f)
            )
        ),
        SanctuaryTheme(
            "Starlight Canyon", "BG19", 1, 1, 5,
            listOf(
                SanctuaryProp("spr_Deco04", 98f, 220f),
                SanctuaryProp("spr_DecoPlant20", 444f, 220f),
                SanctuaryProp("spr_DecoStatue03", 368f, 220f)
            )
        ),
        SanctuaryTheme(
            "Royal Kernel Hall", "BG21", -1, 4, 1,
            listOf(
                SanctuaryProp("spr_DecoStatue03", 88f, 220f),
                SanctuaryProp("spr_DecoFossil01", 440f, 220f)
            )
        ),
        SanctuaryTheme(
            "Deep Savers Reef", "BG24", -1, 1, 4,
            listOf(
                SanctuaryProp("spr_DecoPlant18", 86f, 220f),
                SanctuaryProp("spr_DecoStatue02", 438f, 220f)
            )
        ),
        SanctuaryTheme(
            "Ancient Jungle", "BG16", 1, 5, 2,
            listOf(
                SanctuaryProp("spr_DecoTree03", 82f, 220f),
                SanctuaryProp("spr_DecoMeatField", 418f, 222f)
            )
        )
    )

    val stageArenas = listOf(
        StageArena("Village of Beginnings", "bg_Btl_Village_Beginnings", 3, "Agumon (Leader)", 10, "+1,500 BIT"),
        StageArena("Dina Plains", "bg_Btl_Dina_Plains", 35, "GeoGreymon", 20, "+2,400 BIT"),
        StageArena("Boot Jungle", "bg_Btl_Boot_Jungle", 85, "MetalGreymon", 28, "+3,200 BIT"),
        StageArena("Chrome Mines", "bg_Btl_Chrome_Mines", 87, "SkullGreymon", 34, "+4,500 BIT"),
        StageArena("Server City Arena", "bg_Btl_ServerCity_Ruins", 89, "RizeGreymon", 40, "+5,500 BIT"),
        StageArena("Magma Mountain", "bg_Btl_Magma_Mountain", 151, "WarGreymon", 48, "+7,200 BIT"),
        StageArena("Dark Area Abyss", "bg_Btl_Dark_Area", 152, "BlackWarGreymon", 55, "+9,000 BIT"),
        StageArena("Chaos Tower Top", "bg_Btl_D_Dungeon01", 155, "ShineGreymon", 64, "+12,000 BIT"),
        StageArena("Kernel Zone Final", "BG_InfinityTower", 347, "VictoryGreymon", 75, "+20,000 BIT")
    )

    init {
        loadDatabase()
        initBattleState()
    }

    private fun loadDatabase() {
        try {
            val sprText = context.assets.open("data/sprites.json").bufferedReader().use { it.readText() }
            val sprArr = JSONArray(sprText)
            for (i in 0 until sprArr.length()) {
                val o = sprArr.getJSONObject(i)
                val name = o.getString("name")
                spriteFrames[name] = o.optInt("frames", 1)
                spriteOrigins[name] = Pair(o.optDouble("originX", 0.0).toFloat(), o.optDouble("originY", 0.0).toFloat())
            }
        } catch (_: Exception) {
        }

        try {
            val dbText = context.assets.open("data/full_db.json").bufferedReader().use { it.readText() }
            val root = JSONObject(dbText)

            val dObj = root.getJSONObject("digimons")
            val dKeys = dObj.keys().asSequence().toList().sortedBy { it.toIntOrNull() ?: 9999 }
            for (k in dKeys) {
                val o = dObj.getJSONObject(k)
                val id = o.optInt("id", k.toIntOrNull() ?: 1)
                digimons[id] = DigimonEntry(
                    id = id,
                    name = o.optString("name", "Digimon #$id"),
                    stage = o.optString("stage", "Champion"),
                    attr = o.optString("attr", "Vaccine"),
                    elem = o.optString("elem", "Fire"),
                    baseHp = o.optInt("base_hp", 1800),
                    baseAtk = o.optInt("base_atk", 320),
                    baseDef = o.optInt("base_def", 260),
                    baseSpAtk = o.optInt("base_sp_atk", 300),
                    baseSpd = o.optInt("base_spd", 240),
                    baseLuk = o.optInt("base_luk", 45),
                    desc = o.optString("desc", "Digital World registered organism.")
                )
            }

            val eObj = root.getJSONObject("evolutions")
            val eKeys = eObj.keys()
            while (eKeys.hasNext()) {
                val k = eKeys.next()
                val fromId = k.toIntOrNull() ?: continue
                val arr = eObj.getJSONArray(k)
                val list = ArrayList<EvoRoute>()
                for (i in 0 until arr.length()) {
                    val r = arr.getJSONObject(i)
                    val toId = r.optInt("to_id", 5)
                    list.add(
                        EvoRoute(
                            fromId = fromId,
                            toId = toId,
                            toName = r.optString("to_name", digimons[toId]?.name ?: "Digimon #$toId"),
                            reqLv = r.optInt("req_lv", 18),
                            reqItem = r.optString("req_item", "Digi-Soul"),
                            bonusHp = r.optInt("bonus_hp", 600),
                            bonusAtk = r.optInt("bonus_atk", 95),
                            bonusDef = r.optInt("bonus_def", 80),
                            bonusSp = r.optInt("bonus_sp", 90)
                        )
                    )
                }
                evolutions[fromId] = list
            }

            val iObj = root.getJSONObject("items")
            val iKeys = iObj.keys().asSequence().toList().sortedBy { it.toIntOrNull() ?: 9999 }
            for (k in iKeys) {
                val o = iObj.getJSONObject(k)
                val id = o.optInt("id", k.toIntOrNull() ?: 0)
                items[id] = ItemEntry(
                    id = id,
                    nameEn = o.optString("name", "Item #$id"),
                    namePt = o.optString("name_pt", o.optString("name", "Item #$id")),
                    price = o.optInt("price", 500),
                    descEn = o.optString("desc", "Remastered Aseprite HD item."),
                    descPt = o.optString("desc_pt", o.optString("desc", "Item HD."))
                )
            }

            val qArr = root.getJSONArray("quests")
            for (i in 0 until qArr.length()) {
                val q = qArr.getJSONObject(i)
                quests.add(
                    QuestEntry(
                        id = q.optInt("id", i + 1),
                        nameEn = q.optString("name", "Campaign Quest #${i + 1}"),
                        namePt = q.optString("name_pt", q.optString("name", "Missão #${i + 1}")),
                        npc = q.optString("npc", "Gennai"),
                        stars = q.optInt("stars", 3),
                        descEn = q.optString("desc", "Complete expedition objective."),
                        descPt = q.optString("desc_pt", q.optString("desc", "Complete a missão.")),
                        hint = q.optString("hint", "Check Digital World Map.")
                    )
                )
            }
        } catch (_: Exception) {
        }
    }

    fun tex(spr: String, frame: Int = 0): ImageBitmap? {
        val key = "$spr:$frame"
        if (bmpCache.containsKey(key)) return bmpCache[key]
        val candidates = listOf(
            "sprites/bg_HD/${spr}_$frame.png",
            "sprites/$spr/${spr}_$frame.png",
            "sprites/$spr/${spr}_0.png"
        )
        for (path in candidates) {
            try {
                context.assets.open(path).use { stream ->
                    val bmp = BitmapFactory.decodeStream(stream)?.asImageBitmap()
                    if (bmp != null) {
                        bmpCache[key] = bmp
                        return bmp
                    }
                }
            } catch (_: Exception) {
            }
        }
        bmpCache[key] = null
        return null
    }

    fun texItemHd(itemId: Int): ImageBitmap? {
        val clamped = itemId.coerceIn(0, 749)
        val key = "item_hd:$clamped"
        if (bmpCache.containsKey(key)) return bmpCache[key]
        try {
            context.assets.open("sprites/spr_Items_HD/spr_Items_HD_$clamped.png").use { stream ->
                val bmp = BitmapFactory.decodeStream(stream)?.asImageBitmap()
                bmpCache[key] = bmp
                return bmp
            }
        } catch (_: Exception) {
        }
        return null
    }

    fun texIcon(digiId: Int): ImageBitmap? {
        return tex("spr_Icons", digiId.coerceIn(0, 720)) ?: tex("spr_Icons", 5)
    }

    fun texDigimon(digiId: Int, act: String, tick: Int): ImageBitmap? {
        val candidates = listOf("d${digiId}_$act", "d${digiId}_idle", "d85_$act", "d85_idle", "d5_idle")
        for (c in candidates) {
            val fCount = (spriteFrames[c] ?: 1).coerceAtLeast(1)
            val f = (tick / 3) % fCount
            val b = tex(c, f)
            if (b != null) return b
        }
        return null
    }

    fun showToast(msg: String) {
        toastMessage = msg
        toastTimer = 2.4f
    }

    fun initBattleState() {
        val pEntry = digimons[partnerId]
        val eEntry = digimons[enemyId]
        pHpMax = if (dataMode == "worst") 99999 else if (dataMode == "empty") 950 else hpMax
        pHp = pHpMax
        pSp = 45f
        pX = 124f
        pY = 216f
        pVx = 0f
        pVy = 0f
        pAct = "idle"
        pAnimTimer = 0
        pAiState = "APPROACH"
        pDodges = 0
        pParries = 0
        jackpotCount = 0
        shieldActive = false

        eHpMax = (eEntry?.baseHp ?: 2400) + enemyLv * 52
        eHp = eHpMax
        eSp = 30f
        eAtk = (eEntry?.baseAtk ?: 320) + enemyLv * 4
        eDef = (eEntry?.baseDef ?: 260) + enemyLv * 3
        eSpd = (eEntry?.baseSpd ?: 240) + enemyLv * 2
        eLuk = eEntry?.baseLuk ?: 45
        eX = 414f
        eY = 216f
        eVx = 0f
        eVy = 0f
        eAct = "idle"
        eAnimTimer = 0
        eAiState = "STALKING"

        btlFinished = false
        btlWin = true
        btlResultBanner = ""
        projectiles.clear()
        popups.clear()
        for (s in skills) {
            s.cd = 0.25f
        }
        lastLog = "[AI COMBAT] ${pEntry?.name ?: "Partner"} vs ${eEntry?.name ?: "Boss"} ($battleZone) — 1v1 Single Match!"
    }

    fun startStageBattle(bossId: Int, bossLv: Int, zone: String, bg: String) {
        enemyId = bossId
        enemyLv = bossLv
        battleZone = zone
        battleBg = bg
        initBattleState()
        currentRoom = "room_Battle"
    }

    fun evolvePartner(route: EvoRoute) {
        partnerId = route.toId
        partnerLv += 5
        hpMax += route.bonusHp
        hp = hpMax
        atk += route.bonusAtk
        def += route.bonusDef
        spAtk += route.bonusSp
        spd += 28
        luk = (luk + 8).coerceAtMost(99)
        initBattleState()
        showToast("★ DIGIVOLVED TO ${route.toName.uppercase()}! ★")
    }

    fun saveGameState(): Boolean {
        return try {
            val o = JSONObject()
            o.put("partnerId", partnerId)
            o.put("partnerLv", partnerLv)
            o.put("bits", bits)
            o.put("hpMax", hpMax)
            o.put("atk", atk)
            o.put("def", def)
            o.put("spAtk", spAtk)
            o.put("spd", spd)
            o.put("luk", luk)
            o.put("equippedItem", equippedItem)
            o.put("sanctuaryThemeIdx", sanctuaryThemeIdx)
            o.put("battleZone", battleZone)
            o.put("battleBg", battleBg)
            File(context.filesDir, "tamer_save_v2.json").writeText(o.toString(2))
            true
        } catch (_: Exception) {
            false
        }
    }

    fun loadGameState(): Boolean {
        return try {
            val f = File(context.filesDir, "tamer_save_v2.json")
            if (!f.exists()) return false
            val o = JSONObject(f.readText())
            partnerId = o.optInt("partnerId", partnerId)
            partnerLv = o.optInt("partnerLv", partnerLv)
            bits = o.optInt("bits", bits)
            hpMax = o.optInt("hpMax", hpMax)
            hp = hpMax
            atk = o.optInt("atk", atk)
            def = o.optInt("def", def)
            spAtk = o.optInt("spAtk", spAtk)
            spd = o.optInt("spd", spd)
            luk = o.optInt("luk", luk)
            equippedItem = o.optInt("equippedItem", equippedItem)
            sanctuaryThemeIdx = o.optInt("sanctuaryThemeIdx", sanctuaryThemeIdx)
            battleZone = o.optString("battleZone", battleZone)
            battleBg = o.optString("battleBg", battleBg)
            initBattleState()
            true
        } catch (_: Exception) {
            false
        }
    }

    fun tickFrame() {
        animTick += 1
        if (toastTimer > 0f) {
            toastTimer = max(0f, toastTimer - 1f / 30f)
        }

        if (currentRoom == "room_MainRoom") {
            if (dataMode != "empty") {
                sanctuaryX += sanctuaryDir * 1.1f
                if (sanctuaryX < 145f) {
                    sanctuaryX = 145f
                    sanctuaryDir = 1f
                } else if (sanctuaryX > 395f) {
                    sanctuaryX = 395f
                    sanctuaryDir = -1f
                }
            }
        } else if (currentRoom == "room_Battle") {
            tickBattleAutoChess()
        }
    }

    private fun tickBattleAutoChess() {
        val spdMult = if (btlSpeed2x) 2.0f else 1.0f
        val dt = (1f / 30f) * spdMult
        val groundY = 216f
        val grav = 0.85f

        if (btlFinished) {
            pAct = if (btlWin) "win" else "lose"
            eAct = if (btlWin) "lose" else "win"
            tickProjectilesAndPopups(dt)
            return
        }

        // Player Physics
        pX = (pX + pVx * spdMult).coerceIn(58f, 464f)
        if (pY < groundY || pVy < 0f) {
            pVy += grav * spdMult
            pY += pVy * spdMult
            if (pY >= groundY) {
                pY = groundY
                pVy = 0f
                if (pAnimTimer <= 0) {
                    pVx = 0f
                    pAct = "idle"
                }
            }
        }

        // Enemy Physics
        eX = (eX + eVx * spdMult).coerceIn(68f, 474f)
        if (eY < groundY || eVy < 0f) {
            eVy += grav * spdMult
            eY += eVy * spdMult
            if (eY >= groundY) {
                eY = groundY
                eVy = 0f
                if (eAnimTimer <= 0) {
                    eVx = 0f
                    eAct = "idle"
                }
            }
        }

        // Slot machine luck event
        slotTimer -= dt
        if (slotTimer <= 0f) {
            slotTimer = 4.2f
            val r = Random.nextInt(1, 101)
            when {
                r >= 78 -> {
                    slotReels = "7 · 7 · 7"
                    slotTitle = "JACKPOT FEVER (2x SPD & +25% CRIT)"
                    feverTimer = 4.0f
                    pSp = min(100f, pSp + 25f)
                }
                r >= 45 -> {
                    slotReels = "⚡ · ⚡ · ⚡"
                    slotTitle = "REFLEX SURGE (Jump Dodge +30%)"
                    pHp = min(pHpMax, pHp + (pHpMax * 0.08f).roundToInt())
                }
                else -> {
                    slotReels = "🎲 · 🎲 · 🎲"
                    slotTitle = "CHAOS MULTIPLIER (0.5x ~ 7.77x)"
                }
            }
        }
        if (feverTimer > 0f) feverTimer = max(0f, feverTimer - dt)

        // Skill cooldowns
        val cdRate = (1f + spd / 520f) * (if (feverTimer > 0f) 1.8f else 1f)
        for (sk in skills) {
            if (sk.cd > 0f) sk.cd = max(0f, sk.cd - dt * cdRate)
        }

        // Projectile Jump-Evade Check (Player & Enemy)
        for (proj in projectiles) {
            if (!proj.fromPlayer && pY >= groundY - 2f) {
                val dx = abs(proj.x - pX)
                if (dx in 22f..105f) {
                    val dodgeChance = (20 + (spd * 0.07f).toInt() + (luk * 0.35f).toInt() + if (btlTactic == "evasive") 24 else 0).coerceIn(15, 78)
                    if (Random.nextInt(1, 101) <= dodgeChance) {
                        pVy = -10.5f
                        pVx = if (eX > pX) -2.6f else 2.6f
                        pAct = "jump"
                        pAnimTimer = 14
                        pDodges += 1
                        pAiState = "JUMP EVADE!"
                        popups.add(FloatingPopup(pX, pY - 54f, "⚡ AI JUMP EVADE!", 0xFF38BDF8))
                        break
                    }
                }
            } else if (proj.fromPlayer && eY >= groundY - 2f) {
                val dx = abs(proj.x - eX)
                if (dx in 22f..96f) {
                    val eDodge = (14 + (eSpd * 0.05f).toInt() + (eLuk * 0.22f).toInt()).coerceIn(12, 55)
                    if (Random.nextInt(1, 101) <= eDodge) {
                        eVy = -9.8f
                        eVx = if (pX < eX) 2.2f else -2.2f
                        eAct = "jump"
                        eAnimTimer = 14
                        eAiState = "JUMP EVADE!"
                        popups.add(FloatingPopup(eX, eY - 54f, "💨 ENEMY JUMP DODGE!", 0xFFF5C451))
                        break
                    }
                }
            }
        }

        // Player Autonomous AI
        if (pAnimTimer > 0) {
            pAnimTimer -= ceil(spdMult).toInt()
        } else if (Random.nextFloat() < 0.28f) {
            val dist = abs(eX - pX)
            val dir = if (eX >= pX) 1f else -1f
            if (btlAutoSkill) {
                if (pSp >= 100f) {
                    castPlayerSkill(3, dir)
                    return
                }
                val readyIdx = (0..2).filter { skills[it].cd <= 0f }
                if (readyIdx.isNotEmpty() && Random.nextInt(1, 101) <= 78) {
                    castPlayerSkill(readyIdx.random(), dir)
                    return
                }
            }
            when {
                dist > 175f -> {
                    pVx = dir * 3.2f
                    pAct = "walk"
                    pAiState = "DASH IN"
                }
                dist < 82f -> {
                    pVx = -dir * 2.8f
                    if (pY >= groundY && Random.nextInt(1, 101) <= 45) pVy = -8.6f
                    pAct = "jump"
                    pAiState = "BACKSTEP"
                }
                else -> {
                    pVx = dir * 1.6f
                    pAct = "walk"
                    pAiState = "FOOTSIES"
                }
            }
        }

        // Enemy Autonomous AI
        if (eAnimTimer > 0) {
            eAnimTimer -= ceil(spdMult).toInt()
        } else if (Random.nextFloat() < 0.24f) {
            val dist = abs(pX - eX)
            val dir = if (pX < eX) -1f else 1f
            if (Random.nextInt(1, 101) <= 48) {
                // Enemy casts skill
                val dice = Random.nextInt(1, 101)
                val mult = when {
                    dice >= 93 -> 3.5f
                    dice >= 70 -> 1.8f
                    dice <= 18 -> 0.55f
                    else -> 1.05f
                }
                val tier = if (dice >= 93) "BOSS JACKPOT 3.5x" else if (dice >= 70) "BOSS CRIT 1.8x" else "ENEMY ATK"
                val rawDmg = max(35, ((eAtk * 1.15f - def * 0.42f) * mult).roundToInt())
                eAct = if (eSp >= 100f) "atkSP" else "atk01"
                if (eSp >= 100f) eSp = 0f else eSp = min(100f, eSp + 25f)
                eAnimTimer = 15
                eAiState = "BOSS SKILL!"
                projectiles.add(
                    Projectile(
                        fromPlayer = false,
                        x = eX + dir * 24f,
                        y = eY - 26f,
                        vx = dir * 6.8f,
                        dmg = rawDmg,
                        tier = tier,
                        mult = mult,
                        colHex = 0xFFFF6B4A,
                        isUlt = eAct == "atkSP"
                    )
                )
            } else if (dist > 165f) {
                eVx = dir * 2.6f
                eAct = "walk"
                eAiState = "PURSUING"
            } else {
                eVx = -dir * 2.0f
                if (eY >= groundY && Random.nextInt(1, 101) <= 35) eVy = -8.2f
                eAct = "jump"
                eAiState = "REPOSITION"
            }
        }

        tickProjectilesAndPopups(dt)
    }

    private fun castPlayerSkill(idx: Int, dir: Float) {
        val sk = skills[idx]
        sk.cd = sk.cdMax
        if (idx == 3) pSp = 0f else pSp = min(100f, pSp + sk.spGain)

        val luckBonus = (luk * 0.24f).roundToInt() + if (btlTactic == "gamble") 10 else 0
        val dice = (Random.nextInt(1, 101) + luckBonus).coerceIn(1, 100)
        val (mult, tier, col) = when {
            dice >= 88 -> {
                jackpotCount += 1
                Triple(7.77f, "★ 777 JACKPOT ★", 0xFFF5C451)
            }
            dice >= 70 -> Triple(4.00f, "SSR ULTRA CRIT", 0xFF00E5B0)
            dice >= 46 -> Triple(2.20f, "LUCKY CRIT", 0xFF38BDF8)
            dice <= 14 -> Triple(0.55f, "GRAZE MISS...", 0xFF9BB0C7)
            else -> Triple(1.15f, "NORMAL HIT", 0xFFF0F6FC)
        }

        lastDice = dice
        lastTier = tier
        lastMult = mult.toDouble()
        sk.lastRoll = "D100:$dice → ${mult}x ($tier)"
        sk.lastMult = mult

        if (idx == 2) {
            shieldActive = true
            pAct = "block"
            pAnimTimer = 14
            pAiState = "MIRACLE GUARD"
            popups.add(FloatingPopup(pX, pY - 48f, "🛡️ MIRACLE PARRY READY!", 0xFF38BDF8))
        } else if (idx == 1 && pY >= 214f) {
            pVy = -9.5f
            pVx = dir * 3.8f
            pAct = "jump"
            pAnimTimer = 16
            pAiState = "AERIAL DIVE!"
        } else {
            pAct = if (idx == 3) "atkSP" else "atk01"
            pAnimTimer = 15
            pAiState = "SKILL: ${sk.name}"
        }

        val statVal = if (idx == 0 || idx == 3) spAtk else atk
        val dmg = max(45, ((statVal * sk.power - eDef * 0.35f) * mult).roundToInt())
        projectiles.add(
            Projectile(
                fromPlayer = true,
                x = pX + dir * 24f,
                y = pY - 26f,
                vx = dir * 7.6f,
                dmg = dmg,
                tier = tier,
                mult = mult,
                colHex = col,
                isUlt = idx == 3
            )
        )
        lastLog = "[AUTO] ${sk.name} → D100($dice) $tier [${mult}x] · $dmg DMG!"
    }

    private fun tickProjectilesAndPopups(dt: Float) {
        val spdMult = if (btlSpeed2x) 2.0f else 1.0f
        val toRemove = ArrayList<Projectile>()
        for (p in projectiles) {
            p.x += p.vx * spdMult
            if (p.x < 10f || p.x > 528f) {
                toRemove.add(p)
                continue
            }
            if (p.fromPlayer) {
                val dx = abs(p.x - eX)
                val dy = abs(p.y - (eY - 24f))
                if (dx < 26f && dy < 32f) {
                    eHp = max(0, eHp - p.dmg)
                    eAct = "dmg"
                    eAnimTimer = 10
                    popups.add(FloatingPopup(eX, eY - 48f, "${p.tier} -${p.dmg}", p.colHex))
                    toRemove.add(p)
                    if (eHp <= 0) {
                        btlFinished = true
                        btlWin = true
                        val bonus = 3200 + jackpotCount * 1500
                        bits += bonus
                        btlResultBanner = "🏆 VICTORY! (+$bonus BIT · Jackpots: $jackpotCount)"
                        lastLog = btlResultBanner
                    }
                }
            } else {
                val dx = abs(p.x - pX)
                val dy = abs(p.y - (pY - 24f))
                if (dx < 26f && dy < 32f) {
                    toRemove.add(p)
                    val parry = shieldActive || Random.nextInt(1, 101) <= (12 + (luk * 0.28f).toInt()).coerceIn(12, 48)
                    if (parry) {
                        shieldActive = false
                        pParries += 1
                        val cDmg = (atk * 2.4f).roundToInt()
                        popups.add(FloatingPopup(pX, pY - 56f, "🛡️ PERFECT PARRY & 2.4x COUNTER!", 0xFF00E5B0))
                        eHp = max(0, eHp - cDmg)
                        if (eHp <= 0) {
                            btlFinished = true
                            btlWin = true
                            btlResultBanner = "🏆 VICTORY BY MIRACLE COUNTER!"
                        }
                    } else {
                        pHp = max(0, pHp - p.dmg)
                        pAct = "dmg"
                        pAnimTimer = 10
                        popups.add(FloatingPopup(pX, pY - 48f, "-${p.dmg} (${p.tier})", 0xFFFF6B4A))
                        if (pHp <= 0) {
                            btlFinished = true
                            btlWin = false
                            btlResultBanner = "💀 DEFEAT — Boss Overwhelmed Your Partner"
                            lastLog = btlResultBanner
                        }
                    }
                }
            }
        }
        projectiles.removeAll(toRemove)

        val expiredPopups = ArrayList<FloatingPopup>()
        for (pop in popups) {
            pop.ttl -= dt
            pop.y -= 18f * dt
            if (pop.ttl <= 0f) expiredPopups.add(pop)
        }
        popups.removeAll(expiredPopups)
    }

    fun runDiagnosticSelfTest(): String {
        val sb = StringBuilder()
        sb.append("DB[digimons=${digimons.size},evos=${evolutions.values.sumOf { it.size }},items=${items.size},quests=${quests.size}] | ")

        // 1. Sanctuary biome cycle test
        val oldTheme = sanctuaryThemes[sanctuaryThemeIdx].name
        sanctuaryThemeIdx = (sanctuaryThemeIdx + 1) % sanctuaryThemes.size
        val curTheme = sanctuaryThemes[sanctuaryThemeIdx]
        val bgBmp = tex(curTheme.bg, 0)
        sb.append("Sanctuary[$oldTheme->${curTheme.name},bgLoaded=${bgBmp != null}] | ")

        // 2. HD Item equip & Lucky Forge test
        equippedItem = 10
        itemAffixes[10] = "★777 JACKPOT (+45% ALL)"
        val itemBmp = texItemHd(10)
        sb.append("ItemHD[id=10,bmp=${itemBmp != null},affix=${itemAffixes[10]}] | ")

        // 3. Lucky Training test
        val oldAtk = atk
        atk += 48
        sb.append("Train[ATK:$oldAtk->$atk] | ")

        // 4. Digivolution test
        val routes = evolutions[partnerId] ?: emptyList()
        if (routes.isNotEmpty()) {
            evolvePartner(routes[0])
        }
        sb.append("Evo[partnerId=$partnerId,name=${digimons[partnerId]?.name}] | ")

        // 5. Save & Load persistence test
        val savedOk = saveGameState() && loadGameState()
        sb.append("SaveLoad[ok=$savedOk] | ")

        // 6. 1v1 Single-Match Auto-Chess Battle simulation test
        val stg = stageArenas[2]
        startStageBattle(stg.bossId, stg.lv, stg.zone, stg.bg)
        for (i in 0 until 60) {
            tickFrame()
        }
        sb.append("Battle1v1[room=$currentRoom,zone=$battleZone,pHp=$pHp/$pHpMax,eHp=$eHp/$eHpMax,lastDice=$lastDice,tier=$lastTier]")
        return sb.toString()
    }
}
