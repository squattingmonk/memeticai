/* File: h_util_combat - Memetic Utility File
 * Author: Joel Martin (based upon NamelessOne's CODI Core AI utility scripts
 * Date: May, 2003
 *
 * Description
 *
 * These are the utility functions used by the g_combatai generator and its memes.
 *
 */

#include "h_debug"
#include "h_ai"
//void main(){}

// ----- Structures ------------------------------------------------------------
struct sSpellDefStatus {
    int iTotal;
    int iMantle;
    int iElem;
    int iDeath;
    int iMind;
    int iInvis;
    int iBlocker;
};

struct sPhysDefStatus {
    int iTotal;
    int iDamred;
    int iConceal;
};

// ----- Constants ------------------------------------------------------------
const int SPELL_INVALID = -1;
const int FEATURE_INVALID = -1;

// to avoid syntax problems:
const string GCT                     = "Generic Combat Table";
const string COMBAT_FASTBUFFS        = "f_FastBuffs";
const string COMBAT_SPELLHEAL        = "f_SpellHeal";
const string COMBAT_SPELLDIRECT      = "f_SpellDirect";
const string COMBAT_TOUCH            = "f_Touch";
const string COMBAT_ATTACKRANGED     = "f_AttackRanged";
const string COMBAT_ATTACKMELEE      = "f_AttackMelee";
const string COMBAT_MOVETOLOCATION   = "f_MoveToLocation";
const string COMBAT_TELEPORT         = "f_Teleport";
const string COMBAT_FIGHTBROADCAST   = "f_FightBroadcast";
const string COMBAT_COUNTERSPELL     = "f_CounterSpell";
const string COMBAT_EVACAOE          = "f_EvacAOE";
const string COMBAT_MOVETOOBJECT     = "f_MoveToObject";
const string COMBAT_REGROUP          = "f_Regroup";
const string COMBAT_DEFENDSELF       = "f_DefendSelf";
const string COMBAT_DEFENDSINGLE     = "f_DefendSingle";
const string COMBAT_ENHANCESELF      = "f_EnhanceSelf";
const string COMBAT_ENHANCESINGLE    = "f_EnhanceSingle";
const string COMBAT_SPELLHELP        = "f_SpellHelp";
const string COMBAT_SPELLRAISE       = "f_SpellRaise";
const string COMBAT_SPELLBREACH      = "f_SpellBreach";
const string COMBAT_SPELLAREA        = "f_SpellArea";
const string COMBAT_SPELLSUMMON      = "f_SpellSummon";
const string COMBAT_FEATENHANCE      = "f_FeatEnhance";
const string COMBAT_AVOIDMELEE       = "f_AvoidMelee";
const string COMBAT_TIMESTOP         = "f_TimeStop";
const string COMBAT_VISION           = "f_Vision";
const string COMBAT_BREATHWEAPON     = "f_BreathWeapon";
const string COMBAT_TURNING          = "f_Turning";
const string COMBAT_HEALSELF         = "f_HealSelf";
const string COMBAT_SPELLGRPENHANCE  = "f_SpellGroupEnhance";
const string COMBAT_DISPELAOE        = "f_DispelAOE";
const string COMBAT_DISPELSINGLE     = "f_DispelSingle";
const string COMBAT_DISMISSAL        = "f_Dismissal";
const string COMBAT_SPELLGROUPHEAL   = "f_SpellGroupHeal";
const string COMBAT_BECOMEDEFENSIVE  = "f_BecomeDefensive";
const string COMBAT_FLANK            = "f_Flank";
const string COMBAT_MELEEASSIST      = "f_MeleeAssist";

// ----- Prototypes ------------------------------------------------------------
// h_util

object MeGetNPCSelf(object oTarget = OBJECT_SELF);

// h_util_combat (this)

// Is oSelf in a state to do something?
int CanAct(object oSelf=OBJECT_SELF);
// is oWeapon really a weapon
int GetIsWeapon(object oWeapon);
// is oW a ranged weapon?
int GetIsRangedWeapon(object oW=OBJECT_INVALID);
// find nearest enemy to OBJECT_SELF, calculates only one time each combat round
// force recalculation by setting bEvalutate to TRUE
object GetTarget(object oEnt=OBJECT_SELF, int bEvaluate=FALSE);
// calculate vector dot product
float DotProduct(vector v1, vector v2);
// calculate flank location to oT
location GetFlankLoc(object oT, location lL);
// equip best melee weapon, also re-takes disarmed weapons
// ONLY in Combatround-End scripts!
int CombatEquipMelee(object oT);
// check if ability succeeds
int DoAbilityCheck(int iAbil, int iDC, object oEnt=OBJECT_SELF);
// get best talent for category
talent GetTalentSpell(int iCat, int iD);
// how much time since last fight
int GetTimeSinceLastCombat();
// get bit-encoded bad effects
int GetEffectsOnObject(object oEnt=OBJECT_SELF);
// check if oArea has negative effect on oEnt
int GetAOEThreat(object oArea, object oEnt=OBJECT_SELF);
// number of negative AOEs around oEnt
int GetAOECount();
// vector build from all AOE vectors
vector GetAOEVector();
// number of AOEs created by enemies
int GetHostileAOECount();
// vector build from all hostile AOE vectors
vector GetHostileAOEVector();
// get escape vector from AOE
vector GetAOEEvacVector(vector vS, object oEnt=OBJECT_SELF);
// compute vector of all AOEs around
void ComputeAOEVector(float fRad=15.0f, object oEnt=OBJECT_SELF);
// get target vector for area spell
vector GetAreaTarget(float fRad, float fMinRad=7.5, float fMaxRad=30.0, object oCaster=OBJECT_SELF);
// get vector for group heal
vector GetAreaHealTarget(float fRad=0.0, int iH=0, object oEnt=OBJECT_SELF);
// get target vector for friendly area spell
vector GetFriendlyAreaTarget(float fRad, int iSpell=0, int iType=0, object oCaster=OBJECT_SELF);
// get escape vector away from enemy
vector GetHostileEvacVector(vector vS, object oEnt=OBJECT_SELF);
// check if caster
int GetIsCaster(object oEnt=OBJECT_SELF);
// get buffs against magic
struct sSpellDefStatus EvaluateSpellDefenses(object oTarget=OBJECT_SELF);
// get buffs physical damage
struct sPhysDefStatus EvaluatePhysicalDefenses(object oTarget=OBJECT_SELF);
// is eT a buffering effect
int GetIsBuffEffect(effect eT);
// check if oT is a valid target for turn undead
int GetIsValidTurnTarget(object oT, object oEnt=OBJECT_SELF);
// get vector fr turn undead location
vector GetTurningVector(object oEnt=OBJECT_SELF);
// get tolerance for friend/foe ratio
float GetFriendFoeTolerance(object oEnt=OBJECT_SELF);
// get heal about for a potion
int GetPotionHealAmount(object oP);
// get healing amount potion heal talent
int GetTalentPotionHealAmount(talent tP);
// get average caster-level of effects on oT
int GetAverageEffectCasterLevel(object oT=OBJECT_SELF);
// get location of enemy associates
vector GetEnemySummonedAssociatesVector(float fRad=10.0, object oEnt=OBJECT_SELF);
// get vector of enemy planar associates
vector GetEnemyPlanarVector(float fRad=10.0, object oEnt=OBJECT_SELF);
object GetVisionDeprived(float fRad=10.0, object oT=OBJECT_SELF);
int GetHasRangedCapability(object oEnt=OBJECT_SELF);

int GetEnhanceFeat(object oEnt=OBJECT_SELF);
int GetGroupEnhanceFeat(object oEnt=OBJECT_SELF);
float GetGroupEnhanceFeatRadius(int iFeat);
int GetBestGenericProtection(object oEnt=OBJECT_SELF);

// Get bit encoded available abilities, used e.g. for GetBestHeal()
int GetHealingAbilities(object oCaster=OBJECT_SELF);
// Get bit encoded available abilities, used e.g. for GetBestHelp()
int GetHelpingAbilities(object oCaster=OBJECT_SELF);
// Get bit encoded available abilities, used e.g. for GetBestRaise()
int GetRaisingAbilities(object oCaster=OBJECT_SELF);

// Find best heal spell according to available Spells and minimum damage
int GetBestHeal(int iAbilities, object oEnt=OBJECT_SELF, int iMin=10);
// Find best help
int GetBestHelp(int iAbilities, object oEnt=OBJECT_SELF);
// Find best raise spell
int GetBestRaise(int iAbilities, int iCombat=FALSE);

int GetBestMeleeSpecial(object oTarget, int iChance=50, object oEnt=OBJECT_SELF);
int GetGroupHealSpell(int iMinLvl=0, object oCaster=OBJECT_SELF);
int GetGroupHealSpellAmount(int iH=0, object oCaster=OBJECT_SELF);
float GetGroupHealSpellRadius(int iH=0);
int GetAreaSpell(int iDisc=FALSE, int iMinLvl=0, float fR=40.0, object oCaster=OBJECT_SELF);
float GetAreaSpellRadius(int iSpell);
int GetDirectSpell(object oT, int iMinLvl=0, object oCaster=OBJECT_SELF);
int GetTouchSpell(object oT, int iMinLvl=0, object oCaster=OBJECT_SELF);
int GetSummonSpell(int iMinLvl=1, object oCaster=OBJECT_SELF);
int GetEnhanceSpellSelf(int iMinLvl=1, object oCaster=OBJECT_SELF);
int GetEnhanceSpellSingle(int iMinLvl=1, object oEnt=OBJECT_SELF, object oCaster=OBJECT_SELF);
int GetBestBreach(int iLim=30, object oEnt=OBJECT_SELF);
int GetBestDispel(int iCLvl=20, int iDLvl=20, object oEnt=OBJECT_SELF);
int GetIsDiscriminantSpell(int iSpell);
int GetBreathWeapon(object oEnt=OBJECT_SELF);
int GetGroupEnhanceSpell(int iMinLvl = 1, object oCaster=OBJECT_SELF);
float GetGroupEnhanceSpellRadius(int iSpell);

int GetDispelSpell(object oEnt=OBJECT_SELF);
int GetMaxDispelCasterLevel(object oEnt=OBJECT_SELF);
int GetVisionSpellNeeded(object oS=OBJECT_SELF, object oC=OBJECT_SELF);
int GetHasVisionSpells(object oC=OBJECT_SELF);

// little helper functions
void CombatSetDefaultFunc(object oNPC, string sVar)
{
    if (GetLocalString(oNPC, sVar) == "")
        SetLocalString(NPC_SELF, sVar, sVar);
}

object CombatResume()
{
    object oCombatMeme = GetLocalObject(NPC_SELF, "CombatMeme");
    MeResumeMeme(oCombatMeme, FALSE); // update actions is done within cb_* script
    return oCombatMeme;
}

object CombatSuspend()
{
    object oCombatMeme = GetLocalObject(NPC_SELF, "CombatMeme");
    MeSuspendMeme(oCombatMeme, FALSE); // no need to call _brk
    return oCombatMeme;
}

int UpdateSpellList(string sType, int iSpell, int iPos, object oCaster)
{
    if (!GetHasSpell(iSpell, oCaster))
    {
        int iMax = GetLocalInt(oCaster, sType + "MAX");
        if (iMax > 0)
        {
            // overwrite used spell with last spell in list
            // and decrement max list elements
            // if spell is the last one in list, just decrease max
            if (iPos != iMax)
            {
                int iLastElement = GetLocalInt(oCaster, sType + IntToString(iMax));
                SetLocalInt(oCaster, sType + IntToString(iPos), iLastElement);
            }
            SetLocalInt(oCaster, sType + "MAX", iMax-1);
        }
        return FALSE;
    }

    return TRUE;
}

int UpdateFeatureList(string sType, int iFeat, int iPos, object oUser)
{
    if (!GetHasFeat(iFeat, oUser))
    {
        int iMax = GetLocalInt(oUser, sType + "MAX");
        if (iMax > 0)
        {
            // overwrite used feature with last feature in list
            // and decrement max list elements
            if (iPos != iMax)
            {
                int iLastElement = GetLocalInt(oUser, sType + IntToString(iMax));
                SetLocalInt(oUser, sType + IntToString(iPos), iLastElement);
            }
            SetLocalInt(oUser, sType + "MAX", iMax-1);
        }
        return FALSE;
    }
    return TRUE;
}

// Init Spells/Featurelists
void CombatInitCache(object oEnt=OBJECT_SELF)
{
    object o = GetModule();
    int iMax;
    int i, iSpell;
    int iCnt;

    // features
    iCnt = 0;
    iMax = GetLocalInt(o, "#ENHFEATMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#ENHFEAT"+IntToString(i));
        if (iSpell != 0 && GetHasFeat(iSpell, oEnt) > 0)
            SetLocalInt(oEnt, "#ENHFEAT" + IntToString(++iCnt), iSpell);
    }
    SetLocalInt(oEnt, "#ENHFEATMAX", iCnt);

    // melee attack features
    iCnt = 0;
    iMax = GetLocalInt(o, "#FEATMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#FEAT"+IntToString(i));
        if (iSpell != 0 && GetHasFeat(iSpell, oEnt) > 0)
            SetLocalInt(oEnt, "#FEAT" + IntToString(++iCnt), iSpell);
    }
    SetLocalInt(oEnt, "#FEATMAX", iCnt);

    // touch spells
    iCnt = 0;
    iMax = GetLocalInt(o, "#TSPLMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#TSPL"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
        {
            SetLocalInt(oEnt, "#TSPL" + IntToString(++iCnt), iSpell);
            // store position in module-infolist, for more info
            SetLocalInt(oEnt, "#SPPOS" + IntToString(iSpell), i);
        }
    }
    SetLocalInt(oEnt, "#TSPLMAX", iCnt);

    // summon spells
    iCnt = 0;
    iMax = GetLocalInt(o, "#SUMMONSPLMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#SUMMONSPL"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
            SetLocalInt(oEnt, "#SUMMONSPL" + IntToString(++iCnt), iSpell);
    }
    SetLocalInt(oEnt, "#SUMMONSPLMAX", iCnt);

    // defend single spells
    iCnt = 0;
    iMax = GetLocalInt(o, "#ENHSINGLESPLMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#ENHSINGLESPL"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
            SetLocalInt(oEnt, "#ENHSINGLESPL" + IntToString(++iCnt), iSpell);
    }
    SetLocalInt(oEnt, "#ENHSINGLESPLMAX", iCnt);

    // defend self spells
    iCnt = 0;
    iMax = GetLocalInt(o, "#ENHSELFSPLMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#ENHSELFSPL"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
            SetLocalInt(oEnt, "#ENHSELFSPL" + IntToString(++iCnt), iSpell);
    }
    SetLocalInt(oEnt, "#ENHSELFSPLMAX", iCnt);

    // direct spells
    iCnt = 0;
    iMax = GetLocalInt(o, "#DSPLMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#DSPL"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
        {
            if (GetLocalInt(o, "DEBUG") > 0)
                SendMessageToAllDMs("DSPL: " + IntToString(iSpell) +
                    " Uses: " + IntToString(GetHasSpell(iSpell, oEnt)));

            SetLocalInt(oEnt, "#DSPL" + IntToString(++iCnt), iSpell);
            // store position in module-infolist, for more info
            SetLocalInt(oEnt, "#SPPOS" + IntToString(iSpell), i);
        }
    }
    SetLocalInt(oEnt, "#DSPLMAX", iCnt);

    // defend group spells
    iCnt = 0;
    iMax = GetLocalInt(o, "#GRPENHSPLMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#GRPENHSPL"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
            SetLocalInt(oEnt, "#GRPENHSPL" + IntToString(++iCnt), iSpell);
    }
    SetLocalInt(oEnt, "#GRPENHSPLMAX", iCnt);

    // area spells
    iCnt = 0;
    iMax = GetLocalInt(o, "#AREASPLMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#AREASPL"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
        {
            SetLocalInt(oEnt, "#AREASPL" + IntToString(++iCnt), iSpell);
            // store position in module-infolist, for more info
            SetLocalInt(oEnt, "#SPPOS" + IntToString(iSpell), i);
        }
    }
    SetLocalInt(oEnt, "#AREASPLMAX", iCnt);

    // breath attacks
    iCnt = 0;
    iMax = GetLocalInt(o, "#BRTMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#BRT"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
            SetLocalInt(oEnt, "#BRT" + IntToString(++iCnt), iSpell);
    }
    SetLocalInt(oEnt, "#BRTMAX", iCnt);

    // defend self abilities
    iCnt = 0;
    iMax = GetLocalInt(o, "#ENHSELFABMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#ENHSELFAB"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
            SetLocalInt(oEnt, "#ENHSELFAB" + IntToString(++iCnt), iSpell);
    }
    SetLocalInt(oEnt, "#ENHSELFABMAX", iCnt);

    // direct spellabilities
    iCnt = 0;
    iMax = GetLocalInt(o, "#DSPLABMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#DSPLAB"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
        {
            SetLocalInt(oEnt, "#DSPLAB" + IntToString(++iCnt), iSpell);
            // store position in module-infolist, for more info
            SetLocalInt(oEnt, "#SPPOS" + IntToString(iSpell), i);
        }
    }
    SetLocalInt(oEnt, "#DSPLABMAX", iCnt);

    // area spellabilities
    iCnt = 0;
    iMax = GetLocalInt(o, "#AREASPLABMAX");
    for (i=1; i<=iMax; i++)
    {
        iSpell = GetLocalInt(o, "#AREASPLAB"+IntToString(i));
        if (iSpell != 0 && GetHasSpell(iSpell, oEnt) > 0)
        {
            SetLocalInt(oEnt, "#AREASPLAB" + IntToString(++iCnt), iSpell);
            // store position in module-infolist, for more info
            SetLocalInt(oEnt, "#SPPOS" + IntToString(iSpell), i);
        }
    }
    SetLocalInt(oEnt, "#AREASPLABMAX", iCnt);

    if (GetHasRangedCapability())
        SetLocalInt(NPC_SELF, "#RANGEDCAPABLE", 1);
}

