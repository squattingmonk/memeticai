/*------------------------------------------------------------------------------
 * lib_door
 * 
 * Modified by Senach -- May 3, 2004
 * Original by Garad Moonbeam
 ------------------------------------------------------------------------------*/

#include "h_library"

object f_fail_door(object oDoor)
{
    //SpeakString("Fail Door.");
    _PrintString("Function: Fail door.", DEBUG_COREAI);

    object oParent = MeGetParentMeme(MEME_SELF);
    _PrintString("Parent Meme: " + _GetName(oParent), DEBUG_COREAI);

    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    MeClearMemeFlag(oParent, MEME_REPEAT);

    ActionWait(6.0);
    return OBJECT_SELF;
}

object f_knock_door(object oDoor)
{
    _PrintString("Function: Knock Door.", DEBUG_COREAI);
    if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_KNOCK))
    {
        _PrintString("Casting Knock on door: " + _GetName(oDoor), DEBUG_COREAI);
        SpeakString("Knock Door");
        ActionWait(2.0);
    }
    return OBJECT_INVALID;
}

object f_unlock_door(object oDoor)
{
    _PrintString("Function: Unlock Door.", DEBUG_COREAI);

    if(GetLocked(oDoor))
    {
        _PrintString("Locked Door: " + _GetName(oDoor), DEBUG_COREAI);

        //check if you have the key to this door
        //string sKeyTag = GetLockKeyTag(oDoor);
        object oKey = GetItemPossessedBy(OBJECT_SELF, GetLockKeyTag(oDoor));
        string sResponse;

        if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_UNLOCK) || GetIsObjectValid(oKey))
        {
            _PrintString("DOOR_ACTION_UNLOCK is possible.", DEBUG_COREAI);

            // Get response from Door/Locked
            sResponse = MeRespond("Door/Locked", oDoor, TRUE);
        }

        if (sResponse == "")
        {
            //SpeakString("Unable to unlock this door.");
            _PrintString("DOOR_ACTION_UNLOCK not possible. Switching to Door/Bash table.", DEBUG_COREAI);

            sResponse = MeRespond("Door/Bash", oDoor, TRUE);

            if (sResponse == "")
            {
                _PrintString("Cannot grok how to bash this door. I guess I failed.");
                SpeakString("No responses for 'Door/Bash', trying 'Door/Fail'.");
                sResponse = MeRespond("Door/Fail", oDoor, TRUE);
            }

            if (sResponse == "")
            {
                _PrintString("No response was selected, waiting...");
                SpeakString("No responses for either 'Door/Bash' or 'Door/Fail', aborting the 'Door/Blocked' response.");
                MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
                ActionWait(6.0); // one round
            }
        }

        if (sResponse == "")
        {
            _PrintString("No response found, aborting.", DEBUG_COREAI);
        }
        else
        {
            _PrintString("Response found.", DEBUG_COREAI);
            return OBJECT_SELF;
        }
    }
    else
    {
        //SpeakString("Door is not locked.");
        _PrintString("Door is not locked.", DEBUG_COREAI);
    }

    return OBJECT_INVALID;
}

object f_unlock_skillcheck(object oLocked)
{
    _PrintString("Function: Unlock Skillcheck.", DEBUG_COREAI);

    if(GetLocked(oLocked))
    {
        _PrintString("Locked: " + _GetName(oLocked), DEBUG_COREAI);
        //SpeakString("Attempting to unlock.");

        object oSolution = MeCreateMeme("i_unlockdoor", PRIO_DEFAULT, 50, MEME_RESUME, MEME_SELF);
        SetLocalObject(oSolution, "Door", oLocked);

        _PrintString("Created solution meme: i_unlockdoor", DEBUG_COREAI);

        string sKeyTag = GetLockKeyTag(oLocked);
        object oKey = GetItemPossessedBy(OBJECT_SELF, sKeyTag);
        if(GetIsObjectValid(oKey))
        {
            _PrintString("Setting bHadKey=TRUE for i_unlockdoor", DEBUG_COREAI);
            SetLocalInt(oSolution, "bHasKey", TRUE);
        }

        return oLocked;
    }

