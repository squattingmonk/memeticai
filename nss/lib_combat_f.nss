/*------------------------------------------------------------------------------
 *  Combat Actions Function Library
 *  May, 2003
 *  Joel Martin
 *  modifications by Niveau0
 *  Jan, 2004
 *
 *  This library contains memetic functions used by lib_combat.
 *  These functions instantiate the actions that an NPC might take during combat.
 *  For the most part, they are called from the i_docombat meme, although in some
 *  cases they me be called directly from the g_combatai generator.
 *
 *  At the end of this library you will find a main() function. This contains
 *  the code that registers and runs the scripts in this library. Read the
 *  instructions to add your own objects to this library or to a new library.
 ------------------------------------------------------------------------------*/

#include "h_library"
#include "h_util_combat"

// This function checks to see if the NPC is hurt or has more friends around
// than enemies. In which case it will change its tactic. The argument to this
// function is the combat meme. When the combat meme runs through a table, it
// passes itself as a parameter. This gives the function a chance to change
// which behavior table it should be using.
object f_BecomeDefensive(object oMeme = OBJECT_INVALID)
{
    // The result is a fraction enemy_count/friendly_count
    if (GetFriendFoeRatio() < 1.0)
    {
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Switch to defensive");
        MeSetActiveResponseTable("Combat", "Defensive Combat Table");
        return NPC_SELF;
    }
    return OBJECT_INVALID;
}


object f_FastBuffs()
{
    int iSuccess=FALSE;
    int iSpell, i;

    for (i=0; i<=13; i++)
    {
        switch (i)
        {
        case 0: iSpell = SPELLABILITY_DRAGON_FEAR; break;
        case 1: iSpell = SPELLABILITY_AURA_BLINDING; break;
        case 2: iSpell = SPELLABILITY_AURA_COLD; break;
        case 3: iSpell = SPELLABILITY_AURA_ELECTRICITY; break;
        case 4: iSpell = SPELLABILITY_AURA_FIRE; break;
        case 5: iSpell = SPELLABILITY_AURA_MENACE; break;
        case 6: iSpell = SPELLABILITY_AURA_OF_COURAGE; break;
        case 7: iSpell = SPELLABILITY_AURA_PROTECTION; break;
        case 8: iSpell = SPELLABILITY_AURA_STUN; break;
        case 9: iSpell = SPELLABILITY_AURA_UNEARTHLY_VISAGE; break;
        case 10: iSpell = SPELLABILITY_AURA_FEAR; break;
        case 11: iSpell = SPELLABILITY_AURA_UNNATURAL; break;
        case 12: iSpell = SPELLABILITY_EMPTY_BODY; break;
        case 13: iSpell = SPELLABILITY_TYRANT_FOG_MIST; break;
        }

        if (DoSpell(iSpell)) iSuccess = TRUE;
    }

    if (DoSpell(SPELLABILITY_RAGE_5)) iSuccess=TRUE;
    if (!iSuccess && DoSpell(SPELLABILITY_RAGE_4)) iSuccess=TRUE;
    if (!iSuccess && DoSpell(SPELLABILITY_RAGE_3)) iSuccess=TRUE;

    if (DoSpell(SPELLABILITY_FEROCITY_3)) iSuccess=TRUE;
    if (!iSuccess && DoSpell(SPELLABILITY_FEROCITY_2)) iSuccess=TRUE;
    if (!iSuccess && DoSpell(SPELLABILITY_FEROCITY_1)) iSuccess=TRUE;

    if (DoSpell(SPELLABILITY_INTENSITY_3)) iSuccess=TRUE;
    if (!iSuccess && DoSpell(SPELLABILITY_INTENSITY_2)) iSuccess=TRUE;
    if (!iSuccess && DoSpell(SPELLABILITY_INTENSITY_1)) iSuccess=TRUE;

    if (iSuccess)
    {
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Fastbuffing");
        return NPC_SELF;
    }
    return OBJECT_INVALID;
}

object f_SpellHeal(object oT=OBJECT_INVALID)
{
    int iHeal = GetHealingAbilities();

    if (iHeal)
    {
        int iMin = 8;
        object oHurt = (GetIsObjectValid(oT) ? oT : GetMostDamagedFriendNoHealer());

        if (GetIsObjectValid(oHurt))
        {
            iHeal = GetBestHeal(iHeal, oHurt, iMin);
            if (iHeal != SPELL_INVALID)
            {
                talent tHeal = GetTalentSpell(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, iHeal);
                if (GetIsTalentValid(tHeal))
                {
                    object oNPCSELF = MeGetNPCSelf(oHurt);
                    // tell the target, healing is on its way
                    SetLocalObject(oNPCSELF, "#HEALER", OBJECT_SELF);
                    DelayCommand(6.0, DeleteLocalObject(oNPCSELF, "#HEALER"));
                    if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Healing by talent");
                    ActionUseTalentOnObject(tHeal, oHurt);
                    return oHurt;
                }
            }
        }
    }

    return OBJECT_INVALID;
}

object f_SpellDirect(object oT=OBJECT_INVALID)
{
    // first go for least defended, then for most damaged
    if (GetIsObjectValid(oT))
    {
        _PrintString("Using specified target", DEBUG_COREAI);
    }
//    else if (!GetIsObjectValid(oT = GetLeastMagicDefEnemy()))
	else
    {
        if (DoAbilityCheck(ABILITY_INTELLIGENCE, 10))
            oT = GetMostDamagedEnemy();
        if (!GetIsObjectValid(oT) || !GetObjectSeen(oT))
            oT = GetTarget(OBJECT_SELF, TRUE);
    }

    if (GetIsObjectValid(oT))
    {
        //open up spell level selection range
        int iMinLvl = GetHitDice(oT) / 3; // TODO test if this is too few
        int iSpell = SPELL_INVALID;

        if (GetObjectSeen(oT))
            iSpell = GetDirectSpell(oT, iMinLvl); // this should be a non-area spell

        if (iSpell != SPELL_INVALID)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0)
                ActionSpeakString("Using direct spell " + IntToString(iSpell));
            ActionCastSpellAtObject(iSpell, oT);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}


object f_Touch(object oT=OBJECT_INVALID)
{
    // first go for least defended, then for most damaged
    if (GetIsObjectValid(oT))
    {
        _PrintString("Using specified target", DEBUG_COREAI);
    }
    else if (!GetIsObjectValid(oT = GetLeastMagicDefEnemy()))
    {
        if (DoAbilityCheck(ABILITY_INTELLIGENCE, 10))
            oT = GetMostDamagedEnemy();
        if (!GetIsObjectValid(oT) || !GetObjectSeen(oT))
            oT = GetTarget();
    }

