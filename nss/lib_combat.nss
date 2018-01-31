/*------------------------------------------------------------------------------
 *  Combat Library
 *
 *  This is the combat library
 *
 *  At the end of this library you will find a main() function. This contains
 *  the code that registers and runs the scripts in this library. Read the
 *  instructions to add your own objects to this library or to a new library.
 ------------------------------------------------------------------------------*/

#include "h_library"
#include "h_util_combat"
#include "h_response"

// ---- Combat Classes ---------------------------------------------------------

//---- Animal Combat Behavior --------------------------------------------------
//
// Vermin are simple mindless attacking creatures. They are easy to scare and
// quick to bite.
//

// 1. Everything we do here will be done once for the class. Anything stored on
//    MEME_SELF will be shared by every NPC because MEME_SELF is the class object.
void c_combat_vermin_ini()
{
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSELF,   50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_REGROUP,      40, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_AVOIDMELEE,   50, RESPONSE_LOW);

    MeSetActiveResponseTable("Combat", GCT, "*");
}

// 2. Now everything that happens here is run once for every NPC.
void c_combat_vermin_go()
{
    if (!GetIsObjectValid(GetLocalObject(NPC_SELF, "CombatGenerator")))
    {
        object oCombat = MeCreateGenerator("g_combatai", PRIO_HIGH);
        MeStartGenerator(oCombat);
        SetLocalObject(NPC_SELF, "CombatGenerator", oCombat);

        SetListening(OBJECT_SELF, TRUE);
        SetListenPattern(OBJECT_SELF, "BC_DEAD", CH_DEAD);
        SetListenPattern(OBJECT_SELF, "BC_FIGHTING", CH_COMBAT);
    }
}

//---- Animal Combat Behavior --------------------------------------------------
void c_combat_animal_ini()
{
    MeAddResponse(MEME_SELF, GCT, COMBAT_BECOMEDEFENSIVE,  0, RESPONSE_START);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSINGLE,    50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_REGROUP,         50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_AVOIDMELEE,      40, RESPONSE_LOW);

    // This is the second combat behavior.
    MeAddResponse(MEME_SELF, "Defensive Combat Table", COMBAT_REGROUP, 50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, "Defensive Combat Table", COMBAT_ATTACKMELEE, 100, RESPONSE_END);

    MeSetActiveResponseTable("Combat", GCT, "*");
}

void c_combat_animal_go()
{
    if (!GetIsObjectValid(GetLocalObject(NPC_SELF, "CombatGenerator")))
    {
        object oCombat = MeCreateGenerator("g_combatai", PRIO_HIGH);
        MeStartGenerator(oCombat);
        SetLocalObject(NPC_SELF, "CombatGenerator", oCombat);

        SetListening(OBJECT_SELF, TRUE);
        SetListenPattern(OBJECT_SELF, "BC_DEAD", CH_DEAD);
        SetListenPattern(OBJECT_SELF, "BC_FIGHTING", CH_COMBAT);
    }
}

//---- Caster Combat Behavior --------------------------------------------------

void c_combat_defensive_cast_ini()
{
    MeAddResponse(MEME_SELF, GCT, COMBAT_HEALSELF,        0, RESPONSE_START);
    MeAddResponse(MEME_SELF, GCT, COMBAT_AVOIDMELEE,     50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_EVACAOE,        50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLSUMMON,    60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TURNING,        50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLHEAL,      50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLGROUPHEAL, 60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSELF,     60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLHELP,      70, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLGRPENHANCE,70, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TIMESTOP,       40, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_REGROUP,        50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLRAISE,     30, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ENHANCESELF,    60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_VISION,         60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISMISSAL,      70, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLBREACH,    70, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISPELAOE,      90, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISPELSINGLE,   60, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLAREA,      60, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLDIRECT,    80, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FLANK,          30, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FEATENHANCE,    60, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSINGLE,  100, RESPONSE_END);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ENHANCESINGLE, 100, RESPONSE_END);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ATTACKRANGED,  100, RESPONSE_END);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TOUCH,          80, RESPONSE_END);

    MeSetActiveResponseTable("Combat", GCT, "*");
}

void c_combat_defensive_cast_go()
{
    if (!GetIsObjectValid(GetLocalObject(NPC_SELF, "CombatGenerator")))
    {
        object oCombat = MeCreateGenerator("g_combatai", PRIO_HIGH);
        MeStartGenerator(oCombat);
        SetLocalObject(NPC_SELF, "CombatGenerator", oCombat);

        SetListening(OBJECT_SELF, TRUE);
        SetListenPattern(OBJECT_SELF, "BC_DEAD", CH_DEAD);
        SetListenPattern(OBJECT_SELF, "BC_FIGHTING", CH_COMBAT);
    }
    SetLocalInt(NPC_SELF, "#FASTBUFFER", 1);
}

void c_combat_aggressive_cast_ini()
{
    MeAddResponse(MEME_SELF, GCT, COMBAT_HEALSELF,        0, RESPONSE_START);
    MeAddResponse(MEME_SELF, GCT, COMBAT_AVOIDMELEE,     50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_EVACAOE,        50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLSUMMON,    60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TURNING,        50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLAREA,      60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLDIRECT,    80, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FEATENHANCE,    60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TIMESTOP,       40, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLHEAL,      50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSELF,     60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ENHANCESELF,    60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_VISION,         60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLBREACH,    70, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISMISSAL,      70, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISPELSINGLE,   80, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISPELAOE,      90, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_REGROUP,        50, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLRAISE,     20, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FLANK,          30, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLGROUPHEAL, 60, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLHELP,      70, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLGRPENHANCE,70, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSINGLE,   80, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ENHANCESINGLE,  90, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ATTACKRANGED,  100, RESPONSE_END);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TOUCH,          80, RESPONSE_END);

    MeSetActiveResponseTable("Combat", GCT, "*");
}

void c_combat_aggressive_cast_go()
{
    if (!GetIsObjectValid(GetLocalObject(NPC_SELF, "CombatGenerator")))
    {
        object oCombat = MeCreateGenerator("g_combatai", PRIO_HIGH);
        MeStartGenerator(oCombat);
        SetLocalObject(NPC_SELF, "CombatGenerator", oCombat);

        SetListening(OBJECT_SELF, TRUE);
        SetListenPattern(OBJECT_SELF, "BC_DEAD", CH_DEAD);
        SetListenPattern(OBJECT_SELF, "BC_FIGHTING", CH_COMBAT);
    }
}

//---- Cleric Combat Behavior --------------------------------------------------

void c_combat_cleric_ini()
{
    MeAddResponse(MEME_SELF, GCT, COMBAT_HEALSELF,        0, RESPONSE_START);
    MeAddResponse(MEME_SELF, GCT, COMBAT_EVACAOE,        50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLSUMMON,    60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISMISSAL,      60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_VISION,         60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_REGROUP,        50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLDIRECT,    60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TURNING,        50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FEATENHANCE,    60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSELF,     60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ENHANCESELF,    60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLGROUPHEAL, 50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLHELP,      50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLHEAL,      50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSINGLE,   50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLGRPENHANCE,50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ENHANCESINGLE,  60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLAREA,      40, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLDIRECT,    60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLRAISE,     90, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISPELSINGLE,   90, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISPELAOE,      90, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FLANK,          30, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TOUCH,          50, RESPONSE_END);

    MeSetActiveResponseTable("Combat", GCT, "*");
}

void c_combat_cleric_go()
{
    if (!GetIsObjectValid(GetLocalObject(NPC_SELF, "CombatGenerator")))
    {
        object oCombat = MeCreateGenerator("g_combatai", PRIO_HIGH);
        MeStartGenerator(oCombat);
        SetLocalObject(NPC_SELF, "CombatGenerator", oCombat);

        SetListening(OBJECT_SELF, TRUE);
        SetListenPattern(OBJECT_SELF, "BC_DEAD", CH_DEAD);
        SetListenPattern(OBJECT_SELF, "BC_FIGHTING", CH_COMBAT);
    }
    SetLocalInt(NPC_SELF, "#FASTBUFFER", 1);
}

//---- Fighter Combat Behavior -------------------------------------------------

void c_combat_fighter_ini()
{
    MeAddResponse(MEME_SELF, GCT, COMBAT_HEALSELF,      0, RESPONSE_START);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FEATENHANCE,  60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_EVACAOE,      50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_REGROUP,      40, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FLANK,        20, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_MELEEASSIST,  50, RESPONSE_MEDIUM);

    MeSetActiveResponseTable("Combat", GCT, "*");
}

void c_combat_fighter_go()
{
    if (!GetIsObjectValid(GetLocalObject(NPC_SELF, "CombatGenerator")))
    {
        object oCombat = MeCreateGenerator("g_combatai", PRIO_HIGH);
        MeStartGenerator(oCombat);
        SetLocalObject(NPC_SELF, "CombatGenerator", oCombat);

        SetListening(OBJECT_SELF, TRUE);
        SetListenPattern(OBJECT_SELF, "BC_DEAD", CH_DEAD);
        SetListenPattern(OBJECT_SELF, "BC_FIGHTING", CH_COMBAT);
    }
}


//---- Mage Combat Behavior ----------------------------------------------------