    return OBJECT_INVALID;
}

object f_equip_weapon(object oDoor)
{
    _PrintString("Function: Equip Weapon.", DEBUG_COREAI);
    return OBJECT_INVALID;
}

object f_bash_door(object oDoor)
{
    _PrintString("Function: Bash Door.", DEBUG_COREAI);

    if (oDoor == OBJECT_INVALID)
    {
        //SpeakString("Door has been destroyed.");
        _PrintString("Door is invalid.", DEBUG_COREAI);

        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

        return OBJECT_SELF;
    }

    if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_BASH))
    {
        _PrintString("Bashing door: " + _GetName(oDoor));
        //SpeakString("Bashing door.");

        ActionAttack(oDoor);
        ActionWait(2.0);

        return OBJECT_SELF;
    }

    return OBJECT_INVALID;
}

object f_disarm_door(object oDoor)
{
    _PrintString("Function: Disarm Door.", DEBUG_COREAI);

    if (GetIsTrapped(oDoor) == TRUE)
    {
        // Check for traps.
        SetLocalObject(NPC_SELF, "Trap", oDoor);
        object oResult = MeCallFunction("f_skillcheck_detect_trap", OBJECT_SELF);
        int bSuccess = GetLocalInt(oResult, "SC_RESULT");

        // If traps, then try to disarm.
        if (bSuccess == TRUE)
        {
            object oSolution = MeCreateMeme("i_disabledoor", PRIO_DEFAULT, 50, MEME_RESUME, MEME_SELF);

            SetLocalObject(oSolution, "Door", oDoor);
            _PrintString("Created solution meme: i_disabledoor", DEBUG_COREAI);
            return oSolution;
        }
        else
        {
            _PrintString("Failed to detect traps.", DEBUG_COREAI);
            //SpeakString("Failed to detect traps.");
        }
    }

    return OBJECT_INVALID;
}

object f_open_door(object oDoor)
{
    _PrintString("Function: Open Door.", DEBUG_COREAI);

    if (GetIsObjectValid(oDoor))
    {
        if (GetIsOpen(oDoor) == FALSE)
        {
            object oSolution = MeCreateMeme("i_opendoor", PRIO_DEFAULT, 50, MEME_RESUME, MEME_SELF);

            SetLocalObject(oSolution, "Door", oDoor);
            _PrintString("Created solution meme: i_opendoor", DEBUG_COREAI);
            return oSolution;
        }

        //SpeakString("Door is open.");
        _PrintString("Door is open, aborting response.", DEBUG_COREAI);
    }
    else
    {
        //SpeakString("Door is destroyed.");
        _PrintString("Door is invalid, aborting response.", DEBUG_COREAI);
    }

    //_PrintString("MEME_SELF: " + _GetName(MEME_SELF), DEBUG_COREAI);
    //MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

    return OBJECT_INVALID;
}