void CombatAnalyseSituation(float fRad=30.0f)
{
    float fRad = 30.0;

    object oCreature;
    object oSelf = OBJECT_SELF;
    object oNPCSelf;
    location lSelf = GetLocation(oSelf);
    vector vSelf = GetPosition(oSelf);
    int iCnt = 1;
    int iDmg;
    int iBuffs;
    float fDist = 0.0;

    effect e;

    int iCasterCount = 0;
    int iAttackerCount = 0;
    int iNearAttackerCount = 0;
    int iEnemyCount = 0;
    int iNearEnemyCount = 0;
    int iFriendCount = 0;
    int iEnemyAvgLevel;

    vector vEnemy = Vector(0.0, 0.0, 0.0);
    int iEnemyHD = 0;
    int iEnemyMaxBuff = 0;
    int iEnemyMinMgkDef = 0;
    int iEnemyMaxMgkDef = 0;
    int iEnemyMaxDmg = 0;
    int iEnemyMaxEff = 0;
    int iEnemyMaxAssocHD = 0;
    int iFriendMaxDef = 0;
    int iFriendMinBuff = 10000; // first-one should be always lower buffed
    int iFriendMinDef = 0;
    int iFriendMaxDmg = GetMaxHitPoints(oSelf) - GetCurrentHitPoints(oSelf);
    int iFriendMaxEff = 0;
    int iFriendAllDmg = iFriendMaxDmg;
    float fSumFriendDist = 0.0;

    object oEnemyMostDistant = OBJECT_INVALID;
    object oEnemyNearCaster = OBJECT_INVALID;
    object oEnemyMostBuffed = OBJECT_INVALID;
    object oEnemyMinMgkDef = OBJECT_INVALID;
    object oEnemyMaxMgkDef = OBJECT_INVALID;
    object oEnemyMaxDmg = OBJECT_INVALID;
    object oEnemyMaxEff = OBJECT_INVALID;
    object oEnemyMaxAssocOwner = OBJECT_INVALID;
    object oFriendMostDistant = OBJECT_INVALID;
    object oFriendDead = OBJECT_INVALID;
    object oFriendMinBuffed = OBJECT_INVALID;
    object oFriendMinDef = OBJECT_SELF;
    object oFriendMaxDmg = OBJECT_INVALID;
    object oFriendMaxEff = OBJECT_INVALID;
    object oAssoc;

    struct sPhysDefStatus strP;
    struct sSpellDefStatus strM;

    strP = EvaluatePhysicalDefenses(oSelf);
    strM = EvaluateSpellDefenses(oSelf);
    if (strP.iTotal < strM.iTotal)
        iFriendMinDef = strP.iTotal;
    else
        iFriendMinDef = strM.iTotal;

    if (iFriendMaxDmg > 0)
        oFriendMaxDmg = OBJECT_SELF;

    if (GetLocalInt(OBJECT_SELF, "SSD") > 0)
        SpawnScriptDebugger();

    oCreature = GetNearestObject(OBJECT_TYPE_CREATURE, oSelf, iCnt++);
    while (oCreature != OBJECT_INVALID && fDist < fRad)
    {
        if (!GetObjectSeen(oCreature, oSelf))
        {
            oCreature = GetNearestObject(OBJECT_TYPE_CREATURE, oSelf, iCnt++);
            continue;
        }

        fDist = GetDistanceBetween(oCreature, oSelf);
        iDmg = GetMaxHitPoints(oCreature) - GetCurrentHitPoints(oCreature);
        oNPCSelf = MeGetNPCSelf(oCreature);

        if (GetIsEnemy(oCreature)) // TODO check if neutrals, temp enemies work here
        {
            if (GetIsDead(oCreature))
            {
                // Later: Awake undead
            }
            else
            {
                oEnemyMostDistant = oCreature;
                iEnemyHD += GetHitDice(oCreature);

                iEnemyCount++;

                if (GetAttackTarget(oCreature) == oSelf)
                {
                    iAttackerCount++;
                    if (fDist <= 5.0)
                    {
                        iNearAttackerCount++;
                        iNearEnemyCount++;
                    }
                }
                else if (fDist <= 5.0)
                    iNearEnemyCount++;

                if (iEnemyMaxDmg < iDmg)
                {
                    oEnemyMaxDmg = oCreature; // remember most damaged enemy
                    iEnemyMaxDmg = iDmg;
                }

                if (GetIsCaster(oCreature))
                {
                    iCasterCount++;
                    if (oEnemyNearCaster == OBJECT_INVALID)
                        oEnemyNearCaster = oCreature;
                }

                // get best buffered enemy
                iBuffs = 0;
                e = GetFirstEffect(oCreature);
                while (GetIsEffectValid(e))
                {
                    //try this to narrow down to actual "buffs"
                    if (GetEffectSubType(e) == SUBTYPE_MAGICAL && GetEffectDurationType(e) == DURATION_TYPE_TEMPORARY)
                        iBuffs += GetIsBuffEffect(e);
                    e = GetNextEffect(oCreature);
                }
                if ((oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCreature)) != OBJECT_INVALID)
                {
                    iBuffs++;
                    if (GetHitDice(oAssoc) > iEnemyMaxAssocHD)
                    {
                        iEnemyMaxAssocHD = GetHitDice(oAssoc);
                        oEnemyMaxAssocOwner = oCreature;
                    }
                }
                iBuffs += (GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCreature) != OBJECT_INVALID);
                iBuffs += (GetAssociate(ASSOCIATE_TYPE_DOMINATED, oCreature) != OBJECT_INVALID);
                iBuffs += (GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCreature) != OBJECT_INVALID);
                iBuffs += (GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCreature) != OBJECT_INVALID);
                if (iBuffs > iEnemyMaxBuff)
                {
                    iEnemyMaxBuff = iBuffs;
                    oEnemyMostBuffed = oCreature;
                }

                strP = EvaluatePhysicalDefenses(oCreature);
                strM = EvaluateSpellDefenses(oCreature);
                // least magic defended enemy
                if (iEnemyMinMgkDef == 0 || strM.iTotal < iEnemyMinMgkDef)
                {
                    oEnemyMinMgkDef = oCreature;
                    iEnemyMinMgkDef = strM.iTotal;
                }
                // most magic defended enemy
                if (iEnemyMaxMgkDef == 0 || strM.iTotal+strP.iTotal > iEnemyMaxMgkDef)
                {
                    oEnemyMaxMgkDef = oCreature;
                    iEnemyMaxMgkDef = strM.iTotal+strP.iTotal;
                }

                // hostile vector
                vEnemy += (GetPosition(oCreature) - vSelf);
            }
        }
        else if (GetIsFriend(oCreature))
        {
            if (GetIsDead(oCreature))
            {
                if (oFriendDead == OBJECT_INVALID &&
                    !GetIsObjectValid(GetLocalObject(oNPCSelf, "#RAISER")))
                {
                    // remember nearest dead friend thats not raised by someone
                    oFriendDead = oCreature;
                }
            }
            else
            {
                oFriendMostDistant = oCreature;
                iFriendCount++;

                // get average friend distance for regrouping
                fSumFriendDist += fDist;

                if (GetLocalInt(oCreature, "SUMMONED"))
                {
                    // TODO handle summoned, prefer "real" friends for healing
                }
                else if (iFriendMaxDmg < iDmg)
                {
                    // compute most damaged friend
                    if (!GetIsObjectValid(GetLocalObject(oNPCSelf, "#HEALER")))
                    {
                        oFriendMaxDmg = oCreature;
                        iFriendMaxDmg = iDmg;
                    }
                }
                // summarize friends damage to get an average
                iFriendAllDmg += iDmg;

                if (!GetIsObjectValid(GetMaster(oCreature))) // don't process associates
                {
                    strP = EvaluatePhysicalDefenses(oCreature);
                    strM = EvaluateSpellDefenses(oCreature);
                    if (iFriendMinDef < strM.iTotal)
                    {
                        iFriendMinDef = strM.iTotal;
                        oFriendMinDef = oCreature;
                    }
                    if (iFriendMinDef < strP.iTotal)
                    {
                        iFriendMinDef = strP.iTotal;
                        oFriendMinDef = oCreature;
                    }

                    // get least buffered ally
                    iBuffs = 0;
                    e = GetFirstEffect(oCreature);
                    while (GetIsEffectValid(e))
                    {
                        //try this to narrow down to actual "buffs"
                        if (GetEffectSubType(e) == SUBTYPE_MAGICAL && GetEffectDurationType(e) == DURATION_TYPE_TEMPORARY)
                            iBuffs += GetIsBuffEffect(e);
                        if (iBuffs >= iFriendMinBuff)
                            break;
                        e = GetNextEffect(oCreature);
                    }
                    if (iBuffs < iFriendMinBuff)
                    {
                        iBuffs += (GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCreature) != OBJECT_INVALID);
                        iBuffs += (GetAssociate(ASSOCIATE_TYPE_DOMINATED, oCreature) != OBJECT_INVALID);
                        iBuffs += (GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oCreature) != OBJECT_INVALID);
                        iBuffs += (GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCreature) != OBJECT_INVALID);
                        if (iBuffs < iFriendMinBuff)
                        {
                            iFriendMinBuff = iBuffs;
                            oFriendMinBuffed = oCreature;
                        }
                    }
                }

                // compute most bad effected friend
                if (!GetIsObjectValid(GetLocalObject(oNPCSelf, "HELPER")))
                {
                    int iEff = GetEffectsOnObject(oCreature);
                    if (iEff && iFriendMaxEff < iEff)
                    {
                        oFriendMaxEff = oCreature;
                        iFriendMaxEff = iEff;
                    }
                }
            }
        }

        oCreature = GetNearestObject(OBJECT_TYPE_CREATURE, oSelf, iCnt++);
    }

    if (iEnemyCount)
    {
        vEnemy /= IntToFloat(iEnemyCount);
        SetLocalFloat(OBJECT_SELF, "#ENEMYVX", vEnemy.x);
        SetLocalFloat(OBJECT_SELF, "#ENEMYVY", vEnemy.y);
        SetLocalFloat(OBJECT_SELF, "#ENEMYVZ", vEnemy.z);
        SetLocalInt(OBJECT_SELF, "#AVGLVLENEMY", iEnemyHD / iEnemyCount);
    }
    else
    {
        SetLocalFloat(OBJECT_SELF, "#ENEMYVX", 0.0);
        SetLocalFloat(OBJECT_SELF, "#ENEMYVY", 0.0);
        SetLocalFloat(OBJECT_SELF, "#ENEMYVZ", 0.0);
        SetLocalInt(OBJECT_SELF, "#AVGLVLENEMY", 0);
    }

    if (!iFriendCount)
    {
        SetLocalFloat(OBJECT_SELF, "#FFRATIO", 100.0);
        SetLocalFloat(OBJECT_SELF, "#AVGDISTFRIEND", 0.0);
        SetLocalFloat(OBJECT_SELF, "#AVGDMGFRIEND",0.0);
    }
    else
    {
        SetLocalFloat(OBJECT_SELF, "#AVGDISTFRIEND", fSumFriendDist / IntToFloat(iFriendCount));
        SetLocalFloat(OBJECT_SELF, "#FFRATIO", IntToFloat(iEnemyCount) / IntToFloat(iFriendCount));
        SetLocalFloat(OBJECT_SELF, "#AVGDMGFRIEND",
            IntToFloat(iFriendAllDmg) / IntToFloat(iFriendCount));
    }

/*    if (GetIsDM(OBJECT_SELF) || GetIsDMPossessed(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF,
        "#MOSTDMGENEMY" + GetTag(oEnemyMaxDmg) + "\n" +
        "#MOSTBUFFENEMY" + GetTag(oEnemyMostBuffed) + "\n" +
        "#MOSTEFFENEMY" + GetTag(oEnemyMaxEff) + "\n" +
        "#MOSTDISTENEMY" + GetTag(oEnemyMostDistant) + "\n" +
        "#MINMGKDEFENEMY" + GetTag(oEnemyMinMgkDef) + "\n" +
        "#NEARCASTENEMY" + GetTag(oEnemyNearCaster) + "\n" +
        "#MOSTDMGFRIEND" + GetTag(oFriendMaxDmg) + "\n" +
        "#MOSTEFFFRIEND" + GetTag(oFriendMaxEff) + "\n" +
        "#MINBUFFFRIEND" + GetTag(oFriendMinBuffed) + "\n" +
        "#MINDEFFRIEND" + GetTag(oFriendMinDef) + "\n" +
        "#DEADFRIEND" + GetTag(oFriendDead) + "\n" +
        "#CASTERCOUNT" + IntToString(iCasterCount) + "\n" +
        "#ATTACKERCOUNT"+ IntToString(iAttackerCount) + "\n" +
        "#ENEMYCOUNT"+ IntToString(iEnemyCount));
    }
    else*/
    {
        SetLocalObject(OBJECT_SELF, "#MOSTDMGENEMY", oEnemyMaxDmg);
        SetLocalObject(OBJECT_SELF, "#MOSTBUFFENEMY", oEnemyMostBuffed);
        SetLocalObject(OBJECT_SELF, "#MOSTEFFENEMY", oEnemyMaxEff);
        SetLocalObject(OBJECT_SELF, "#MOSTDISTENEMY", oEnemyMostDistant);
        SetLocalObject(OBJECT_SELF, "#MINMGKDEFENEMY", oEnemyMinMgkDef);
        SetLocalObject(OBJECT_SELF, "#MAXMGKDEFENEMY", oEnemyMaxMgkDef);
        SetLocalObject(OBJECT_SELF, "#NEARCASTENEMY", oEnemyNearCaster);
        SetLocalObject(OBJECT_SELF, "#MAXASSOCOWNER", oEnemyMaxAssocOwner);

        SetLocalObject(OBJECT_SELF, "#MOSTDISTFRIEND", oFriendMostDistant);
        SetLocalObject(OBJECT_SELF, "#MOSTDMGFRIEND", oFriendMaxDmg);
        SetLocalObject(OBJECT_SELF, "#MOSTEFFFRIEND", oFriendMaxEff);
        SetLocalObject(OBJECT_SELF, "#MINBUFFFRIEND", oFriendMinBuffed);
        SetLocalObject(OBJECT_SELF, "#MINDEFFRIEND", oFriendMinDef);
        SetLocalObject(OBJECT_SELF, "#DEADFRIEND", oFriendDead);

        SetLocalInt(OBJECT_SELF, "#CASTERCOUNT", iCasterCount);
        SetLocalInt(OBJECT_SELF, "#ATTACKCOUNT", iAttackerCount);
        SetLocalInt(OBJECT_SELF, "#NATTACKCOUNT", iNearAttackerCount);
        SetLocalInt(OBJECT_SELF, "#ENEMYCOUNT", iEnemyCount);
        SetLocalInt(OBJECT_SELF, "#NENEMYCOUNT", iNearEnemyCount);

    //    SetLocalInt(OBJECT_SELF, "#FRIENDCOUNT", iFriendCount);
    //    object oEnemyStrongAssoc = OBJECT_INVALID;
    }

    ComputeAOEVector();
}


// Wrapper
int GetAOECount()
{
    return GetLocalInt(OBJECT_SELF, "#AOEC");
}

int GetHostileAOECount()
{
    return GetLocalInt(OBJECT_SELF, "#AOEHC");
}

vector GetAOEVector()
{
    return Vector(GetLocalFloat(OBJECT_SELF, "#AOEVX"),
                  GetLocalFloat(OBJECT_SELF, "#AOEVY"),
                  GetLocalFloat(OBJECT_SELF, "#AOEVZ"));
}

vector GetHostileAOEVector()
{
    return Vector(GetLocalFloat(OBJECT_SELF, "#AOEHVX"),
                  GetLocalFloat(OBJECT_SELF, "#AOEHVY"),
                  GetLocalFloat(OBJECT_SELF, "#AOEHVZ"));
}

object GetDeadFriendNoRaiser()
{
    return GetLocalObject(OBJECT_SELF, "#DEADFRIEND");
}

object GetNearEnemyCaster()
{
    return GetLocalObject(OBJECT_SELF, "#NEARCASTENEMY");
}

object GetMostBuffedEnemy()
{
    return GetLocalObject(OBJECT_SELF, "#MOSTBUFFENEMY");
}

object GetMostDistantEnemy()
{
    return GetLocalObject(OBJECT_SELF, "#MOSTDISTENEMY");
}

object GetMostDamagedEnemy()
{
    return GetLocalObject(OBJECT_SELF, "#MOSTDMGENEMY");
}

object GetStrongestEnemyAssocOwner()
{
    return GetLocalObject(OBJECT_SELF, "#MAXASSOCOWNER");
}

object GetLeastMagicDefEnemy()
{
    return GetLocalObject(OBJECT_SELF, "#MINMGKDEFENEMY");
}

object GetMostMagicDefEnemy()
{
    return GetLocalObject(OBJECT_SELF, "#MAXMGKDEFENEMY");
}

object GetMostDistantFriend()
{
    return GetLocalObject(OBJECT_SELF, "#MOSTDISTFRIEND");
}


object GetMostBadEffectedFriend()
{
    return GetLocalObject(OBJECT_SELF, "#MOSTEFFFRIEND");
}

object GetLeastDefFriend()
{
    return GetLocalObject(OBJECT_SELF, "#MINDEFFRIEND");
}

object GetMostDamagedFriendNoHealer()
{
    return GetLocalObject(OBJECT_SELF, "#MOSTDMGFRIEND");
}

object GetLeastBuffedFriend()
{
    return GetLocalObject(OBJECT_SELF, "#MINBUFFFRIEND");
}

int GetNearHostileCount()
{
    return GetLocalInt(OBJECT_SELF, "#NENEMYCOUNT");
}

int GetHostileCount()
{
    return GetLocalInt(OBJECT_SELF, "#ENEMYCOUNT");
}

int GetNearAttackerCount()
{
    return GetLocalInt(OBJECT_SELF, "#NATTACKCOUNT");
}

int GetAttackerCount()
{
    return GetLocalInt(OBJECT_SELF, "#ATTACKCOUNT");
}

int GetCasterCount()
{
    return GetLocalInt(OBJECT_SELF, "#CASTERCOUNT");
}

int GetAverageEnemyLevel()
{
    return GetLocalInt(OBJECT_SELF, "#AVGLVLENEMY");
}

float GetAvgFriendDistance()
{
    return GetLocalFloat(OBJECT_SELF, "#AVGDISTFRIEND");
}

float GetAverageFriendDamage()
{
    return GetLocalFloat(OBJECT_SELF, "#AVGDMGFRIEND");
}

float GetFriendFoeRatio()
{
    return GetLocalFloat(OBJECT_SELF, "#FFRATIO");
}

vector GetHostileVector()
{
    return Vector(GetLocalFloat(OBJECT_SELF, "#ENEMYVX"),
                  GetLocalFloat(OBJECT_SELF, "#ENEMYVY"),
                  GetLocalFloat(OBJECT_SELF, "#ENEMYVZ"));
}

// ----- Functions  ------------------------------------------------------------

object _GetTarget(object oEnt=OBJECT_SELF, int iC = 1)
{
    object oT;
    object oS;
    object oH;

    oS = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oEnt, iC, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    oH = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oEnt, iC, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);

    if (oS != OBJECT_INVALID)
    {
        if (oH != OBJECT_INVALID)
            oT = GetDistanceBetween(oEnt,oS) < GetDistanceBetween(oEnt,oH) ? oS : oH;
        else
            oT = oS; // seeing a near enemy
    }
    else if (oH != OBJECT_INVALID)
        oT = oH; // only hearing a near enemy

    return oT;
}

object GetTarget(object oEnt=OBJECT_SELF, int bEvaluate=FALSE)
{
    object oT = GetLocalObject(oEnt, "#LASTTARGET");

    if (!bEvaluate && GetIsObjectValid(oT) && !GetIsDead(oT))
        return oT;

    int iC = 1;
    while ((oT = _GetTarget(oEnt, iC++)) != OBJECT_INVALID)
    {
        if (CanAct(oT))
            break;
    }

    if (oT == OBJECT_INVALID)
    {
        oT = GetLastHostileActor();
        if (GetIsObjectValid(oT))
        {
            if (GetArea(oT) != GetArea(oEnt) || GetIsDead(oT))
                oT = OBJECT_INVALID;
        }
    }

    SetLocalObject(oEnt, "#LASTTARGET", oT);
    return oT;
}


float DotProduct(vector v1, vector v2)
{
    float fDP;

    fDP = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;

    return fDP;
}

location GetFlankLoc(object oT, location lL)
{
    vector vU;
    vector vT;
    vector vM;
    location lF;
    vector vSelf;

    vSelf = GetPosition(OBJECT_SELF);

    if (GetIsObjectValid(oT))
        vT = GetPosition(oT) - vSelf;
    else
        vT = GetPositionFromLocation(lL) - vSelf;

    vM = VectorNormalize(AngleToVector(VectorToAngle(vT) - 45.0 + 90.0 * IntToFloat(Random(2))));
    vM = DotProduct(vT, vM) * VectorNormalize(vM) + vSelf;
    lF = Location(GetArea(oT), vM, VectorToAngle(vT - vM));

    return lF;
}