void c_combat_mage_ini()
{
    MeAddResponse(MEME_SELF, GCT, COMBAT_HEALSELF,         0, RESPONSE_START);
    MeAddResponse(MEME_SELF, GCT, COMBAT_EVACAOE,         50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_AVOIDMELEE,      50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLSUMMON,     60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISMISSAL,       60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSELF,      50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ENHANCESELF,     50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FEATENHANCE,     60, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, GCT, COMBAT_REGROUP,         50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLAREA,       50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_VISION,          50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TIMESTOP,        40, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISPELAOE,       60, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLBREACH,     50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DISPELSINGLE,    40, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLHELP,       60, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLGRPENHANCE, 60, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_DEFENDSINGLE,    60, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ENHANCESINGLE,   60, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, GCT, COMBAT_SPELLDIRECT,    100, RESPONSE_END);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ATTACKRANGED,   100, RESPONSE_END);
    MeAddResponse(MEME_SELF, GCT, COMBAT_TOUCH,          100, RESPONSE_END);

    MeSetActiveResponseTable("Combat", GCT, "*");
}

void c_combat_mage_go()
{
    if (!GetIsObjectValid(GetLocalObject(NPC_SELF, "CombatGenerator")))
    {
        object oCombat = MeCreateGenerator("g_combatai", PRIO_HIGH);
        MeStartGenerator(oCombat);
        SetLocalObject(NPC_SELF, "CombatGenerator", oCombat);

        SetListening(OBJECT_SELF, TRUE);
        SetListenPattern(OBJECT_SELF, "BC_DEAD", CH_DEAD);
        SetListenPattern(OBJECT_SELF, "BC_FIGHTING", CH_COMBAT);
    }
    SetLocalInt(NPC_SELF, "#FASTBUFFER", 1);
}


//---- Archer Combat Behavior ----------------------------------------------------

void c_combat_archer_ini()
{
    MeAddResponse(MEME_SELF, GCT, COMBAT_HEALSELF,         0, RESPONSE_START);
    MeAddResponse(MEME_SELF, GCT, COMBAT_EVACAOE,         80, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FEATENHANCE,     80, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_REGROUP,         30, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_FLANK,           50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, GCT, COMBAT_ATTACKRANGED,   100, RESPONSE_END);
    MeAddResponse(MEME_SELF, GCT, COMBAT_MELEEASSIST,     90, RESPONSE_END);

    MeSetActiveResponseTable("Combat", GCT, "*");
}

// 2. Now everything that happens here is run once for every NPC.
void c_combat_archer_go()
{
    if (!GetIsObjectValid(GetLocalObject(NPC_SELF, "CombatGenerator")))
    {
        object oCombat = MeCreateGenerator("g_combatai", PRIO_HIGH);
        MeStartGenerator(oCombat);
        SetLocalObject(NPC_SELF, "CombatGenerator", oCombat);

        SetListening(OBJECT_SELF, TRUE);
        SetListenPattern(OBJECT_SELF, "BC_DEAD", CH_DEAD);
        SetListenPattern(OBJECT_SELF, "BC_FIGHTING", CH_COMBAT);
    }
}

/*-----------------------------------------------------------------------------
 * Generator:  g_combatai
 *    Author:  Joel Martin (a.k.a. Garad Moonbeam),
 *             modifications by Niveau0
 *      Date:  Jan, 2004
 *   Purpose:  This generator controls combat behaviour/ai for a creature.  It
 *             will react to various combat situations by creating appropriate
 *             meme's based upon configurable tactics.  This generator is
 *             based heavily upon NamelessOne's CODI Core AI and Jasperre's AI
 -----------------------------------------------------------------------------
 *    Timing:  All
 -----------------------------------------------------------------------------*/
void g_combatai_ini()
{
    _Start("Generator name='" + _GetName( MEME_SELF ) + "' timing='Initialize'", DEBUG_COREAI);

    // We create one combat meme, remembered by generator,
    // it'll be suspended (dormant) until a combat starts
    object oCombatMeme = GetLocalObject(NPC_SELF, "CombatMeme");
    if (!GetIsObjectValid(oCombatMeme))
    {
        // this should always be invalid here, else there is something wrong
        oCombatMeme = MeCreateMeme("i_docombat", PRIO_HIGH, PRIO_DEFAULT,
                                   MEME_RESUME | MEME_REPEAT, MEME_SELF);
        SetLocalObject(NPC_SELF, "CombatMeme", oCombatMeme);
        CombatSuspend();
    }

    // TODO check if this is too early
    // Store current weapons for later use (after disarm)
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
    if (oWeapon != OBJECT_INVALID)
        SetLocalObject(OBJECT_SELF, "#LHAND", oWeapon);
    oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    if (oWeapon != OBJECT_INVALID)
        SetLocalObject(OBJECT_SELF, "#RHAND", oWeapon);

    // Set defaults if still unset

    // how far does perception work
    // TODO: currently not in use
    if (GetLocalFloat(MEME_SELF, "PerceptionRange") == 0.0)
        SetLocalFloat(MEME_SELF, "PerceptionRange", 40.0);
    // how long to dislike temporary enemies
    if (GetLocalFloat(MEME_SELF, "GrudgeTime") == 0.0)
        SetLocalFloat(MEME_SELF, "GrudgeTime", 300.0);
    // chance to say something if enemies approach
    if(!GetLocalInt(MEME_SELF, "SpeakChanceSee"))
        SetLocalInt(MEME_SELF, "SpeakChanceSee", 10);

    CombatSetDefaultFunc(NPC_SELF, COMBAT_FASTBUFFS);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLHEAL);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLDIRECT);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_TOUCH);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_ATTACKRANGED);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_ATTACKMELEE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_MOVETOLOCATION);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_TELEPORT);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_FIGHTBROADCAST);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_COUNTERSPELL);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_EVACAOE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_MOVETOOBJECT);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_REGROUP);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_DEFENDSELF);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_DEFENDSINGLE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_ENHANCESELF);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_ENHANCESINGLE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLHELP);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLRAISE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLBREACH);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLAREA);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLSUMMON);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_FEATENHANCE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_AVOIDMELEE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_TIMESTOP);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_VISION);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_BREATHWEAPON);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_TURNING);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_HEALSELF);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLGRPENHANCE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_DISPELAOE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_DISPELSINGLE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_DISMISSAL);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_SPELLGROUPHEAL);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_BECOMEDEFENSIVE);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_FLANK);
    CombatSetDefaultFunc(NPC_SELF, COMBAT_MELEEASSIST);

    _End();
}

void g_combatai_see()
{
    _Start("Generator name='" + _GetName( MEME_SELF ) + "' timing='See'", DEBUG_COREAI);

    object oPer = GetLastPerceived();

    if (oPer != OBJECT_INVALID && !GetIsDead(oPer) && GetIsEnemy(oPer))
    {
        // TODO check user-configured perception range here

        CombatResume(); // care for running combat meme

        //trigger combat
        _PrintString("Enemy seen: " + GetName(OBJECT_SELF) + " -> " + GetName(oPer));

        if (d100() < GetLocalInt(MEME_SELF, "SpeakChanceSee"))
        {
            // say something
            string s = GetLocalString(MEME_SELF, "SpeakSee");
            if (s == "")
                PlayVoiceChat(VOICE_CHAT_ENEMIES);
            else
                ActionSpeakString(s);
        }
        if (GetLocalInt(NPC_SELF, "#FASTBUFFER") && !GetLocalInt(NPC_SELF, "#FASTBUFFED"))
        {
            // instantly start fastbuffering
            MeCreateMeme("i_castfastbuff", PRIO_VERYHIGH, PRIO_DEFAULT, MEME_INSTANT,
                GetLocalObject(NPC_SELF, "CombatMeme"));
            // set always as done, even if fastbuff actions fail.
            // if meme executes fast enough, its nice. if not, its already too late
            // this resets after combat
            SetLocalInt(NPC_SELF, "#FASTBUFFED", 1);
        }
    }

    _End();
}

void g_combatai_hea()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='Heard'", DEBUG_COREAI);

    object oPer = GetLastPerceived();

    if (oPer != OBJECT_INVALID &&
        !GetObjectSeen(oPer) && // won't be processed in _see
        GetObjectType(oPer) == OBJECT_TYPE_CREATURE &&
        !GetIsDead(oPer) && GetIsEnemy(oPer))
        // TODO check user configured perception range
    {
        CombatResume();


/*  TODO test vision spells and vanishing enemies
    if (!GetObjectSeen(oPer))
        {
            // cannot see target, try to help myself

            SetLocalInt(NPC_SELF, "#VANISHED", 1);
            if (GetVisionSpellNeeded())
                MeCreateMeme( "i_castvision", PRIO_HIGH, PRIO_DEFAULT, MEME_INSTANT);
            else
            {
                //generic response for noticing something is up with no spells
                /*
                vector vT = -1.0 * GetPosition( oPer ) - GetPosition( OBJECT_SELF );
                location lM = Location( GetArea( OBJECT_SELF ), GetPosition( OBJECT_SELF ) + vT, VectorToAngle( vT ) );
                ActionMoveToLocation( lM, TRUE );
            }
        }*/
    }

    _End();
}

void g_combatai_van()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='Vanished'", DEBUG_COREAI);

    object oPer = GetLastPerceived();