    if (GetIsObjectValid(oT))
    {
        //open up spell level selection range
        int iMinLvl = GetHitDice(oT) / 3; // TODO test if this is too few
        int iSpell = SPELL_INVALID;

        if (GetObjectSeen(oT, OBJECT_SELF))
            iSpell = GetTouchSpell(oT, iMinLvl);

        if (iSpell != SPELL_INVALID)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Using touch spell");
            ActionCastSpellAtObject(iSpell, oT);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}


object f_AttackRanged(object oT=OBJECT_INVALID)
{
    DeleteLocalInt(NPC_SELF, "#RANGED");

    if (GetHasFeatEffect(FEAT_BARBARIAN_RAGE, OBJECT_SELF))
    {
        //raging barbarians should skip ranged
        return OBJECT_INVALID;
    }

    int iT = 0;
    if (!GetIsObjectValid(oT))
        oT = GetTarget();
    else
        iT = 1; // forced target

    if (!GetIsObjectValid(oT))
        return OBJECT_INVALID;

    if (!GetLocalInt(NPC_SELF, "#RANGEDCAPABLE"))
        return OBJECT_INVALID;

    if (!GetNearAttackerCount())
    {
        // get distance to enemies
        if (GetNearHostileCount())
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Avoid melee before range");
            if (GetIsObjectValid(MeCallFunction(GetLocalString(NPC_SELF, COMBAT_AVOIDMELEE))))
                return NPC_SELF;
        }
    }
    else if (!Random(3))
    {
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Avoid melee before range");
        if (GetIsObjectValid(MeCallFunction(GetLocalString(NPC_SELF, COMBAT_AVOIDMELEE))))
            return NPC_SELF;
    }

    if (iT == 0) // not specifically told to attack a target
    {
        object oHurt;

        // if I'm smart enough and out of pressure, attack enemies near death
        if (GetAttackTarget(oT) != OBJECT_SELF &&
            DoAbilityCheck(ABILITY_INTELLIGENCE, 10))
        {
            oHurt = GetMostDamagedEnemy();
            if (GetIsObjectValid(oHurt))
                oT = oHurt;
        }
    }

    if (!Random(10))
    {
        int iChat;
        switch (Random(5))
        {
        case 0: iChat = VOICE_CHAT_ATTACK; break;
        case 1: iChat = VOICE_CHAT_BATTLECRY1; break;
        case 2: iChat = VOICE_CHAT_BATTLECRY2; break;
        case 3: iChat = VOICE_CHAT_BATTLECRY3; break;
        case 4: iChat = VOICE_CHAT_TAUNT; break;
        }
        PlayVoiceChat(iChat);
    }

    if (!GetIsRangedWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)))
    {
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Equip Range");
        ActionEquipMostDamagingRanged(oT);
        SetLocalInt(NPC_SELF, "#EQUIPRANGED", 1);
    }
    else
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Range attack");

    ActionAttack(oT);

    return NPC_SELF;
}

object f_AttackMelee(object oT=OBJECT_INVALID)
{
    if (GetIsObjectValid(oT))
    {
        _PrintString("Using specified target", DEBUG_COREAI);
    }
    else
    {
        oT = GetTarget();

        if (GetNearAttackerCount() && GetAttackTarget(oT) != OBJECT_SELF)
        {
            // someone is near attacking me, but not oT
            // so choose one of those that attack me,
            // ignore visibility, since I can feel who is attacking me
            int iCnt = 1;
            oT = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF,
                        iCnt++, CREATURE_TYPE_IS_ALIVE, TRUE);

            while (oT != OBJECT_INVALID && GetAttackTarget(oT) != OBJECT_SELF &&
                   GetDistanceBetween(OBJECT_SELF, oT) <= 10.0)
                oT = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF,
                        iCnt++, CREATURE_TYPE_IS_ALIVE, TRUE);
        }
    }

    if (GetIsObjectValid(oT))
    {
        if (CombatEquipMelee(oT) == TRUE)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Equip Melee");
            return NPC_SELF;
        }

        int iSpecial = GetBestMeleeSpecial(oT);

        if (!Random(10))
        {
            int iChat;
            switch (Random(5))
            {
            case 0: iChat = VOICE_CHAT_ATTACK; break;
            case 1: iChat = VOICE_CHAT_BATTLECRY1; break;
            case 2: iChat = VOICE_CHAT_BATTLECRY2; break;
            case 3: iChat = VOICE_CHAT_BATTLECRY3; break;
            case 4: iChat = VOICE_CHAT_TAUNT; break;
            }
            PlayVoiceChat(iChat);
        }


        if (iSpecial != FEATURE_INVALID)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Melee feature attack");
            ActionUseFeat(iSpecial, oT);
        }
        else
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Melee attack");
            ActionAttack(oT);
        }
        return NPC_SELF;
    }
    else
    {
        // hm, still no valid target, try some last things to find the enemy
        oT = GetLastHostileActor();

        if (oT != OBJECT_INVALID && !GetIsDead(oT) && GetArea(oT) == GetArea(OBJECT_SELF))
        {
            location lLoc;
            vector vT, vU;

            // move to a location somewhere near to target
            vU = GetPosition(OBJECT_SELF);
            vT = GetPosition(oT) - vU;
            vT = VectorMagnitude(vT) * VectorNormalize(AngleToVector(VectorToAngle(vT) - 45.0 + IntToFloat(Random(90))));
            lLoc = Location(GetArea(OBJECT_SELF), vU + vT, VectorToAngle(vT));

            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Moving for melee attack");

            SetLocalLocation(OBJECT_SELF, "lDest", lLoc);
            SetLocalInt(OBJECT_SELF, "bRun", TRUE);
            MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOLOCATION), OBJECT_SELF);
            DeleteLocalLocation(OBJECT_SELF, "lDest");
            DeleteLocalInt(OBJECT_SELF, "bRun");

            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}


object f_MoveToObject(object oDest)
{
    if (GetIsObjectValid(oDest))
    {
        int bRun = GetLocalInt(oDest, "bRun");
        float fDist = GetLocalFloat(oDest, "fDist");
        location lDest;
        vector vT;

        if (GetLocalInt(NPC_SELF, "TELEPORTER"))
        {
            vT = GetPosition(oDest) + fDist * VectorNormalize(GetPosition(NPC_SELF) - GetPosition(oDest));
            lDest = Location(GetArea(oDest), vT, VectorToAngle(GetPosition(oDest) - vT));

            SetLocalLocation(OBJECT_SELF, "lLoc", lDest);
            MeCallFunction(GetLocalString(NPC_SELF, COMBAT_TELEPORT), OBJECT_SELF);
            DeleteLocalLocation(OBJECT_SELF, "lLoc");
        }
        else if (GetLocalInt(NPC_SELF, "DRAGONFLYER"))
        {
            vT = GetPosition(oDest) + fDist * VectorNormalize(GetPosition(NPC_SELF) - GetPosition(oDest));
            lDest = Location(GetArea(oDest), vT, VectorToAngle(GetPosition(oDest) - vT));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDisappearAppear(lDest), NPC_SELF, 3.0);
        }
        else
            ActionMoveToObject(oDest, bRun, fDist);
    }

    return NPC_SELF;
}