int CombatEquipMelee(object oT)
{
    switch (GetRacialType(OBJECT_SELF))
    {
    case RACIAL_TYPE_ANIMAL:
    case RACIAL_TYPE_BEAST:
    case RACIAL_TYPE_DRAGON:
    case RACIAL_TYPE_OOZE:
    case RACIAL_TYPE_VERMIN:
        return FALSE;
    }

    object oR = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, OBJECT_SELF);

    if (oR != OBJECT_INVALID)
        SetLocalObject(OBJECT_SELF, "#RHAND", oR);

    if (GetLocalInt(NPC_SELF, "#EQUIPMELEE"))
    {
        // already tried equip, but sometimes reevaluate best weapon
        // TODO: search a solution to diff between disarm or weapon available
        //  => cache weapons at combat start
        if (Random(10))
            return FALSE;
    }

    SetLocalInt(NPC_SELF, "#EQUIPMELEE", 1);

    if (!GetIsObjectValid(oT))
        oT = OBJECT_INVALID;

    // sometimes try to re-evaluate the best weapon or try to pickup a lost one
    if (!Random(4) || oR != OBJECT_INVALID)
        ActionEquipMostDamagingMelee(oT);
    else
    {
        oR = GetLocalObject(OBJECT_SELF, "#RHAND");
        if ((GetIsObjectValid(oR) && !GetIsRangedWeapon(oR)))
        {
            if (GetItemPossessor(oR) == OBJECT_INVALID &&
                GetArea(oR) == GetArea(OBJECT_SELF) &&
                GetDistanceBetween(oR, OBJECT_SELF) < 10.0)
            {
                // weapon is somewhere around
                ActionPickUpItem(oR);
                ActionEquipItem(oR, INVENTORY_SLOT_RIGHTHAND);

                object oL = GetLocalObject(OBJECT_SELF, "#LHAND");
                if (GetIsObjectValid(oL) &&
                    GetItemPossessor(oL) == OBJECT_INVALID &&
                    GetArea(oL) == GetArea(OBJECT_SELF) &&
                    GetDistanceBetween(oL, OBJECT_SELF) < 10.0)
                {
                    // weapon is somewhere around
                    ActionPickUpItem(oL);
                    ActionEquipItem(oL, INVENTORY_SLOT_LEFTHAND);
                }
            }
            else // weapon is not here or try to choose a different one
                ActionEquipMostDamagingMelee(oT);
                // TODO remember equipment ?
        }
        else
            ActionEquipMostDamagingMelee(oT);
    }

    return TRUE;
}

talent GetTalentSpell(int iCat, int iD)
{
    int iCR = 21;
    talent tT;
    talent iT; //reserve for invalid talent return

    while (--iCR)
    {
        tT = GetCreatureTalentBest(iCat, iCR);
        if (!GetIsTalentValid(tT))
            break;
        if (GetIdFromTalent(tT) == iD)
            return tT;
    }
    return iT;
}

int GetTimeSinceLastCombat()
{
    int iTime = GetTimeSecond();
    int iLast = GetLocalInt(MeGetNPCSelf(OBJECT_SELF), "#LASTCREBC");
    int iS = iTime < iLast ? iTime + 60 : iTime;
    int iT = iS - iLast;

    return iT;
}

int GetSpellMatchesAOE(int iSpell, object oAOE)
{
    if (!GetIsObjectValid(oAOE))
        return FALSE;

    string sAOE = GetTag(oAOE);

    if (sAOE == "VFX_PER_DARKNESS" && iSpell == SPELL_DARKNESS)
        return TRUE;
    if (sAOE == "VFX_PER_ENTANGLE" && iSpell == SPELL_ENTANGLE)
        return TRUE;
    if (sAOE == "VFX_PER_EVARDS_BLACK_TENTACLES" && iSpell == SPELL_EVARDS_BLACK_TENTACLES)
        return TRUE;
    if (sAOE == "VFX_PER_CREEPING_DOOM" && iSpell == SPELL_CREEPING_DOOM)
        return TRUE;
    if (sAOE == "VFX_PER_DELAYED_BLAST_FIREBALL" && iSpell == SPELL_DELAYED_BLAST_FIREBALL)
        return TRUE;
    if (sAOE == "VFX_PER_FOGACID" && iSpell == -69) //SPELL_ACID_FOG
        return TRUE;
    if (sAOE == "VFX_PER_FOGFIRE" && iSpell == SPELL_INCENDIARY_CLOUD)
        return TRUE;
    if (sAOE == "VFX_PER_FOGKILL" && iSpell == SPELL_CLOUDKILL)
        return TRUE;
    if (sAOE == "VFX_PER_FOGMIND" && iSpell == SPELL_MIND_FOG)
        return TRUE;
    if (sAOE == "VFX_PER_FOGSTINK" && iSpell == SPELL_STINKING_CLOUD)
        return TRUE;
    if (sAOE == "VFX_PER_GREASE" && iSpell == SPELL_GREASE)
        return TRUE;
    if (sAOE == "VFX_PER_STORM" && iSpell == SPELL_STORM_OF_VENGEANCE)
        return TRUE;
    if (sAOE == "VFX_PER_WALLBLADE" && iSpell == SPELL_BLADE_BARRIER)
        return TRUE;
    if (sAOE == "VFX_PER_WALLFIRE" && iSpell == SPELL_WALL_OF_FIRE)
        return TRUE;
    if (sAOE == "VFX_PER_WEB" && iSpell == SPELL_WEB)
        return TRUE;
        //sAOE == "VFX_PER_FOGBEWILDERMENT")
        //return TRUE;
        //sAOE == "VFX_PER_STONEHOLD")
        //return TRUE;

    return FALSE;
}

int GetIsCloudAOE(object oAOE)
{
    if (!GetIsObjectValid(oAOE))
        return FALSE;

    string sAOE = GetTag(oAOE);

    if (sAOE == "VFX_PER_FOGACID")
        return TRUE;
    if (sAOE == "VFX_PER_FOGFIRE")
        return TRUE;
    if (sAOE == "VFX_PER_FOGKILL")
        return TRUE;
    if (sAOE == "VFX_PER_FOGMIND")
        return TRUE;
    if (sAOE == "VFX_PER_FOGSTINK")
        return TRUE;
        //sAOE == "VFX_PER_FOGBEWILDERMENT")
        //return TRUE;

    return FALSE;
}

int GetAOEThreat(object oArea, object oEnt=OBJECT_SELF)
{
    if (!GetIsObjectValid(oArea))
        return FALSE;

    string sArea = GetTag(oArea);

    if (sArea == "VFX_PER_DARKNESS")
    {
        if (GetHasSpellEffect(SPELL_TRUE_SEEING, oEnt) || GetHasSpellEffect(SPELL_DARKVISION, oEnt))
            return FALSE;
        return TRUE;
    }
    if (sArea == "VFX_PER_ENTANGLE")
    {
        if (GetIsEnemy(GetAreaOfEffectCreator(oArea), oEnt))
            return TRUE;
        return FALSE;
    }
    if (sArea == "VFX_PER_EVARDS_BLACK_TENTACLES")
    {
        if (GetIsEnemy(GetAreaOfEffectCreator(oArea), oEnt))
            return TRUE;
        return FALSE;
    }
    if (sArea == "VFX_PER_CREEPING_DOOM" ||
        sArea == "VFX_PER_DELAYED_BLAST_FIREBALL" ||
        sArea == "VFX_PER_FOGACID" ||
        sArea == "VFX_PER_FOGFIRE" ||
        sArea == "VFX_PER_FOGKILL" ||
        sArea == "VFX_PER_FOGMIND" ||
        sArea == "VFX_PER_FOGSTINK" ||
        sArea == "VFX_PER_GREASE" ||
        sArea == "VFX_PER_STORM" ||
        sArea == "VFX_PER_WALLBLADE" ||
        sArea == "VFX_PER_WALLFIRE" ||
        sArea == "VFX_PER_WEB")
        //sArea == "VFX_PER_FOGBEWILDERMENT")
        //sArea == "VFX_PER_STONEHOLD")
        return TRUE;

    return FALSE;
}


void ComputeAOEVector(float fRad=15.0f, object oEnt=OBJECT_SELF)
{
    int iCnt = 1;
    int iAOECnt = 0;
    int iHostileAOECnt = 0;
    vector vU = GetPosition(oEnt);
    vector vT = Vector(0.0, 0.0, 0.0);
    vector vTHostile = Vector(0.0, 0.0, 0.0);
    object oAOE;
    location lLoc = GetLocation(oEnt);

    oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oEnt, iCnt++);
    while (oAOE != OBJECT_INVALID && GetDistanceBetween(oEnt, oAOE) < fRad)
    {
        if (GetIsEnemy(GetAreaOfEffectCreator(oAOE)))
        {
            iHostileAOECnt++;
            vTHostile = vTHostile + GetPosition(oAOE) - vU;
        }
        if (GetAOEThreat(oAOE))
        {
            iAOECnt++;
            vT = vT + GetPosition(oAOE) - vU;
        }
        oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oEnt, iCnt++);
    }

    SetLocalInt(oEnt, "#AOEC", iAOECnt);
    SetLocalFloat(oEnt, "#AOEVX", vT.x);
    SetLocalFloat(oEnt, "#AOEVY", vT.y);
    SetLocalFloat(oEnt, "#AOEVZ", vT.z);
    SetLocalInt(oEnt, "#AOEHC", iHostileAOECnt);
    SetLocalFloat(oEnt, "#AOEHVX", vTHostile.x);
    SetLocalFloat(oEnt, "#AOEHVY", vTHostile.y);
    SetLocalFloat(oEnt, "#AOEHVZ", vTHostile.z);
}


vector GetAOEEvacVector(vector vS, object oEnt=OBJECT_SELF)
{
    vector vU = GetPosition(oEnt);
    vector vT = Vector(0.0, 0.0, 0.0);

    if (vS != Vector(0.0, 0.0, 0.0))
    {
        if (GetLocalLocation(oEnt, "LASTLOC") == GetLocation(oEnt))
        {
            //we've had location flag set, if matches we haven't moved
            //probably stuck between wall and AOEs or paralyzed in AOEs
            vT = vU + 15.0 * VectorNormalize(vS);
        }
        else
        {
            //proceed away from AOEs
            vT = vU - 15.0 * VectorNormalize(vS);
        }
    }
    else
    {
        //we know there was at least 1 area, must be on self
        vT = vU + 15.0 * VectorNormalize(AngleToVector(IntToFloat(Random(360))));
    }

    return vT;
}


vector GetAreaTarget(float fRad, float fMinRad=7.5, float fMaxRad=30.0, object oCaster=OBJECT_SELF)
{
    vector vU = GetPosition(oCaster);
    vector vS = Vector(0.0, 0.0, 0.0);
    vector vT = Vector(0.0, 0.0, 0.0);
    object oSub1 = OBJECT_INVALID;
    object oSub2 = OBJECT_INVALID;
    int iCnt1 = 0;
    int iCnt2 = 0;
    int iCnt3 = 0;
    int iBestCnt = 0;
    float fMinSearchRad = fMinRad;
    float fMaxSearchRad = fMaxRad;

// TODO this is expensive... any other way?

    oSub1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCaster, ++iCnt1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    //first pad out to fMinSearchRad
    while (oSub1 != OBJECT_INVALID && GetDistanceBetween(oCaster, oSub1) <= fMinSearchRad)
        oSub1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCaster, ++iCnt1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);

    //now scan from 7.5 out to 40.0
    while (oSub1 != OBJECT_INVALID && GetDistanceBetween(oCaster, oSub1) <= fMaxSearchRad)
    {
        iCnt2 = 0;
        iCnt3 = 0;
        //don't count them as target if they're on the move
        if (GetCurrentAction(oSub1) != ACTION_MOVETOPOINT)
        {
            iCnt3 = 1; //starts at 1 to count oSub1
            vT = GetPosition (oSub1) - vU;
        }
        oSub2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oSub1, ++iCnt2, CREATURE_TYPE_IS_ALIVE, TRUE);
        //this should not pick up dead creatures
        while (oSub2 != OBJECT_INVALID && GetDistanceBetween(oSub1, oSub2) <= fRad)
        {
            //don't count them as target if they're on the move
            if (GetCurrentAction(oSub2) != ACTION_MOVETOPOINT && GetObjectSeen(oSub2, oCaster))
            {
                iCnt3++;
                vT = vT + GetPosition(oSub2) - vU;
            }
            oSub2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oSub1, ++iCnt2, CREATURE_TYPE_IS_ALIVE, TRUE);
        }
        if (iCnt3 > iBestCnt)
        {
             vS = VectorNormalize(vT) * (VectorMagnitude(vT) / IntToFloat(iCnt3));
            iBestCnt = iCnt3;
        }
        oSub1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCaster, ++iCnt1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    //vS should now be averaged central vector to densest concentration of enemies
    //iBestCnt is count of enemies within radius of spell at this point
    if (iBestCnt > 1)
    {
        // at least 2 targets, nice target for area spell
        return vS;
    }
    return Vector(0.0, 0.0, 0.0);
}

vector GetFriendlyAreaTarget(float fRad, int iSpell=0, int iType=0, object oCaster=OBJECT_SELF)
{
    vector vU = GetPosition(oCaster);
    vector vS = Vector(0.0, 0.0, 0.0);
    vector vT = Vector(0.0, 0.0, 0.0);
    object oSub1 = OBJECT_INVALID;
    object oSub2 = OBJECT_INVALID;
    int iCnt1 = 0;
    int iCnt2 = 0;
    int iCnt3 = 0;
    int iBestCnt = 0;
    float fMaxSearchRad = 30.0;

    oSub1 = oCaster;
    while (GetIsObjectValid(oSub1) && GetDistanceBetween(oCaster, oSub1) <= fMaxSearchRad)
    {
        if ((!iType && !GetHasSpellEffect(iSpell, oSub1)) ||
            (iType && !GetHasFeatEffect(iSpell, oSub1)))
        {
            iCnt2 = 0;
            iCnt3 = 0;
            //don't count them as target if they're on the move
            //if (GetCurrentAction(oSub1) != ACTION_MOVETOPOINT)
            //if (TRUE)
            {
                iCnt3++; // count oT1 as target
                vT = GetPosition (oSub1) - vU;
            }
            oSub2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oSub1, ++iCnt2, CREATURE_TYPE_IS_ALIVE, TRUE);
            //this should not pick up dead creatures
            while (oSub2 != OBJECT_INVALID && GetDistanceBetween(oSub1, oSub2) <= fRad)
            {
                //don't count them as target if they're on the move
                //if (GetObjectSeen(oSub2, oCaster) && GetCurrentAction(oSub2) != ACTION_MOVETOPOINT)
                if (GetObjectSeen(oSub2, oCaster) &&
                    ((!iType && !GetHasSpellEffect(iSpell, oSub2)) ||
                    (iType && !GetHasFeatEffect(iSpell, oSub2))))
                {
                    iCnt3++;
                    vT = vT + GetPosition(oSub2) - vU;
                }
                oSub2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oSub1, ++iCnt2, CREATURE_TYPE_IS_ALIVE, TRUE);
            }
            if (iCnt3 > iBestCnt)
            {
                vS = vT / IntToFloat(iCnt3);
                iBestCnt = iCnt3;
            }
        }
        oSub1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oCaster, ++iCnt1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    //vS should now be averaged central vector to densest concentration of enemies
    //iBestCnt is count of enemies within radius
    //if (iBestCnt > 1)
    if (iBestCnt)
        return vS;
    return Vector(0.0, 0.0, 0.0);
}


int GetIsWeapon(object oWeapon)
{
    int iType;

    if (GetIsObjectValid(oWeapon) && (iType = GetBaseItemType(oWeapon)) != BASE_ITEM_INVALID)
    {
        if (iType == BASE_ITEM_BASTARDSWORD ||
            iType == BASE_ITEM_BATTLEAXE ||
            iType == BASE_ITEM_CLUB ||
            iType == BASE_ITEM_DAGGER ||
            iType == BASE_ITEM_DART ||
            iType == BASE_ITEM_DIREMACE ||
            iType == BASE_ITEM_DOUBLEAXE ||
            iType == BASE_ITEM_GREATAXE ||
            iType == BASE_ITEM_GREATSWORD ||
            iType == BASE_ITEM_HALBERD ||
            iType == BASE_ITEM_HANDAXE ||
            iType == BASE_ITEM_HEAVYCROSSBOW ||
            iType == BASE_ITEM_HEAVYFLAIL ||
            iType == BASE_ITEM_KAMA ||
            iType == BASE_ITEM_KATANA ||
            iType == BASE_ITEM_KUKRI ||
            iType == BASE_ITEM_LIGHTFLAIL ||
            iType == BASE_ITEM_LIGHTHAMMER ||
            iType == BASE_ITEM_LIGHTMACE ||
            iType == BASE_ITEM_LONGBOW ||
            iType == BASE_ITEM_LONGSWORD ||
            iType == BASE_ITEM_MAGICSTAFF ||
            iType == BASE_ITEM_MORNINGSTAR ||
            iType == BASE_ITEM_QUARTERSTAFF ||
            iType == BASE_ITEM_RAPIER ||
            iType == BASE_ITEM_SCIMITAR ||
            iType == BASE_ITEM_SCYTHE ||
            iType == BASE_ITEM_SHORTBOW ||
            iType == BASE_ITEM_SHORTSPEAR ||
            iType == BASE_ITEM_SHORTSWORD ||
            iType == BASE_ITEM_SHURIKEN ||
            iType == BASE_ITEM_SICKLE ||
            iType == BASE_ITEM_SLING ||
            iType == BASE_ITEM_THROWINGAXE ||
            iType == BASE_ITEM_TORCH ||
            iType == BASE_ITEM_TWOBLADEDSWORD ||
            iType == BASE_ITEM_WARHAMMER)
        {
            return TRUE;
        }
    }
    return FALSE;
}


vector GetHostileEvacVector(vector vS, object oEnt=OBJECT_SELF)
{
    vector vT = Vector(0.0, 0.0, 0.0);
    int iR = GetLocalInt(MeGetNPCSelf(oEnt), "#LASTHSRETRIES");

    if (VectorMagnitude(vS) > 0.0)
    {
        if (GetLocalLocation(MeGetNPCSelf(oEnt), "#LASTHOTSPOT") == GetLocation(oEnt))
        {
            if (!iR)
            {
                iR++;
                vT = 10.0 * VectorNormalize(AngleToVector(GetLocalFloat(MeGetNPCSelf(oEnt), "#LASTAMANGLE") - 90.0 + 180.0 * IntToFloat(Random(2))));
            }
            else
                iR--;
        }
        else
            vT = 10.0 * VectorNormalize(vS);
    }
    else
        vT = 10.0 * VectorNormalize(AngleToVector(IntToFloat(Random(360))));

    if (iR)
        SetLocalInt(MeGetNPCSelf(oEnt), "#LASTHSRETRIES", iR);
    else
        SetLocalInt(MeGetNPCSelf(oEnt), "#LASTHSRETRIES", 0);
    return vT;
}