//   TODO, check if this comment is right... putting the meme off makes #VANISHED useless

/*  We should reprioritize the combat meme down. We don't and it means that
   fighters sometimes don't disengage and go braindead instead. For example, if
   they flee and run into a tree! */
//    CombatSuspend();

    //make sure it isn't a corpse that just faded out
    if (oPer != OBJECT_INVALID && !GetIsDead(oPer) && GetIsEnemy(oPer))
    {
        // report vanished enemies who have not just died,
        // but not if the cause of vanishing is blindness on self
        if (GetDistanceBetween(OBJECT_SELF, oPer) < GetLocalFloat(MEME_SELF, "PerceptionRange") &&
            !(GetEffectsOnObject() & BLINDNESS))
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
                ActionSpeakString(GetName(oPer) + " vanished from sight");
            if (!Random(10))
                PlayVoiceChat(VOICE_CHAT_CUSS);
            SetLocalInt(NPC_SELF, "#VANISHED", 1);
        }
    }

    _End();
}

// End of a combat round; generally occurs once every 6 seconds.
void g_combatai_end()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='CombatRoundEnd'", DEBUG_COREAI);

    // allow next combat round actions
    SetLocalInt(NPC_SELF, "#INCOMBAT", 0);

    if (GetLocalInt(NPC_SELF, "#EQUIPRANGED"))
    {
        DeleteLocalInt(NPC_SELF, "#EQUIPRANGED");
        if (!GetIsRangedWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)))
        {
            // do no range attacks if no more weapon available
            if (!GetHasRangedCapability())
                DeleteLocalInt(NPC_SELF, "#RANGEDCAPABLE");
        }
    }

    // meme must restart itself, because some Actions are blockers
    // need to clean action queue here, but do not interrupt spell casting
    switch (GetCurrentAction())
    {
    case ACTION_INVALID:
    case ACTION_ATTACKOBJECT:
    case ACTION_COUNTERSPELL:
    case ACTION_DIALOGOBJECT:
    case ACTION_FOLLOW:
    case ACTION_RANDOMWALK:
    case ACTION_REST:
    case ACTION_SIT:
    case ACTION_SMITEGOOD:
    case ACTION_WAIT:
        MeRestartMeme(GetLocalObject(NPC_SELF, "CombatMeme"), 0);
    }

    _End();
}

void g_combatai_tlk()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='Conversation'", DEBUG_COREAI);

    int iBroadcast = GetListenPatternNumber();

    if (iBroadcast == -1)
    {
        // general talk request, this should be handled by other generators, not combat
    }
    else
    {
        object oBroadcaster = GetLastSpeaker();

        if (GetArea(oBroadcaster) != GetArea(OBJECT_SELF))
        {
            _End();
            return;
        }

        object oT = OBJECT_INVALID;
        object oM = OBJECT_INVALID;
        object oMeme;

        if (iBroadcast == CH_COMBAT)
        {
            // Something fighting nearby
            object oEnemy;

            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
                ActionSpeakString("Heard Combat!");
            _PrintString("CH_COMBAT: " + GetName(oBroadcaster) + " heard by " + GetName(OBJECT_SELF), DEBUG_COREAI);

            string sFriend = GetLocalString(OBJECT_SELF, "FriendType");

            if (GetIsFriend(oBroadcaster))
//              ||  (sFriend != "" && GetLocalString(oBroadcaster, "FriendType") == sFriend))
            {
                oT = GetTarget(OBJECT_SELF);

                if (!GetIsObjectValid(oT))
                // only help if not currently fighting against someone else
                {
                    // heard combat from a friend but can't see the combat or any enemies
                    // => go there and become enemy of friends target
                    if (!GetIsObjectValid(GetLocalObject(OBJECT_SELF, "GotoMeme")))
                    {
                        oT = GetTarget(oBroadcaster);
                        if (GetIsObjectValid(oT) && !GetIsEnemy(oT))
                            SetIsTemporaryEnemy(oT, OBJECT_SELF, TRUE, GetLocalFloat(MEME_SELF, "GrudgeTime"));

                        // use prio default, so combat can start if enemies can be seen
                        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
                            ActionSpeakString("Going to assist " + GetName(oBroadcaster));
                        oMeme = MeCreateMeme("i_goto", PRIO_DEFAULT, 0);
                        if (GetIsObjectValid(oMeme))
                        {
                            SetLocalObject(oMeme, "Object", oBroadcaster);
                            SetLocalInt(oMeme, "Run", 1);
                            SetLocalObject(OBJECT_SELF, "GotoMeme", oMeme);
                            MeCallFunction(GetLocalString(NPC_SELF, COMBAT_FIGHTBROADCAST));
                        }
                    }
                }
                else
                    CombatResume();
            }
        }
        else if (iBroadcast == CH_DEAD)
        {
            // Something is dying nearby
            _PrintString("CH_DEAD: " + GetName(oBroadcaster) + " (Died) heard by " + GetName(OBJECT_SELF), DEBUG_COREAI);
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
                ActionSpeakString("Heard Death!");

            if (GetIsFriend(oBroadcaster))
            {
                if (Random(2))
                    PlayVoiceChat(VOICE_CHAT_CUSS);
            }
            else if (GetIsEnemy(oBroadcaster))
            {
                if (!Random(5))
                {
                    if (Random(2))
                        PlayVoiceChat(VOICE_CHAT_CHEER);
                    else
                        PlayVoiceChat(VOICE_CHAT_LAUGH);
                }
            }
        }
        else if (GetIsObjectValid(oM = GetMaster(OBJECT_SELF)) && oBroadcaster == oM)
        {
            // Master speaking to servant
            if (iBroadcast == ASSOCIATE_COMMAND_STANDGROUND)
            {
                //stand ground
                // TODO: #SGLOC never used for now?
                SetLocalLocation( NPC_SELF, "#SGLOC", GetLocation(OBJECT_SELF));
                SetLocalInt(NPC_SELF, "#STANDGROUND", 1);
                PlayVoiceChat(VOICE_CHAT_TASKCOMPLETE);
                // following meme ensures the henchman stopping right at his location now
                // if he is moving, he should go back where he was
                oMeme = MeCreateMeme("i_movetolocation", PRIO_VERYHIGH, 0);

                if (GetIsObjectValid(oMeme))
                    SetLocalLocation(oMeme, "lDest", GetLocation(OBJECT_SELF));
            }
            else if (iBroadcast == ASSOCIATE_COMMAND_ATTACKNEAREST)
            {
                //attack nearest
                SetLocalInt(NPC_SELF, "#STANDGROUND", 0);

                // TODO: check user-configured perception range?
                oT = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1,
                                        CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE );
                if (oT != OBJECT_INVALID)
                {
                    if (Random(2))
                        PlayVoiceChat(VOICE_CHAT_GOODIDEA);
                    CombatResume();
                }
                else
                    PlayVoiceChat(VOICE_CHAT_CANTDO);
            }
            else if (iBroadcast == ASSOCIATE_COMMAND_HEALMASTER)
            {
                //heal master
                if (GetHealingAbilities())
                {
                    PlayVoiceChat(VOICE_CHAT_CANDO);
                    oMeme = MeCreateMeme("i_castheal", PRIO_VERYHIGH, 0);
                    if (GetIsObjectValid(oMeme))
                        SetLocalObject(oMeme, "Target", oM);
                }
                else
                    PlayVoiceChat(VOICE_CHAT_CANTDO);
            }
            else if (iBroadcast == ASSOCIATE_COMMAND_FOLLOWMASTER)
            {
                //follow master
                SetLocalInt(NPC_SELF, "#STANDGROUND", 0);
                oMeme = MeCreateMeme("i_follow", PRIO_HIGH, 0);
                if (GetIsObjectValid(oMeme))
                    SetLocalObject(oMeme, "Leader", oM);
            }
            else if (iBroadcast == ASSOCIATE_COMMAND_GUARDMASTER)
            {
                //guard master
                SetLocalInt(NPC_SELF, "#STANDGROUND", 0);
                oT = GetLastHostileActor(oM);
                if (oT == OBJECT_INVALID)
                    oT = GetLastAttacker(oM);
                if (oT == OBJECT_INVALID)
                    PlayVoiceChat(VOICE_CHAT_CANTDO);
                else if (GetObjectSeen(oT) || GetObjectHeard(oT))
                {
                    oMeme = MeCreateMeme("i_guardmaster", PRIO_VERYHIGH, 0);
                    if (GetIsObjectValid(oMeme))
                        SetLocalObject(oMeme, "Target", oT);
                }
            }
        }
    }

    _End();
}

void g_combatai_atk()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='Attacked'", DEBUG_COREAI);

    object oT = GetLastAttacker();
    if (GetIsObjectValid(oT))
    {
        if (!GetIsEnemy(oT))
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
            {
                if (GetIsFriend(oT))
                    SpeakString("Attack by friend");
                else
                    SpeakString("Attack by neutral");
            }
            if (GetMaster(OBJECT_SELF) != oT)
            {
                SetIsTemporaryEnemy(oT, OBJECT_SELF, TRUE, GetLocalFloat(MEME_SELF, "GrudgeTime"));
                CombatResume();
            }
        }
        else
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
                SpeakString("Attack by enemy");
            CombatResume();
        }
    }

    _End();
}