void c_door_ini()
{
    _Start("Instantiate class='"+MEME_CALLED+"'", DEBUG_TOOLKIT);

    MeAddResponse(MEME_SELF, "Generic Door Table", "f_disarm_door", 100, RESPONSE_START);
    MeAddResponse(MEME_SELF, "Generic Door Table", "f_unlock_door", 100, RESPONSE_START);
    MeAddResponse(MEME_SELF, "Generic Door Table", "f_open_door",   100, RESPONSE_START);
    MeAddResponse(MEME_SELF, "Generic Door Table", "f_end_response", 100, RESPONSE_START);

    MeAddResponse(MEME_SELF, "Generic Door Locked Table", "f_unlock_skillcheck", 100, RESPONSE_START);
    MeAddResponse(MEME_SELF, "Generic Door Locked Table", "f_knock_door",  100, RESPONSE_START);
    MeAddResponse(MEME_SELF, "Generic Door Locked Table", "f_open_door",   100, RESPONSE_START);

    MeAddResponse(MEME_SELF, "Generic Door Bash Table", "f_bash_door",   100, RESPONSE_END);

    MeAddResponse(MEME_SELF, "Generic Door Fail Table", "f_end_response",   100, RESPONSE_START);

    MeSetActiveResponseTable("Door/Blocked", "Generic Door Table");
    MeSetActiveResponseTable("Door/Locked", "Generic Door Locked Table");
    MeSetActiveResponseTable("Door/Bash", "Generic Door Bash Table");
    MeSetActiveResponseTable("Door/Fail", "Generic Door Fail Table");

    _End();
}

void c_door_go()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_TOOLKIT);

     object oDoor = MeCreateGenerator("g_door", PRIO_HIGH, 100);
     MeStartGenerator(oDoor);

     _End();
}

/*-----------------------------------------------------------------------------
 * Generator:  g_door
 *    Author:  Joel Martin (a.k.a. Garad Moonbeam)
 *      Date:  April, 2003
 *   Purpose:  This generator will try to solve the problem of being blocked by
 *             a door.  Possible solutions are:
 *                  OpenDoor
 *
 -----------------------------------------------------------------------------
 *    Timing:  Intialize, OnBlocked
 -----------------------------------------------------------------------------*/
void g_door_ini()
{
    _Start("Generator name='g_door' timing='Initialize'", DEBUG_TOOLKIT);

    if(!GetLocalInt(MEME_SELF, "PreferOpen"))
        SetLocalInt(MEME_SELF, "PreferOpen", -GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE));
    if(!GetLocalInt(MEME_SELF, "PreferUnlock"))
        SetLocalInt(MEME_SELF, "PreferUnlock", GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE));
    if(!GetLocalInt(MEME_SELF, "PreferDisable"))
        SetLocalInt(MEME_SELF, "PreferDisable", GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE)+GetSkillRank(SKILL_DISABLE_TRAP, OBJECT_SELF));
    if(!GetLocalInt(MEME_SELF, "PreferKnock"))
        SetLocalInt(MEME_SELF, "PreferKnock", GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE));
    if(!GetLocalInt(MEME_SELF, "PreferBash"))
        SetLocalInt(MEME_SELF, "PreferBash", -GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE));

    if(!GetLocalInt(MEME_SELF, "DO_PLOT"))
        SetLocalInt(MEME_SELF, "DO_PLOT", FALSE);

    if(!GetLocalInt(MEME_SELF, "bAutoDetect"))
        SetLocalInt(MEME_SELF, "bAutoDetect", FALSE);

    if(!GetLocalInt(MEME_SELF, "bAutoDisable"))
        SetLocalInt(MEME_SELF, "bAutoDisable", FALSE);

    if(!GetLocalInt(MEME_SELF, "Disable_Confidence"))
        SetLocalInt(MEME_SELF, "Disable_Confidence", 10);

    _End("Generator", DEBUG_COREAI);
}