int GetIsCaster(object oEnt=OBJECT_SELF)
{
    int iCnt = 0;

    if (GetLevelByClass(CLASS_TYPE_BARD, oEnt) ||
        GetLevelByClass(CLASS_TYPE_CLERIC, oEnt) ||
        GetLevelByClass(CLASS_TYPE_DRUID, oEnt) ||
        GetLevelByClass(CLASS_TYPE_PALADIN, oEnt) > 4 ||
        GetLevelByClass(CLASS_TYPE_RANGER, oEnt) > 4 ||
        GetLevelByClass(CLASS_TYPE_SORCERER, oEnt) ||
        GetLevelByClass(CLASS_TYPE_WIZARD, oEnt) ||
        GetLocalInt(MeGetNPCSelf(oEnt), "#CASTER"))
    {
        return TRUE;
    }
    return FALSE;
}

int DoAbilityCheck(int iAbil, int iDC, object oEnt=OBJECT_SELF)
{
    if (d20() + GetAbilityModifier(iAbil, oEnt) >= iDC)
        return TRUE;
    return FALSE;
}

float GetFriendFoeTolerance(object oEnt=OBJECT_SELF)
{
    float fTol = 2.0;
    int iGE = GetAlignmentGoodEvil(oEnt);
    int iLC = GetAlignmentLawChaos(oEnt);

    if (iGE == ALIGNMENT_GOOD)
        fTol *= 2.0;
    else if (iGE == ALIGNMENT_EVIL)
        fTol *= 0.5;

    if (iLC == ALIGNMENT_LAWFUL)
        fTol *= 2.0;
    else if (iLC == ALIGNMENT_CHAOTIC)
        fTol *= 0.5;

    return fTol;
}


vector GetTurningVector(object oEnt=OBJECT_SELF)
{
    int iCnt1, iCnt2, iCnt3, iBestCnt;
    float fRad = 20.0;
    vector vT = Vector(0.0, 0.0, 0.0);
    vector vS = Vector(0.0, 0.0, 0.0);
    vector vU = GetPosition(oEnt);
    object oT1, oT2;

    iCnt1 = 0;
    iBestCnt = 0;
    oT1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oEnt, ++iCnt1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    while (oT1 != OBJECT_INVALID && GetDistanceBetween(oEnt, oT1) <= 40.0f)
    {
        iCnt2 = 0;
        iCnt3 = 0;
        if (GetIsValidTurnTarget(oT1))
        {
            if (GetCurrentAction(oT1) != ACTION_MOVETOPOINT)
            {
                iCnt3 = 1; //starts at 1 to count oSub1
                vT = GetPosition (oT1) - vU;
            }
            oT2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oT1, ++iCnt2, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            //this should not pick up dead creatures
            while (oT2 != OBJECT_INVALID && GetDistanceBetween(oT1, oT2) <= fRad)
            {
                //don't count them as target if they're on the move
                if (GetCurrentAction(oT2) != ACTION_MOVETOPOINT)
                {
                    if (GetIsValidTurnTarget(oT2))
                    {
                        iCnt3++;
                        vT = vT + GetPosition(oT2) - vU;
                    }
                }
                oT2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oT1, ++iCnt2, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            }
            if (iCnt3 > iBestCnt)
            {
                vS = vT / IntToFloat(iCnt3);
                iBestCnt = iCnt3;
            }
        }
        oT1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oEnt, ++iCnt1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    if (iBestCnt)
    {
        return vS;
    }
    return Vector(0.0, 0.0, 0.0);
}

int GetIsValidTurnTarget(object oT, object oEnt=OBJECT_SELF)
{
    int iElemental;
    int iVermin;
    int iConstructs;
    int iOutsider;
    int iRace;
    int iTurn = 0;

    iRace = GetRacialType(oT);

    if (iRace == RACIAL_TYPE_UNDEAD)
    {
        iTurn = 1;
    }
    else if (iRace == RACIAL_TYPE_ELEMENTAL &&
        (GetHasFeat(FEAT_AIR_DOMAIN_POWER, oEnt) ||
         GetHasFeat(FEAT_EARTH_DOMAIN_POWER, oEnt) ||
         GetHasFeat(FEAT_FIRE_DOMAIN_POWER, oEnt) ||
         GetHasFeat(FEAT_WATER_DOMAIN_POWER, oEnt)))
    {
        iTurn = 1;
    }
    else if (iRace == RACIAL_TYPE_VERMIN &&
        (GetHasFeat(FEAT_PLANT_DOMAIN_POWER, oEnt) ||
         GetHasFeat(FEAT_ANIMAL_COMPANION, oEnt)))
    {
        iTurn = 1;
    }
    else if (iRace == RACIAL_TYPE_CONSTRUCT &&
        GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER, oEnt))
    {
        iTurn = 1;
    }
    else if (iRace == RACIAL_TYPE_OUTSIDER &&
        (GetHasFeat(FEAT_GOOD_DOMAIN_POWER, oEnt) ||
        GetHasFeat(FEAT_EVIL_DOMAIN_POWER, oEnt)))
    {
         iTurn = 1;
    }

    return iTurn;
}

int GetPotionHealAmount(object oP)
{
    int iHeal = 0;
    string sP = GetResRef(oP);

    if (sP == "nw_it_mpotion002")
        iHeal = 10; //cure light wounds
    else if (sP == "nw_it_mpotion021")
        iHeal = 20; //cure moderate wounds
    else if (sP == "nw_it_mpotion003")
        iHeal = 30; //cure serious wounds
    else if (sP == "nw_it_mpotion004")
        iHeal = 40; //cure critical wounds
    else if (sP == "nw_it_mpotion013")
        iHeal = 60; //heal
    return iHeal;
}

int GetTalentPotionHealAmount(talent tP)
{
    int iHeal = 0;
    int iP = GetIdFromTalent(tP);

    if (iP ==  32)
        iHeal = 10; //cure light wounds
    else if (iP == 34)
        iHeal = 20; //cure moderate wounds
    else if (iP == 35)
        iHeal = 30; //cure serious wounds
    else if (iP == 31)
        iHeal = 40; //cure critical wounds
    else if (iP == 79)
        iHeal = 60; //heal
    return iHeal;
}

vector GetAreaHealTarget(float fRad=0.0, int iH=0, object oEnt=OBJECT_SELF)
{
    int iCnt1, iCnt2, iCnt3, iBestCnt, iDam;
    float fRad = 20.0;
    vector vT = Vector(0.0, 0.0, 0.0);
    vector vS = Vector(0.0, 0.0, 0.0);
    vector vU = GetPosition(oEnt);
    object oT1, oT2;
    float fMaxSearchRad = 30.0;

    iCnt1 = 0;
    iBestCnt = 0;

    oT1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oEnt, ++iCnt1,
                             CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    while (oT1 != OBJECT_INVALID && GetDistanceBetween(oEnt, oT1) <= fMaxSearchRad)
    {
        iDam = GetMaxHitPoints(oT1) - GetCurrentHitPoints(oT1);
        if (iDam >= iH)
        {
            iCnt2 = 0;
            iCnt3 = 0;
            if (GetCurrentAction(oT1) != ACTION_MOVETOPOINT)
            {
                iCnt3++; // oT1 also counts as target
                vT = GetPosition (oT1) - vU;
            }

            // now count all near to oT1
            oT2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oT1, ++iCnt2,
                                     CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            while (oT2 != OBJECT_INVALID && GetDistanceBetween(oT1, oT2) <= fRad)
            {
                // don't count them as target if they're on the move
                if (GetCurrentAction(oT2) != ACTION_MOVETOPOINT)
                {
                    iDam = GetMaxHitPoints(oT2) - GetCurrentHitPoints(oT2);
                    if (iDam >= iH)
                    {
                        iCnt3++;
                        vT += (GetPosition(oT2) - vU);
                    }
                }
                oT2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oT1, ++iCnt2,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            }
            if (iCnt3 > iBestCnt)
            {
                vS = vT / IntToFloat(iCnt3);
                iBestCnt = iCnt3;
            }
        }
        oT1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oEnt, ++iCnt1,
                                 CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    if (iBestCnt)
        return vS;
    return Vector(0.0, 0.0, 0.0);
}


int GetIsBuffEffect(effect eT)
{
    int id = GetEffectSpellId(eT);

    if (id == -1) return FALSE;
    if (id == SPELL_GREATER_SPELL_MANTLE ||
        id == SPELL_PREMONITION ||
        id == SPELL_MIND_BLANK ||
        id == SPELL_SPELL_MANTLE ||
        id == SPELL_SHADOW_SHIELD ||
        id == SPELL_PROTECTION_FROM_SPELLS ||
        id == SPELL_TRUE_SEEING ||
        id == SPELL_TENSERS_TRANSFORMATION ||
        id == SPELL_MASS_HASTE ||
        id == SPELL_GREATER_STONESKIN ||
        id == SPELL_GLOBE_OF_INVULNERABILITY ||
        id == SPELL_ETHEREAL_VISAGE ||
        id == SPELL_LESSER_SPELL_MANTLE ||
        id == SPELL_LESSER_MIND_BLANK ||
        id == SPELL_ENERGY_BUFFER ||
        id == SPELL_ELEMENTAL_SHIELD ||
        id == SPELL_STONESKIN ||
        id == SPELL_POLYMORPH_SELF ||
        id == SPELL_MINOR_GLOBE_OF_INVULNERABILITY ||
        id == SPELL_IMPROVED_INVISIBILITY ||
        id == SPELL_PROTECTION_FROM_ELEMENTS ||
        id == SPELL_MAGIC_CIRCLE_AGAINST_GOOD ||
        id == SPELL_MAGIC_CIRCLE_AGAINST_EVIL ||
        id == SPELL_MAGIC_CIRCLE_AGAINST_CHAOS ||
        id == SPELL_MAGIC_CIRCLE_AGAINST_LAW ||
        id == SPELL_INVISIBILITY_SPHERE ||
        id == SPELL_HASTE ||
        id == SPELL_CLARITY ||
        id == SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE ||
        id == SPELL_SEE_INVISIBILITY ||
        id == SPELL_RESIST_ELEMENTS ||
        id == SPELL_OWLS_WISDOM ||
        id == SPELL_INVISIBILITY ||
        id == SPELL_GHOSTLY_VISAGE ||
        id == SPELL_FOXS_CUNNING ||
        id == SPELL_ENDURANCE ||
        id == SPELL_EAGLE_SPLEDOR ||
        id == SPELL_DARKVISION ||
        id == SPELL_CATS_GRACE ||
        id == SPELL_BULLS_STRENGTH ||
        id == SPELL_PROTECTION_FROM_GOOD ||
        id == SPELL_PROTECTION_FROM_EVIL ||
        id == SPELL_PROTECTION__FROM_CHAOS ||
        id == SPELL_PROTECTION_FROM_LAW ||
        id == SPELL_MAGE_ARMOR ||
        id == SPELL_FREEDOM_OF_MOVEMENT ||
        id == SPELL_DEATH_WARD ||
        id == SPELL_PRAYER ||
        id == SPELL_AID ||
        id == SPELL_VIRTUE ||
        id == SPELL_BLESS ||
        id == SPELL_SHAPECHANGE ||
        id == SPELL_NATURES_BALANCE ||
        id == SPELL_AURA_OF_VITALITY ||
        id == SPELL_REGENERATE ||
        id == SPELL_SPELL_RESISTANCE ||
        id == SPELL_AWAKEN ||
        id == SPELL_BARKSKIN ||
        id == SPELL_RESISTANCE ||
        id == SPELL_HOLY_AURA ||
        id == SPELL_UNHOLY_AURA ||
        id == SPELL_DIVINE_POWER ||
        id == SPELL_NEGATIVE_ENERGY_PROTECTION ||
        id == SPELL_SANCTUARY ||
        id == SPELL_REMOVE_FEAR ||
        id == SPELL_WAR_CRY)
        return TRUE;
    return FALSE;
}

int GetAverageEffectCasterLevel(object oT=OBJECT_SELF)
{
    int iT = 0;
    int iC = 0;
    int iL = 0;
    object oE;
    object oB = OBJECT_INVALID;
    effect eT = GetFirstEffect(oT);

    while (GetIsEffectValid(eT))
    {
        //try this to narrow down to actual "buffs"
        if (GetEffectSubType(eT) == SUBTYPE_MAGICAL &&
            GetEffectDurationType(eT) == DURATION_TYPE_TEMPORARY &&
            GetIsBuffEffect(eT))
        {
            iC += 1;
            //try this to reduce redundant checking
            oE = GetEffectCreator(eT);
            if (GetIsObjectValid(oE))
            {
                if (oE != oB)
                {
                    //new caster
                    iL = GetMaxDispelCasterLevel(oE);
                    oB = oE;
                }
                iT += iL;
                iC += 1;
            }
            else
            {
                //something has happened to effect creator, assume the worst
                iT += 20;
                iC += 1;
            }
        }
        eT = GetNextEffect(oT);
    }
    if (iC)
        return iT / iC;
    return 0;
}


vector GetEnemySummonedAssociatesVector(float fRad=10.0, object oEnt=OBJECT_SELF)
{
    int iCnt1, iCnt2, iCnt3, iBestCnt;
    vector vT = Vector(0.0, 0.0, 0.0);
    vector vS = Vector(0.0, 0.0, 0.0);
    vector vU = GetPosition(oEnt);
    object oT1, oT2, oM;

    iCnt1 = 0;
    iBestCnt = 0;
    oT1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oEnt, ++iCnt1,
                             CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    while (oT1 != OBJECT_INVALID && GetDistanceBetween(oEnt, oT1) <= 30.0f)
    {
        oM = GetMaster(oT1);
        if (GetIsObjectValid(oM) && GetAssociate(ASSOCIATE_TYPE_SUMMONED, oM) == oT1)
        {
            iCnt2 = 0;
            iCnt3 = 0;

            if (GetCurrentAction(oT1) != ACTION_MOVETOPOINT)
            {
                iCnt3++; // oT1 also counts as target
                vT = GetPosition (oT1) - vU;
            }

            // now count all near to oT1
            oT2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oT1, ++iCnt2,
                                     CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            while (oT2 != OBJECT_INVALID && GetDistanceBetween(oT1, oT2) <= fRad)
            {
                // don't count them as target if they're on the move
                if (GetCurrentAction(oT2) != ACTION_MOVETOPOINT)
                {
                    oM = GetMaster(oT2);
                    if (GetIsObjectValid(oM) && GetAssociate(ASSOCIATE_TYPE_SUMMONED, oM) == oT2)
                    {
                        iCnt3++;
                        vT += (GetPosition(oT2) - vU);
                    }
                }
                oT2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oT1, ++iCnt2,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            }
            if (iCnt3 > iBestCnt)
            {
                vS = vT / IntToFloat(iCnt3);
                iBestCnt = iCnt3;
            }
        }
        oT1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oEnt, ++iCnt1,
                                 CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    if (iBestCnt)
        return vS;
    return Vector(0.0, 0.0, 0.0);
}

vector GetEnemyPlanarVector(float fRad=10.0, object oEnt=OBJECT_SELF)
{
    int iCnt1, iCnt2, iCnt3, iBestCnt;
    vector vT = Vector(0.0, 0.0, 0.0);
    vector vS = Vector(0.0, 0.0, 0.0);
    vector vU = GetPosition(oEnt);
    object oT1, oT2;

    iCnt1 = 0;
    iBestCnt = 0;
    oT1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oEnt, ++iCnt1,
                             CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);

    while (oT1 != OBJECT_INVALID && GetDistanceBetween(oEnt, oT1) <= 30.0f)
    {
        if (GetRacialType(oT1) == RACIAL_TYPE_OUTSIDER ||
            GetRacialType(oT1) == RACIAL_TYPE_ELEMENTAL)
        {
            iCnt2 = 0;
            iCnt3 = 0;
            if (GetCurrentAction(oT1) != ACTION_MOVETOPOINT)
            {
                iCnt3++; // oT1 also counts as target
                vT = GetPosition (oT1) - vU;
            }

            // now count all near to oT1
            oT2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oT1, ++iCnt2,
                                     CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            while (oT2 != OBJECT_INVALID && GetDistanceBetween(oT1, oT2) <= fRad)
            {
                // don't count them as target if they're on the move
                if (GetCurrentAction(oT2) != ACTION_MOVETOPOINT)
                {
                    if (GetRacialType(oT2) == RACIAL_TYPE_OUTSIDER ||
                        GetRacialType(oT2) == RACIAL_TYPE_ELEMENTAL)
                    {
                        iCnt3++;
                        vT += (GetPosition(oT2) - vU);
                    }
                }
                oT2 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oT1, ++iCnt2,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            }
            if (iCnt3 > iBestCnt)
            {
                vS = vT / IntToFloat(iCnt3);
                iBestCnt = iCnt3;
            }
        }
        oT1 = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oEnt, ++iCnt1,
                                 CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    if (iBestCnt)
        return vS;
    return Vector(0.0, 0.0, 0.0);
}

object GetVisionDeprived(float fRad=10.0, object oT=OBJECT_SELF)
{
    object oS = oT;
    object oA;
    object oP;
    int iCnt = 0;
    int iSpell = 0;

    while (oS != OBJECT_INVALID && GetDistanceBetween(oT, oS) < fRad && !GetIsObjectValid(oP))
    {
        if (!GetIsObjectValid(GetLocalObject(MeGetNPCSelf(oS), "#VISION")) && (iSpell = GetVisionSpellNeeded(oS)))
        {
            if (GetIsObjectValid(GetMaster(oS)))
            {
                //associates
                oA = oS;
            }
            else
            {
                //"real" allies
                oP = oS;
            }
        }
        oS = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oT, ++iCnt, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    if (GetIsObjectValid(oP)) //"real" allies take preference over associates
        return oP;
    return oA;
}


int GetHasRangedCapability(object oEnt=OBJECT_SELF)
{
    object oI;

    oI = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oEnt);
    if (oI != OBJECT_INVALID && GetIsRangedWeapon(oI))
        return TRUE;

    oI = GetFirstItemInInventory(oEnt);
    while (oI != OBJECT_INVALID)
    {
        if (GetIsRangedWeapon(oI))
            return TRUE;
        oI = GetNextItemInInventory(oEnt);
    }
    return FALSE;
}

int GetIsRangedWeapon(object oW)
{
    if (GetIsObjectValid(oW))
    {
        int iS = GetBaseItemType(oW);
        if (iS == BASE_ITEM_DART || iS == BASE_ITEM_HEAVYCROSSBOW || iS == BASE_ITEM_LIGHTCROSSBOW ||
            iS == BASE_ITEM_LONGBOW || iS == BASE_ITEM_SHORTBOW || iS == BASE_ITEM_SHURIKEN ||
            iS == BASE_ITEM_SLING || iS == BASE_ITEM_THROWINGAXE)
            return TRUE;
    }
    return FALSE;
}


int GetBestMagicDefSpellSelf(object oEnt=OBJECT_SELF)
{
    if (!GetHasSpellEffect(SPELL_LESSER_SPELL_MANTLE, oEnt) &&
        !GetHasSpellEffect(SPELL_SPELL_MANTLE, oEnt) &&
        !GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE, oEnt))
    {
        switch (Random(3) + 1) // chose random mantle
        {
        case 1:
            if (GetHasSpell(SPELL_LESSER_SPELL_MANTLE, oEnt))
                return SPELL_LESSER_SPELL_MANTLE;
        case 2:
            if (GetHasSpell(SPELL_SPELL_MANTLE, oEnt))
                return SPELL_SPELL_MANTLE;
        case 3:
            if (GetHasSpell(SPELL_GREATER_SPELL_MANTLE, oEnt))
                return SPELL_GREATER_SPELL_MANTLE;
        }
    }
    // Don't have mantles active or not chosen any of them
    // No reliable defense against high level spells available
    // Do the best we can with other spells
    // resistance from spells
    if (!GetHasSpellEffect(SPELL_SPELL_RESISTANCE, oEnt))
        if (GetHasSpell(SPELL_SPELL_RESISTANCE, oEnt))
            return SPELL_SPELL_RESISTANCE;
    // protection from spells
    if (!GetHasSpellEffect(SPELL_PROTECTION_FROM_SPELLS, oEnt))
        if (GetHasSpell(SPELL_PROTECTION_FROM_SPELLS, oEnt))
            return SPELL_PROTECTION_FROM_SPELLS;
    // Shadow Shield/Death Ward for negation of death effects
    if (!GetHasSpellEffect(SPELL_SHADOW_SHIELD, oEnt) &&
        !GetHasSpellEffect(SPELL_DEATH_WARD, oEnt))
    {
        if (GetHasSpell(SPELL_SHADOW_SHIELD, oEnt))
            return SPELL_SHADOW_SHIELD;
        if (GetHasSpell(SPELL_DEATH_WARD, oEnt))
            return SPELL_DEATH_WARD;
    }
    // Next go for elemental protection
    if (!GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, oEnt) &&
        !GetHasSpellEffect(SPELL_RESIST_ELEMENTS, oEnt) &&
        !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, oEnt) &&
        !GetHasSpellEffect(SPELL_ENERGY_BUFFER, oEnt))
    {
        switch (Random(4) + 1)
        {
        case 1:
            if (GetHasSpell(SPELL_ENDURE_ELEMENTS, oEnt))
                return SPELL_ENDURE_ELEMENTS;
        case 2:
            if (GetHasSpell(SPELL_RESIST_ELEMENTS, oEnt))
                return SPELL_RESIST_ELEMENTS;
        case 3:
            if (GetHasSpell(SPELL_PROTECTION_FROM_ELEMENTS, oEnt))
                return SPELL_PROTECTION_FROM_ELEMENTS;
        case 4:
            if (GetHasSpell(SPELL_ENERGY_BUFFER, oEnt))
                return SPELL_ENERGY_BUFFER;
        }
    }
    // Next go for elemental shield
    if (!GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD, oEnt))
        if (GetHasSpell(SPELL_ELEMENTAL_SHIELD, oEnt))
            return SPELL_ELEMENTAL_SHIELD;
    // Next try any other defenses
    if (!GetHasSpellEffect(SPELL_LESSER_MIND_BLANK, oEnt) &&
        !GetHasSpellEffect(SPELL_MIND_BLANK, oEnt))
    {
        // ramp up mind blanks
        // LATER: add check for allies, use mind blank appropriately
        if (GetHasSpell(SPELL_LESSER_MIND_BLANK, oEnt))
            return SPELL_LESSER_MIND_BLANK;
        /* used in group stuff
        if (GetHasSpell(SPELL_MIND_BLANK, oEnt))
            return SPELL_MIND_BLANK;
        */
    }
    // globes, biggest first
    if (!GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, oEnt))
        if (GetHasSpell(SPELL_GLOBE_OF_INVULNERABILITY, oEnt))
            return SPELL_GLOBE_OF_INVULNERABILITY;
    if (!GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oEnt))
        if (GetHasSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oEnt))
            return SPELL_MINOR_GLOBE_OF_INVULNERABILITY;
    // scraping the bottom of the barrel now
    if (!GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, oEnt) &&
        !GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oEnt) &&
        !GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, oEnt))
    {
        if (GetHasSpell(SPELL_ETHEREAL_VISAGE, oEnt))
            return SPELL_ETHEREAL_VISAGE;
        if (!GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, oEnt) && GetHasSpell(SPELL_GHOSTLY_VISAGE, oEnt))
            return SPELL_GHOSTLY_VISAGE;
    }
    return SPELL_INVALID;
}