void g_combatai_dmg()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='Damaged'", DEBUG_COREAI);

    object oDam = GetLastDamager();

    if (oDam != OBJECT_INVALID)
    {
        if (!GetIsEnemy(oDam))
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
            {
                if (GetIsFriend(oDam))
                    SpeakString("Damaged by friend");
                else
                    SpeakString("Damaged by neutral");
            }
            if (GetMaster(OBJECT_SELF) != oDam)
            {
                SetIsTemporaryEnemy(oDam, OBJECT_SELF, TRUE, GetLocalFloat(MEME_SELF, "GrudgeTime"));
                CombatResume();
            }
        }
        else // enemy
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
                SpeakString("Damaged by enemy");
            CombatResume();

            if (!GetIsObjectValid(GetTarget()))
            {
                object oMeme = MeCreateMeme("i_goto", PRIO_DEFAULT, 0);
                if (GetIsObjectValid(oMeme))
                {
                    SetLocalObject(oMeme, "Object", oDam);
                    SetLocalInt(oMeme, "Run", 1);
                    SetLocalObject(OBJECT_SELF, "GotoMeme", oMeme);
                    MeCallFunction(GetLocalString(NPC_SELF, COMBAT_FIGHTBROADCAST));
                }
            }
        }
    }
    else
        _PrintString("Invalid damager");

    if (!GetLocalInt(NPC_SELF, "#HEALDEL"))
    {
        float fHP = IntToFloat(GetCurrentHitPoints(OBJECT_SELF)) / IntToFloat(GetMaxHitPoints(OBJECT_SELF));

        // only start calling for healing once we've taken 50%
        // and there are friends around (this can be summons, so TODO somehow else maybe)
        if (fHP < 0.51 &&
            GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, OBJECT_SELF, 1,
                               CREATURE_TYPE_IS_ALIVE, TRUE) != OBJECT_INVALID)
        {
            // broadcast request for healing for display purposes
            PlayVoiceChat(VOICE_CHAT_HEALME);
            // do not broadcast again until this int is cleared
            SetLocalInt(NPC_SELF, "#HEALDEL", 1);
        }
    }
    else if (Random(2))
        SetLocalInt(NPC_SELF, "#HEALDEL", 0);

    _End();
}

void g_combatai_dth()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='Death'", DEBUG_COREAI);

    ClearAllActions(TRUE);

    //broadcast death
    SpeakString("BC_DEAD", TALKVOLUME_SILENT_TALK);

    _PrintString(GetName(OBJECT_SELF) + " killed by " + GetName(GetLastKiller()));

//  TODO: use a different generator for special death or XP reward
//  if (GetLocalInt( NPC_SELF, "BALORDEATH"))
//      MeCreateMeme("i_balordeath", PRIO_HIGH, PRIO_DEFAULT, MEME_INSTANT);

    _End();
}

void g_combatai_inv()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='InvDisturbed'", DEBUG_COREAI);

    object oT = GetLastDisturbed();

    if (oT != OBJECT_INVALID) // TODO: add a check if we really notified the thief
    {
        if (!GetIsEnemy(oT) && GetMaster(OBJECT_SELF) != oT)
        {
            SetIsTemporaryEnemy(oT, OBJECT_SELF, TRUE, GetLocalFloat(MEME_SELF, "GrudgeTime"));
            _PrintString("Setting thief as enemy");
        }
        CombatResume();
    }

    _End();
}

void g_combatai_mgk()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='SpellCastAt'", DEBUG_COREAI);

    int iS = GetLastSpell();
    object oC = GetLastSpellCaster();

    if (!GetLastSpellHarmful())
    {
        // hit by friendly spell

        if (iS == SPELL_RAISE_DEAD || iS == SPELL_RESURRECTION)
        {
            SetCommandable(TRUE, OBJECT_SELF);
            SetLocalObject(NPC_SELF, "#RAISER", OBJECT_INVALID);
        }
        else if (iS == SPELL_HEAL || iS == SPELL_CURE_CRITICAL_WOUNDS ||
                 iS == SPELL_CURE_SERIOUS_WOUNDS || iS == SPELL_CURE_MODERATE_WOUNDS ||
                 iS == SPELL_CURE_LIGHT_WOUNDS || iS == SPELL_CURE_MINOR_WOUNDS )
        {
            if (oC != OBJECT_SELF && GetIsFriend(oC))
                PlayVoiceChat(VOICE_CHAT_THANKS);
            SetLocalObject(NPC_SELF, "#HEALER", OBJECT_INVALID);
        }
        else if (iS == SPELL_DARKVISION)
        {
           SetLocalInt(NPC_SELF, "#DARKNESS", 0);
           SetLocalObject(NPC_SELF, "#VISION", OBJECT_INVALID);
        }
        else if (iS == SPELL_SEE_INVISIBILITY)
        {
           SetLocalInt(NPC_SELF, "#VANISHED", 0);
           SetLocalObject(NPC_SELF, "#VISION", OBJECT_INVALID);
        }
        else if (iS == SPELL_TRUE_SEEING)
        {
           SetLocalInt(NPC_SELF, "#DARKNESS", 0);
           SetLocalInt(NPC_SELF, "#VANISHED", 0);
           SetLocalObject(NPC_SELF, "#VISION", OBJECT_INVALID);
        }
    }
    else
    {
       if (!GetIsFriend(oC) && !GetIsEnemy(oC) && GetMaster(OBJECT_SELF) != oC)
       {
           //neutrals
           SetIsTemporaryEnemy(oC, OBJECT_SELF, TRUE, GetLocalFloat(MEME_SELF, "GrudgeTime"));
       }
       CombatResume();
    }

    if (iS == SPELL_DARKNESS)
       SetLocalInt(NPC_SELF, "#DARKNESS", 1);

    _End();
}

void g_combatai_rst()
{
    _Start("Generator name='" + _GetName(MEME_SELF) + "' timing='Rest'", DEBUG_COREAI);

    if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Taking a rest");
    CombatInitCache();

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_docombat (Docombat)
 *  Author:  Joel Martin (taken from NamelessOne's DoCombat routine),
 *           modifications by Niveau0
 *    Date:  Jan, 2004
 * Purpose:  This is the meme responsible for determining all combat actions.
 -----------------------------------------------------------------------------
 * No data.
 -----------------------------------------------------------------------------*/
void i_docombat_ini()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='Ini'", DEBUG_COREAI);

    CombatInitCache();

    _End();
}

void i_docombat_go()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='Go'", DEBUG_COREAI);

    if (GetCurrentAction() == ACTION_CASTSPELL)
    {
        // TODO: is this possible? if the action is not finished, this
        // should never be called
        _PrintString("Avoid disturbing spellcast", DEBUG_COREAI);
        _End();
        return;
    }

    if (GetTarget(OBJECT_SELF, TRUE) == OBJECT_INVALID)
    {
        _PrintString("No target", DEBUG_COREAI);
        _End();
        return;
    }

    int iDelay = GetLocalInt(NPC_SELF, "#INCOMBAT");
    int iSec = GetTimeSecond();
    // in combat slow down actions (do nothing)
    if (iDelay > 0 && GetCurrentAction() != ACTION_INVALID)
    {
        // security time check, g_combatai_end fails to execute sometimes
        int iLast = GetLocalInt(NPC_SELF, "#LASTSEC");
        if (iSec < iLast) iSec += 60;
        if ((iSec - iLast) <= iDelay)
        {
             _PrintString("INCOMBAT", DEBUG_COREAI);
            _End();
            return;
        }
        SetLocalInt(NPC_SELF, "#LASTSEC", iSec);
    }
    else
    {
        SetLocalInt(NPC_SELF, "#INCOMBAT", 1);
        SetLocalInt(NPC_SELF, "#LASTSEC", iSec);
    }

    //don't bother running scripts if we can't do anything
    if (!CanAct())
    {
        _PrintString("Cannot act: " + GetName(OBJECT_SELF), DEBUG_COREAI);
        ActionWait(6.0);
        _End();
        return;
    }

    //make combat noise for nearby listeners
    // TODO: why configurable?
    MeCallFunction(GetLocalString(NPC_SELF, COMBAT_FIGHTBROADCAST));

    CombatAnalyseSituation();

    if (MeRespond("Combat") == "")
        _PrintString( "ERROR: " + _GetName(OBJECT_SELF) + " has no action. When you make a combat response table your last entry should generally have a 100% chance of succeeding.");

    _End();
    return;
}

