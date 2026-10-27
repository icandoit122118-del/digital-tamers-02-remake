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
    var en by mutableIntStateOf(100)
    var xp by mutableIntStateOf(74)
    var hunger by mutableIntStateOf(82)
    var friendship by mutableFloatStateOf(75f)
    var injury by mutableIntStateOf(0)
    var poopCount by mutableIntStateOf(0)
    var wins by mutableIntStateOf(18)
    var losses by mutableIntStateOf(2)
    var totalBattles by mutableIntStateOf(20)
    var tamerLv by mutableIntStateOf(12)
    var tamerXp by mutableIntStateOf(420)
    var tamerSp by mutableIntStateOf(5)
    var tamerSkills by mutableIntStateOf(3)
    var battleMode by mutableStateOf("world")
    var infinityFloor by mutableIntStateOf(1)
    var challengeRank by mutableIntStateOf(1)
    var adventureStage by mutableIntStateOf(1)
    var pAtrMod by mutableFloatStateOf(1.0f)
    var eAtrMod by mutableFloatStateOf(1.0f)
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

    // Original Real-Time Action Combat + Auto-Battle State (acao 1..12)
    var btlAutoSkill by mutableStateOf(true)
    var btlSpeed2x by mutableStateOf(true)
    var btlTactic by mutableStateOf("balanced")
    var btlFinished by mutableStateOf(false)
    var btlWin by mutableStateOf(true)
    var btlResultBanner by mutableStateOf("")

    var pAcao by mutableIntStateOf(1)
    var pX by mutableFloatStateOf(124f)
    var pY by mutableFloatStateOf(216f)
    var pVx by mutableFloatStateOf(0f)
    var pVy by mutableFloatStateOf(0f)
    var pAct by mutableStateOf("idle")
    var pAnimTimer by mutableIntStateOf(0)
    var pAiState by mutableStateOf("IDLE (acao=1)")
    var pHp by mutableIntStateOf(2200)
    var pHpMax by mutableIntStateOf(2200)
    var pSp by mutableFloatStateOf(45f)
    var pBlock by mutableFloatStateOf(100f)
    var pCombo by mutableIntStateOf(0)
    var pDodges by mutableIntStateOf(0)
    var pParries by mutableIntStateOf(0)
    var jackpotCount by mutableIntStateOf(0)
    var shieldActive by mutableStateOf(false)

    var eAcao by mutableIntStateOf(1)
    var eX by mutableFloatStateOf(414f)
    var eY by mutableFloatStateOf(216f)
    var eVx by mutableFloatStateOf(0f)
    var eVy by mutableFloatStateOf(0f)
    var eAct by mutableStateOf("idle")
    var eAnimTimer by mutableIntStateOf(0)
    var eAiState by mutableStateOf("IDLE (acao=1)")
    var eHp by mutableIntStateOf(5200)
    var eHpMax by mutableIntStateOf(5200)
    var eSp by mutableFloatStateOf(30f)
    var eCombo by mutableIntStateOf(0)
    var eAtk by mutableIntStateOf(680)
    var eDef by mutableIntStateOf(520)
    var eSpd by mutableIntStateOf(310)
    var eLuk by mutableIntStateOf(52)

    var slotReels by mutableStateOf("AUTO BATTLE")
    var slotTitle by mutableStateOf("ORIGINAL COMBAT")
    var slotTimer by mutableFloatStateOf(0f)
    var feverTimer by mutableFloatStateOf(0f)
    var lastDice by mutableIntStateOf(0)
    var lastTier by mutableStateOf("READY")
    var lastMult by mutableDoubleStateOf(1.0)
    var lastLog by mutableStateOf("[AUTO BATTLE] Original Real-Time Action Combat Ready!")

    val skills = mutableStateListOf(
        SkillSlot("Melee Strike", "acao=7 · Physical ATK", 1.4f, 1.15f, 18f, 0.2f, "READY (ATK)", 1.0f),
        SkillSlot("Ranged Sp.Atk", "acao=8 · Elemental SP.ATK", 2.0f, 1.25f, 22f, 0.4f, "READY (SP.ATK)", 1.0f),
        SkillSlot("Guard / Jump", "acao=4/5 · Block & Evade", 2.8f, 1.00f, 15f, 0.6f, "BLOCK 100%", 1.0f),
        SkillSlot("Special Ultimate", "acao=10 · SP 100% Finisher", 1.0f, 2.35f, 0f, 0.0f, "SP GAUGE AUTO", 2.0f)
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
        val pAttr = pEntry?.attr ?: "Vaccine"
        val eAttr = eEntry?.attr ?: "Virus"
        if ((pAttr == "Vaccine" && eAttr == "Virus") || (pAttr == "Virus" && eAttr == "Data") || (pAttr == "Data" && eAttr == "Vaccine")) {
            pAtrMod = 1.2f
            eAtrMod = 0.9f
        } else if ((eAttr == "Vaccine" && pAttr == "Virus") || (eAttr == "Virus" && pAttr == "Data") || (eAttr == "Data" && pAttr == "Vaccine")) {
            pAtrMod = 0.9f
            eAtrMod = 1.2f
        } else {
            pAtrMod = 1.0f
            eAtrMod = 1.0f
        }

        pHpMax = if (dataMode == "worst") 99999 else if (dataMode == "empty") 950 else hpMax
        pHp = pHpMax
        pSp = 45f
        pBlock = 100f
        pCombo = 0
        pAcao = 1
        pX = 124f
        pY = 216f
        pVx = 0f
        pVy = 0f
        pAct = "idle"
        pAnimTimer = 0
        pAiState = "IDLE (acao=1)"
        pDodges = 0
        pParries = 0
        jackpotCount = 0
        shieldActive = false

        eHpMax = (eEntry?.baseHp ?: 2400) + enemyLv * 52
        eHp = eHpMax
        eSp = 30f
        eCombo = 0
        eAcao = 1
        eAtk = (((eEntry?.baseAtk ?: 320) + enemyLv * 4) * eAtrMod).roundToInt()
        eDef = (eEntry?.baseDef ?: 260) + enemyLv * 3
        eSpd = (eEntry?.baseSpd ?: 240) + enemyLv * 2
        eLuk = eEntry?.baseLuk ?: 45
        eX = 414f
        eY = 216f
        eVx = 0f
        eVy = 0f
        eAct = "idle"
        eAnimTimer = 0
        eAiState = "IDLE (acao=1)"

        btlFinished = false
        btlWin = true
        btlResultBanner = ""
        projectiles.clear()
        popups.clear()
        for (s in skills) {
            s.cd = 0.2f
        }
        lastTier = "READY"
        lastMult = pAtrMod.toDouble()
        lastLog = "[AUTO BATTLE] ${pEntry?.name ?: "Partner"} ($pAttr ${pAtrMod}x) vs ${eEntry?.name ?: "Boss"} ($battleZone)"
    }

    fun careAction(kind: String) {
        when (kind) {
            "food" -> {
                hunger = min(100, hunger + 25)
                hp = min(hpMax, hp + (hpMax * 0.25f).roundToInt())
                xp = min(100, xp + 15)
                if (xp >= 100) {
                    xp = 0
                    partnerLv += 1
                    hpMax += 85
                    atk += 12
                    def += 10
                }
                showToast("🍖 Fed Meat! Hunger $hunger% · HP Restored")
            }
            "vitamin" -> {
                en = min(100, en + 40)
                friendship = min(100f, friendship + 3f)
                showToast("💊 Vitamin! Energy $en/100 · Friendship ${friendship.roundToInt()}%")
            }
            "clean" -> {
                poopCount = 0
                friendship = min(100f, friendship + 4f)
                showToast("🧹 Cleaned Sanctuary! Hygiene 100%")
            }
            "bandage" -> {
                injury = 0
                hp = hpMax
                showToast("🩹 Bandage Applied! Injury=0 & Full HP")
            }
            "sleep" -> {
                en = 100
                hp = hpMax
                showToast("💤 Partner Slept! Energy 100/100 & Full HP")
            }
        }
        initBattleState()
    }

    fun trainGymStat(statKey: String) {
        when (statKey) {
            "HP" -> {
                hpMax += 80
                hp = hpMax
                en = max(0, en - 15)
                showToast("🏋️ HP Gym Drill: +80 Max HP!")
            }
            "ATK" -> {
                atk += 14
                en = max(0, en - 15)
                showToast("🏋️ ATK Gym Drill: +14 Physical ATK!")
            }
            "DEF" -> {
                def += 12
                en = max(0, en - 15)
                showToast("🏋️ DEF Gym Drill: +12 Physical DEF!")
            }
            "SP.ATK" -> {
                spAtk += 14
                en = max(0, en - 15)
                showToast("🏋️ SP.ATK Gym Drill: +14 Elemental SP.ATK!")
            }
            "SPD" -> {
                spd += 10
                en = max(0, en - 15)
                showToast("🏋️ SPD Gym Drill: +10 Speed!")
            }
            "BULK" -> {
                hpMax += 160
                hp = hpMax
                atk += 24
                def += 20
                spAtk += 24
                spd += 16
                en = max(0, en - 30)
                showToast("🏋️ Bulk Gym Coach: All Stats Boosted!")
            }
        }
        initBattleState()
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
            o.put("hunger", hunger)
            o.put("friendship", friendship.toDouble())
            o.put("injury", injury)
            o.put("poopCount", poopCount)
            o.put("wins", wins)
            o.put("losses", losses)
            o.put("tamerLv", tamerLv)
            o.put("tamerXp", tamerXp)
            o.put("tamerSp", tamerSp)
            o.put("battleMode", battleMode)
            o.put("infinityFloor", infinityFloor)
            o.put("adventureStage", adventureStage)
            o.put("challengeRank", challengeRank)
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
            hunger = o.optInt("hunger", hunger)
            friendship = o.optDouble("friendship", friendship.toDouble()).toFloat()
            injury = o.optInt("injury", injury)
            poopCount = o.optInt("poopCount", poopCount)
            wins = o.optInt("wins", wins)
            losses = o.optInt("losses", losses)
            tamerLv = o.optInt("tamerLv", tamerLv)
            tamerXp = o.optInt("tamerXp", tamerXp)
            tamerSp = o.optInt("tamerSp", tamerSp)
            battleMode = o.optString("battleMode", battleMode)
            infinityFloor = o.optInt("infinityFloor", infinityFloor)
            adventureStage = o.optInt("adventureStage", adventureStage)
            challengeRank = o.optInt("challengeRank", challengeRank)
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
            pAcao = if (btlWin) 12 else 11
            eAcao = if (btlWin) 11 else 12
            pAct = if (btlWin) "win" else "lose"
            eAct = if (btlWin) "lose" else "win"
            tickProjectilesAndPopups(dt)
            return
        }

        // Player Physics (acao=4 Jump / Floor landing)
        pX = (pX + pVx * spdMult).coerceIn(58f, 464f)
        if (pY < groundY || pVy < 0f) {
            pVy += grav * spdMult
            pY += pVy * spdMult
            if (pY >= groundY) {
                pY = groundY
                pVy = 0f
                if (pAnimTimer <= 0) {
                    pAcao = 1
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
                    eAcao = 1
                    eVx = 0f
                    eAct = "idle"
                }
            }
        }

        // Block Gauge regeneration & Skill cooldowns
        pBlock = min(100f, pBlock + dt * 14f)
        val cdRate = 1f + spd / 560f
        for (sk in skills) {
            if (sk.cd > 0f) sk.cd = max(0f, sk.cd - dt * cdRate)
        }

        // Original GML Incoming Projectile Check (distance_to_object(obj_Enemy_SPAtk) < 140)
        for (proj in projectiles) {
            if (!proj.fromPlayer && pY >= groundY - 2f && pAcao < 5) {
                val dx = abs(proj.x - pX)
                if (dx in 22f..115f) {
                    val roll = Random.nextInt(0, 10)
                    if (roll <= (if (btlTactic == "evasive") 3 else 2)) {
                        pAcao = 4
                        pVy = -10.2f
                        pVx = if (eX > pX) -2.4f else 2.4f
                        pAct = "jump"
                        pAnimTimer = 14
                        pDodges += 1
                        pAiState = "JUMP (acao=4)"
                        popups.add(FloatingPopup(pX, pY - 54f, "JUMP EVADE!", 0xFF00E5B0))
                        break
                    } else if (btlAutoSkill && pBlock >= 25f && roll <= (if (btlTactic == "evasive") 6 else 4)) {
                        castPlayerSkill(2, if (eX >= pX) 1f else -1f)
                        break
                    }
                }
            } else if (proj.fromPlayer && eY >= groundY - 2f && eAcao < 5) {
                val dx = abs(proj.x - eX)
                if (dx in 22f..96f && Random.nextInt(0, 10) <= 1) {
                    eAcao = 4
                    eVy = -9.6f
                    eVx = if (pX < eX) 2.2f else -2.2f
                    eAct = "jump"
                    eAnimTimer = 14
                    eAiState = "JUMP (acao=4)"
                    break
                }
            }
        }

        // Player Original Real-Time Action AI (acao 1..10) + Auto-Battle
        if (pAnimTimer > 0) {
            pAnimTimer -= ceil(spdMult).toInt()
            if (pAnimTimer <= 0 && pY >= groundY) {
                pAcao = 1
                pVx = 0f
                pAct = "idle"
            }
        } else if (Random.nextFloat() < 0.34f) {
            val dist = abs(eX - pX)
            val dir = if (eX >= pX) 1f else -1f
            if (btlAutoSkill && pSp >= 100f) {
                castPlayerSkill(3, dir)
                return
            }
            if (dist >= 68f) {
                pAcao = 2
                pVx = dir * 3.2f
                pAct = "walk"
                pAiState = "WALK (acao=2)"
                if (btlAutoSkill && skills[1].cd <= 0f && (dist > 105f || btlTactic == "ranged")) {
                    castPlayerSkill(1, dir)
                    return
                }
            } else {
                if (btlAutoSkill && skills[0].cd <= 0f) {
                    castPlayerSkill(0, dir)
                    return
                } else if (btlAutoSkill && skills[1].cd <= 0f) {
                    castPlayerSkill(1, dir)
                    return
                } else if (pY >= groundY && Random.nextInt(1, 101) <= 22) {
                    pAcao = 4
                    pVy = -8.8f
                    pVx = -dir * 2.4f
                    pAct = "jump"
                    pAnimTimer = 14
                    pAiState = "JUMP (acao=4)"
                }
            }
        }

        // Enemy Original Real-Time Action AI (acao 1..10)
        if (eAnimTimer > 0) {
            eAnimTimer -= ceil(spdMult).toInt()
            if (eAnimTimer <= 0 && eY >= groundY) {
                eAcao = 1
                eVx = 0f
                eAct = "idle"
            }
        } else if (Random.nextFloat() < 0.28f) {
            val dist = abs(pX - eX)
            val dir = if (pX < eX) -1f else 1f
            if (Random.nextInt(1, 101) <= 46) {
                val isUlt = eSp >= 100f
                val isCrit = Random.nextInt(1, 15) == 1
                val critMult = if (isCrit) 2f else 1f
                val isMelee = dist < 72f && !isUlt
                val rawDmg = max(enemyLv, (((eAtk * (if (isUlt) 1.85f else 1.18f) - def * 0.52f) / 1.8f) * critMult).roundToInt())
                eAcao = if (isUlt) 10 else if (isMelee) 7 else 8
                eAct = if (isUlt) "atkSP" else "atk01"
                if (isUlt) eSp = 0f else eSp = min(100f, eSp + 22f)
                eAnimTimer = 15
                eAiState = if (isUlt) "SPECIAL (acao=10)" else if (isMelee) "MELEE (acao=7)" else "SP.ATK (acao=8)"
                projectiles.add(
                    Projectile(
                        fromPlayer = false,
                        x = eX + dir * 24f,
                        y = eY - 26f,
                        vx = dir * 6.8f,
                        dmg = rawDmg,
                        tier = if (isCrit) "CRIT 2x" else "ATK",
                        mult = critMult,
                        colHex = 0xFFFF6B4A,
                        isUlt = isUlt
                    )
                )
            } else if (dist > 68f) {
                eAcao = 2
                eVx = dir * 2.8f
                eAct = "walk"
                eAiState = "WALK (acao=2)"
            } else {
                eAcao = 4
                eVx = -dir * 2.2f
                if (eY >= groundY && Random.nextInt(1, 101) <= 30) eVy = -8.2f
                eAct = "jump"
                eAiState = "JUMP (acao=4)"
            }
        }

        tickProjectilesAndPopups(dt)
    }

    fun castPlayerSkill(idx: Int, dir: Float = if (eX >= pX) 1f else -1f) {
        if (btlFinished || idx !in 0..3) return
        val sk = skills[idx]
        sk.cd = sk.cdMax

        // Original Critical Formula: CRITICAL = 2 (2.0x) or 1 (1.0x)
        val focus = (spd / 30).coerceIn(1, 14)
        val isCrit = Random.nextInt(1, (18 - focus).coerceAtLeast(3) + 1) == 1
        val critMult = if (isCrit) 2.0f else 1.0f

        if (idx == 2) {
            pAcao = 5
            shieldActive = true
            pAct = "block"
            pAnimTimer = 14
            pAiState = "GUARD (acao=5)"
            lastTier = "GUARD (acao=5)"
            lastMult = 1.0
            sk.lastRoll = "BLOCK ${pBlock.roundToInt()}%"
            popups.add(FloatingPopup(pX, pY - 48f, "GUARD READY!", 0xFF38BDF8))
            lastLog = "[AUTO] Guard (acao=5) active — Block Gauge ${pBlock.roundToInt()}%"
            return
        }

        if (idx == 3) {
            pSp = 0f
            pAcao = 10
            pAct = "atkSP"
            pAnimTimer = 18
            pAiState = "SPECIAL (acao=10)"
        } else if (idx == 0) {
            pSp = min(100f, pSp + sk.spGain)
            pAcao = 7
            pVx = dir * 1.8f
            pAct = "atk01"
            pAnimTimer = 14
            pAiState = "MELEE (acao=7)"
        } else {
            pSp = min(100f, pSp + sk.spGain)
            pAcao = 8
            pAct = "atk01"
            pAnimTimer = 15
            pAiState = "SP.ATK (acao=8)"
        }

        val statVal = if (idx == 1 || idx == 3) spAtk else atk
        val baseDmg = max(partnerLv, ((statVal * sk.power - eDef * 0.50f) / 1.7f).roundToInt())
        val dmg = (baseDmg * critMult).roundToInt()
        val tier = if (idx == 3) "SPECIAL ULTIMATE!" else if (isCrit) "CRITICAL 2x!" else sk.name.uppercase()
        val col = if (isCrit || idx == 3) 0xFFF5C451 else 0xFF00E5B0

        lastTier = tier
        lastMult = critMult.toDouble()
        sk.lastRoll = "$dmg DMG${if (isCrit) " (CRIT!)" else ""}"
        sk.lastMult = critMult

        projectiles.add(
            Projectile(
                fromPlayer = true,
                x = pX + dir * 24f,
                y = pY - 26f,
                vx = dir * 7.6f,
                dmg = dmg,
                tier = tier,
                mult = critMult,
                colHex = col,
                isUlt = idx == 3
            )
        )
        lastLog = "[AUTO] ${sk.name} (acao=$pAcao) → $dmg DMG${if (isCrit) " [CRITICAL 2x!]" else ""}"
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
                    pCombo += 1
                    eCombo = 0
                    pSp = min(100f, pSp + 10f)
                    eSp = min(100f, eSp + 12f)
                    eAcao = 6
                    eAct = "dmg"
                    eAnimTimer = 10
                    val comboTxt = if (pCombo >= 2) " (${pCombo} HIT)" else ""
                    popups.add(FloatingPopup(eX, eY - 48f, "-${p.dmg}$comboTxt", p.colHex))
                    toRemove.add(p)
                    if (eHp <= 0) {
                        settleOriginalMatchOutcome(true)
                    }
                }
            } else {
                val dx = abs(p.x - pX)
                val dy = abs(p.y - (pY - 24f))
                if (dx < 26f && dy < 32f) {
                    toRemove.add(p)
                    if (pAcao == 5 || shieldActive) {
                        shieldActive = false
                        pBlock = max(0f, pBlock - 28f)
                        pParries += 1
                        val blockedDmg = max(1, (p.dmg * 0.15f).roundToInt())
                        pHp = max(0, pHp - blockedDmg)
                        val cDmg = max(partnerLv, (atk * 1.35f - eDef * 0.4f).roundToInt())
                        popups.add(FloatingPopup(pX, pY - 56f, "BLOCKED (-$blockedDmg) & COUNTER!", 0xFF38BDF8))
                        eHp = max(0, eHp - cDmg)
                        if (eHp <= 0) {
                            settleOriginalMatchOutcome(true)
                        }
                    } else {
                        pHp = max(0, pHp - p.dmg)
                        pCombo = 0
                        eCombo += 1
                        pSp = min(100f, pSp + 12f)
                        pAcao = 6
                        pAct = "dmg"
                        pAnimTimer = 10
                        popups.add(FloatingPopup(pX, pY - 48f, "-${p.dmg} (${p.tier})", 0xFFFF6B4A))
                        if (pHp <= 0) {
                            settleOriginalMatchOutcome(false)
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

    private fun settleOriginalMatchOutcome(playerWon: Boolean) {
        if (btlFinished) return
        btlFinished = true
        btlWin = playerWon
        totalBattles += 1
        hunger = max(0, hunger - 4)
        en = max(0, en - 8)
        if (playerWon) {
            wins += 1
            friendship = min(100f, friendship + 0.3f)
            val wonBits = (enemyLv * 50f * pAtrMod).roundToInt() + 1200
            val givenXp = (enemyLv * 45f * pAtrMod).roundToInt()
            val tamerGain = max(10, givenXp / 4)
            bits += wonBits
            xp += 35
            if (xp >= 100) {
                xp -= 100
                partnerLv += 1
                hpMax += 90
                hp = hpMax
                atk += 14
                def += 12
                spAtk += 14
                spd += 8
            }
            tamerXp += tamerGain
            if (tamerXp >= tamerLv * 250) {
                tamerXp = 0
                tamerLv += 1
                tamerSp += 1
            }
            when (battleMode) {
                "infinity" -> infinityFloor += 1
                "challenge" -> challengeRank += 1
                "adventure" -> adventureStage += 1
            }
            btlResultBanner = "🏆 VICTORY! (+$wonBits BIT · +$givenXp XP · Tamer Lv.$tamerLv)"
        } else {
            losses += 1
            injury = min(5, injury + 1)
            friendship = max(0f, friendship - 1f)
            val consolationXp = max(15, (enemyLv * 12f).roundToInt())
            tamerXp += consolationXp / 4
            btlResultBanner = "💀 DEFEAT (Injury:$injury — Use Bandage in Sanctuary)"
        }
        lastLog = btlResultBanner
    }

    fun runDiagnosticSelfTest(): String {
        val sb = StringBuilder()
        sb.append("DB[digimons=${digimons.size},evos=${evolutions.values.sumOf { it.size }},items=${items.size},quests=${quests.size}] | ")

        // 1. Sanctuary biome & V-Pet care test
        val oldTheme = sanctuaryThemes[sanctuaryThemeIdx].name
        sanctuaryThemeIdx = (sanctuaryThemeIdx + 1) % sanctuaryThemes.size
        val curTheme = sanctuaryThemes[sanctuaryThemeIdx]
        val bgBmp = tex(curTheme.bg, 0)
        careAction("food")
        sb.append("Sanctuary[$oldTheme->${curTheme.name},bgLoaded=${bgBmp != null},hunger=$hunger] | ")

        // 2. HD Item equip & Lucky Forge test
        equippedItem = 10
        itemAffixes[10] = "★777 JACKPOT (+45% ALL)"
        val itemBmp = texItemHd(10)
        sb.append("ItemHD[id=10,bmp=${itemBmp != null},affix=${itemAffixes[10]}] | ")

        // 3. Original Gym Training test
        val oldAtk = atk
        trainGymStat("ATK")
        sb.append("GymTrain[ATK:$oldAtk->$atk] | ")

        // 4. Digivolution test
        val routes = evolutions[partnerId] ?: emptyList()
        if (routes.isNotEmpty()) {
            evolvePartner(routes[0])
        }
        sb.append("Evo[partnerId=$partnerId,name=${digimons[partnerId]?.name}] | ")

        // 5. Save & Load persistence test
        val savedOk = saveGameState() && loadGameState()
        sb.append("SaveLoad[ok=$savedOk] | ")

        // 6. Original Real-Time Action Auto-Battle simulation test
        val stg = stageArenas[2]
        startStageBattle(stg.bossId, stg.lv, stg.zone, stg.bg)
        for (i in 0 until 60) {
            tickFrame()
        }
        sb.append("BattleOrig[room=$currentRoom,zone=$battleZone,pHp=$pHp/$pHpMax,eHp=$eHp/$eHpMax,pAcao=$pAcao,combo=$pCombo,block=${pBlock.roundToInt()}%,tier=$lastTier]")
        return sb.toString()
    }
}