int GetBestMagicDefSpellSingle(object oEnt=OBJECT_SELF, object oC=OBJECT_SELF)
{
    if (!GetHasSpellEffect(SPELL_SPELL_RESISTANCE, oEnt))
        if (GetHasSpell(SPELL_SPELL_RESISTANCE, oC))
            return SPELL_SPELL_RESISTANCE;
    // Shadow Shield/Death Ward for negation of death effects
    if (!GetHasSpellEffect(SPELL_SHADOW_SHIELD, oEnt) &&
        !GetHasSpellEffect(SPELL_DEATH_WARD, oEnt))
    {
        /*
        if (GetHasSpell(SPELL_SHADOW_SHIELD, oC))
            return SPELL_SHADOW_SHIELD;
        */
        if (GetHasSpell(SPELL_DEATH_WARD, oC))
            return SPELL_DEATH_WARD;
    }
    // Next go for elemental protection
    if (!GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, oEnt) &&
        !GetHasSpellEffect(SPELL_RESIST_ELEMENTS, oEnt) &&
        !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, oEnt) &&
        !GetHasSpellEffect(SPELL_ENERGY_BUFFER, oEnt))
    {
        int iR = 3;
        if (oEnt == oC)
            iR = 4;
        switch (Random(iR) + 1)
        {
        case 1:
            if (GetHasSpell(SPELL_ENDURE_ELEMENTS, oC))
                return SPELL_ENDURE_ELEMENTS;
        case 2:
            if (GetHasSpell(SPELL_RESIST_ELEMENTS, oC))
                return SPELL_RESIST_ELEMENTS;
        case 3:
            if (GetHasSpell(SPELL_PROTECTION_FROM_ELEMENTS, oC))
                return SPELL_PROTECTION_FROM_ELEMENTS;
        case 4:
            if (GetHasSpell(SPELL_ENERGY_BUFFER, oC))
                return SPELL_ENERGY_BUFFER;
        }
    }
    if (!GetHasSpellEffect(SPELL_LESSER_MIND_BLANK, oEnt) &&
        !GetHasSpellEffect(SPELL_MIND_BLANK, oEnt))
        if (GetHasSpell(SPELL_LESSER_MIND_BLANK, oC))
            return SPELL_LESSER_MIND_BLANK;
    return SPELL_INVALID;
}

int GetBestPhysDefSpellSelf(object oEnt=OBJECT_SELF)
{
    //function not finished

    if (!GetHasSpellEffect(SPELL_STONESKIN, oEnt) &&
        !GetHasSpellEffect(SPELL_GREATER_STONESKIN, oEnt) &&
        !GetHasSpellEffect(SPELL_PREMONITION, oEnt))
    {
        if (GetHasSpell(SPELL_GREATER_STONESKIN, oEnt))
            return SPELL_GREATER_STONESKIN;
        if (GetHasSpell(SPELL_PREMONITION, oEnt))
            return SPELL_PREMONITION;
        if (GetHasSpell(SPELL_STONESKIN, oEnt))
            return SPELL_STONESKIN;
    }
    return SPELL_INVALID;
}

int GetBestPhysDefSpellSingle(object oEnt=OBJECT_SELF, object oC=OBJECT_SELF)
{
    //function not finished
    if (!GetHasSpellEffect(SPELL_STONESKIN, oEnt) &&
        !GetHasSpellEffect(SPELL_GREATER_STONESKIN, oEnt) &&
        !GetHasSpellEffect(SPELL_PREMONITION, oEnt))
    {
        if (GetHasSpell(SPELL_STONESKIN, oC))
            return SPELL_STONESKIN;
    }
    return SPELL_INVALID;
}

int GetBestGenericProtection(object oEnt=OBJECT_SELF)
{
    //TESTING FOR GATE PROTECTIONS
    //Currently not in use because of casting bugs
    if (!GetHasSpellEffect(SPELL_HOLY_AURA, oEnt) &&
        !GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, oEnt) &&
        !GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL, oEnt))
    {
        if (GetHasSpell(SPELL_HOLY_AURA, oEnt))
            return SPELL_HOLY_AURA;
        if (GetHasSpell(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, oEnt))
            return SPELL_MAGIC_CIRCLE_AGAINST_EVIL;
        if (GetHasSpell(SPELL_PROTECTION_FROM_EVIL, oEnt))
            return SPELL_PROTECTION_FROM_EVIL;
    }
    return SPELL_INVALID;
}

struct sSpellDefStatus EvaluateSpellDefenses(object oTarget=OBJECT_SELF)
{
    struct sSpellDefStatus sDef;