void i_docombat_end()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='End'", DEBUG_COREAI);

    SetLocalObject(OBJECT_SELF, "#LASTTARGET", OBJECT_INVALID); // reset target for next lookup

    if (GetTarget() != OBJECT_INVALID)
    {
        _PrintString("I still see enemies, go get them.", DEBUG_COREAI);
        MeResumeMeme(MEME_SELF, FALSE);
    }
    else
    {
        _PrintString("No more enemies, take breather.", DEBUG_COREAI);

        // done fighting, reset combat state.
        MeSetActiveResponseTable("Combat", GCT, "*");

        SetLocalInt(NPC_SELF, "#EQUIPMELEE", 0);
        SetLocalInt(NPC_SELF, "#EQUIPRANGED", 0);
        SetLocalInt(NPC_SELF, "#FASTBUFFED", 0);
        MeSuspendMeme(MEME_SELF, FALSE);
        ClearAllActions(TRUE);

        if (!GetIsObjectValid(GetLocalObject(MEME_SELF, "RestMeme")) &&
            GetCurrentHitPoints() < GetMaxHitPoints())
        {
            // checking only hit points this is not friendly for spellcasters
            // but they should not rest to much, so it should be enough if
            // they only rest after getting hurt
            object oMeme = MeCreateMeme("i_rest", PRIO_DEFAULT, 50, MEME_RESUME | MEME_REPEAT);
            SetLocalObject(MEME_SELF, "RestMeme", oMeme);
            MeUpdateActions();
        }
    }

    _End();

    return;
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_castfastbuff (DoFastBuff)
 *  Author:  Joel Martin (taken from NamelessOne's DoFastBuff routine)
 *           modifications by Niveau0
 *    Date:  Jan, 2004
 * Purpose:  This is the meme responsible for immediately casting buff spells on
 *           perceiving an enemy.
 -----------------------------------------------------------------------------
 * No data.
 -----------------------------------------------------------------------------*/
void i_castfastbuff_go()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='Go'", DEBUG_COREAI);

    _PrintString("FASTBUFF: " + GetName(OBJECT_SELF));

    // TODO: check if fastbuffing is bad if enemies are too near
    MeCallFunction(GetLocalString(NPC_SELF, COMBAT_FASTBUFFS));

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_castvision (DoVision)
 *  Author:  Joel Martin (taken from NamelessOne's DoVision routine)
 *           modifications by Niveau0
 *    Date:  Jan, 2004
 * Purpose:  This is the meme responsible for immediately reacting to a vanishing
 *           enemy.
 -----------------------------------------------------------------------------
 * No data.
 -----------------------------------------------------------------------------*/
void i_castvision_go()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='Go'", DEBUG_COREAI);

    MeCallFunction(GetLocalString(NPC_SELF, COMBAT_VISION));

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_movetolocation (DoMoveToLocation)
 *  Author:  Joel Martin (taken from NamelessOne's DoMoveToLocation routine)
 *           modifications by Niveau0
 *    Date:  Jan, 2004
 * Purpose:  This is the meme allows the NPC to move to a specified location
 *           using any special movement abilities it may have (Teleport, etc).
 -----------------------------------------------------------------------------
 * lDest - The location to move to.
 -----------------------------------------------------------------------------*/
void i_movetolocation_go()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='Go'", DEBUG_COREAI);

    SetLocalLocation(NPC_SELF, "lDest", GetLocalLocation(MEME_SELF, "lDest"));
    MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOLOCATION), OBJECT_SELF);

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_castheal (DoSpellHeal)
 *  Author:  Joel Martin (taken from NamelessOne's DoSpellHeal routine)
 *           modifications by Niveau0
 *    Date:  Jan, 2004
 * Purpose:  This is the meme responsible for the NPC using its healing abilities.
-----------------------------------------------------------------------------
 * oTarget - The target needing healing.
 -----------------------------------------------------------------------------*/
void i_castheal_go()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='Go'", DEBUG_COREAI);

    object oTarget = GetLocalObject(MEME_SELF, "Target");
    MeCallFunction(GetLocalString(NPC_SELF, COMBAT_SPELLHEAL), oTarget);

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_guardmaster (GuardMaster)
 *  Author:  Joel Martin
 *           modifications by Niveau0
 *    Date:  Jan, 2004
 * Purpose:  This is the meme responsible for allowing a summoned creature to
 *           follow its master's "Guard Me" command.
 -----------------------------------------------------------------------------
 * oT - The target threatening our master.
 -----------------------------------------------------------------------------*/
void i_guardmaster_go()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='Go'", DEBUG_COREAI);

    object oT = GetLocalObject( MEME_SELF, "Target" );

    // TODO this meme gets called one time for the Guardmaster command
    // is this enough? does it start combat then?

    if (!GetIsObjectValid(MeCallFunction(GetLocalString(NPC_SELF, COMBAT_SPELLDIRECT), oT)) &&
        !GetIsObjectValid(MeCallFunction(GetLocalString(NPC_SELF, COMBAT_TOUCH), oT)) &&
        !GetIsObjectValid(MeCallFunction(GetLocalString(NPC_SELF, COMBAT_ATTACKRANGED), oT)) &&
        !GetIsObjectValid(MeCallFunction(GetLocalString(NPC_SELF, COMBAT_ATTACKMELEE), oT)))
        PlayVoiceChat(VOICE_CHAT_CANTDO);
    else
        PlayVoiceChat(VOICE_CHAT_CANDO);

    _End();
}

/*  Script:  Meme Event Execution Script
 *    Info:  Following script to follow another character.
 *  Timing:  Called by to make NPC approach leader.
 *  Author:  Sam Jones
 *           modifications by Niveau0
 *    Date:  Jan, 2004
 */
void i_follow_ini()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' timing='Initialize'", DEBUG_COREAI);

    if (GetLocalObject(MEME_SELF, "Leader") == OBJECT_INVALID)
        SetLocalObject(MEME_SELF, "Leader", GetMaster(OBJECT_SELF));

    if (GetLocalFloat(NPC_SELF, "FollowDistance") == 0.0)
        SetLocalFloat(NPC_SELF, "FollowDistance", 3.0);

    _End();
}

void i_follow_go()
{
    _Start("Meme name='" + _GetName(MEME_SELF) + "' timing='Go'", DEBUG_COREAI);

    object oLeader = GetLocalObject(MEME_SELF, "Leader");
    float fDistance = GetLocalFloat(NPC_SELF, "FollowDistance");

    if (GetDistanceToObject(oLeader) > fDistance * 2.0)
        ActionMoveToObject(oLeader, TRUE, fDistance);
    else
        ActionMoveToObject(oLeader, FALSE, fDistance);

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_rest
 *  Author:  Niveau0
 *    Date:  Feb, 2004
 * Purpose:  This is the meme responsible for the NPC resting after combat.
 -----------------------------------------------------------------------------*/
void i_rest_go()
{
    int iRestWait = 30; // TODO make configurable
    if (GetIsObjectValid(GetTarget()) || GetTimeSinceLastCombat() < iRestWait)
    {
        ActionWait(6.0);
        return;
    }

    _Start("Meme name='" + _GetName(MEME_SELF) + "' event='Go'", DEBUG_COREAI);

    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

    ActionRest();

    int iRace = GetRacialType(OBJECT_SELF);
    if (iRace == RACIAL_TYPE_HUMAN ||
        iRace == RACIAL_TYPE_HUMANOID_GOBLINOID ||
        iRace == RACIAL_TYPE_HUMANOID_MONSTROUS ||
        iRace == RACIAL_TYPE_HUMANOID_ORC ||
        iRace == RACIAL_TYPE_HUMANOID_REPTILIAN)
        ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 0.5, 20.0);

    _End();
}

/*-----------------------------------------------------------------------------
 * Combat cache
 -----------------------------------------------------------------------------*/
void AddFeatInfo(string sList, int iPos, int iFeat)
{
    object o = GetModule();

    if (iPos < 0) // store max value
        SetLocalInt(o, sList, iFeat);
    else
        SetLocalInt(o, sList+IntToString(iPos), iFeat);
}

void AddSpellInfo(string sList, int iPos, int iLevel, int iSpell,
                  float fSize=0.0, float fRange=0.0, int iDisc=0)
{
    object o = GetModule();

    if (iPos < 0) // store max value
        SetLocalInt(o, sList, iSpell);
    else
    {
        string sPos = IntToString(iPos);
        SetLocalInt(o, sList+sPos, iSpell);
        SetLocalInt(o, sList+"L"+sPos, iLevel);
        SetLocalFloat(o, sList+"S"+sPos, fSize);
        SetLocalFloat(o, sList+"R"+sPos, fRange);
        SetLocalInt(o, sList+"D"+sPos, iDisc);
    }
}

void InitFeatureInfo()
{
    int iCnt;

    // enhance features
    iCnt = 0;
    AddFeatInfo("#ENHFEAT", ++iCnt, FEAT_EMPTY_BODY);
    AddFeatInfo("#ENHFEAT", ++iCnt, FEAT_BARBARIAN_RAGE);
    AddFeatInfo("#ENHFEAT", ++iCnt, FEAT_BARD_SONGS);
    AddFeatInfo("#ENHFEATMAX", -1, iCnt);

    // melee features
    iCnt = 0;
    AddFeatInfo("#FEAT", ++iCnt, FEAT_IMPROVED_KNOCKDOWN);
    AddFeatInfo("#FEAT", ++iCnt, FEAT_KNOCKDOWN);
    AddFeatInfo("#FEAT", ++iCnt, FEAT_CALLED_SHOT);
    AddFeatInfo("#FEAT", ++iCnt, FEAT_IMPROVED_DISARM);
    AddFeatInfo("#FEAT", ++iCnt, FEAT_DISARM);
    AddFeatInfo("#FEAT", ++iCnt, FEAT_STUNNING_FIST);
    AddFeatInfo("#FEAT", ++iCnt, FEAT_QUIVERING_PALM);
    AddFeatInfo("#FEATMAX", -1, iCnt);
}