void g_door_blk()
{
    object oBlocking = GetBlockingDoor();
    if (GetObjectType(oBlocking) != OBJECT_TYPE_DOOR)
    {
        return;
    }

    _Start("Generator name='g_door' timing='Blocked'", DEBUG_COREAI);

    _PrintString("Blocked by " + GetTag(oBlocking), DEBUG_COREAI);

    if(GetPlotFlag(oBlocking) && !GetLocalInt(MEME_SELF, "DO_PLOT"))
    {
        _PrintString("Not allowed to deal with plot doors", DEBUG_COREAI);
        _End();
        return;
    }

    // Signal a private message, "DOOR/BLOCKED", to activate the appropriate
    // response table, passing the blocking door as a message argument.
    // Message is received by the e_generic event and the parameters passed
    // to a i_response solution meme.

    struct message stMsg;
    stMsg.sMessageName = "Door/Blocked";
    stMsg.oData = oBlocking;
    stMsg.iData = TRUE; // Resume

    MeSendMessage(stMsg);

    _PrintString("Sent DOOR/BLOCKED message.", DEBUG_COREAI);
    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_equipappropriate (EquipAppropriateWeapons)
 *  Author:  Joel Marting (a.k.a. Garad Moonbeam) - Taken from Jasperre's AI
 *    Date:  April, 2003
 * Purpose:  This meme allows the NPC to equip weapons appropriate for the target.
 -----------------------------------------------------------------------------
 * Object "Target": The target
  -----------------------------------------------------------------------------*/
void i_equipappropriate_ini()
{
    _Start("Meme name='EquipAppropriateWeapons' event='Initialize'", DEBUG_COREAI);

    if(GetLocalFloat(MEME_SELF, "MIN_RANGED_DISTANCE")!=0.0f)
        SetLocalFloat(MEME_SELF, "MIN_RANGED_DISTANCE", 3.0);

    _End("Meme", DEBUG_COREAI);
}

void i_equipappropriate_go()
{
    _Start("Meme name='EquipAppropriateWeapons' event='Go'", DEBUG_COREAI);

    object oTarget = GetLocalObject(MEME_SELF, "Target");
    object oRanged = GetLocalObject(OBJECT_SELF, "DW_RANGED");
    float fMinRanged = GetLocalFloat(MEME_SELF, "MIN_RANGED_DISTANCE");
    int iRanged = GetIsObjectValid(oRanged);
    if(iRanged && GetItemPossessor(oRanged) != OBJECT_SELF)
    {
        _PrintString("No ranged weapon.", DEBUG_COREAI);

        DeleteLocalObject(OBJECT_SELF, "DW_RANGED");
        iRanged = FALSE;
    }
    object oRight = (GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));
    if(GetDistanceToObject(oTarget) > fMinRanged && iRanged && (oRight != oRanged))
    {
        _PrintString("Equipping ranged weapon.", DEBUG_COREAI);

        ActionEquipItem(oRanged, INVENTORY_SLOT_RIGHTHAND);
    }
    else if(GetDistanceToObject(oTarget) <= fMinRanged || !iRanged)
    {
        object oPrimary = GetLocalObject(OBJECT_SELF, "DW_PRIMARY");
        int iPrimary = GetIsObjectValid(oPrimary);
        if(iPrimary && GetItemPossessor(oPrimary) != OBJECT_SELF)
        {
            _PrintString("No primary hand weapon.", DEBUG_COREAI);

            DeleteLocalObject(OBJECT_SELF, "DW_PRIMARY");
            iPrimary = FALSE;
        }
        object oSecondary = GetLocalObject(OBJECT_SELF, "DW_SECONDARY");
        int iSecondary = GetIsObjectValid(oSecondary);
        if(iPrimary && GetItemPossessor(oSecondary) != OBJECT_SELF)
        {
            _PrintString("No secondary hand weapon.", DEBUG_COREAI);

            DeleteLocalObject(OBJECT_SELF, "DW_SECONDARY");
            iSecondary = FALSE;
        }
        object oShield = GetLocalObject(OBJECT_SELF, "DW_SHIELD");
        int iShield = GetIsObjectValid(oShield);
        if(iPrimary && GetItemPossessor(oShield) != OBJECT_SELF)
        {
            _PrintString("No shield.", DEBUG_COREAI);

            DeleteLocalObject(OBJECT_SELF, "DW_SHIELD");
            iShield = FALSE;
        }
        object oTwoHanded = GetLocalObject(OBJECT_SELF, "DW_TWO_HANDED");
        int iTwoHanded = GetIsObjectValid(oTwoHanded);
        if(iTwoHanded && GetItemPossessor(oTwoHanded) != OBJECT_SELF)
        {
            _PrintString("No two-hand weapon.", DEBUG_COREAI);

            DeleteLocalObject(OBJECT_SELF, "DW_TWO_HANDED");
            iTwoHanded = FALSE;
        }
        object oLeft = (GetItemInSlot(INVENTORY_SLOT_LEFTHAND));
        // Complete change - it will check the slots, if not eqip, then do so.
        if(iPrimary && (oRight != oPrimary))
        {
            _PrintString("Equipping primary weapon: " + GetName(oPrimary), DEBUG_COREAI);

            ActionEquipItem(oPrimary, INVENTORY_SLOT_RIGHTHAND);
        }
        if(iSecondary && (oLeft != oSecondary))
        {
            _PrintString("Equipping secondary weapon: " + GetName(oSecondary), DEBUG_COREAI);

            ActionEquipItem(oSecondary, INVENTORY_SLOT_LEFTHAND);
        }
        else if(!iSecondary && iShield && (oLeft != oShield))
        {
            _PrintString("Equipping shield: " + GetName(oShield), DEBUG_COREAI);

            ActionEquipItem(oShield, INVENTORY_SLOT_LEFTHAND);
        }
        if(!iPrimary && iTwoHanded && (oRight != oTwoHanded))
        {
            _PrintString("Equipping two-handed weapon: " + GetName(oTwoHanded), DEBUG_COREAI);

            ActionEquipItem(oTwoHanded, INVENTORY_SLOT_RIGHTHAND);
        }
        // If all else fails...TRY most damaging melee weapon.
        if(!iPrimary && !iTwoHanded)
        {
            _PrintString("Couldn't find weapon. Using ActionEquipMostDamagingMelee instead.", DEBUG_COREAI);

            ActionEquipMostDamagingMelee(oTarget, TRUE);
        }
    }

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_knockdoor (WizardKnock)
 *  Author:  Joel Marting (a.k.a. Garad Moonbeam)
 *    Date:  April, 2003
 * Purpose:  This meme allows the NPC to cast knock on a locked door.
 -----------------------------------------------------------------------------
 * Object "Door": The door that's in the way
  -----------------------------------------------------------------------------*/
void i_knockdoor_go()
{
    _Start("Meme name='WizardKnock' event='Go'", DEBUG_COREAI);

    object oBlocking = GetLocalObject(MEME_SELF, "Door");

    if(GetIsDoorActionPossible(oBlocking, DOOR_ACTION_KNOCK))
    {
        ActionCastSpellAtObject(SPELL_KNOCK, oBlocking);
    }

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_disabledoor
 *  Author:  Joel Marting (a.k.a. Garad Moonbeam)
 *    Date:  April, 2003
 * Purpose:  This meme allows the NPC to disable a trap.
 -----------------------------------------------------------------------------
 * Object "Door": The trapped door to disable
  -----------------------------------------------------------------------------*/
 void i_disabledoor_go()
 {
    _Start("Meme name='DisableTrap' event='Go'", DEBUG_COREAI);

    object oGenerator = MeGetParentGenerator(MEME_SELF);
    int bAutoDisable = GetLocalInt(oGenerator, "bAutoDisable");
    object oTrap = GetLocalObject(MEME_SELF, "Door");
    SetLocalObject(NPC_SELF, "Trap", oTrap);

    object oResult = MeCallFunction("f_skillcheck_disable_trap", OBJECT_SELF);

    int bSuccess = GetLocalInt(oResult, "SC_RESULT");
    int iDiff = GetLocalInt(oResult, "SC_DIFF");

    DeleteLocalInt(oResult, "SC_RESULT");
    DeleteLocalInt(oResult, "SC_DIFF");
    DeleteLocalObject(NPC_SELF, "Trap");

    int iCount;
    string sText;
    if(bSuccess || bAutoDisable)
    {
        _PrintString("Succeeded at Disable Trap check", DEBUG_COREAI);

        ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 6.0); // One round
        SetTrapDisabled(oTrap);

        MeSetMemeResult(FALSE); // Trap has been disarmed, so fall through to other functions.
        //SpeakString("I disarmed the trap. Continuing.");
    }
    else
    {
        _PrintString("Failed DisableTrap skill check", DEBUG_COREAI);
        //SpeakString("I failed to disarm the trap.");

        // if the check failed by 5 point or more, trigger the trap
        if(iDiff >= 5)
        {
            _PrintString("Failure difference exceeded 5 points, triggering trap.", DEBUG_COREAI);
            ActionOpenDoor(oTrap);
            MeSetMemeResult(FALSE);
            _End();
            return;
        }

        // Traps still exist, and no other functions should be eval'd, as the door is unsafe.
        string sResponse;
        sResponse = MeRespond("Door/Fail", oTrap, TRUE);

        if (sResponse == "")
        {
            _PrintString("No response was selected, waiting...");
            //SpeakString("No responses for 'Door/Fail', aborting.");
            MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        }
    }

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_unlockdoor (UnlockDoor)
 *  Author:  Joel Marting (a.k.a. Garad Moonbeam)
 *    Date:  April, 2003
 * Purpose:  This meme allows the NPC to unlock a locked door that is blocking it.
 -----------------------------------------------------------------------------
 * Object   "Door": The door that is blocking you.
 * Int      "bHasKey": TRUE if creature has the key to this door, FALSE otherwise
 -----------------------------------------------------------------------------*/
 void i_unlockdoor_go()
 {
    _Start("Meme name='UnlockDoor' event = 'Go'", DEBUG_COREAI);

    object oBlocking = GetLocalObject(MEME_SELF, "Door");
    int bHasKey = GetLocalInt(MEME_SELF, "bHasKey");

    if(bHasKey)
    {
        _PrintString("I've got the key, I'll use that.", DEBUG_COREAI);
        ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 2.0);
        SetLocked(oBlocking, FALSE);
        MeSetMemeResult(TRUE);
    }
    else
    {
        _PrintString("I'm going to have to pick it", DEBUG_COREAI);

        SetLocalObject(NPC_SELF, "Door", oBlocking);
        object oResult = MeCallFunction("f_skillcheck_open_lock", OBJECT_SELF);
        int bSuccess = GetLocalInt(oResult, "SC_RESULT");

        DeleteLocalInt(oResult, "SC_RESULT");
        DeleteLocalObject(NPC_SELF, "Door");

        int iCount;
        string sText;

        if(bSuccess)
        {
            _PrintString("Succeeded at OpenLock", DEBUG_COREAI);
            DoDoorAction(oBlocking, DOOR_ACTION_UNLOCK);
        }
        else
        {
            _PrintString("I failed at my pick attempt.", DEBUG_COREAI);
            PlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 6.0);  // Full round
            MeSetMemeResult(FALSE);
        }
    }

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_lockdoor (LockDoor)
 * Purpose:  This meme allows the NPC to unlock a locked door that is blocking it.
 -----------------------------------------------------------------------------
 * Object   "Door": The door you want to lock.
 * Int      "bHasKey": TRUE if creature has the key to this door, FALSE otherwise
 -----------------------------------------------------------------------------*/
 void i_lockdoor_go()
 {
    _Start("Meme name='LockDoor' event = 'Go'", DEBUG_COREAI);

    object oDoor = GetLocalObject(MEME_SELF, "Door");
    int bHasKey = GetLocalInt(MEME_SELF, "bHasKey");

    if(bHasKey)
    {
        _PrintString("I've got the key, I'll use that.", DEBUG_COREAI);
        ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 2.0);
        SetLocked(oDoor, TRUE);
        MeSetMemeResult(TRUE);
    }
    else
    {
        _PrintString("I'm going to have to pick it", DEBUG_COREAI);

        SetLocalObject(NPC_SELF, "Door", oDoor);
        object oResult = MeCallFunction("f_skillcheck_open_lock", OBJECT_SELF);
        int bSuccess = GetLocalInt(oResult, "SC_RESULT");

        DeleteLocalInt(oResult, "SC_RESULT");
        DeleteLocalObject(NPC_SELF, "Door");

        int iCount;
        string sText;

        if(bSuccess)
        {
            _PrintString("I succeeded to lock door.", DEBUG_COREAI);
            ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 6.0);
            SetLocked(oDoor, TRUE);
            MeSetMemeResult(TRUE);
        }
        else
        {
            _PrintString("I failed to lock the door.", DEBUG_COREAI);
            PlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 6.0);  // Full round
            MeSetMemeResult(FALSE);
        }
    }

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_opendoor (OpenDoor)
 *  Author:  Joel Marting (a.k.a. Garad Moonbeam)
 *    Date:  April, 2003
 * Purpose:  This meme allows the NPC to open a door that is blocking it.
 -----------------------------------------------------------------------------
 * Object "Door": The door that is blocking you.
 -----------------------------------------------------------------------------*/
 void i_opendoor_go()
 {
    _Start("Meme name='OpenDoor' event = 'Go'", DEBUG_COREAI);

    object oDoor = GetLocalObject(MEME_SELF, "Door");

    if (! GetIsObjectValid(oDoor))
    {
        _PrintString("Door is invalid.", DEBUG_COREAI);
        _End();
        return;
    }
    else
    {
        _PrintString("Opening door: " + _GetName(oDoor), DEBUG_COREAI);
    }

    if (GetIsObjectValid(oDoor) && GetIsOpen(oDoor) == FALSE)
    {
        if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN))
        {
            //SpeakString("Attempting to open door.");
            _PrintString("Executing ActionOpenDoor.", DEBUG_COREAI);
            ActionOpenDoor(oDoor);
            _End();
            return;
        }

        ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 1.5);

        _PrintString("Unable to open the door, failing.", DEBUG_COREAI);

        string sResponse;
        sResponse = MeRespond("Door/Fail", oDoor, TRUE);

        if (sResponse == "")
        {
            _PrintString("No response was selected, waiting...");
            SpeakString("No responses for 'Door/Fail', aborting.");
            MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
            ActionWait(6.0); // one round
        }
    }
    else
    {
        _PrintString("Door is open, clearing parent MEME_REPEAT.", DEBUG_COREAI);

        //SpeakString("Door is open, telling parent not to repeat.");
        object oParent = MeGetParentMeme(MEME_SELF);

        MeClearMemeFlag(oParent, MEME_REPEAT);
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    }

    _End();
}