    if (GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 9;
        sDef.iMantle = sDef.iMantle + 9;
    }
    if (GetHasSpellEffect(SPELL_SPELL_MANTLE, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 7;
        sDef.iMantle = sDef.iMantle + 7;
    }
    if (GetHasSpellEffect(SPELL_LESSER_SPELL_MANTLE, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 5;
        sDef.iMantle = sDef.iMantle + 5;
    }
    if (GetHasSpellEffect(SPELL_ENERGY_BUFFER, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 5;
        sDef.iElem = sDef.iElem + 5;
    }
    if (GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 3;
        sDef.iElem = sDef.iElem + 3;
    }
    if (GetHasSpellEffect(SPELL_RESIST_ELEMENTS, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 2;
        sDef.iElem = sDef.iElem + 2;
    }
    if (GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 1;
        sDef.iElem = sDef.iElem + 1;
    }
    if (GetHasSpellEffect(SPELL_SHADOW_SHIELD, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 7;
        sDef.iDeath = sDef.iDeath + 7;
    }
    if (GetHasSpellEffect(SPELL_MIND_BLANK, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 8;
        sDef.iMind = sDef.iMind + 8;
    }
    if (GetHasSpellEffect(SPELL_LESSER_MIND_BLANK, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 5;
        sDef.iMind = sDef.iMind + 5;
    }
    if (GetHasSpellEffect(SPELL_CLARITY, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 3;
        sDef.iMind = sDef.iMind + 3;
    }
    if (GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 2;
        sDef.iMind = sDef.iBlocker + 2;
    }
    if (GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 6;
        sDef.iMind = sDef.iBlocker + 6;
    }
    if (GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 4;
        sDef.iMind = sDef.iBlocker + 4;
    }
    if (GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 6;
        sDef.iMind = sDef.iBlocker + 6;
    }

    return sDef;
}

struct sPhysDefStatus EvaluatePhysicalDefenses(object oTarget=OBJECT_SELF)
{
    //function not finished
    struct sPhysDefStatus sDef;

    if (GetHasSpellEffect(SPELL_STONESKIN, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 4;
        sDef.iDamred = sDef.iDamred + 4;
    }
    if (GetHasSpellEffect(SPELL_GREATER_STONESKIN, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 6;
        sDef.iDamred = sDef.iDamred + 6;
    }
    if (GetHasSpellEffect(SPELL_PREMONITION, oTarget))
    {
        sDef.iTotal = sDef.iTotal + 8;
        sDef.iDamred = sDef.iDamred + 8;
    }

    return sDef;
}

int GetGroupHealSpell(int iMinLvl=0, object oCaster=OBJECT_SELF)
{
    if (iMinLvl >= 5 && GetHasSpell(SPELL_HEALING_CIRCLE, oCaster))
        return SPELL_HEALING_CIRCLE;
    if (iMinLvl >= 8 && GetHasSpell(SPELL_MASS_HEAL, oCaster))
        return SPELL_MASS_HEAL;
    return SPELL_INVALID;
}

int GetGroupHealSpellAmount(int iH=0, object oCaster=OBJECT_SELF)
{
    if (iH == SPELL_HEALING_CIRCLE) return 20;
    if (iH == SPELL_MASS_HEAL)      return 60;
    return 0;
}

float GetGroupHealSpellRadius(int iH=0)
{
    if (iH == SPELL_HEALING_CIRCLE)  return RADIUS_SIZE_MEDIUM;
    if (iH == SPELL_MASS_HEAL)       return RADIUS_SIZE_LARGE;

    return 0.0;
}

int GetHealingAbilities(object oCaster=OBJECT_SELF)
{
    int iHeal = 0;

    if (GetHasSpell(SPELL_CURE_MINOR_WOUNDS, oCaster))
        iHeal |= 1;
    if (GetHasSpell(SPELL_CURE_LIGHT_WOUNDS, oCaster))
        iHeal |= 2;
    if (GetHasSpell(SPELL_CURE_MODERATE_WOUNDS, oCaster))
        iHeal |= 4;
    if (GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS, oCaster))
        iHeal |= 8;
    if (GetHasFeat(FEAT_LAY_ON_HANDS, oCaster))
        iHeal |= 16;
    if (GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS, oCaster))
        iHeal |= 32;
    if (GetHasSpell(SPELL_HEAL, oCaster))
        iHeal |= 64;
    return iHeal;
}

int GetBestHeal(int iAbilities, object oEnt=OBJECT_SELF, int iMin=10)
{
    if (iAbilities > 0 && GetIsObjectValid(oEnt))
    {
        int iDamage = GetMaxHitPoints(oEnt) - GetCurrentHitPoints(oEnt);

        if (iDamage < iMin)
            return SPELL_INVALID;
        if (iDamage >= 60 && (iAbilities & 64)) // SPELL_HEAL
            return SPELL_HEAL;
        if (iDamage >= 40)
        {
            if (iAbilities & 32) // SPELL_CURE_CRITICAL_WOUNDS
                return SPELL_CURE_CRITICAL_WOUNDS;
            if (iAbilities & 16) // FEAT_LAY_ON_HANDS
                return FEAT_LAY_ON_HANDS;
        }
        if (iDamage >= 30 && (iAbilities & 8)) // SPELL_CURE_SERIOUS_WOUNDS
            return SPELL_CURE_SERIOUS_WOUNDS;
        if (iDamage >= 20 && (iAbilities & 4)) // SPELL_CURE_MODERATE_WOUNDS
            return SPELL_CURE_MODERATE_WOUNDS;
        if (iDamage >= 10 && (iAbilities & 2)) // SPELL_CURE_LIGHT_WOUNDS
            return SPELL_CURE_LIGHT_WOUNDS;
    }
    return SPELL_INVALID;
}

int GetHelpingAbilities(object oCaster=OBJECT_SELF)
{
    if (!GetIsObjectValid(oCaster))
        return 0;

    int iHelp = 0;

    if (GetHasSpell(SPELL_REMOVE_FEAR, oCaster))
        iHelp += 1;
    if (GetHasSpell(SPELL_LESSER_RESTORATION, oCaster))
        iHelp += 2;
    if (GetHasSpell(SPELL_REMOVE_PARALYSIS, oCaster))
        iHelp += 4;
    if (GetHasSpell(SPELL_CLARITY, oCaster))
        iHelp += 8;
    if (GetHasSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS, oCaster))
        iHelp += 16;
    if (GetHasSpell(SPELL_REMOVE_CURSE, oCaster))
        iHelp += 32;
    if (GetHasSpell(SPELL_REMOVE_DISEASE, oCaster))
        iHelp += 64;
    if (GetHasSpell(SPELL_FREEDOM_OF_MOVEMENT, oCaster))
        iHelp += 128;
    if (GetHasSpell(SPELL_NEUTRALIZE_POISON, oCaster))
        iHelp += 256;
    if (GetHasSpell(SPELL_LESSER_MIND_BLANK, oCaster))
        iHelp += 512;
    if (GetHasSpell(SPELL_RESTORATION, oCaster))
        iHelp += 1024;
    if (GetHasSpell(SPELL_GREATER_RESTORATION, oCaster))
        iHelp += 2048;
    if (GetHasSpell(SPELL_STONE_TO_FLESH, oCaster))
        iHelp += 4096;
    return iHelp;
}

int GetBestHelp(int iAbilities, object oEnt)
{
    // TODO: name constants
    int iEff = GetEffectsOnObject(oEnt);

    if (iEff & 8192) //PETRIFY
    {
        if (iAbilities & 4096) // SPELL_STONE_TO_FLESH
            return SPELL_STONE_TO_FLESH;
    }
    if (iEff & 4096) //PARALYZE
    {
        if (iAbilities & 4) // SPELL_REMOVE_PARALYSIS
            return SPELL_REMOVE_PARALYSIS;
        if (iAbilities & 128) // SPELL_FREEDOM_OF_MOVEMENT
            return SPELL_FREEDOM_OF_MOVEMENT;
    }
    if (iEff & 2048) //STUNNED
    {
        if (iAbilities & 8) // SPELL_CLARITY
            return SPELL_CLARITY;
    }
    if (iEff & 1024) //SLEEP
    {
        if (iAbilities & 8) // SPELL_CLARITY
            return SPELL_CLARITY;
    }
    if (iEff & 512) //CHARMED
    {
        if (iAbilities & 8) // SPELL_CLARITY
            return SPELL_CLARITY;
    }
    if (iEff & 256) //CONFUSED
    {
        if (iAbilities & 8) // SPELL_CLARITY
            return SPELL_CLARITY;
    }
    if (iEff & 128) //FRIGHTENED
    {
        if (iAbilities & 1) // SPELL_REMOVE_FEAR
            return SPELL_REMOVE_FEAR;
    }
    if (iEff & 64) //NEGATIVELEVEL
    {
        if (iAbilities & 1024) // SPELL_RESTORATION
            return SPELL_RESTORATION;
        if (iAbilities & 2048) // SPELL_GREATER_RESTORATION))
            return SPELL_GREATER_RESTORATION;
    }
    if (iEff & 32) //BLINDNESS
    {
        if (iAbilities & 16) // SPELL_REMOVE_BLINDNESS_AND_DEAFNESS
            return SPELL_REMOVE_BLINDNESS_AND_DEAFNESS;
        if (iAbilities & 1024) // SPELL_RESTORATION
            return SPELL_RESTORATION;
    }
    if (iEff & 16) //DEAFNESS
    {
        if (iAbilities & 16) // SPELL_REMOVE_BLINDNESS_AND_DEAFNESS
            return SPELL_REMOVE_BLINDNESS_AND_DEAFNESS;
    }
    if (iEff & 8) //POISON
    {
        if (iAbilities & 256) // SPELL_NEUTRALIZE_POISON
            return SPELL_NEUTRALIZE_POISON;
    }
    if (iEff & 4) //CURSE
    {
        if (iAbilities & 32) // SPELL_REMOVE_CURSE
            return SPELL_REMOVE_CURSE;
    }
    if (iEff & 2) //DISEASE
    {
        if (iAbilities & 64) // SPELL_REMOVE_DISEASE
            return SPELL_REMOVE_DISEASE;
    }
    if (iEff & 1) //ABILITY,AC,ATTACK,DAMAGE,SR,SAVE
    {
        if (iAbilities & 2) // SPELL_LESSER_RESTORATION
            return SPELL_LESSER_RESTORATION;
        if (iAbilities & 1024) // SPELL_RESTORATION
            return SPELL_RESTORATION;
    }
    return SPELL_INVALID;
}

int GetRaisingAbilities(object oCaster=OBJECT_SELF)
{
    int iHeal = 0;

    if (GetHasSpell(SPELL_RAISE_DEAD, oCaster))
        iHeal += 1;
    if (GetHasSpell(SPELL_RESURRECTION, oCaster))
        iHeal += 2;
    return iHeal;
}

int GetBestRaise(int iAbilities, int iCombat=FALSE)
{
    //full resurrection is preference in combat situation
    if (iCombat)
    {
        if (iAbilities & 2) // SPELL_RESURRECTION
            return SPELL_RESURRECTION;
        if (iAbilities & 1) // SPELL_RAISE_DEAD
            return SPELL_RAISE_DEAD;
    }
    else
    {
        if (iAbilities & 1) // SPELL_RAISE_DEAD
            return SPELL_RAISE_DEAD;
        if (iAbilities & 2) // SPELL_RESURRECTION
            return SPELL_RESURRECTION;
    }
    return SPELL_INVALID;
}


float GetLastAreaSpellRange(object oCaster=OBJECT_SELF)
{
    int iPos = GetLocalInt(oCaster, "#LASTSPPOS");
    string sList = GetLocalString(oCaster, "#LASTSPLIST");
    return GetLocalFloat(GetModule(), sList+"R"+IntToString(iPos));
}


float GetLastAreaSpellSize(object oCaster=OBJECT_SELF)
{
    int iPos = GetLocalInt(oCaster, "#LASTSPPOS");
    string sList = GetLocalString(oCaster, "#LASTSPLIST");
    return GetLocalFloat(GetModule(), sList+"S"+IntToString(iPos));
}


int GetLastAreaSpellDiscriminant(object oCaster=OBJECT_SELF)
{
    int iPos = GetLocalInt(oCaster, "#LASTSPPOS");
    string sList = GetLocalString(oCaster, "#LASTSPLIST");
    return GetLocalInt(GetModule(), sList+"D"+IntToString(iPos));
}

int GetAreaSpell(int iSafeFriends=FALSE, int iMinLvl=0, float fR=40.0, object oCaster=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;
    int iMax = GetLocalInt(oCaster, "#AREASPLMAX");
    int iPos;
    int iLvl;
    int iIsDisc;
    int bDone = FALSE;
    int iRandom;
    int iGuess = 3;
    int iC = 1;
    float fRange;
    string sPos;
    object oMod = GetModule();
    object oAOE;

    if (iMax > 0)
    {
        oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oCaster, iC++);
        while (oAOE != OBJECT_INVALID && GetAreaOfEffectCreator(oAOE) != oCaster &&
               GetDistanceBetween(oAOE, oCaster) < 20.0)
            oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oCaster, iC++);

        // TODO SPELL_EPIC_HELLBALL     and more
        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#AREASPL"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            sPos = IntToString(iPos);
            iLvl = GetLocalInt(oMod, "#AREASPLL" + sPos);
            fRange = GetLocalFloat(oMod, "#AREASPLR" + sPos);
            iIsDisc = GetLocalInt(oMod, "#AREASPLD" + sPos);

            if ((iIsDisc || !iSafeFriends) && // not hurting friends || not needed to do so
                (fRange == 0.0 || fR < fRange) && // within range
                iLvl <= iMinLvl) // below allowed level
                bDone = TRUE;

            // if spell matches the nearest AOE, dont cast it again
            // too avoid many doubled effects at one location
            if (oAOE != OBJECT_INVALID && GetSpellMatchesAOE(iSpell, oAOE))
                bDone = FALSE;

            if (!UpdateSpellList("#AREASPL", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone

        if (bDone)
        {
            if (iSpell == -69) //temp value for acid fog
                iSpell = SPELL_ACID_FOG;
            SetLocalString(oCaster, "#LASTSPLIST", "#AREASPL");
            SetLocalInt(oCaster, "#LASTSPPOS", iPos);
            return iSpell;
        }
    }

    iGuess = 3;
    iMax = GetLocalInt(oCaster, "#AREASPLABMAX");
    if (iMax > 0)
    {
        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#AREASPLAB"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            sPos = IntToString(iPos);
            iLvl = GetLocalInt(oMod, "#AREASPLABL" + sPos);
            fRange = GetLocalFloat(oMod, "#AREASPLABR" + sPos);

            if ((fRange == 0.0 || fR < fRange) && // within range
                iLvl <= iMinLvl) // below allowed level
                bDone = TRUE;

            if (!UpdateSpellList("#AREASPLAB", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone

        if (bDone)
        {
            SetLocalString(oCaster, "#LASTSPLIST", "#AREASPLAB");
            SetLocalInt(oCaster, "#LASTSPPOS", iPos);
        }
    }
    return iSpell;
}


int GetDirectSpell(object oT, int iMinLvl=0, object oCaster=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;
    int iPos;
    int iLvl;
    int bDone = FALSE;
    int iRandom;
    int iGuess = 3;
    int iSmartEnough = DoAbilityCheck(ABILITY_INTELLIGENCE, 10);
    int iEffects = GetEffectsOnObject(oT);
    int bImmune;
    object oMod = GetModule();

    int iMax = GetLocalInt(oCaster, "#DSPLMAX");
    if (iMax > 0)
    {
        // TODO SPELL_EPIC_HELLBALL
        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#DSPL"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            iLvl = GetLocalInt(oMod, "#DSPLL" + IntToString(iPos));

            if (iMinLvl > iLvl) // try next spell if above allowed level
            {
                iMinLvl -= Random(2); // sometimes decrease minlevel to get better chance for a spell
                continue; // try another one
            }

            bDone = TRUE;
            bImmune = FALSE;

            switch (iSpell)
            {
            //9TH LEVEL CLR
            case SPELL_ENERGY_DRAIN:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_NEGATIVE_LEVEL);
                break;
            //9TH LEVEL DRD
            //9TH LEVEL SOR/WIZ
            case SPELL_DOMINATE_MONSTER:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DOMINATE) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          GetHasSpellEffect(SPELL_DOMINATE_MONSTER, oT);
                break;
            case SPELL_POWER_WORD_KILL:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DEATH) ||
                          (GetCurrentHitPoints(oT) > 100);
                break;
            //8TH LEVEL CLR
            //8TH LEVEL DRD
            case SPELL_FINGER_OF_DEATH:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DEATH);
                break;
            //8TH LEVEL SOR/WIZ
            case SPELL_GREATER_PLANAR_BINDING:
                bImmune = !GetLevelByClass(CLASS_TYPE_OUTSIDER, oT) ||
                          (iEffects & 4096); //paralysis check
                break;
            //7TH LEVEL CLR
            case SPELL_DESTRUCTION:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DEATH);
                break;
            //7TH LEVEL DRD
            //7TH LEVEL SOR/WIZ
            case SPELL_POWER_WORD_STUN:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_STUN) ||
                          (GetCurrentHitPoints(oT) > 150) ||
                          (iEffects & 2048);
                break;
            //6TH LEVEL CLR
            //6TH LEVEL DRD
            //6TH LEVEL SOR/WIZ
            case SPELL_PLANAR_BINDING:
                bImmune = !GetLevelByClass(CLASS_TYPE_OUTSIDER, oT) ||
                          (iEffects & 4096);
                break;
            // Spell/Talent Bug Problem
            //case SPELL_SHADES_FIREBALL:
            //5TH LEVEL CLR
            case SPELL_SLAY_LIVING:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DEATH);
                break;
            //5TH LEVEL DRD
            //5TH LEVEL SOR/WIZ
            case SPELL_DOMINATE_PERSON:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DOMINATE) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          GetHasSpellEffect(SPELL_DOMINATE_PERSON, oT);
                break;
            case SPELL_FEEBLEMIND:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_ABILITY_DECREASE) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          !GetLevelByClass(CLASS_TYPE_WIZARD, oT);
                break;
            // Spell/Talent Bug
            //case SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW:
            case SPELL_HOLD_MONSTER:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_PARALYSIS) ||
                          GetHasSpellEffect(SPELL_HOLD_MONSTER, oT);
                break;
            case SPELL_LESSER_PLANAR_BINDING:
                bImmune = !GetLevelByClass(CLASS_TYPE_OUTSIDER, oT) ||
                          (iEffects & 4096);
                break;
            //4TH LEVEL CLR
            //4TH LEVEL DRD
            //4TH LEVEL SOR/WIZ
            case SPELL_CHARM_MONSTER:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_CHARM) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          (iEffects & 512);
                break;
            case SPELL_ENERVATION:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_NEGATIVE_LEVEL);
                break;
            /* Spell/Talent Bug
            case SPELL_SHADOW_CONJURATION_MAGIC_MISSILE, oCaster))
            */
            case SPELL_PHANTASMAL_KILLER:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DEATH) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS);
                break;
            //3RD LEVEL CLR
            case SPELL_BLINDNESS_AND_DEAFNESS:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_BLINDNESS) ||
                          (iEffects & 32);
                break;
            case SPELL_CONTAGION:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DISEASE) ||
                          GetHasSpellEffect(SPELL_CONTAGION, oT);
                break;
            case SPELL_SEARING_LIGHT:
            //3RD LEVEL DRD
            //3RD LEVEL SOR/WIZ
            case SPELL_FLAME_ARROW:
                break;
            case SPELL_HOLD_PERSON:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_PARALYSIS) ||
                          (iEffects & 4096); //paralysis check
                break;
            //2ND LEVEL CLR
            case SPELL_NEGATIVE_ENERGY_RAY:
                break;
            //2ND LEVEL DRD
            case SPELL_CHARM_PERSON_OR_ANIMAL:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_CHARM) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          (iEffects & 512);
                break;
            case SPELL_FLAME_LASH:
                break;
            //2ND LEVEL SOR/WIZ
            case SPELL_MELFS_ACID_ARROW:
                break;
            //1ST LEVEL CLR
            case SPELL_DOOM:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          GetHasSpellEffect(SPELL_DOOM, oT);
                break;
            case SPELL_SCARE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          GetHasSpellEffect(SPELL_SCARE, oT);
                break;
            //1ST LEVEL DRD
            //1ST LEVEL SOR/WIZ
            case SPELL_CHARM_PERSON:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_CHARM) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          (iEffects & 512);
                break;
            case SPELL_MAGIC_MISSILE:
                break;
            case SPELL_RAY_OF_ENFEEBLEMENT:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_ABILITY_DECREASE);
                break;
            //0TH LEVEL CLR
            //0TH LEVEL DRD
            //0TH LEVEL SOR/WIZ
            case SPELL_DAZE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DAZED) ||
                          GetHasSpellEffect(SPELL_DAZE, oT);
                break;
            case SPELL_RAY_OF_FROST:
                break;
            default:
                bDone = FALSE;
            }

            if (!UpdateSpellList("#DSPL", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (bImmune && iSmartEnough)
            {
                // I know about my enemies immunities
                // => guess another spell by random
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone

        if (bDone)
            return iSpell;
    }

    iGuess = 3;
    iMax = GetLocalInt(oCaster, "#DSPLABMAX");
    if (iMax > 0)
    {
        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#DSPLAB"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            iLvl = GetLocalInt(oMod, "#DSPLABL" + IntToString(iPos));

            if (iMinLvl > iLvl) // above allowed level
            {
                iMinLvl -= Random(2); // sometimes decrease minlevel to get better chance for a spell
                continue; // try another one
            }

            bDone = TRUE;
            bImmune = FALSE;

            switch (iSpell)
            {
            case SPELLABILITY_BOLT_ABILITY_DRAIN_CHARISMA:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_ABILITY_DECREASE); break;
            case SPELLABILITY_BOLT_ABILITY_DRAIN_CONSTITUTION:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_ABILITY_DECREASE); break;
            case SPELLABILITY_BOLT_ABILITY_DRAIN_DEXTERITY:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_ABILITY_DECREASE); break;
            case SPELLABILITY_BOLT_ABILITY_DRAIN_INTELLIGENCE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_ABILITY_DECREASE); break;
            case SPELLABILITY_BOLT_ABILITY_DRAIN_STRENGTH:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_ABILITY_DECREASE); break;
            case SPELLABILITY_BOLT_ABILITY_DRAIN_WISDOM:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_ABILITY_DECREASE); break;
            case SPELLABILITY_BOLT_ACID: break;
            case SPELLABILITY_BOLT_CHARM:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_CHARM) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS);
            case SPELLABILITY_BOLT_COLD: break;
            case SPELLABILITY_BOLT_CONFUSE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS);
                break;
            case SPELLABILITY_BOLT_DAZE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_DAZED) ||
                          GetHasSpellEffect(SPELL_DAZE, oT);
                break;
            case SPELLABILITY_BOLT_DEATH:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DEATH); break;
            case SPELLABILITY_BOLT_DISEASE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DISEASE); break;
            case SPELLABILITY_BOLT_DOMINATE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_DOMINATE) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS);
                break;
            case SPELLABILITY_BOLT_FIRE: break;
            // case SPELLABILITY_BOLT_KNOCKDOWN, oCaster))
            case SPELLABILITY_BOLT_LEVEL_DRAIN:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_NEGATIVE_LEVEL); break;
            case SPELLABILITY_BOLT_LIGHTNING: break;
            case SPELLABILITY_BOLT_PARALYZE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_PARALYSIS) || (iEffects & 4096); break;
            case SPELLABILITY_BOLT_POISON:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_POISON); break;
            case SPELLABILITY_BOLT_SHARDS: break;
            case SPELLABILITY_BOLT_SLOW:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE); break;
            case SPELLABILITY_BOLT_STUN:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_STUN); break;
            case SPELLABILITY_BOLT_WEB:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE); break;
            case SPELLABILITY_GAZE_CHARM:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_CHARM, oT) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_CHARM) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS);
                break;
            case SPELLABILITY_GAZE_CONFUSION:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_CONFUSION, oT) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS);
                break;
            case SPELLABILITY_GAZE_DAZE:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_DAZE, oT) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_DAZED) ||
                          GetHasSpellEffect(SPELL_DAZE, oT);
                break;
            case SPELLABILITY_GAZE_DEATH:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_DEATH, oT) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_DEATH);
                break;
            case SPELLABILITY_GAZE_DOMINATE:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_DOMINATE, oT) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_DOMINATE) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS);
                break;
            case SPELLABILITY_GAZE_DOOM:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_DOOM, oT); break;
            case SPELLABILITY_GAZE_FEAR:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_FEAR, oT) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_MIND_SPELLS) ||
                          GetHasSpellEffect(SPELL_SCARE, oT);
                break;
            case SPELLABILITY_GAZE_PARALYSIS:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_PARALYSIS, oT) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_PARALYSIS) || (iEffects & 4096);
                break;
            case SPELLABILITY_GAZE_STUNNED:
                bImmune = GetHasSpellEffect(SPELLABILITY_GAZE_STUNNED, oT) ||
                          GetIsImmune(oT, IMMUNITY_TYPE_STUN);
                break;
            //MISCELLANEOUS SPELLABILITIES
            case SPELLABILITY_MEPHIT_SALT_BREATH: break;
            case SPELLABILITY_MEPHIT_STEAM_BREATH: break;
            default:
                bDone = FALSE;
            }

            if (!UpdateSpellList("#DSPLAB", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (bImmune && iSmartEnough)
            {
                // I know about my enemies immunities
                // => guess another spell by random
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone
    }
    return iSpell;
}

int GetTouchSpell(object oT, int iMinLvl=0, object oCaster=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;
    int iMax = GetLocalInt(oCaster, "#TSPLMAX");

    if (iMax > 0)
    {
        int iPos;
        int iLvl;
        int bDone = FALSE;
        int iRandom;
        int iGuess = 3;
        int iSmartEnough = DoAbilityCheck(ABILITY_INTELLIGENCE, 10);
        int iEffects = GetEffectsOnObject(oT);
        int bImmune;
        object oMod = GetModule();

        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#TSPL"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            iLvl = GetLocalInt(oMod, "#TSPLL" + IntToString(iPos));

            if (iMinLvl > iLvl) // above allowed level
            {
                iMinLvl -= Random(2); // sometimes decrease minlevel to get better chance for a spell
                continue; // try another one
            }

            bDone = TRUE;
            bImmune = FALSE;

            switch (iSpell)
            {
            //6TH LEVEL CLR
            case SPELL_HARM: bImmune = (GetCurrentHitPoints(oT) > 60); break;
            //4TH LEVEL CLR
            case SPELL_POISON: bImmune = GetIsImmune(oT, IMMUNITY_TYPE_POISON); break;
            //4TH LEVEL DRD
            //4TH LEVEL SOR/WIZ
            case SPELL_BESTOW_CURSE:
                bImmune = GetIsImmune(oT, IMMUNITY_TYPE_CURSED) ||
                          GetHasSpellEffect(SPELL_BESTOW_CURSE, oT);
                          break;
            //3RD LEVEL CLR
            //3RD LEVEL DRD
            case SPELL_VAMPIRIC_TOUCH: break;
            //2ND LEVEL CLR
            case SPELL_GHOUL_TOUCH: break;
            default:
                bDone = FALSE;
            }

            if (!UpdateSpellList("#TSPL", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (bImmune && iSmartEnough)
            {
                // I know about my enemies immunities
                // => guess another spell by random
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone
    }
    return iSpell;
}

int GetSummonSpell(int iMinLvl=1, object oCaster=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;
    int iMax = GetLocalInt(oCaster, "#SUMMONSPLMAX");

    if (iMax > 0)
    {
        int iPos;
        int iLvl;
        int bDone = FALSE;
        int iRandom;
        int iGuess = 3;
        int iSmartEnough = DoAbilityCheck(ABILITY_INTELLIGENCE, 10);
        int bImmune;
        object oMod = GetModule();

        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#SUMMONSPL"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            iLvl = GetLocalInt(oMod, "#SUMMONSPLL" + IntToString(iPos));

            if (iMinLvl > iLvl) // above allowed level
            {
                iMinLvl -= Random(2); // sometimes decrease minlevel to get better chance for a spell
                continue; // try another one
            }

            bDone = TRUE;
            bImmune = FALSE;


            switch (iSpell)
            {
            // 9
            case SPELL_SUMMON_CREATURE_IX: break;
            case SPELL_GATE:
                // use Gate only if I have protection
                bImmune = !(GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL, oCaster) ||
                            GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, oCaster) ||
                            GetHasSpellEffect(SPELL_HOLY_AURA, oCaster));
            case SPELL_ELEMENTAL_SWARM: break;
            // 8
            case SPELL_SUMMON_CREATURE_VIII: break;
            case SPELL_CREATE_UNDEAD: break;
            case SPELL_CREATE_GREATER_UNDEAD: break;
            case SPELL_GREATER_PLANAR_BINDING: break;
            // 7
            case SPELL_SUMMON_CREATURE_VII: break;
            case SPELL_MORDENKAINENS_SWORD: break;
            // 6
            case SPELL_SUMMON_CREATURE_VI: break;
            case SPELL_PLANAR_BINDING: break;
            // Spell/Talent Bug     case SPELL_SHADES_SUMMON_SHADOW: break;
            // 5
            case SPELL_SUMMON_CREATURE_V: break;
            case SPELL_ANIMATE_DEAD: break;
            // Spell/Talent Bug    case SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW: break;
            case SPELL_LESSER_PLANAR_BINDING: break;
            // 4
            case SPELL_SUMMON_CREATURE_IV: break;
            // Spell/Talent Bug    case SPELL_SHADOW_CONJURATION_SUMMON_SHADOW: break;
            // 3
            case SPELL_SUMMON_CREATURE_III: break;
            // 2
            case SPELL_SUMMON_CREATURE_II: break;
            //
            case SPELL_SUMMON_CREATURE_I: break;
            default:
                bDone = FALSE;
            }

            if (!UpdateSpellList("#SUMMONSPL", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (bImmune && iSmartEnough)
            {
                // I know about my enemies immunities
                // => guess another spell by random
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone
    }
    return iSpell;
}

int GetEnhanceSpellSelf(int iMinLvl=1, object oCaster=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;
    int iMax = GetLocalInt(oCaster, "#ENHSELFSPLMAX");
    int iPos;
    int iLvl;
    int bDone = FALSE;
    int iRandom;
    int iGuess = 3;
    object oMod = GetModule();

    if (iMax > 0)
    {
        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#ENHSELFSPL"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            iLvl = GetLocalInt(oMod, "#ENHSELFSPLL" + IntToString(iPos));

            if (iMinLvl > iLvl) // above allowed level
            {
                iMinLvl -= Random(2); // sometimes decrease minlevel to get better chance for a spell
                continue; // try another one
            }

            bDone = TRUE;

            switch (iSpell)
            {
            //7TH LEVEL CLR
            case SPELL_REGENERATE: bDone = !GetHasSpellEffect(SPELL_REGENERATE, oCaster); break;
            //4TH LEVEL CLR
            case SPELL_DIVINE_POWER: bDone = !GetHasSpellEffect(SPELL_DIVINE_POWER, oCaster); break;
            //4TH LEVEL SOR/WIZ
            case SPELL_IMPROVED_INVISIBILITY: bDone = !GetHasSpellEffect(SPELL_IMPROVED_INVISIBILITY, oCaster); break;
            //3RD LEVEL CLR
            //3RD LEVEL SOR/WIZ
            case SPELL_HASTE:
                bDone = !GetHasSpellEffect(SPELL_HASTE, oCaster) &&
                        !GetHasSpellEffect(SPELL_MASS_HASTE, oCaster);
                        break;
            //2ND LEVEL CLR
            case SPELL_AID: bDone = !GetHasSpellEffect(SPELL_AID, oCaster); break;
            case SPELL_BULLS_STRENGTH: bDone = !GetHasSpellEffect(SPELL_BULLS_STRENGTH, oCaster); break;
            case SPELL_ENDURANCE: bDone = !GetHasSpellEffect(SPELL_ENDURANCE, oCaster); break;
            //2ND LEVEL DRD
            //2ND LEVEL SOR/WIZ
            case SPELL_FOXS_CUNNING: bDone = !GetHasSpellEffect(SPELL_FOXS_CUNNING, oCaster); break;
            //1ST LEVEL CLR
            //1ST LEVEL SOR/WIZ
            case SPELL_MAGE_ARMOR: bDone = !GetHasSpellEffect(SPELL_MAGE_ARMOR, oCaster); break;
            //0TH LEVEL CLR
            //0TH LEVEL DRD
            //0TH LEVEL SOR/WIZ
            case SPELL_RESISTANCE: bDone = !GetHasSpellEffect(SPELL_RESISTANCE, oCaster); break;
            default:
                bDone = FALSE;
            }

            if (!UpdateSpellList("#ENHSELFSPL", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone

        if (bDone)
            return iSpell;
    }

    //SPELLABILITIES
    //NOTE: these should be activated by DoFastBuffs() but might need to be recast

    iGuess = 3;
    iMax = GetLocalInt(oCaster, "#ENHSELFABMAX");
    if (iMax > 0)
    {
        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#ENHSELFAB"+IntToString(iRandom));

            bDone = TRUE;

            switch (iSpell)
            {
            case SPELLABILITY_DRAGON_FEAR: bDone = !GetHasSpellEffect(SPELLABILITY_DRAGON_FEAR, oCaster); break;
            case SPELLABILITY_AURA_BLINDING: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_BLINDING, oCaster); break;
            case SPELLABILITY_AURA_COLD: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_COLD, oCaster); break;
            case SPELLABILITY_AURA_ELECTRICITY: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_ELECTRICITY, oCaster); break;
            case SPELLABILITY_AURA_FIRE: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_FIRE, oCaster); break;
            case SPELLABILITY_AURA_MENACE: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_MENACE, oCaster); break;
            case SPELLABILITY_AURA_OF_COURAGE: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_OF_COURAGE, oCaster); break;
            case SPELLABILITY_AURA_PROTECTION: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_PROTECTION, oCaster); break;
            case SPELLABILITY_AURA_STUN: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_STUN, oCaster); break;
            case SPELLABILITY_AURA_UNEARTHLY_VISAGE: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_UNEARTHLY_VISAGE, oCaster); break;
            case SPELLABILITY_AURA_FEAR: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_FEAR, oCaster); break;
            case SPELLABILITY_AURA_UNNATURAL: bDone = !GetHasSpellEffect(SPELLABILITY_AURA_UNNATURAL, oCaster); break;
            case SPELLABILITY_EMPTY_BODY: bDone = !GetHasSpellEffect(SPELLABILITY_EMPTY_BODY, oCaster); break;
            case SPELLABILITY_TYRANT_FOG_MIST: bDone = !GetHasSpellEffect(SPELLABILITY_TYRANT_FOG_MIST, oCaster); break;

            case SPELLABILITY_RAGE_5: bDone = !GetHasSpellEffect(SPELLABILITY_RAGE_5, oCaster); break;
            case SPELLABILITY_RAGE_4: bDone = !GetHasSpellEffect(SPELLABILITY_RAGE_4, oCaster); break;
            case SPELLABILITY_RAGE_3: bDone = !GetHasSpellEffect(SPELLABILITY_RAGE_3, oCaster); break;

            case SPELLABILITY_FEROCITY_3: bDone = !GetHasSpellEffect(SPELLABILITY_FEROCITY_3, oCaster); break;
            case SPELLABILITY_FEROCITY_2: bDone = !GetHasSpellEffect(SPELLABILITY_FEROCITY_2, oCaster); break;
            case SPELLABILITY_FEROCITY_1: bDone = !GetHasSpellEffect(SPELLABILITY_FEROCITY_1, oCaster); break;

            case SPELLABILITY_INTENSITY_3: bDone = !GetHasSpellEffect(SPELLABILITY_INTENSITY_3, oCaster); break;
            case SPELLABILITY_INTENSITY_2: bDone = !GetHasSpellEffect(SPELLABILITY_INTENSITY_2, oCaster); break;
            case SPELLABILITY_INTENSITY_1: bDone = !GetHasSpellEffect(SPELLABILITY_INTENSITY_1, oCaster); break;
            //SELF-ENHANCING DOMAIN POWERS
            case SPELLABILITY_BATTLE_MASTERY: bDone = !GetHasSpellEffect(SPELLABILITY_BATTLE_MASTERY, oCaster); break;
            case SPELLABILITY_DIVINE_PROTECTION: bDone = !GetHasSpellEffect(SPELLABILITY_DIVINE_PROTECTION, oCaster); break;
            case SPELLABILITY_DIVINE_STRENGTH: bDone = !GetHasSpellEffect(SPELLABILITY_DIVINE_STRENGTH, oCaster); break;
            /* NOT DIRECTLY USEFUL IN COMBAT
            case SPELLABILITY_DIVINE_TRICKERY: bDone = !GetHasSpellEffect(SPELLABILITY_DIVINE_TRICKERY, oCaster); break;
            */
            default:
                bDone = FALSE;
            }

            if (!UpdateSpellList("#ENHSELFAB", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
                iSpell = SPELL_INVALID;
        } // while !bDone
    }

    return iSpell;
}