void InitSpellInfo()
{
    int iCnt;
    object o = GetModule();

    // touch spells
    iCnt = 0;
    AddSpellInfo("#TSPL", ++iCnt, 6, SPELL_HARM);
    AddSpellInfo("#TSPL", ++iCnt, 5, SPELL_POISON);
    AddSpellInfo("#TSPL", ++iCnt, 4, SPELL_BESTOW_CURSE);
    AddSpellInfo("#TSPL", ++iCnt, 3, SPELL_VAMPIRIC_TOUCH);
    AddSpellInfo("#TSPL", ++iCnt, 2, SPELL_GHOUL_TOUCH);
    AddSpellInfo("#TSPLMAX", -1, 0, iCnt);

    // summon spells
    iCnt = 0;
    AddSpellInfo("#SUMMONSPL", ++iCnt, 9, SPELL_SUMMON_CREATURE_IX);
    // Currently locked out due to slow down issues with Balor + Succubus
    //AddSpellInfo("#SUMMONSPL", ++iCnt, 9, SPELLABILITY_SUMMON_TANARRI);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 9, SPELL_GATE);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 9, SPELL_ELEMENTAL_SWARM);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 8, SPELL_SUMMON_CREATURE_VIII);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 8, SPELL_CREATE_UNDEAD);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 8, SPELL_CREATE_GREATER_UNDEAD);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 7, SPELL_GREATER_PLANAR_BINDING);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 7, SPELL_SUMMON_CREATURE_VII);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 7, SPELL_MORDENKAINENS_SWORD);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 6, SPELL_SUMMON_CREATURE_VI);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 6, SPELL_PLANAR_BINDING);
    // Spell/Talent Bug
    // AddSpellInfo("#SUMMONSPL", ++iCnt, 5, SPELL_SHADES_SUMMON_SHADOW);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 5, SPELL_SUMMON_CREATURE_V);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 5, SPELL_ANIMATE_DEAD);
    // Spell/Talent Bug
    //    AddSpellInfo("#SUMMONSPL", ++iCnt, 4, SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 4, SPELL_LESSER_PLANAR_BINDING);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 4, SPELL_SUMMON_CREATURE_IV);
    // Spell/Talent Bug
    AddSpellInfo("#SUMMONSPL", ++iCnt, 3, SPELL_SHADOW_CONJURATION_SUMMON_SHADOW);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 3, SPELL_SUMMON_CREATURE_III);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 2, SPELL_SUMMON_CREATURE_II);
    AddSpellInfo("#SUMMONSPL", ++iCnt, 1, SPELL_SUMMON_CREATURE_I);
    AddSpellInfo("#SUMMONSPLMAX", -1, 0, iCnt);

    // defend single spells
    iCnt = 0;
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 7, SPELL_REGENERATE);
    // SELF ONLY?
    // AddSpellInfo("#ENHSINGLESPL", ++iCnt, 7, SPELL_DIVINE_POWER);
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 4, SPELL_IMPROVED_INVISIBILITY);
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 3, SPELL_HASTE);
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 2, SPELL_AID);
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 2, SPELL_BULLS_STRENGTH);
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 2, SPELL_ENDURANCE);
    // not a good general buff
    // AddSpellInfo("#ENHSINGLESPL", ++iCnt, 2, SPELL_FOXS_CUNNING);
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 2, SPELL_CATS_GRACE);
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 1, SPELL_MAGE_ARMOR);
    AddSpellInfo("#ENHSINGLESPL", ++iCnt, 0, SPELL_RESISTANCE);
    AddSpellInfo("#ENHSINGLESPLMAX", -1, 0, iCnt);

    // defend self spells
    iCnt = 0;
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 7, SPELL_REGENERATE);
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 6, SPELL_DIVINE_POWER);
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 4, SPELL_IMPROVED_INVISIBILITY);
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 2, SPELL_AID);
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 2, SPELL_BULLS_STRENGTH);
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 2, SPELL_ENDURANCE);
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 2, SPELL_FOXS_CUNNING);
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 1, SPELL_MAGE_ARMOR);
    AddSpellInfo("#ENHSELFSPL", ++iCnt, 0, SPELL_RESISTANCE);
    AddSpellInfo("#ENHSELFSPLMAX", -1, 0, iCnt);

    // direct spells
    iCnt = 0;
    AddSpellInfo("#DSPL", ++iCnt, 9, SPELL_ENERGY_DRAIN);
    AddSpellInfo("#DSPL", ++iCnt, 9, SPELL_DOMINATE_MONSTER);
    AddSpellInfo("#DSPL", ++iCnt, 9, SPELL_POWER_WORD_KILL);
    AddSpellInfo("#DSPL", ++iCnt, 8, SPELL_FINGER_OF_DEATH);
    AddSpellInfo("#DSPL", ++iCnt, 8, SPELL_GREATER_PLANAR_BINDING);
    AddSpellInfo("#DSPL", ++iCnt, 7, SPELL_DESTRUCTION);
    AddSpellInfo("#DSPL", ++iCnt, 7, SPELL_POWER_WORD_STUN);
    AddSpellInfo("#DSPL", ++iCnt, 6, SPELL_PLANAR_BINDING);
    // Spell/Talent Bug Problem
    // AddSpellInfo("#DSPL", ++iCnt, 6, SPELL_SHADES_FIREBALL);
    AddSpellInfo("#DSPL", ++iCnt, 5, SPELL_SLAY_LIVING);
    AddSpellInfo("#DSPL", ++iCnt, 5, SPELL_DOMINATE_PERSON);
    AddSpellInfo("#DSPL", ++iCnt, 5, SPELL_FEEBLEMIND);
    // Spell/Talent Bug
    // AddSpellInfo("#DSPL", ++iCnt, 5, SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW);
    AddSpellInfo("#DSPL", ++iCnt, 5, SPELL_HOLD_MONSTER);
    AddSpellInfo("#DSPL", ++iCnt, 5, SPELL_LESSER_PLANAR_BINDING);
    AddSpellInfo("#DSPL", ++iCnt, 4, SPELL_CHARM_MONSTER);
    AddSpellInfo("#DSPL", ++iCnt, 4, SPELL_ENERVATION);
    // Spell/Talent Bug
    // AddSpellInfo("#DSPL", ++iCnt, 0, SPELL_SHADOW_CONJURATION_MAGIC_MISSILE);
    AddSpellInfo("#DSPL", ++iCnt, 4, SPELL_PHANTASMAL_KILLER);
    AddSpellInfo("#DSPL", ++iCnt, 3, SPELL_BLINDNESS_AND_DEAFNESS);
    AddSpellInfo("#DSPL", ++iCnt, 3, SPELL_CONTAGION);
    AddSpellInfo("#DSPL", ++iCnt, 3, SPELL_SEARING_LIGHT);
    AddSpellInfo("#DSPL", ++iCnt, 3, SPELL_FLAME_ARROW);
    AddSpellInfo("#DSPL", ++iCnt, 3, SPELL_HOLD_PERSON);
    AddSpellInfo("#DSPL", ++iCnt, 2, SPELL_NEGATIVE_ENERGY_RAY);
    AddSpellInfo("#DSPL", ++iCnt, 2, SPELL_CHARM_PERSON_OR_ANIMAL);
    AddSpellInfo("#DSPL", ++iCnt, 2, SPELL_FLAME_LASH);
    AddSpellInfo("#DSPL", ++iCnt, 2, SPELL_MELFS_ACID_ARROW);
    AddSpellInfo("#DSPL", ++iCnt, 1, SPELL_DOOM);
    AddSpellInfo("#DSPL", ++iCnt, 1, SPELL_SCARE);
    AddSpellInfo("#DSPL", ++iCnt, 1, SPELL_CHARM_PERSON);
    AddSpellInfo("#DSPL", ++iCnt, 1, SPELL_MAGIC_MISSILE);
    AddSpellInfo("#DSPL", ++iCnt, 1, SPELL_RAY_OF_ENFEEBLEMENT);
    AddSpellInfo("#DSPL", ++iCnt, 0, SPELL_DAZE);
    AddSpellInfo("#DSPL", ++iCnt, 0, SPELL_RAY_OF_FROST);
    AddSpellInfo("#DSPLMAX", -1, 0, iCnt);

    // group enhance spells
    iCnt = 0;
    AddSpellInfo("#GRPENHSPL", ++iCnt, 0, SPELL_MIND_BLANK);
    AddSpellInfo("#GRPENHSPL", ++iCnt, 0, SPELL_NATURES_BALANCE);
    AddSpellInfo("#GRPENHSPL", ++iCnt, 0, SPELL_AURA_OF_VITALITY);
    AddSpellInfo("#GRPENHSPL", ++iCnt, 0, SPELL_PROTECTION_FROM_SPELLS);
    AddSpellInfo("#GRPENHSPL", ++iCnt, 0, SPELL_MASS_HASTE);
    AddSpellInfo("#GRPENHSPL", ++iCnt, 0, SPELL_PRAYER);
    AddSpellInfo("#GRPENHSPL", ++iCnt, 0, SPELL_BLESS);
    AddSpellInfo("#GRPENHSPLMAX", -1, 0, iCnt);

    // area spells
    iCnt = 0;
    // SPELL_CIRCLE_OF_DOOM?
    // SPELL_MASS_DOMINATION?
    // SPELL_MASS_CHARM?
    // SPELL_POWER_WORD_STUN?
    AddSpellInfo("#AREASPL", ++iCnt, 9, SPELL_IMPLOSION,        RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPL", ++iCnt, 9, SPELL_STORM_OF_VENGEANCE, RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPL", ++iCnt, 9, SPELL_METEOR_SWARM,     RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPL", ++iCnt, 9, SPELL_POWER_WORD_KILL,  RADIUS_SIZE_HUGE, 8.5);
    AddSpellInfo("#AREASPL", ++iCnt, 9, SPELL_WAIL_OF_THE_BANSHEE, RADIUS_SIZE_COLOSSAL, 8.5, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 9, SPELL_WEIRD,            RADIUS_SIZE_COLOSSAL, 8.5, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 8, SPELL_EARTHQUAKE,       RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPL", ++iCnt, 8, SPELL_FIRE_STORM,       RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPL", ++iCnt, 8, SPELL_BOMBARDMENT,      RADIUS_SIZE_HUGE);
    AddSpellInfo("#AREASPL", ++iCnt, 8, SPELL_SUNBEAM,          RADIUS_SIZE_COLOSSAL, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 8, SPELL_HORRID_WILTING,   RADIUS_SIZE_COLOSSAL, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 8, SPELL_INCENDIARY_CLOUD, RADIUS_SIZE_LARGE, 40.0);
    AddSpellInfo("#AREASPL", ++iCnt, 8, SPELL_MASS_BLINDNESS_AND_DEAFNESS, RADIUS_SIZE_MEDIUM, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 7, SPELL_WORD_OF_FAITH,    RADIUS_SIZE_COLOSSAL, 20.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 7, SPELL_CREEPING_DOOM,    RADIUS_SIZE_LARGE, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 7, SPELL_FIRE_STORM,       RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPL", ++iCnt, 7, SPELL_DELAYED_BLAST_FIREBALL, RADIUS_SIZE_HUGE, 20.0);
    // TODO AddSpellInfo("#AREASPL", ++iCnt, 7, SPELL_GREAT_THUNDERCLAP);
    AddSpellInfo("#AREASPL", ++iCnt, 7, SPELL_PRISMATIC_SPRAY,  RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPL", ++iCnt, 6, SPELL_BLADE_BARRIER,    RADIUS_SIZE_HUGE, 20.0);
    // TODO AddSpellInfo("#AREASPL", ++iCnt, 6, SPELL_STONEHOLD, RADIUS_SIZE_HUGE);
    //NOTE: SPELL_ACID_FOG == 0
    //using temporary value for acid fog inside this function
    AddSpellInfo("#AREASPL", ++iCnt, 6, -69,                    RADIUS_SIZE_LARGE, 40.0);
    AddSpellInfo("#AREASPL", ++iCnt, 6, SPELL_CHAIN_LIGHTNING,  RADIUS_SIZE_COLOSSAL, 40.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 6, SPELL_CIRCLE_OF_DEATH,  RADIUS_SIZE_COLOSSAL, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 6, SPELL_ISAACS_GREATER_MISSILE_STORM, RADIUS_SIZE_GARGANTUAN, 0.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 5, SPELL_FLAME_STRIKE,     RADIUS_SIZE_MEDIUM, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 5, SPELL_ICE_STORM,        RADIUS_SIZE_HUGE, 40.0);
    AddSpellInfo("#AREASPL", ++iCnt, 5, SPELL_WALL_OF_FIRE,     RADIUS_SIZE_HUGE, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 5, SPELL_CLOUDKILL,        RADIUS_SIZE_LARGE, 40.0);
    AddSpellInfo("#AREASPL", ++iCnt, 5, SPELL_CONE_OF_COLD,     RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPL", ++iCnt, 5, SPELL_MIND_FOG,         RADIUS_SIZE_COLOSSAL, 40.0);
    AddSpellInfo("#AREASPL", ++iCnt, 5, SPELL_FIREBRAND,        RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPL", ++iCnt, 4, SPELL_HAMMER_OF_THE_GODS, RADIUS_SIZE_HUGE, 20.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 4, SPELL_CONFUSION,        RADIUS_SIZE_LARGE, 0.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 4, SPELL_EVARDS_BLACK_TENTACLES, RADIUS_SIZE_LARGE, 20.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 4, SPELL_FEAR,             RADIUS_SIZE_LARGE, 20.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 4, SPELL_ISAACS_LESSER_MISSILE_STORM, RADIUS_SIZE_GARGANTUAN, 0.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 3, SPELL_CALL_LIGHTNING,   RADIUS_SIZE_LARGE, 40.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 3, SPELL_SPIKE_GROWTH,     RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPL", ++iCnt, 3, SPELL_FIREBALL,         RADIUS_SIZE_HUGE, 40.0);
    AddSpellInfo("#AREASPL", ++iCnt, 3, SPELL_GUST_OF_WIND,     RADIUS_SIZE_HUGE);
    AddSpellInfo("#AREASPL", ++iCnt, 3, SPELL_LIGHTNING_BOLT,   RADIUS_SIZE_HUGE, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 3, SPELL_NEGATIVE_ENERGY_BURST, RADIUS_SIZE_HUGE, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 3, SPELL_SLOW,             RADIUS_SIZE_COLOSSAL, 8.5, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 3, SPELL_STINKING_CLOUD,   RADIUS_SIZE_HUGE, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 2, SPELL_DARKNESS,         RADIUS_SIZE_HUGE, 40.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 2, SPELL_SOUND_BURST,      RADIUS_SIZE_MEDIUM, 40.0);
    AddSpellInfo("#AREASPL", ++iCnt, 2, SPELL_WEB,              RADIUS_SIZE_HUGE, 20.0);
    AddSpellInfo("#AREASPL", ++iCnt, 2, SPELL_BALAGARNSIRONHORN, RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPL", ++iCnt, 1, SPELL_BANE,             RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPL", ++iCnt, 1, SPELL_ENTANGLE,         RADIUS_SIZE_LARGE, 40.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 1, SPELL_GREASE,           RADIUS_SIZE_MEDIUM, 40.0);
    AddSpellInfo("#AREASPL", ++iCnt, 1, SPELL_SLEEP,            RADIUS_SIZE_HUGE, 20.0, TRUE);
    AddSpellInfo("#AREASPL", ++iCnt, 1, SPELL_BURNING_HANDS,    RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPL", ++iCnt, 1, SPELL_COLOR_SPRAY,      RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPLMAX", -1, 0, iCnt);
}

void InitSpellabilityInfo()
{
    int iCnt;
    object o = GetModule();

    // breath attacks
    iCnt = 0;
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_ACID, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_COLD, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_FEAR, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_FIRE, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_GAS, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_LIGHTNING, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_PARALYZE, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_SLEEP, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_SLOW, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRT", ++iCnt, 0, SPELLABILITY_DRAGON_BREATH_WEAKEN, RADIUS_SIZE_LARGE);
    AddSpellInfo("#BRTMAX", -1, 0, iCnt);

    // defend self abilities (should fastbuffer)
    iCnt = 0;
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_DRAGON_FEAR);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_BLINDING);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_COLD);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_ELECTRICITY);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_FIRE);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_MENACE);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_OF_COURAGE);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_PROTECTION);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_STUN);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_UNEARTHLY_VISAGE);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_FEAR);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_AURA_UNNATURAL);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_EMPTY_BODY);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_TYRANT_FOG_MIST);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_RAGE_5);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_RAGE_4);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_RAGE_3);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_FEROCITY_3);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_FEROCITY_2);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_FEROCITY_1);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_INTENSITY_3);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_INTENSITY_2);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_INTENSITY_1);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_BATTLE_MASTERY);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_DIVINE_PROTECTION);
    AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_DIVINE_STRENGTH);
    // NOT DIRECTLY USEFUL IN COMBAT
    // AddSpellInfo("#ENHSELFAB", ++iCnt, 0, SPELLABILITY_DIVINE_TRICKERY);
    AddSpellInfo("#ENHSELFABMAX", -1, 0, iCnt);

    // direct spell abilities
    iCnt = 0;
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_ABILITY_DRAIN_CHARISMA);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_ABILITY_DRAIN_CONSTITUTION);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_ABILITY_DRAIN_DEXTERITY);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_ABILITY_DRAIN_INTELLIGENCE);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_ABILITY_DRAIN_STRENGTH);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_ABILITY_DRAIN_WISDOM);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_ACID);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_CHARM);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_COLD);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_CONFUSE);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_DAZE);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_DEATH);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_DISEASE);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_DOMINATE);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_FIRE);
    // why comment? also bug?
    // AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_KNOCKDOWN);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_LEVEL_DRAIN);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_LIGHTNING);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_PARALYZE);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_POISON);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_SHARDS);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_SLOW);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_STUN);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_BOLT_WEB);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_CHARM);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_CONFUSION);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_DAZE);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_DEATH);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_DOMINATE);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_DOOM);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_FEAR);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_PARALYSIS);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_GAZE_STUNNED);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_MEPHIT_SALT_BREATH);
    AddSpellInfo("#DSPLAB", ++iCnt, 0, SPELLABILITY_MEPHIT_STEAM_BREATH);
    AddSpellInfo("#DSPLABMAX", -1, 0, iCnt);

    // area spell abilities
    iCnt = 0;
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_CONE_ACID,       RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_CONE_COLD,       RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_CONE_DISEASE,    RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_CONE_FIRE,       RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_CONE_LIGHTNING,  RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_CONE_POISON,     RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_CONE_SONIC,      RADIUS_SIZE_MEDIUM, 8.5);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HOWL_CONFUSE,    RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HOWL_DAZE,       RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HOWL_DEATH,      RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HOWL_DOOM,       RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HOWL_FEAR,       RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HOWL_PARALYSIS,  RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HOWL_SONIC,      RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HOWL_STUN,       RADIUS_SIZE_COLOSSAL);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_ABILITY_DRAIN_CHARISMA, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_ABILITY_DRAIN_CONSTITUTION, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_ABILITY_DRAIN_DEXTERITY, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_ABILITY_DRAIN_INTELLIGENCE, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_ABILITY_DRAIN_STRENGTH, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_ABILITY_DRAIN_WISDOM, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_COLD,      RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_DEATH,     RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_DISEASE,   RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_DROWN,     RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_FIRE,      RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_HOLY,      RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_LEVEL_DRAIN, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_LIGHTNING, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_NEGATIVE,  RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_POISON,    RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_SPORES,    RADIUS_SIZE_LARGE);
    // HotU AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_PULSE_WHIRLWIND, RADIUS_SIZE_LARGE);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_DRAGON_WING_BUFFET, RADIUS_SIZE_GARGANTUAN);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_KRENSHAR_SCARE,  RADIUS_SIZE_MEDIUM);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_GOLEM_BREATH_GAS, RADIUS_SIZE_MEDIUM);
    AddSpellInfo("#AREASPLAB", ++iCnt, 0, SPELLABILITY_HELL_HOUND_FIREBREATH, RADIUS_SIZE_MEDIUM);
    AddSpellInfo("#AREASPLABMAX", -1, 0, iCnt);
}