/*-----------------------------------------------------------------------------
 *    Meme:  i_closedoor (CloseDoor)
 * Purpose:  This meme allows the NPC to close a door.
 -----------------------------------------------------------------------------
 * Object "Door": The door to close.
 -----------------------------------------------------------------------------*/
 void i_closedoor_go()
 {
    _Start("Meme name='CloseDoor' event = 'Go'", DEBUG_COREAI);

    object oDoor = GetLocalObject(MEME_SELF, "Door");

    if (! GetIsObjectValid(oDoor))
    {
        _PrintString("Door is invalid.", DEBUG_COREAI);
        _End();
        return;
    }
    else
    {
        _PrintString("Closing door: " + _GetName(oDoor), DEBUG_COREAI);
    }

    if (GetIsObjectValid(oDoor) == TRUE && GetIsOpen(oDoor) == TRUE)
    {
        //SpeakString("Attempting to close door.");
        _PrintString("Executing ActionCloseDoor.", DEBUG_COREAI);
        ActionCloseDoor(oDoor);
        _End();
        return;
    }
    else if (GetIsObjectValid(oDoor) == TRUE)
    {
        ActionPlayAnimation(ANIMATION_LOOPING_GET_MID, 1.0, 1.5);

        _PrintString("Unable to close the door, failing.", DEBUG_COREAI);

        string sResponse;
        sResponse = MeRespond("Door/Fail", oDoor, TRUE);

        if (sResponse == "")
        {
            _PrintString("No response was selected, waiting...");
            SpeakString("No responses for 'Door/Fail', aborting.");
            MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
            ActionWait(6.0); // one round
        }
    }
    else
    {
        _PrintString("Door is invalid, clearing MEME_REPEAT.", DEBUG_COREAI);

        //SpeakString("Door is invalid.");
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    }

    _End();
}