int GetEnhanceSpellSingle(int iMinLvl=1, object oEnt=OBJECT_SELF, object oCaster=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;
    int iMax = GetLocalInt(oCaster, "#ENHSINGLESPLMAX");
    int iPos;
    int iLvl;
    int bDone = FALSE;
    int iRandom;
    int iGuess = 3;
    object oMod = GetModule();

    if (iMax > 0)
    {
        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#ENHSINGLESPL"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            iLvl = GetLocalInt(oMod, "#ENHSINGLESPLL" + IntToString(iPos));

            if (iMinLvl > iLvl) // above allowed level
            {
                iMinLvl -= Random(2); // sometimes decrease minlevel to get better chance for a spell
                continue; // try another one
            }

            bDone = TRUE;

            switch (iSpell)
            {
            //7TH LEVEL CLR
            case SPELL_REGENERATE: bDone = !GetHasSpellEffect(SPELL_REGENERATE, oEnt); break;
            //4TH LEVEL CLR
            // SELF ONLY?   case SPELL_DIVINE_POWER: bDone = !GetHasSpellEffect(SPELL_DIVINE_POWER, oEnt); break;
            //4TH LEVEL SOR/WIZ
            case SPELL_IMPROVED_INVISIBILITY: bDone = !GetHasSpellEffect(SPELL_IMPROVED_INVISIBILITY, oEnt); break;
            //3RD LEVEL CLR
            //3RD LEVEL SOR/WIZ
            case SPELL_HASTE:
                bDone = !GetHasSpellEffect(SPELL_HASTE, oEnt) &&
                        !GetHasSpellEffect(SPELL_MASS_HASTE, oEnt);
                        break;
            //2ND LEVEL CLR
            case SPELL_AID: bDone = !GetHasSpellEffect(SPELL_AID, oEnt); break;
            case SPELL_BULLS_STRENGTH: bDone = !GetHasSpellEffect(SPELL_BULLS_STRENGTH, oEnt); break;
            case SPELL_ENDURANCE: bDone = !GetHasSpellEffect(SPELL_ENDURANCE, oEnt); break;
            //2ND LEVEL DRD
            //2ND LEVEL SOR/WIZ
            // not a good general buff  case SPELL_FOXS_CUNNING: bDone = !GetHasSpellEffect(SPELL_FOXS_CUNNING, oEnt); break;
            case SPELL_CATS_GRACE: bDone = !GetHasSpellEffect(SPELL_CATS_GRACE, oEnt); break;
            //1ST LEVEL CLR
            //1ST LEVEL SOR/WIZ
            case SPELL_MAGE_ARMOR: bDone = !GetHasSpellEffect(SPELL_MAGE_ARMOR, oEnt); break;
            //0TH LEVEL CLR
            case SPELL_RESISTANCE: bDone = !GetHasSpellEffect(SPELL_RESISTANCE, oEnt); break;
            default:
                bDone = FALSE;
            }

            if (!UpdateSpellList("#ENHSINGLESPL", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone
    }
    return iSpell;
}

int GetBestBreach(int iLim=30, object oEnt=OBJECT_SELF)
{
    //dispels not returned here
    if (iLim > 12)
    {
        if (GetHasSpell(SPELL_GREATER_SPELL_BREACH, oEnt))
            return SPELL_GREATER_SPELL_BREACH;
        if (GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION, oEnt))
            return SPELL_MORDENKAINENS_DISJUNCTION;
        /*
        if (GetHasSpell(SPELL_GREATER_DISPELLING, oEnt))
            return SPELL_GREATER_DISPELLING;
        */
    }
    if (iLim > 7)
    {
        if (GetHasSpell(SPELL_LESSER_SPELL_BREACH, oEnt))
            return SPELL_LESSER_SPELL_BREACH;
        /*
        if (GetHasSpell(SPELL_DISPEL_MAGIC, oEnt))
            return SPELL_DISPEL_MAGIC;
        */
    }
    /*
    if (iLim > 5)
        if (GetHasSpell(SPELL_LESSER_DISPEL, oEnt))
            return SPELL_LESSER_DISPEL;
    */
    return SPELL_INVALID;
}

int GetBestDispel(int iCLvl=20, int iDLvl=20, object oEnt=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;

    if (GetHasSpell(SPELL_LESSER_DISPEL, oEnt))
        iSpell = SPELL_LESSER_DISPEL;
    else if (iCLvl > 5 && iDLvl > 5)
    {
        if (GetHasSpell(SPELL_DISPEL_MAGIC, oEnt))
            iSpell = SPELL_DISPEL_MAGIC;
        else if (iCLvl > 10 && iDLvl > 10)
            if (GetHasSpell(SPELL_GREATER_DISPELLING, oEnt))
                iSpell = SPELL_GREATER_DISPELLING;
    }
    return iSpell;
}


int GetBreathWeapon(object oEnt=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;
    int iMax = GetLocalInt(oEnt, "#BRTMAX");

    if (iMax > 0)
    {
        int bDone = FALSE;
        int iRandom;
        int iGuess = 3;

        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oEnt, "#BRT"+IntToString(iRandom));

            bDone = TRUE;

            switch (iSpell)
            {
            case SPELLABILITY_DRAGON_BREATH_ACID: break;
            case SPELLABILITY_DRAGON_BREATH_COLD: break;
            case SPELLABILITY_DRAGON_BREATH_FEAR: break;
            case SPELLABILITY_DRAGON_BREATH_FIRE: break;
            case SPELLABILITY_DRAGON_BREATH_GAS: break;
            case SPELLABILITY_DRAGON_BREATH_LIGHTNING: break;
            case SPELLABILITY_DRAGON_BREATH_PARALYZE: break;
            case SPELLABILITY_DRAGON_BREATH_SLEEP: break;
            case SPELLABILITY_DRAGON_BREATH_SLOW: break;
            case SPELLABILITY_DRAGON_BREATH_WEAKEN: break;
            default: bDone = FALSE;
            }

            if (!UpdateSpellList("#BRT", iSpell, iRandom, oEnt))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
                iSpell = SPELL_INVALID;
        } // while !bDone
    }
    return iSpell;
}


int GetGroupEnhanceSpell(int iMinLvl = 1, object oCaster=OBJECT_SELF)
{
    int iSpell = SPELL_INVALID;
    int iMax = GetLocalInt(oCaster, "#GRPENHSPLMAX");

    if (iMax > 0)
    {
        int iPos;
        int iLvl;
        int bDone = FALSE;
        int iRandom;
        int iGuess = 3;
        object oMod = GetModule();

        while (!bDone && iGuess--)
        {
            iRandom = Random(iMax) + 1;
            iSpell = GetLocalInt(oCaster, "#GRPENHSPL"+IntToString(iRandom));
            iPos = GetLocalInt(oCaster, "#SPPOS" + IntToString(iSpell));
            iLvl = GetLocalInt(oMod, "#GRPENHSPLL" + IntToString(iPos));

            bDone = TRUE;

            if (iMinLvl > iLvl) // above allowed level
            {
                iMinLvl -= Random(2); // sometimes decrease minlevel to get better chance for a spell
                continue; // try another one
            }

            switch (iSpell)
            {
            case SPELL_MIND_BLANK: break;
            case SPELL_NATURES_BALANCE: break;
            //7
            case SPELL_AURA_OF_VITALITY: break;
            case SPELL_PROTECTION_FROM_SPELLS: break;
            //6
            case SPELL_MASS_HASTE: break;
            //3
            case SPELL_PRAYER: break;
            //1
            case SPELL_BLESS: break;
            default:
                bDone = FALSE;
            }

            if (!UpdateSpellList("#GRPENHSPL", iSpell, iRandom, oCaster))
            {
                bDone = FALSE;
                iSpell = SPELL_INVALID;
            }
            else if (!bDone)
            {
                if (iMinLvl > iLvl) // sometimes decrease minlevel to get better chance for a spell
                    iMinLvl -= Random(2);
                iSpell = SPELL_INVALID;
            }
        } // while !bDone
    }
    return iSpell;
}

float GetGroupEnhanceSpellRadius(int iSpell)
{
    if (iSpell == SPELL_MIND_BLANK)
        return RADIUS_SIZE_HUGE;
    if (iSpell == SPELL_NATURES_BALANCE)
        return RADIUS_SIZE_LARGE;
    if (iSpell == SPELL_AURA_OF_VITALITY)
        return RADIUS_SIZE_COLOSSAL;
    if (iSpell == SPELL_PROTECTION_FROM_SPELLS)
        return RADIUS_SIZE_LARGE;   //NOT SURE, NEED TO CHECK
    if (iSpell == SPELL_MASS_HASTE)
        return RADIUS_SIZE_LARGE;
    if (iSpell == SPELL_PRAYER)
        return RADIUS_SIZE_COLOSSAL;
    if (iSpell == SPELL_BLESS)
        return RADIUS_SIZE_GARGANTUAN;
    return 0.0;
}

int GetDispelSpell(object oEnt=OBJECT_SELF)
{
    if (GetHasSpell(SPELL_LESSER_DISPEL, oEnt))
        return SPELL_LESSER_DISPEL;
    if (GetHasSpell(SPELL_DISPEL_MAGIC, oEnt))
        return SPELL_DISPEL_MAGIC;
    if (GetHasSpell(SPELL_GREATER_DISPELLING, oEnt))
        return SPELL_GREATER_DISPELLING;
    if (GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION, oEnt))
        return SPELL_MORDENKAINENS_DISJUNCTION;
    return SPELL_INVALID;
}

int GetMaxDispelCasterLevel(object oEnt=OBJECT_SELF)
{
    //NOTE: this function may return some bad results if creatures with innate dispel abilities
    //also have levels in standard caster levels, where those levels are lower than their innate ones
    //Should be compensated for by GetBestDispel()
    int iL = 0;
    int iT = 0;
    int iC = 0;

    iL = GetLevelByClass(CLASS_TYPE_BARD, oEnt);
    iC += iL;
    if ((iT = GetLevelByClass(CLASS_TYPE_CLERIC, oEnt)) > iL)
        iL = iT;
    iC += iT;
    if ((iT = GetLevelByClass(CLASS_TYPE_DRUID, oEnt)) > iL)
        iL = iT;
    iC += iT;
    if ((iT = GetLevelByClass(CLASS_TYPE_PALADIN, oEnt)) > iL)
        iL = iT;
    iC += iT;
    if ((iT = GetLevelByClass(CLASS_TYPE_SORCERER, oEnt)) > iL)
        iL = iT;
    iC += iT;
    if ((iT = GetLevelByClass(CLASS_TYPE_WIZARD, oEnt)) > iL)
        iL = iT;
    iC += iT;
    if (!iC)
    {
        //no standard caster levels, check for innate abilities
        if (GetDispelSpell(oEnt) != 0)
            iL = 20; //pad out to max for safety, use the best
    }
    return iL;
}

int GetVisionSpellNeeded(object oS=OBJECT_SELF, object oC=OBJECT_SELF)
{
    int iT = GetHasSpellEffect(SPELL_TRUE_SEEING, oS);
    int iU = GetHasSpellEffect(SPELL_DARKVISION, oS);
    int iD = GetLocalInt(MeGetNPCSelf(oS), "#DARKNESS") || GetHasSpellEffect(SPELL_DARKNESS, oS);
    int iV = GetLocalInt(MeGetNPCSelf(oS), "#VANISHED");
    int iP = GetIsPC(oS) && GetHasSpellEffect(SPELL_DARKNESS, oS);
    object oA;
    int iCnt = 0;
    float fRad = 20.0;

    if (iV && !iD)
    {
        oA = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oS, ++iCnt);
        while (!iD && oA != OBJECT_INVALID && GetDistanceBetween(oS, oA) < fRad)
        {
            if (GetTag(oA) == "VFX_PER_DARKNESS")
            {
                //there is darkness in the area, could be messing with things
                //_PrintString("DARKNESS: " + GetName(oC) + " sees Darkness in range of " + GetName(oS), DEBUG_UTILITY);
                iD = 1;
            }
            oA = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oS, ++iCnt);
        }
    }

    if ((iD && !(iU || iT)) || iP)
    {
        //darkness, no ultravision, no true seeing
        if (GetHasSpell(SPELL_DARKVISION, oC))
            return SPELL_DARKVISION;
        if (GetHasSpell(SPELL_TRUE_SEEING, oC))
            return SPELL_TRUE_SEEING;
    }

    int iS = GetHasSpellEffect(SPELL_SEE_INVISIBILITY, oS);

    if (iV && !iD && !(iS || iT))
    {
        //vanished enemy, no darkness, no see invis, no true seeing
        if (GetHasSpell(SPELL_SEE_INVISIBILITY, oC))
            return SPELL_SEE_INVISIBILITY;
        if (GetHasSpell(SPELL_TRUE_SEEING, oC))
            return SPELL_TRUE_SEEING;
    }
    return SPELL_INVALID;
}