object f_MoveToLocation(object oArg=OBJECT_SELF)
{
    if (GetIsObjectValid(oArg))
    {
        location lDest = GetLocalLocation(oArg, "lDest");
        int bRun = GetLocalInt(oArg, "bRun");

        if (GetLocalInt(NPC_SELF, "TELEPORTER"))
        {
            SetLocalLocation(OBJECT_SELF, "lLoc", lDest);
            MeCallFunction(GetLocalString(NPC_SELF, COMBAT_TELEPORT), OBJECT_SELF);
            DeleteLocalLocation(OBJECT_SELF, "lLoc");
        }
        else if (GetLocalInt(NPC_SELF, "DRAGONFLYER"))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDisappearAppear(lDest), OBJECT_SELF, 3.0);
        }
        else
            ActionMoveToLocation(lDest, bRun);
    }

    return NPC_SELF;
}

object f_Teleport(object oArg=OBJECT_SELF)
{
    if (GetIsObjectValid(oArg))
    {
        location lLoc = GetLocalLocation(oArg, "lLoc");
        effect eVis = EffectVisualEffect(VFX_IMP_GLOBE_USE);

        ActionCastFakeSpellAtObject(SPELLABILITY_SUMMON_CELESTIAL, OBJECT_SELF);
        ActionDoCommand(ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(OBJECT_SELF)));
        ActionDoCommand(ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lLoc));
        ActionJumpToLocation(lLoc);
    }

    return NPC_SELF;
}

object f_FightBroadcast()
{
    //broadcast fight "noise" at most once a second
    int iDelay = 6;
    int iTime = GetTimeSecond();
    int iLast = GetLocalInt(NPC_SELF, "#LASTCREBC");
    int iS = iTime < iLast ? iTime + 60 : iTime;
    //anti-spamloop delay
    if (iS - iLast > iDelay)
    {
        SpeakString("BC_FIGHTING", TALKVOLUME_SILENT_TALK);
        SetLocalInt(NPC_SELF, "#LASTCREBC", iTime);
    }

    return NPC_SELF;
}

object f_CounterSpell(object oT=OBJECT_INVALID)
{
    //do not counterspell if I have timestop running
    if (GetHasSpellEffect(SPELL_TIME_STOP))
        return OBJECT_INVALID;

    //do not counterspell if I have attackers
    if (GetAttackerCount())
        return OBJECT_INVALID;

    object oC = GetIsObjectValid(oT) ? oT : GetNearEnemyCaster();
    if (GetIsObjectValid(oC))
    {
        ActionCounterSpell(oC); // TODO whats happening here? check if it stopps the npc
        return NPC_SELF;
    }
    return OBJECT_INVALID;
}

object f_EvacAOE()
{
    vector vT;
    location lLoc;

    //don't bother if we have time stop
    if (GetHasSpellEffect(SPELL_TIME_STOP))
        return OBJECT_INVALID;

    if (GetHostileAOECount() > 0)
    {
        vT = GetAOEEvacVector(GetHostileAOEVector());
        lLoc = Location(GetArea(OBJECT_SELF), vT, GetFacing(OBJECT_SELF));

        SetLocalLocation(NPC_SELF, "LASTLOC", GetLocation(OBJECT_SELF));

        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("AOE evasion");

        SetLocalLocation(OBJECT_SELF, "lDest", lLoc);
        SetLocalInt(OBJECT_SELF, "bRun", TRUE);
        MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOLOCATION), OBJECT_SELF);
        DeleteLocalLocation(OBJECT_SELF, "lDest");
        DeleteLocalInt(OBJECT_SELF, "bRun");

        return NPC_SELF;
    }
    return OBJECT_INVALID;
}

object f_Regroup(object oT=OBJECT_INVALID)
{
    //don't bother if we have time stop
    if (GetHasSpellEffect(SPELL_TIME_STOP))
        return OBJECT_INVALID;

    //check for order to regroup to a particular object
    if (GetIsObjectValid(oT))
    {
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Regroup around given target");

        SetLocalInt(oT, "bRun", TRUE);
        SetLocalFloat(oT, "fDist", 5.0);
        MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOOBJECT), oT);
        DeleteLocalInt(oT, "bRun");
        DeleteLocalFloat(oT, "fDist");

        return NPC_SELF;
    }

    object oMostDistant = GetMostDistantFriend();
    if (!GetIsObjectValid(oMostDistant))
    {
        return OBJECT_INVALID;
    }

    float fAvgFriendDistance = GetAvgFriendDistance();
    if (fAvgFriendDistance > 15.0 && DoAbilityCheck(ABILITY_INTELLIGENCE, 10))
    {
        // average distance greater 15.0
        // I need to regroup, get movement vector
        location lLoc;
        vector vT = GetPosition(oMostDistant);
        vT = VectorMagnitude(vT) / 2 * VectorNormalize(vT);
        lLoc = Location(GetArea(OBJECT_SELF), vT, VectorToAngle(vT));

        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Regroup");

        SetLocalLocation(OBJECT_SELF, "lDest", lLoc);
        SetLocalInt(OBJECT_SELF, "bRun", TRUE);
        MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOLOCATION), OBJECT_SELF);
        DeleteLocalLocation(OBJECT_SELF, "lDest");
        DeleteLocalInt(OBJECT_SELF, "bRun");

        if (!Random(5))
            PlayVoiceChat(VOICE_CHAT_GROUP);
        return NPC_SELF;
    }
    else
    {
        //look for outliers
        if (GetDistanceBetween(OBJECT_SELF, oMostDistant) > 25.0)
        {
            // if I'm to far away, move near most distant =>
            // TODO: eval if dynamic squad leader better calls for regrouping around him
            // or make an extra function for squad leaders
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Regroup at outlier");

            SetLocalInt(oMostDistant, "bRun", TRUE);
            SetLocalFloat(oMostDistant, "fDist", 5.0);
            MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOOBJECT), oMostDistant);
            DeleteLocalInt(oMostDistant, "bRun");
            DeleteLocalFloat(oMostDistant, "fDist");

            if (!Random(5))
                PlayVoiceChat(VOICE_CHAT_GROUP);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_DefendSelf()
{
    int iSpell = SPELL_INVALID;

    // Don't take attackers into account... its too late then
    // if (GetAttackerCount() || GetHostileCount())
    if (GetHostileCount())
    {
        struct sPhysDefStatus strPDef = EvaluatePhysicalDefenses();
        if (strPDef.iTotal < 4 && (iSpell = GetBestPhysDefSpellSelf()) != SPELL_INVALID)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Defend self against physics");
            ActionCastSpellAtObject(iSpell, OBJECT_SELF);
            return NPC_SELF;
        }
    }

    if (GetCasterCount())
    {
        struct sSpellDefStatus strMDef = EvaluateSpellDefenses();
        if (strMDef.iTotal < 4 && (iSpell = GetBestMagicDefSpellSelf()) != SPELL_INVALID)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Defend self against magic");
            ActionCastSpellAtObject(iSpell, OBJECT_SELF);
            return NPC_SELF;
        }
    }

    if (!Random(5))
    {
        talent tEnh;

        tEnh = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_PROTECTION_POTION);
        if (GetIsTalentValid(tEnh))
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Use protection potion");
            ActionUseTalentOnObject(tEnh, OBJECT_SELF);
            return NPC_SELF;
        }

        tEnh = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_POTION);
        if (GetIsTalentValid(tEnh))
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Use conditional potion");
            ActionUseTalentOnObject(tEnh, OBJECT_SELF);
            return NPC_SELF;
        }
    }

    return OBJECT_INVALID;
}