/*------------------------------------------------------------------------------
 *   Script: Library Initialization and Scheduling
 ------------------------------------------------------------------------------*/

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("g_door",               "_ini", 0x0100+0x01);
        MeLibraryImplements("g_door",               "_blk", 0x0100+0x02);

        MeLibraryImplements("i_opendoor",           "_go",  0x0200+0x01);

        MeLibraryImplements("i_unlockdoor",         "_go",  0x0300+0x01);

        MeLibraryImplements("i_disabledoor",        "_go",  0x0400+0x01);

        MeLibraryImplements("i_knockdoor",          "_go",  0x0500+0x01);

        MeLibraryImplements("i_equipappropriate",   "_ini", 0x0600+0x01);
        MeLibraryImplements("i_equipappropriate",   "_go",  0x0600+0x02);

        MeRegisterClass("door");
        MeLibraryImplements("c_door",               "_ini", 0x0700+0xff);
        MeLibraryImplements("c_door",               "_go",  0x0700+0x01);

        MeLibraryFunction("f_fail_door",                    0x0800);
        MeLibraryFunction("f_open_door",                    0x0900);
        MeLibraryFunction("f_unlock_door",                  0x0a00);
        MeLibraryFunction("f_disarm_door",                  0x0b00);
        MeLibraryFunction("f_knock_door",                   0x0c00);
        MeLibraryFunction("f_bash_door",                    0x0d00);
        MeLibraryFunction("f_unlock_skillcheck",            0x0e00);

        MeLibraryImplements("i_lockdoor",         "_go",    0x0f00+0x01);

        MeLibraryImplements("i_closedoor",        "_go",    0x1000+0x01);

        _End();
        return;
    }

    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: g_door_ini();    break;
            case 0x02: g_door_blk();    break;
        }   break;

        case 0x0200: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_opendoor_go(); break;
        }   break;

        case 0x0300: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_unlockdoor_go();   break;
        }   break;

        case 0x0400: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_disabledoor_go();  break;
        }   break;

        case 0x0500: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_knockdoor_go();    break;
        }   break;

        case 0x0600: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_equipappropriate_ini();    break;
            case 0x02: i_equipappropriate_go();     break;
        }   break;

        case 0x0700: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_door_ini(); break;
            case 0x01: c_door_go(); break;
        } break;

        case 0x0800: MeSetResult(f_fail_door(MEME_ARGUMENT)); break;
        case 0x0900: MeSetResult(f_open_door(MEME_ARGUMENT)); break;
        case 0x0a00: MeSetResult(f_unlock_door(MEME_ARGUMENT)); break;
        case 0x0b00: MeSetResult(f_disarm_door(MEME_ARGUMENT)); break;
        case 0x0c00: MeSetResult(f_knock_door(MEME_ARGUMENT)); break;
        case 0x0d00: MeSetResult(f_bash_door(MEME_ARGUMENT)); break;
        case 0x0e00: MeSetResult(f_unlock_skillcheck(MEME_ARGUMENT)); break;

        case 0x0f00: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_lockdoor_go();   break;
        }   break;

        case 0x01000: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_closedoor_go();   break;
        }   break;
    }

    _End();
}