int GetHasVisionSpells(object oC=OBJECT_SELF)
{
    if (GetHasSpell(SPELL_DARKVISION, oC) ||
        GetHasSpell(SPELL_SEE_INVISIBILITY, oC) ||
        GetHasSpell(SPELL_TRUE_SEEING, oC))
        return TRUE;
    return FALSE;
}

int GetHasWeaponFocus(object oWeapon, object oC=OBJECT_SELF)
{
    switch (GetBaseItemType(oWeapon))
    {
        case BASE_ITEM_BASTARDSWORD:
            return GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD, oC);
        case BASE_ITEM_BATTLEAXE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE, oC);
        case BASE_ITEM_CLUB:
            return GetHasFeat(FEAT_WEAPON_FOCUS_CLUB, oC);
        case BASE_ITEM_DAGGER:
            return GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER, oC);
        case BASE_ITEM_DART:
            return GetHasFeat(FEAT_WEAPON_FOCUS_DART, oC);
        case BASE_ITEM_DIREMACE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE, oC);
        case BASE_ITEM_DOUBLEAXE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE, oC);
        case BASE_ITEM_GREATAXE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE, oC);
        case BASE_ITEM_GREATSWORD:
            return GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD, oC);
        case BASE_ITEM_HALBERD:
            return GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD, oC);
        case BASE_ITEM_HANDAXE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE, oC);
        case BASE_ITEM_HEAVYCROSSBOW:
            return GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW, oC);
        case BASE_ITEM_HEAVYFLAIL:
            return GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL, oC);
        case BASE_ITEM_KAMA:
            return GetHasFeat(FEAT_WEAPON_FOCUS_KAMA, oC);
        case BASE_ITEM_KATANA:
            return GetHasFeat(FEAT_WEAPON_FOCUS_KATANA, oC);
        case BASE_ITEM_KUKRI:
            return GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI, oC);
        case BASE_ITEM_LIGHTFLAIL:
            return GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL, oC);
        case BASE_ITEM_LIGHTHAMMER:
            return GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER, oC);
        case BASE_ITEM_LIGHTMACE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE, oC);
        case BASE_ITEM_LONGBOW:
            return GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW, oC);
        case BASE_ITEM_LONGSWORD:
            return GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD, oC);
        case BASE_ITEM_MORNINGSTAR:
            return GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR, oC);
        case BASE_ITEM_QUARTERSTAFF:
            return GetHasFeat(FEAT_WEAPON_FOCUS_STAFF, oC);
        case BASE_ITEM_RAPIER:
            return GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER, oC);
        case BASE_ITEM_SCIMITAR:
            return GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR, oC);
        case BASE_ITEM_SCYTHE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE, oC);
        case BASE_ITEM_SHORTBOW:
            return GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW, oC);
        case BASE_ITEM_SHORTSPEAR:
            return GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR, oC);
        case BASE_ITEM_SHORTSWORD:
            return GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD, oC);
        case BASE_ITEM_SHURIKEN:
            return GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN, oC);
        case BASE_ITEM_SICKLE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE, oC);
        case BASE_ITEM_SLING:
            return GetHasFeat(FEAT_WEAPON_FOCUS_SLING, oC);
        case BASE_ITEM_THROWINGAXE:
            return GetHasFeat(FEAT_WEAPON_FOCUS_THROWING_AXE, oC);
        case BASE_ITEM_TWOBLADEDSWORD:
            return GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD, oC);
        case BASE_ITEM_WARHAMMER:
            return GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER, oC);
        case BASE_ITEM_CBLUDGWEAPON:
            return GetHasFeat(FEAT_WEAPON_FOCUS_CREATURE, oC);
        case BASE_ITEM_CPIERCWEAPON:
            return GetHasFeat(FEAT_WEAPON_FOCUS_CREATURE, oC);
        case BASE_ITEM_CSLASHWEAPON:
            return GetHasFeat(FEAT_WEAPON_FOCUS_CREATURE, oC);
        case BASE_ITEM_CSLSHPRCWEAP:
            return GetHasFeat(FEAT_WEAPON_FOCUS_CREATURE, oC);
        case BASE_ITEM_INVALID:
            return GetHasFeat(FEAT_WEAPON_FOCUS_UNARMED_STRIKE, oC) || GetHasFeat(FEAT_WEAPON_FOCUS_CREATURE, oC);
    }
    return FALSE;
}

int GetIsDoubleWeapon(object oWeapon)
{
    int iType;

    if (GetIsObjectValid(oWeapon) && (iType = GetBaseItemType(oWeapon)) != BASE_ITEM_INVALID)
    {
        if (iType == BASE_ITEM_DIREMACE ||
            iType == BASE_ITEM_DOUBLEAXE ||
            iType == BASE_ITEM_TWOBLADEDSWORD)
            return TRUE;
    }
    return FALSE;
}

int GetIsLightWeapon( object oWeapon, int iCanBeInvalid=FALSE )
{
    int iType;

    if (GetIsObjectValid(oWeapon) && (iType = GetBaseItemType(oWeapon)) != BASE_ITEM_INVALID)
    {
        if (iType == BASE_ITEM_CLUB ||
            iType == BASE_ITEM_DAGGER ||
            iType == BASE_ITEM_HANDAXE ||
            iType == BASE_ITEM_KAMA ||
            iType == BASE_ITEM_KUKRI ||
            iType == BASE_ITEM_LIGHTFLAIL ||
            iType == BASE_ITEM_LIGHTHAMMER ||
            iType == BASE_ITEM_LIGHTMACE ||
            iType == BASE_ITEM_RAPIER ||
            iType == BASE_ITEM_SHORTSWORD ||
            iType == BASE_ITEM_SICKLE)
            return TRUE;
    }
    else if (!GetIsObjectValid(oWeapon) && iCanBeInvalid)
        return TRUE;
    return FALSE;
}


int GetDualWieldingPenalty(object oC=OBJECT_SELF, object oWeaponR=OBJECT_INVALID, object oWeaponL=OBJECT_INVALID)
{
    int iL;

    if (!GetIsObjectValid(oWeaponL))
    {
        //no weapon in left hand
        if (GetIsDoubleWeapon(oWeaponR))
            iL = 1; //right hand weapon is double weapon, effectively light offhand
        else //not wielding an offhand weapon, not dual wielding, no penalty, finish here
            return 0;
    }
    else
        iL = GetIsLightWeapon(oWeaponL);

    int iA = GetHasFeat(FEAT_AMBIDEXTERITY, oC);
    int iT = GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oC);
    int iP = 0;

    if (iA && iT)
    {
        //ambidex, two weapon fighting
        if (iL)
            iP = -2; //light offhand
        else
            iP = -4; //non-light offhand
    }
    else if (iA) //no iT
    {
        //ambidex, no two weapon
        if (iL)
            iP = -4; //light offhand
        else
            iP = -6; //non-light offhand
    }
    else if ( iT ) //no iA
    {
        //two weapon, no ambidex
        if (iL)
            iP = -2; //light offhand
        else
            //non-light offhand
            iP = -4;
    }
    else //no iA, no iT
    {
        //no two weapon, no ambidex
        if (iL)
            iP = -4; //light offhand
        else
            iP = -6; //non-light offhand
    }
    return iP;
}


int GetBestMeleeSpecial(object oTarget, int iChance=50, object oEnt=OBJECT_SELF)
{
    if (Random(100) > iChance || !GetIsObjectValid(oTarget))
        return FEATURE_INVALID;

    int iMax = GetLocalInt(oEnt, "#FEATMAX");
    if (iMax < 1)
        return FEATURE_INVALID;

    // get target's discipline skill as it opposes some melee specials
    int iDiscipline = GetSkillRank(SKILL_DISCIPLINE, oTarget) +
        GetAbilityModifier(ABILITY_STRENGTH, oTarget) +
        3 * GetHasFeat(FEAT_SKILL_FOCUS_DISCIPLINE, oTarget);

    int iKnowINT = DoAbilityCheck(ABILITY_INTELLIGENCE, 10);
    int iAB = GetBaseAttackBonus(oEnt);
    // use either my intelligence or BAB to check for creature knowledge
    int iKnowAB = GetAbilityModifier(ABILITY_INTELLIGENCE, oEnt);
    if (iKnowAB < iAB)
        iKnowAB = iAB;
    if (d20() + iKnowAB >= 10)
        iKnowAB = TRUE;
    else
        iKnowAB = FALSE;

    object oWeaponR = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oEnt);
    object oWeaponL = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oEnt);
    iAB += GetHasWeaponFocus(oWeaponR);

    if (GetHasFeat(FEAT_WEAPON_FINESSE, oWeaponR) && GetIsLightWeapon(oWeaponR, TRUE))
        iAB += GetAbilityModifier(ABILITY_DEXTERITY, oEnt);
    else
        iAB += GetAbilityModifier( ABILITY_STRENGTH, oEnt);

    // dual wielding penalties
    if (GetIsWeapon(oWeaponR))
        iAB += GetDualWieldingPenalty(oEnt, oWeaponR, oWeaponL);

    int iEnemyAC = GetAC(oTarget) - 10;
    int iFeat = FEATURE_INVALID;
    int bDone = FALSE;
    int iRandom;
    int iGuess = 3;

    while (!bDone && iGuess--)
    {
        iRandom = Random(iMax) + 1;
        iFeat = GetLocalInt(oEnt, "#FEAT"+IntToString(iRandom));

        bDone = TRUE;

        switch (iFeat)
        {
        case FEAT_KNOCKDOWN:
            bDone = (iAB >= iEnemyAC && iAB > iDiscipline) &&
                    !GetHasFeatEffect(FEAT_KNOCKDOWN, oTarget);
            break;
        case FEAT_IMPROVED_KNOCKDOWN:
            bDone = !iKnowAB || ((iAB-4 >= iEnemyAC) && (iAB-4 > iDiscipline) &&
                               !GetHasFeatEffect(FEAT_IMPROVED_KNOCKDOWN, oTarget));
            break;
        case FEAT_CALLED_SHOT:
            bDone = !iKnowAB || ((iAB-4 >= iEnemyAC) && (iAB-4 > iDiscipline));
            break;
        case FEAT_DISARM:
            // TODO weaponsize modifier?
            bDone = !iKnowAB && ((iAB-6 >= iEnemyAC) && (iAB-6 > iDiscipline));
            break;
        case FEAT_IMPROVED_DISARM:
            // TODO weaponsize modifier?
            bDone = (oWeaponR != OBJECT_INVALID || oWeaponL != OBJECT_INVALID) &&
                    (!iKnowAB || ((iAB-4 >= iEnemyAC) && (iAB-4 > iDiscipline)));
            break;
        case FEAT_STUNNING_FIST:
            // TODO Hit dice threshold?
            bDone = !GetHasFeatEffect(FEAT_STUNNING_FIST, oTarget) &&
                    (!iKnowINT || !GetIsImmune(oTarget, IMMUNITY_TYPE_STUN));
            break;
        case FEAT_QUIVERING_PALM:
            bDone = (!iKnowINT || !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH));
            break;
            // TODO Hit dice threshold?
        // TODO HotU:
        // case FEAT_SMITE_EVIL:
        // case FEAT_SMITE_GOOD:
        // case FEAT_IMPROVED_WHIRLWIND:
        // case FEAT_WHIRLWIND_ATTACK:
        // case FEAT_KI_DAMAGE: => what is KI_STRIKE?
        default:
            bDone = FALSE;
        }
        if (!UpdateFeatureList("#FEAT", iFeat, iRandom, oEnt))
        {
            bDone = FALSE;
            iFeat = SPELL_INVALID;
        }
        else if (!bDone)
            iFeat = FEATURE_INVALID;
    }

    return iFeat;
}

int GetEnhanceFeat(object oEnt=OBJECT_SELF)
{
    int iMax = GetLocalInt(oEnt, "#ENHFEATMAX");
    if (iMax < 1)
        return FEATURE_INVALID;

    int iFeat = FEATURE_INVALID;
    int bDone = FALSE;
    int iRandom;
    int iGuess = 3;
    // don't use barbarian rage if archer, this would cause melee
    int iRanged = GetIsRangedWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oEnt));

    while (!bDone && iGuess--)
    {
        iRandom = Random(iMax) + 1;
        iFeat = GetLocalInt(oEnt, "#ENHFEAT"+IntToString(iRandom));
        bDone = TRUE;

        switch (iFeat)
        {
        case FEAT_EMPTY_BODY: bDone = !GetHasFeatEffect(FEAT_EMPTY_BODY, oEnt); break;
        case FEAT_BARBARIAN_RAGE: bDone = !iRanged && !GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oEnt); break;
        case FEAT_BARD_SONGS: bDone = !GetHasFeatEffect(FEAT_BARD_SONGS, oEnt); break;
        default: bDone = FALSE;
        }
        if (!UpdateFeatureList("#ENHFEAT", iFeat, iRandom, oEnt))
        {
            bDone = FALSE;
            iFeat = SPELL_INVALID;
        }
        else if (!bDone)
            iFeat = FEATURE_INVALID;
    }
    return iFeat;
}

int GetGroupEnhanceFeat(object oEnt=OBJECT_SELF)
{
    if (GetHasFeat(FEAT_BARD_SONGS, oEnt) && !GetHasFeatEffect(FEAT_BARD_SONGS, oEnt))
        return FEAT_BARD_SONGS;
    return FEATURE_INVALID;
}

float GetGroupEnhanceFeatRadius(int iFeat)
{
    if (iFeat == FEAT_BARD_SONGS)
        return RADIUS_SIZE_COLOSSAL;
    return 0.0;
}

int DoSpell(int iSpell)
{
    if (GetHasSpell(iSpell, OBJECT_SELF) && !GetHasSpellEffect(SPELLABILITY_DRAGON_FEAR, OBJECT_SELF))
    {
        ActionCastSpellAtObject(iSpell, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        return TRUE;
    }
    return FALSE;
}


//Function imported from SoU x0_i0_spells
int IsImmuneToPetrification(object oCreature)
{
    switch (GetAppearanceType(oCreature))
    {
    case APPEARANCE_TYPE_BASILISK:
    case APPEARANCE_TYPE_COCKATRICE:
    case APPEARANCE_TYPE_MEDUSA:
    case APPEARANCE_TYPE_ALLIP:
    case APPEARANCE_TYPE_ELEMENTAL_AIR:
    case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
    case APPEARANCE_TYPE_ELEMENTAL_EARTH:
    case APPEARANCE_TYPE_ELEMENTAL_EARTH_ELDER:
    case APPEARANCE_TYPE_ELEMENTAL_FIRE:
    case APPEARANCE_TYPE_ELEMENTAL_FIRE_ELDER:
    case APPEARANCE_TYPE_ELEMENTAL_WATER:
    case APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER:
    case APPEARANCE_TYPE_GOLEM_STONE:
    case APPEARANCE_TYPE_GOLEM_IRON:
    case APPEARANCE_TYPE_GOLEM_CLAY:
    case APPEARANCE_TYPE_GOLEM_BONE:
    case APPEARANCE_TYPE_GORGON:
    case APPEARANCE_TYPE_HEURODIS_LICH:
    case APPEARANCE_TYPE_LANTERN_ARCHON:
    case APPEARANCE_TYPE_SHADOW:
    case APPEARANCE_TYPE_SHADOW_FIEND:
    case APPEARANCE_TYPE_SHIELD_GUARDIAN:
    case APPEARANCE_TYPE_SKELETAL_DEVOURER:
    case APPEARANCE_TYPE_SKELETON_CHIEFTAIN:
    case APPEARANCE_TYPE_SKELETON_COMMON:
    case APPEARANCE_TYPE_SKELETON_MAGE:
    case APPEARANCE_TYPE_SKELETON_PRIEST:
    case APPEARANCE_TYPE_SKELETON_WARRIOR:
    case APPEARANCE_TYPE_SKELETON_WARRIOR_1:
    case APPEARANCE_TYPE_SPECTRE:
    case APPEARANCE_TYPE_WILL_O_WISP:
    case APPEARANCE_TYPE_WRAITH:
    case APPEARANCE_TYPE_BAT_HORROR:
        return TRUE;
    }
    return FALSE;
}

int CanAct(object oSelf=OBJECT_SELF)
{
    int iType;

    if (GetIsDead(oSelf))
        return FALSE;

    effect eEff = GetFirstEffect(oSelf);

    while (GetIsEffectValid(eEff))
    {
        iType = GetEffectType(eEff);
        if (iType == EFFECT_TYPE_CONFUSED ||
            iType == EFFECT_TYPE_DAZED ||
            iType == EFFECT_TYPE_FRIGHTENED ||
            iType == EFFECT_TYPE_PARALYZE ||
            iType == EFFECT_TYPE_PETRIFY ||
            iType == EFFECT_TYPE_SLEEP ||
            iType == EFFECT_TYPE_STUNNED ||
            //iType == EFFECT_TYPE_DOMINATED ||
            //iType == EFFECT_TYPE_CHARMED ||
            iType == EFFECT_TYPE_TURNED)
            return FALSE;
        eEff = GetNextEffect(oSelf);
    }

    return TRUE;
}

int GetEffectsOnObject(object oEnt=OBJECT_SELF)
{
    int iTally = 0;
    int iType;
    effect eSubj;

    eSubj = GetFirstEffect(oEnt);
    while (GetIsEffectValid(eSubj))
    {
        iType = GetEffectType(eSubj);
        if (iType == EFFECT_TYPE_ABILITY_DECREASE ||
            iType == EFFECT_TYPE_AC_DECREASE ||
            iType == EFFECT_TYPE_ATTACK_DECREASE ||
            iType == EFFECT_TYPE_DAMAGE_DECREASE ||
            iType == EFFECT_TYPE_SPELL_RESISTANCE_DECREASE ||
            iType == EFFECT_TYPE_SAVING_THROW_DECREASE)  iTally |= 1;
        else if (iType == EFFECT_TYPE_DISEASE)           iTally |= 2;
        else if (iType == EFFECT_TYPE_CURSE)             iTally |= 4;
        else if (iType == EFFECT_TYPE_POISON)            iTally |= 8;
        else if (iType == EFFECT_TYPE_DEAF)              iTally |= 16;
        else if (iType == EFFECT_TYPE_BLINDNESS)         iTally |= 32;
        else if (iType == EFFECT_TYPE_NEGATIVELEVEL)     iTally |= 64;
        else if (iType == EFFECT_TYPE_FRIGHTENED)        iTally |= 128;
        else if (iType == EFFECT_TYPE_CONFUSED)          iTally |= 256;
        else if (iType == EFFECT_TYPE_CHARMED)           iTally |= 512;
        else if (iType == EFFECT_TYPE_SLEEP)             iTally |= 1024;
        else if (iType == EFFECT_TYPE_STUNNED)           iTally |= 2048;
        else if (iType == EFFECT_TYPE_PARALYZE)          iTally |= 4096;
        else if (iType == EFFECT_TYPE_PETRIFY)           iTally |= 8192;

        eSubj = GetNextEffect(oEnt);
    }
    return iTally;
}