/*------------------------------------------------------------------------------
 *   Script: Library Initialization and Scheduling
 *
 *   This main() defines this script as a library. The following two steps
 *   handle registration and execution of the scripts inside this library. It
 *   is assumed that a call to MeLoadLibrary() has occured in the ModuleLoad
 *   callback. This lets the MeExecuteScript() function know how to find the
 *   functions in this library. You can create your own library by copying this
 *   file and editing "cb_mod_onload" to register the name of your new library.
 ------------------------------------------------------------------------------*/

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'");

    //  Step 1: Library Setup
    //
    //  This is run once to bind your scripts to a unique number.
    //  The number is composed of a top half - for the "class" and lower half
    //  for the specific "method". If you are adding your own scripts, copy
    //  the example, make sure to change the first number. Then edit the
    //  switch statement following this if statement.

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("g_combatai",       "_see",     0x0100+0x01);
        MeLibraryImplements("g_combatai",       "_hea",     0x0100+0x02);
        MeLibraryImplements("g_combatai",       "_van",     0x0100+0x03);
        MeLibraryImplements("g_combatai",       "_end",     0x0100+0x04);
        MeLibraryImplements("g_combatai",       "_tlk",     0x0100+0x05);
        MeLibraryImplements("g_combatai",       "_atk",     0x0100+0x06);
        MeLibraryImplements("g_combatai",       "_dmg",     0x0100+0x07);
        MeLibraryImplements("g_combatai",       "_dth",     0x0100+0x08);
        MeLibraryImplements("g_combatai",       "_inv",     0x0100+0x09);
        MeLibraryImplements("g_combatai",       "_mgk",     0x0100+0x0a);
        MeLibraryImplements("g_combatai",       "_rst",     0x0100+0x0b);
        MeLibraryImplements("g_combatai",       "_ini",     0x0100+0x0c);

        MeLibraryImplements("i_follow",         "_go",      0x0200+0x01);

        MeLibraryImplements("i_docombat",       "_go",      0x0300+0x01);
        MeLibraryImplements("i_docombat",       "_end",     0x0300+0x02);
        MeLibraryImplements("i_docombat",       "_ini",     0x0300+0x03);

        MeLibraryImplements("i_castfastbuff",   "_go",      0x0400+0x01);

        MeLibraryImplements("i_castvision",     "_go",      0x0500+0x01);

        MeLibraryImplements("i_movetolocation", "_go",      0x0600+0x01);

        MeLibraryImplements("i_castheal",       "_go",      0x0700+0x01);

        MeLibraryImplements("i_guardmaster",    "_go",      0x0800+0x01);

        MeLibraryImplements("i_rest",           "_go",      0x0900+0x01);

        MeRegisterClass("combat_archer");
        MeLibraryImplements("c_combat_archer",  "_ini",     0x1000+0xff);
        MeLibraryImplements("c_combat_archer",  "_go",      0x1000+0x01);

        MeRegisterClass("combat_mage");
        MeLibraryImplements("c_combat_mage",    "_ini",     0x1100+0xff);
        MeLibraryImplements("c_combat_mage",    "_go",      0x1100+0x01);

        MeRegisterClass("combat_fighter");
        MeLibraryImplements("c_combat_fighter", "_ini",     0x1200+0xff);
        MeLibraryImplements("c_combat_fighter", "_go",      0x1200+0x01);

        MeRegisterClass("combat_cleric");
        MeLibraryImplements("c_combat_cleric",  "_ini",     0x1300+0xff);
        MeLibraryImplements("c_combat_cleric",  "_go",      0x1300+0x01);

        MeRegisterClass("combat_vermin");
        MeLibraryImplements("c_combat_vermin",  "_ini",     0x1400+0xff);
        MeLibraryImplements("c_combat_vermin",  "_go",      0x1400+0x01);

        MeRegisterClass("combat_animal");
        MeLibraryImplements("c_combat_animal",  "_ini",     0x1500+0xff);
        MeLibraryImplements("c_combat_animal",  "_go",      0x1500+0x01);

        MeRegisterClass("combat_defensive_cast");
        MeLibraryImplements("c_combat_defensive_cast",  "_ini",  0x1600+0xff);
        MeLibraryImplements("c_combat_defensive_cast",  "_go",   0x1600+0x01);

        MeRegisterClass("combat_aggressive_cast");
        MeLibraryImplements("c_combat_aggressive_cast",  "_ini", 0x1700+0xff);
        MeLibraryImplements("c_combat_aggressive_cast",  "_go",  0x1700+0x01);

        // init module combat cache
        InitFeatureInfo();
        InitSpellInfo();
        InitSpellabilityInfo();

        _End();
        return;
    }

    //  Step 2: Library Dispatcher
    //
    //  These switch statements are what decide to run your scripts, based
    //  on the numbers you provided in Step 1. Notice that you only need
    //  an inner switch statement if you exported more than one method
    //  (like go and end). Also notice that the value used by the case statement
    //  is the two numbers added up.

    //_PrintString("MEME_ENTRYPOINT == "+IntToHexString(MEME_ENTRYPOINT), DEBUG_UTILITY);
    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: g_combatai_see();   break;
            case 0x02: g_combatai_hea();   break;
            case 0x03: g_combatai_van();   break;
            case 0x04: g_combatai_end();   break;
            case 0x05: g_combatai_tlk();   break;
            case 0x06: g_combatai_atk();   break;
            case 0x07: g_combatai_dmg();   break;
            case 0x08: g_combatai_dth();   break;
            case 0x09: g_combatai_inv();   break;
            case 0x0a: g_combatai_mgk();   break;
            case 0x0b: g_combatai_rst();   break;
            case 0x0c: g_combatai_ini();   break;
        }   break;

        case 0x0200: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_follow_ini();  break;
            case 0x02: i_follow_go();   break;
        }   break;

        case 0x0300: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_docombat_go();     break;
            case 0x02: i_docombat_end();    break;
            case 0x03: i_docombat_ini();    break;
        }   break;

        case 0x0400: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_castfastbuff_go();   break;
        }   break;

        case 0x0500: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_castvision_go();     break;
        }   break;

        case 0x0600: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_movetolocation_go(); break;
        }   break;

        case 0x0700: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_castheal_go();  break;
        }   break;

        case 0x0800: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_guardmaster_go();  break;
        }   break;

        case 0x0900: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_rest_go();  break;
        }   break;

        case 0x1000: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_combat_archer_ini(); break;
            case 0x01: c_combat_archer_go(); break;
        }   break;

        case 0x1100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_combat_mage_ini(); break;
            case 0x01: c_combat_mage_go(); break;
        }   break;

        case 0x1200: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_combat_fighter_ini(); break;
            case 0x01: c_combat_fighter_go(); break;
        }   break;

        case 0x1300: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_combat_cleric_ini(); break;
            case 0x01: c_combat_cleric_go(); break;
        } break;

        case 0x1400: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_combat_vermin_ini(); break;
            case 0x01: c_combat_vermin_go(); break;
        } break;

        case 0x1500: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_combat_animal_ini(); break;
            case 0x01: c_combat_animal_go(); break;
        } break;

        case 0x1600: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_combat_defensive_cast_ini(); break;
            case 0x01: c_combat_defensive_cast_go(); break;
        } break;

        case 0x1700: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_combat_aggressive_cast_ini(); break;
            case 0x01: c_combat_aggressive_cast_go(); break;
        } break;
    }

    _End();
}


