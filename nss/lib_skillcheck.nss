/*------------------------------------------------------------------------------
 *  HCMAAI Memetic Function Library
 *
 *  This library contains functions used by the HCMAAI libraries.
 *  It does not contain memetic code, per se. It contains general functions
 *  used by HCMAAI memetic systems.
 *
 *  At the end of this library you will find a main() function. This contains
 *  the code that registers and runs the scripts in this library. Read the
 *  instructions to add your own objects to this library or to a new library.
 ------------------------------------------------------------------------------*/

#include "h_library"

// Trained-only
object f_skillcheck_open_lock(object oNPC)
{
    _PrintString("Running Open Lock skill check for: " + _GetName(oNPC));

    int bSuccess = FALSE;

    if (GetObjectType(oNPC) != OBJECT_TYPE_CREATURE)
    {
        _PrintString("ERROR: f_skillcheck_open_lock was passed invalid argument", DEBUG_COREAI);
    }
    else
    {
        object oBlocking = GetLocalObject(NPC_SELF, "Door");
        if(!GetIsObjectValid(oBlocking))
        {
            _PrintString("ERROR: f_skillcheck_open_lock does not have a valid lock to check against", DEBUG_COREAI);
        }
        else
        {
            int iOpenSkill = GetSkillRank(SKILL_OPEN_LOCK, oNPC);
            if (iOpenSkill > 0)
            {
                int iUnlockDC = GetLockUnlockDC(oBlocking);
                if (iUnlockDC >= 100) iUnlockDC -= 100; //in case they are using HCR locks
                int iRoll = d20();
                int iCheck = iRoll + iOpenSkill;
                if (iCheck >= iUnlockDC) bSuccess = TRUE;
                _PrintString("Rolled: " + IntToString(iRoll) + "+" + IntToString(iOpenSkill) + " vs " + IntToString(iUnlockDC), DEBUG_TOOLKIT);
            }
            else
            {
                _PrintString("No skill in lockpicking.", DEBUG_COREAI);
            }
        }
    }
    SetLocalInt(oNPC, "SC_RESULT", bSuccess);
    return oNPC;
}

object f_skillcheck_detect_trap(object oNPC)
{
    _PrintString("Running Detect Trap skill check for: " + _GetName(oNPC));

    int bSuccess = FALSE;

    if (GetObjectType(oNPC) != OBJECT_TYPE_CREATURE)
    {
        _PrintString("ERROR: f_skillcheck_detect_trap was passed an invalid argument", DEBUG_COREAI);
    }
    else
    {
        object oTrap = GetLocalObject(NPC_SELF, "Trap");
        if (!GetIsObjectValid(oTrap))
        {
            _PrintString("ERROR: f_skillcheck_detect_trap does not have a valid trap to check against", DEBUG_COREAI);
        }
        else
        {
            int iSkillSearch = GetSkillRank(SKILL_SEARCH, oNPC);
            if (iSkillSearch > 0)
            {
                int iDetectDC = GetTrapDetectDC(oTrap);
                if (iDetectDC >= 100) iDetectDC -= 100; //in case they are using HCR traps
                int iRoll = d20();
                int iCheck = iRoll + iSkillSearch;
                if (iCheck >= iDetectDC) bSuccess = TRUE;
                _PrintString("Rolled: " + IntToString(iRoll) + "+" + IntToString(iSkillSearch) + " vs " + IntToString(iDetectDC), DEBUG_COREAI);
            }
            else
            {
                _PrintString("No skill in detecting traps.", DEBUG_COREAI);
            }
        }
    }
    SetLocalInt(oNPC, "SC_RESULT", bSuccess);
    return oNPC;
}

// Trained-only
object f_skillcheck_disable_trap(object oNPC)
{
    _PrintString("Running Disable Trap skill check for: " + _GetName(oNPC));

    int bSuccess = FALSE;

    if (GetObjectType(oNPC) != OBJECT_TYPE_CREATURE)
    {
        _PrintString("ERROR: f_skillcheck_disable_trap was passed an invalid argument", DEBUG_COREAI);
    }
    else
    {
        object oTrap = GetLocalObject(NPC_SELF, "Trap");
        if (!GetIsObjectValid(oTrap))
        {
            _PrintString("ERROR: f_skillcheck_disable_trap does not have a valid trap to check against", DEBUG_COREAI);
        }
        else
        {
            int iSkillDisable = GetSkillRank(SKILL_DISABLE_TRAP, oNPC);
            if (iSkillDisable > 0)
            {
                int iDisableDC = GetTrapDisarmDC(oTrap);
                if (iDisableDC >= 100) iDisableDC -= 100; //in case they are using HCR traps
                int iRoll = d20();
                int iCheck = iRoll + iSkillDisable;
                SetLocalInt(oNPC, "SC_DIFF", iDisableDC - iCheck);
                if (iCheck >= iDisableDC) bSuccess = TRUE;
                _PrintString("Rolled: " + IntToString(iRoll) + "+" + IntToString(iSkillDisable) + " vs " + IntToString(iDisableDC), DEBUG_TOOLKIT);
            }
            else
            {
                _PrintString("No skill in disabling traps.", DEBUG_COREAI);
            }
        }
    }
    SetLocalInt(oNPC, "SC_RESULT", bSuccess);
    return oNPC;
}

/*------------------------------------------------------------------------------
 *   Script: Library Initialization and Scheduling
 ------------------------------------------------------------------------------*/

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryFunction("f_skillcheck_open_lock",    1);
        MeLibraryFunction("f_skillcheck_detect_trap",  2);
        MeLibraryFunction("f_skillcheck_disable_trap", 3);
        _End();
        return;
    }

    switch (MEME_ENTRYPOINT)
    {
        case 1:  MeSetResult(f_skillcheck_open_lock(MEME_ARGUMENT));
                 break;
        case 2:  MeSetResult(f_skillcheck_detect_trap(MEME_ARGUMENT));
                 break;
        case 3:  MeSetResult(f_skillcheck_disable_trap(MEME_ARGUMENT));
                 break;
    }

    _End();
}