object f_DefendSingle(object oT=OBJECT_INVALID)
{
    object oD;
    int iSpell;
    struct sSpellDefStatus strM;
    struct sPhysDefStatus strP;

    oD = GetIsObjectValid(oT) ? oT : GetLeastDefFriend();
    if (GetIsObjectValid(oD))
    {
        strM = EvaluateSpellDefenses(oD);
        strP = EvaluatePhysicalDefenses(oD);
        if (strM.iTotal < strP.iTotal)
        {
            if ((iSpell = GetBestMagicDefSpellSingle(oD)) != SPELL_INVALID)
            {
                if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Defend other against physics");
                ActionCastSpellAtObject(iSpell, oD);
                return NPC_SELF;
            }
        }
        else
        {
            if ((iSpell = GetBestPhysDefSpellSingle(oD)) != SPELL_INVALID)
            {
                if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Defend other against magic");
                ActionCastSpellAtObject(iSpell, oD);
                return NPC_SELF;
            }
        }
    }
    return OBJECT_INVALID;
}

object f_EnhanceSelf()
{
    int iMinLvl = GetHitDice(OBJECT_SELF);
    iMinLvl = iMinLvl > 20 ? 20 : iMinLvl;

    int iSpell = GetEnhanceSpellSelf(iMinLvl / 3);
    if (iSpell != SPELL_INVALID)
    {
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Enhance self");
        ActionCastSpellAtObject(iSpell, OBJECT_SELF);
        return NPC_SELF;
    }
    return OBJECT_INVALID;
}


object f_EnhanceSingle(object oT=OBJECT_INVALID)
{
    if (!GetIsObjectValid(oT))
        oT = GetLeastBuffedFriend();

    if (GetIsObjectValid(oT))
    {
        int iSpell = SPELL_INVALID;
        int iMinLvl = GetHitDice(OBJECT_SELF);

        iMinLvl = iMinLvl > 20 ? 20 : iMinLvl;
        iMinLvl = iMinLvl / 3;
        if ((iSpell = GetEnhanceSpellSingle(iMinLvl, oT)) != SPELL_INVALID)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Enhance spell other");
            ActionCastSpellAtObject(iSpell, oT);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_SpellHelp(object oT=OBJECT_INVALID)
{
    int iHelp = GetHelpingAbilities();

    if (iHelp)
    {
        if (!GetIsObjectValid(oT))
            oT = GetMostBadEffectedFriend();

        if (GetIsObjectValid(oT))
        {
            iHelp = GetBestHelp(iHelp, oT);
            if (iHelp != SPELL_INVALID)
            {
                object oNPCSELF = MeGetNPCSelf(oT);

                // tell target,help is on its way
                SetLocalObject(oNPCSELF, "HELPER", OBJECT_SELF);
                DelayCommand(6.0, DeleteLocalObject(oNPCSELF, "HELPER"));
                if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Spell help");
                ActionCastSpellAtObject(iHelp, oT);
                return NPC_SELF;
            }
        }
    }
    return OBJECT_INVALID;
}

object f_SpellRaise(object oT=OBJECT_INVALID)
{
    int iRaise;

    if (iRaise = GetRaisingAbilities())
    {
        if (!GetIsObjectValid(oT))
            oT = GetDeadFriendNoRaiser();

        if (GetIsObjectValid(oT))
        {
            iRaise = GetBestRaise(iRaise, TRUE);
            if (iRaise != SPELL_INVALID)
            {
                object oNPCSELF = MeGetNPCSelf(oT);

                SetLocalObject(oNPCSELF, "#RAISER", OBJECT_SELF);
                DelayCommand(6.0, DeleteLocalObject(oNPCSELF, "#RAISER"));
                if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Raise");
                ActionCastSpellAtObject(iRaise, oT);
                return NPC_SELF;
            }
        }
    }
    return OBJECT_INVALID;
}

object f_SpellBreach(object oT=OBJECT_INVALID)
{
    int iCnt = 1;
    int iSpell = SPELL_INVALID;
    int iMaxLvl = 0;
    int iMaxNum = 0;
    struct sSpellDefStatus strMDef;
    struct sPhysDefStatus strPDef;

    //add breach check before doing search?
    if (!GetIsObjectValid(oT))
        oT = GetMostMagicDefEnemy();

    if (GetIsObjectValid(oT))
    {
        if ((iSpell = GetBestBreach(iMaxLvl)) != SPELL_INVALID)
        {
            object oNPCSELF = MeGetNPCSelf(oT);

            SetLocalObject(oNPCSELF, "BREACHER", OBJECT_SELF);
            DelayCommand(4.0, DeleteLocalObject(oNPCSELF, "BREACHER"));
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Breach");
            ActionCastSpellAtObject(iSpell, oT);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_SpellArea()
{
    int iCnt;
    int iMinLvl = 0;
    int iSpell = SPELL_INVALID;
    float fRad;
    float fRatio;
    float fMinSearch = 0.0;
    float fMaxSearch;
    float fRange;
    vector vU;
    vector vT;
    location lMark;
    object oTarget;
    object oD;

    vU = GetPosition(OBJECT_SELF);
    iMinLvl = GetAverageEnemyLevel() / 3;

    int iHostiles = GetHostileCount();

    if (iHostiles == 1)
    {
        oTarget = GetTarget();
        if (!GetIsObjectValid(oTarget))
            return OBJECT_INVALID;

        fMaxSearch = GetDistanceBetween(OBJECT_SELF, oTarget);
        iSpell = GetAreaSpell(FALSE, iMinLvl, fMaxSearch);

        if (iSpell == SPELL_INVALID)
            return OBJECT_INVALID;

        fRad = GetLastAreaSpellSize();
        vT = GetPosition(oTarget) - vU;

        fRange = GetLastAreaSpellRange();
        if (GetLastAreaSpellDiscriminant())
        {
            if (fRange == 0.0)
                ActionCastSpellAtLocation(iSpell, GetLocation(OBJECT_SELF));
            else
                ActionCastSpellAtObject(iSpell, oTarget);
        }
        else
        {
            fRatio = GetFriendFoeRatio();
            if (fRatio < GetFriendFoeTolerance())
            {
                iSpell = GetAreaSpell(TRUE, iMinLvl, fMaxSearch);
                if (iSpell == SPELL_INVALID)
                    return OBJECT_INVALID;
            }
            //either fRatio is okay or we have a discriminant spell now

            fRange = GetLastAreaSpellRange();
            if (fRange == 0.0)
                ActionCastSpellAtLocation(iSpell, GetLocation(OBJECT_SELF));
            else
                ActionCastSpellAtObject(iSpell, oTarget);
        }
        return NPC_SELF;
    }
    else if (iHostiles > 1)
    {
        oD = GetMostDistantEnemy();
        if (GetIsObjectValid(oD))
            fMaxSearch = GetDistanceBetween(OBJECT_SELF, oD);
        else
        {
            //apparently no enemies spotted, should be impossible at this point of the code
            fMaxSearch = 40.0;
        }
        iSpell = GetAreaSpell(FALSE, iMinLvl, fMaxSearch);
        if (iSpell == SPELL_INVALID)
            return OBJECT_INVALID;
        fRad = GetLastAreaSpellSize();
        vT = GetAreaTarget(fRad, fMinSearch, fMaxSearch);
        if (VectorMagnitude(vT) == 0.0)
            return OBJECT_INVALID;
        /*
        if (5 - GetAbilityModifier(ABILITY_INTELLIGENCE) > 0)
            lMark = Location(GetArea(OBJECT_SELF),
                    vU + vT + VectorNormalize(AngleToVector(IntToFloat(Random(360)))) * IntToFloat(Random(5 - GetAbilityModifier(ABILITY_INTELLIGENCE))),
                    GetFacing(OBJECT_SELF));
        else
            lMark = Location(GetArea(OBJECT_SELF), vU + vT, GetFacing(OBJECT_SELF));
        */
        lMark = Location(GetArea(OBJECT_SELF), vU + vT, VectorToAngle(vT));
        if (!GetLastAreaSpellDiscriminant())
        {
            fRatio = GetFriendFoeRatio();
            if (fRatio < GetFriendFoeTolerance())
            {
                iSpell = GetAreaSpell(TRUE, iMinLvl, fMaxSearch); //get discriminant area spell if possible
                if (iSpell == SPELL_INVALID)
                    return OBJECT_INVALID;
            }
        }
        //either friendfoe ratio is acceptable or we have a discriminant spell
        //if the spell is lightning or chain lightning target it at nearest creature
        if (iSpell == SPELL_LIGHTNING_BOLT || iSpell == SPELL_CHAIN_LIGHTNING)
        {
            // TODO: dont get a near creature again here, put into CombatAnalyseSituation
            oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRad, lMark);
            while (oTarget != OBJECT_INVALID)
            {
                if (GetObjectSeen(oTarget) && !GetIsDead(oTarget) && GetIsEnemy(oTarget))
                    break;
                oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRad, lMark);
            }
            if (GetIsObjectValid(oTarget)) //should always be valid
            {
                ActionCastSpellAtObject(iSpell, oTarget);
                return NPC_SELF;
            }
            return OBJECT_INVALID; // strange
        }
        //don't cast an area spell right next to myself
        //maybe later add something to see if I am immune to the spell
        //and cast anyway if so
        else if (GetLastAreaSpellDiscriminant() ||
                (GetLastAreaSpellRange() > 0.0 && VectorMagnitude(vT) > fRad))
                //TODO: need again => || IsCone(iSpell))
        {
            ActionCastSpellAtLocation(iSpell, lMark);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}


object f_SpellSummon()
{
    if (!GetLocalInt(NPC_SELF, "#SUMMONDEL") &&
        GetAssociate(ASSOCIATE_TYPE_SUMMONED) == OBJECT_INVALID)
    {
        vector vT;
        int iMinLvl = GetAverageEnemyLevel();
        int iSpell = GetSummonSpell(iMinLvl);
        if (iSpell == SPELL_INVALID)
            return OBJECT_INVALID;

        vT = AngleToVector(GetFacing(OBJECT_SELF) - 90.0 + IntToFloat(Random(180)));
        //testing addition to stop summoning creatures into AOEs
        if (GetAOECount())
        {
            vT = GetAOEVector();
            vT *= -1.0;
        }
        //end test code
        vT = 3.0 * VectorNormalize(vT);
        vT = GetPosition(OBJECT_SELF) + vT;
        ActionCastSpellAtLocation(iSpell, Location(GetArea(OBJECT_SELF), vT, GetFacing(OBJECT_SELF)));
        SetLocalInt(NPC_SELF, "#SUMMONDEL", 1);
        DelayCommand(4.0, DeleteLocalInt(NPC_SELF, "#SUMMONDEL"));
        // start combat for summon
        // TODO: why? perception should do, test it
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Summon");
        //DelayCommand(4.0, SpeakString("BC_FIGHTING", TALKVOLUME_SILENT_TALK));
        return NPC_SELF;
    }
    return OBJECT_INVALID;
}

object f_FeatEnhance()
{
    if (!Random(5))
    {
        object oT = GetTarget();
        if (GetIsObjectValid(oT) && GetHitDice(oT) > GetHitDice(OBJECT_SELF)-4)
        {
            talent tEnh;
            tEnh = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_POTION);
            if (GetIsTalentValid(tEnh))
            {
                ActionUseTalentOnObject(tEnh, OBJECT_SELF);
                return NPC_SELF;
            }
        }
    }

    int iFeat = GetEnhanceFeat();
    if (iFeat != FEATURE_INVALID)
    {
        ActionUseFeat(iFeat, OBJECT_SELF);
        return NPC_SELF;
    }

    return OBJECT_INVALID;
}

object f_AvoidMelee()
{
    //don't bother if we have time stop
    // TODO: is this check not done by CanAct before? if so, add it there?
    if (GetHasSpellEffect(SPELL_TIME_STOP))
        return OBJECT_INVALID;

    if (GetNearHostileCount())
    {
        vector vT;
        location lLoc;

        vT = GetHostileEvacVector(GetHostileVector());
        if (VectorMagnitude(vT) > 5.0)
        {
            SetLocalLocation(NPC_SELF, "#LASTHOTSPOT", GetLocation(OBJECT_SELF));
            SetLocalFloat(NPC_SELF, "#LASTAMANGLE", VectorToAngle(vT));
            vT = GetPosition(OBJECT_SELF) - vT;
            lLoc = Location(GetArea(OBJECT_SELF), vT, VectorToAngle(vT));
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Avoid melee");

            SetLocalLocation(OBJECT_SELF, "lDest", lLoc);
            SetLocalInt(OBJECT_SELF, "bRun", TRUE);
            MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOLOCATION), OBJECT_SELF);
            DeleteLocalLocation(OBJECT_SELF, "lDest");
            DeleteLocalInt(OBJECT_SELF, "bRun");

            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_TimeStop()
{
    if (GetHostileCount())
    {
        if (GetHasSpell(SPELL_TIME_STOP) && !GetHasSpellEffect(SPELL_TIME_STOP))
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Timestop");
            ActionCastSpellAtObject(SPELL_TIME_STOP, OBJECT_SELF);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_Vision()
{
    object oS;
    int iCnt = 1;
    int iSpell = SPELL_INVALID;

    if (!GetHasVisionSpells())
        return OBJECT_INVALID;

    oS = GetVisionDeprived(20.0);
    if (GetIsObjectValid(oS))
    {
        iSpell = GetVisionSpellNeeded(oS);
        if (iSpell != SPELL_INVALID)
        {
            object oNPCSELF = MeGetNPCSelf(oS);

            SetLocalObject(oNPCSELF, "#VISION", OBJECT_SELF);
            DelayCommand(6.0, DeleteLocalObject(oNPCSELF, "#VISION"));
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Vision");
            ActionCastSpellAtObject(iSpell, oS);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_BreathWeapon()
{
    int iSpell;

    if (!GetLocalInt(NPC_SELF, "#BDEL") &&
        (iSpell = GetBreathWeapon()) != SPELL_INVALID)
    {
        float fRad = RADIUS_SIZE_LARGE;
        float fMinSearch = 2.5;
        float fMaxSearch = fRad;
        vector vT;
        location lMark;

        vT = GetAreaTarget(fRad, fMinSearch, fMaxSearch);
        if (VectorMagnitude(vT) > 0.0)
        {
            lMark = Location(GetArea(OBJECT_SELF), GetPosition(OBJECT_SELF) + vT, GetFacing(OBJECT_SELF));
            SetLocalInt(NPC_SELF, "#BDEL", 1);
            DelayCommand(RoundsToSeconds(d4()), DeleteLocalInt(NPC_SELF, "#BDEL"));
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Breath");
            ActionCastSpellAtLocation(iSpell, lMark);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}


object f_Turning()
{
    if (!GetHasFeat(FEAT_TURN_UNDEAD))
        return OBJECT_INVALID;

    vector vT = GetTurningVector();

    if (VectorMagnitude(vT) > 0.0)
    {
        location lLoc;
        vT = GetPosition(OBJECT_SELF) + vT;
        lLoc = Location(GetArea(OBJECT_SELF), vT, VectorToAngle(vT));

        SetLocalLocation(OBJECT_SELF, "lDest", lLoc);
        SetLocalInt(OBJECT_SELF, "bRun", TRUE);
        MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOLOCATION), OBJECT_SELF);
        DeleteLocalLocation(OBJECT_SELF, "lDest");
        DeleteLocalInt(OBJECT_SELF, "bRun");

        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Turn undead");
        ActionUseFeat(FEAT_TURN_UNDEAD, OBJECT_SELF);
        return NPC_SELF;
    }
    return OBJECT_INVALID;
}

object f_HealSelf()
{
    int iDam;
    object oHealer;

    oHealer = GetLocalObject(NPC_SELF, "#HEALER");
    if (GetIsObjectValid(oHealer))
    {
        if (GetDistanceBetween(OBJECT_SELF, oHealer) < 10.0)
        {
            //got a healer who is close, don't double up, healing is on the way
            return OBJECT_INVALID;
        }
    }

    iDam = GetMaxHitPoints() - GetCurrentHitPoints();
    if (iDam < 1)
        return OBJECT_INVALID;

    int iFeat = FEATURE_INVALID;

    //see if wholeness of body is an option
    if (GetHasFeat(FEAT_WHOLENESS_OF_BODY))
    {
        if (iDam < GetLevelByClass(CLASS_TYPE_MONK) * 2)
            iFeat = FEATURE_INVALID;
        else
            iFeat = FEAT_WHOLENESS_OF_BODY;
    }
    if (iFeat != FEATURE_INVALID)
    {
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Heal self");
        ActionUseFeat(iFeat, OBJECT_SELF);
        SetLocalObject(NPC_SELF, "#HEALER", OBJECT_SELF);
        DelayCommand(4.0, DeleteLocalObject(NPC_SELF, "#HEALER"));
        return NPC_SELF;
    }

    if (GetRacialType(OBJECT_SELF ) != RACIAL_TYPE_UNDEAD) //undead do not use healing potions
    {
        int iP;
        talent tHeal, tP;
        object oP;
        int iHealTalent = 0;
        int iCount = 3; // check three times for a random potion that matches best

        while (iCount-- &&
            GetIsTalentValid(tP = GetCreatureTalentRandom(TALENT_CATEGORY_BENEFICIAL_HEALING_POTION)))
        {
            if (iP = GetTalentPotionHealAmount(tP))
            {
                if (iP > iHealTalent)
                {
                    tHeal = tP;
                    iHealTalent = iP;
                    if (iP <= iDam)
                        break;
                }
            }
        }

        // heal self if best potion found or damage is more than 40%
        if (iHealTalent > 0 &&
            (iHealTalent <= iDam) ||
             (IntToFloat(GetMaxHitPoints())/100.0*IntToFloat(iDam)) > 40.0)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Heal self");
            ActionUseTalentOnObject(tHeal, OBJECT_SELF);
            SetLocalObject(NPC_SELF, "#HEALER", OBJECT_SELF);
            DelayCommand(4.0, DeleteLocalObject(NPC_SELF, "#HEALER"));
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_SpellGroupEnhance()
{
    int iSpell, iMinLvl;
    float fRad = 0.0;
    vector vT, vU;
    location lLoc;

    //try feats first
    if ((iSpell = GetGroupEnhanceFeat()) != FEATURE_INVALID)
    {
        fRad = GetGroupEnhanceFeatRadius(iSpell);
        vT = GetFriendlyAreaTarget(fRad, iSpell, 1);
        if (VectorMagnitude(vT) > 0.0)
        {
            vU = GetPosition(OBJECT_SELF);
            lLoc = Location(GetArea(OBJECT_SELF), vU + vT, VectorToAngle(vT));

            SetLocalLocation(OBJECT_SELF, "lDest", lLoc);
            SetLocalInt(OBJECT_SELF, "bRun", TRUE);
            MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOLOCATION), OBJECT_SELF);
            DeleteLocalLocation(OBJECT_SELF, "lDest");
            DeleteLocalInt(OBJECT_SELF, "bRun");

            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Group feat enhance");

            ActionUseFeat(iSpell, OBJECT_SELF);
            return NPC_SELF;
        }
    }

    //then spells
    iMinLvl = GetAverageEnemyLevel() / 3;

    if ((iSpell = GetGroupEnhanceSpell(iMinLvl)) != SPELL_INVALID)
    {
        fRad = GetGroupEnhanceSpellRadius(iSpell);
        vT = GetFriendlyAreaTarget(fRad, iSpell);
        if (VectorMagnitude(vT) > 0.0)
        {
            vU = GetPosition(OBJECT_SELF);
            lLoc = Location(GetArea(OBJECT_SELF), vU + vT, VectorToAngle(vT));
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Group spell enhance");
            ActionCastSpellAtLocation(iSpell, lLoc);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_DispelAOE()
{
    if (GetHostileAOECount())
    {

        int iSpell;
        if ((iSpell = GetDispelSpell()) == SPELL_INVALID)
        {
            // if we have SPELL_GUST_OF_WIND, try to dispel clouds
            if (GetHasSpell(SPELL_GUST_OF_WIND))
            {
                int iC = 1;
                object oAOE;

                oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, OBJECT_SELF, iC++);
                while (oAOE != OBJECT_INVALID && GetAreaOfEffectCreator(oAOE) == OBJECT_SELF &&
                       GetDistanceBetween(oAOE, OBJECT_SELF) < 20.0 && !GetIsCloudAOE(oAOE))
                    oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, OBJECT_SELF, iC++);

                if (GetIsObjectValid(oAOE))
                {
                    if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Dispel Cloud AOE");
                    ActionCastSpellAtLocation(iSpell, GetLocation(oAOE));
                    return NPC_SELF;
                }
            }

            return OBJECT_INVALID;
        }

        vector vT, vU;
        location lT;

        vU = GetPosition(OBJECT_SELF);
        vT = GetHostileAOEVector();
        lT = Location(GetArea(OBJECT_SELF), vU + vT, VectorToAngle(vT));
        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Dispel AOE");
        ActionCastSpellAtLocation(iSpell, lT);
        return NPC_SELF;
    }
    return OBJECT_INVALID;
}

object f_DispelSingle()
{
    object oTarget;

    if (GetIsObjectValid(oTarget = GetMostBuffedEnemy()))
    {
        int iAverage = 0;
        int iSpell;
        int iCL = GetMaxDispelCasterLevel();

        iAverage = GetAverageEffectCasterLevel(oTarget);
        if ((iSpell = GetBestDispel(iAverage, iCL)) != SPELL_INVALID)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Dispel Single");
            ActionCastSpellAtObject(iSpell, oTarget);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}


object f_Dismissal()
{
    int iSpell = SPELL_DISMISSAL;
    float fRad = RADIUS_SIZE_COLOSSAL; // TODO use spells radius
    object oT;
    vector vT;
    location lT;

    //dismissal is optimal choice for enemy summons
    if (GetHasSpell(iSpell, OBJECT_SELF))
    {
        vT = GetEnemySummonedAssociatesVector(fRad); // TODO long bad function
        if (VectorMagnitude(vT) > 0.0)
        {
            lT = Location(GetArea(OBJECT_SELF), GetPosition(OBJECT_SELF) + vT, VectorToAngle(vT));
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Dismissal");
            ActionCastSpellAtLocation(iSpell, lT);
            return NPC_SELF;
        }
    }
    //next check is to look for Outsiders and Elementals and clear them out with Word of Faith
    //this will pick up against summoned and non-summoned planars
    iSpell = SPELL_WORD_OF_FAITH;
    if (GetHasSpell(iSpell, OBJECT_SELF))
    {
        vT = GetEnemyPlanarVector(fRad);
        if (VectorMagnitude(vT) > 0.0)
        {
            lT = Location(GetArea(OBJECT_SELF), GetPosition(OBJECT_SELF) + vT, VectorToAngle(vT));
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Word of faith");
            ActionCastSpellAtLocation(iSpell, lT);
            return NPC_SELF;
        }
    }
    //no dismissal, look for a summoned associate owner to use dispel magic on if we have it
    if ((iSpell = GetDispelSpell()) != SPELL_INVALID)
    {
        //we have a dispel
        if (GetIsObjectValid(oT = GetStrongestEnemyAssocOwner()))
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Dismissal,dispel");
            ActionCastSpellAtObject(iSpell, oT);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}

object f_SpellGroupHeal()
{
    int iSpell, iMinLvl;

    iMinLvl = GetAverageEnemyLevel() / 3;

    if ((iSpell = GetGroupHealSpell(iMinLvl)) != SPELL_INVALID)
    {
        int iHeal;
        float fRad = 0.0;
        vector vT, vU;
        location lLoc;
        float fDam;

        iHeal = GetGroupHealSpellAmount(iSpell);
        fRad = GetGroupHealSpellRadius(iSpell);
        vU = GetPosition(OBJECT_SELF);
        vT = GetAreaHealTarget(fRad, iHeal);
        lLoc = Location(GetArea(OBJECT_SELF), vU + vT, VectorToAngle(vT));
        fDam = GetAverageFriendDamage();
        if (VectorMagnitude(vT) > 0.0 && IntToFloat(iHeal) < fDam)
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Spell group heal");
            ActionCastSpellAtLocation(iSpell, lLoc);
            return NPC_SELF;
        }
    }
    return OBJECT_INVALID;
}


object f_Flank(object oF=OBJECT_INVALID)
{
    if (!GetIsObjectValid(oF))
    {
        if ((oF = GetAttackTarget()) == OBJECT_INVALID)
            oF = GetTarget();
    }

    if (!GetIsObjectValid(oF) || GetDistanceBetween(oF, OBJECT_SELF) < 10.0)
        return OBJECT_INVALID;

    if (GetIsObjectValid(oF))
    {
        location lLoc = GetFlankLoc(oF, GetLocation(OBJECT_SELF));

        if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Flank");

        SetLocalLocation(OBJECT_SELF, "lDest", lLoc);
        SetLocalInt(OBJECT_SELF, "bRun", TRUE);
        MeCallFunction(GetLocalString(NPC_SELF, COMBAT_MOVETOLOCATION), OBJECT_SELF);
        DeleteLocalLocation(OBJECT_SELF, "lDest");
        DeleteLocalInt(OBJECT_SELF, "bRun");
    }
    return oF;
}


object f_MeleeAssist(object oT=OBJECT_INVALID)
{
    if (!GetIsObjectValid(oT))
        oT = GetMostDamagedFriendNoHealer(); // TODO

    if (GetIsObjectValid(oT))
    {
        oT = GetTarget(oT);
        if (GetIsObjectValid(oT))
        {
            if (GetLocalInt(OBJECT_SELF, "DEBUG") > 0) ActionSpeakString("Melee assist");
            MeCallFunction(GetLocalString(NPC_SELF, COMBAT_ATTACKMELEE), oT);
        }
    }
    return oT;
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
    //_Start("Library name='"+MEME_LIBRARY+"'");

    //  Step 1: Library Setup
    //
    //  This is run once to bind your scripts to a unique number.
    //  The number is composed of a top half - for the "class" and lower half
    //  for the specific "method". If you are adding your own scripts, copy
    //  the example, make sure to change the first number. Then edit the
    //  switch statement following this if statement.

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryFunction(COMBAT_FASTBUFFS,          1);
        MeLibraryFunction(COMBAT_SPELLHEAL,          2);
        MeLibraryFunction(COMBAT_SPELLDIRECT,        3);
        MeLibraryFunction(COMBAT_TOUCH,              4);
        MeLibraryFunction(COMBAT_ATTACKRANGED,       5);
        MeLibraryFunction(COMBAT_ATTACKMELEE,        6);
        MeLibraryFunction(COMBAT_MOVETOLOCATION,     7);
        MeLibraryFunction(COMBAT_TELEPORT,           8);
        MeLibraryFunction(COMBAT_FIGHTBROADCAST,     9);
        MeLibraryFunction(COMBAT_COUNTERSPELL,      10);
        MeLibraryFunction(COMBAT_EVACAOE,           11);
        MeLibraryFunction(COMBAT_MOVETOOBJECT,      12);
        MeLibraryFunction(COMBAT_REGROUP,           13);
        MeLibraryFunction(COMBAT_DEFENDSELF,        14);
        MeLibraryFunction(COMBAT_DEFENDSINGLE,      15);
        MeLibraryFunction(COMBAT_ENHANCESELF,       16);
        MeLibraryFunction(COMBAT_ENHANCESINGLE,     17);
        MeLibraryFunction(COMBAT_SPELLHELP,         18);
        MeLibraryFunction(COMBAT_SPELLRAISE,        19);
        MeLibraryFunction(COMBAT_SPELLBREACH,       20);
        MeLibraryFunction(COMBAT_SPELLAREA,         21);
        MeLibraryFunction(COMBAT_SPELLSUMMON,       22);
        MeLibraryFunction(COMBAT_FEATENHANCE,       23);
        MeLibraryFunction(COMBAT_AVOIDMELEE,        24);
        MeLibraryFunction(COMBAT_TIMESTOP,          25);
        MeLibraryFunction(COMBAT_VISION,            26);
        MeLibraryFunction(COMBAT_BREATHWEAPON,      27);
        MeLibraryFunction(COMBAT_TURNING,           28);
        MeLibraryFunction(COMBAT_HEALSELF,          29);
        MeLibraryFunction(COMBAT_SPELLGRPENHANCE,   30);
        MeLibraryFunction(COMBAT_DISPELAOE,         31);
        MeLibraryFunction(COMBAT_DISPELSINGLE,      32);
        MeLibraryFunction(COMBAT_DISMISSAL,         33);
        MeLibraryFunction(COMBAT_SPELLGROUPHEAL,    34);
        MeLibraryFunction(COMBAT_BECOMEDEFENSIVE,   35);
        MeLibraryFunction(COMBAT_FLANK,             36);
        MeLibraryFunction(COMBAT_MELEEASSIST,       37);
        //_End("Library");
        return;
    }

    //  Step 2: Library Dispatcher
    //
    //  These switch statements are what decide to run your scripts, based
    //  on the numbers you provided in Step 1. Notice that you only need
    //  an inner switch statement if you exported more than one method
    //  (like go and end). Also notice that the value used by the case statement
    //  is the two numbers added up.

    switch (MEME_ENTRYPOINT)
    {
        case 1:  MeSetResult(f_FastBuffs());                    break;
        case 2:  MeSetResult(f_SpellHeal(MEME_ARGUMENT));       break;
        case 3:  MeSetResult(f_SpellDirect(MEME_ARGUMENT));     break;
        case 4:  MeSetResult(f_Touch(MEME_ARGUMENT));           break;
        case 5:  MeSetResult(f_AttackRanged(MEME_ARGUMENT));    break;
        case 6:  MeSetResult(f_AttackMelee(MEME_ARGUMENT));     break;
        case 7:  MeSetResult(f_MoveToLocation(MEME_ARGUMENT));  break;
        case 8:  MeSetResult(f_Teleport(MEME_ARGUMENT));        break;
        case 9:  MeSetResult(f_FightBroadcast());               break;
        case 10: MeSetResult(f_CounterSpell(MEME_ARGUMENT));    break;
        case 11: MeSetResult(f_EvacAOE());                      break;
        case 12: MeSetResult(f_MoveToObject(MEME_ARGUMENT));    break;
        case 13: MeSetResult(f_Regroup(MEME_ARGUMENT));         break;
        case 14: MeSetResult(f_DefendSelf());                   break;
        case 15: MeSetResult(f_DefendSingle());                 break;
        case 16: MeSetResult(f_EnhanceSelf());                  break;
        case 17: MeSetResult(f_EnhanceSingle());                break;
        case 18: MeSetResult(f_SpellHelp(MEME_ARGUMENT));       break;
        case 19: MeSetResult(f_SpellRaise(MEME_ARGUMENT));      break;
        case 20: MeSetResult(f_SpellBreach(MEME_ARGUMENT));     break;
        case 21: MeSetResult(f_SpellArea());                    break;
        case 22: MeSetResult(f_SpellSummon());                  break;
        case 23: MeSetResult(f_FeatEnhance());                  break;
        case 24: MeSetResult(f_AvoidMelee());                   break;
        case 25: MeSetResult(f_TimeStop());                     break;
        case 26: MeSetResult(f_Vision());                       break;
        case 27: MeSetResult(f_BreathWeapon());                 break;
        case 28: MeSetResult(f_Turning());                      break;
        case 29: MeSetResult(f_HealSelf());                     break;
        case 30: MeSetResult(f_SpellGroupEnhance());            break;
        case 31: MeSetResult(f_DispelAOE());                    break;
        case 32: MeSetResult(f_DispelSingle());                 break;
        case 33: MeSetResult(f_Dismissal());                    break;
        case 34: MeSetResult(f_SpellGroupHeal());               break;
        case 35: MeSetResult(f_BecomeDefensive(MEME_ARGUMENT)); break;
        case 36: MeSetResult(f_Flank(MEME_ARGUMENT));           break;
        case 37: MeSetResult(f_MeleeAssist(MEME_ARGUMENT));     break;
    }
    //_End("Library");
}

