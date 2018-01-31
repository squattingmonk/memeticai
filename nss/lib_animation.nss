#include "h_util"
#include "h_library"

// Function: Sit ---------------------------------------------------------------
// This is an example of an ambient animation function. It uses a
// generic animation meme to perform the sitting animation...
object f_sit(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Sit", DEBUG_COREAI);

    object oSit = MeCreateMeme("i_animate", PRIO_DEFAULT, 0, MEME_ONCE);
    SetLocalFloat(oSit, "Duration", 20.0);
    SetLocalInt(oSit, "Animation", ANIMATION_LOOPING_SIT_CROSS);
    SetLocalInt(oSit, "IsResumable", TRUE);

    return NPC_SELF;
}

// Function: Chatter -----------------------------------------------------------
object f_chatter(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Chatter", DEBUG_COREAI);

    object oTarget = MeGetActiveClass();
    _PrintString("Active Class: " + _GetName(oTarget));

    string sTalkTable = MeGetLocalString(oTarget, "TalkTable");
    int i = Random(MeGetStringCount(oTarget, sTalkTable));
    if (i > 0)
        ActionSpeakString(MeGetStringByIndex(oTarget, i, sTalkTable));

    return OBJECT_INVALID;
}

// Function: Wait --------------------------------------------------------------
object f_wait(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Wait", DEBUG_COREAI);

    float fWait = MeGetLocalFloat(NPC_SELF, "WaitTime");
    if (fWait == 0.0f) fWait = 6.0; // Approx. one round
    _PrintString("Waiting for " + FloatToString(fWait) + " secs.", DEBUG_USERAI);

    object oWait = MeCreateMeme("i_wait", PRIO_DEFAULT, 0, MEME_INSTANT);
    SetLocalFloat(oWait, "Duration", fWait);

    return NPC_SELF;
}

// Function: Bored -------------------------------------------------------------
object f_bored(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Bored", DEBUG_COREAI);

    float fSpeed = 0.5f + (IntToFloat(Random(11)) / 10.0f);
    switch (Random(20))
    {
        case 0: case 1: case 2:
            ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, fSpeed);
            break;
        case 3: case 4: case 5:
            ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, fSpeed);
            break;
        case 6: case  7: case  8:
        case 9: case 10: case 11:
            ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD, fSpeed);
            break;
        case 12:
            ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_BORED, fSpeed);
            break;
    }
    return NPC_SELF;
}

// Function: Idle Animations ---------------------------------------------------
object f_idle_animations(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Idle Animations", DEBUG_COREAI);

    float fPause = 6.0; // Grab from config var
    switch (Random(20))
    {
        case 0:
            ActionPlayAnimation(ANIMATION_LOOPING_LOOK_FAR,1.0, fPause);
            break;
        case 1: case 2: case 3:
        case 4: case 5: case 6:
            ActionPlayAnimation(ANIMATION_LOOPING_PAUSE2,1.0, fPause);
            break;
        case 7: case 8: case 9:
            f_bored();
            ActionWait(fPause);
            f_bored();
            break;
        default:
            ActionWait(fPause);

    }

    return NPC_SELF;
}

/*------------------------------------------------------------------------------
 *    Meme:  i_animate
 * Purpose:  This is the first cut of a multi-purpose animation meme.
 * -----------------------------------------------------------------------------
 * Int   "EndTime": The optional time-of-day you want to stop this animation
 * Int   "EndDate": The optional date you want the animation to stop
 *
 -----------------------------------------------------------------------------*/

void i_animate_ini()
{
    _Start("Animation timing='ini'", DEBUG_COREAI);

    int   iDuration  = GetLocalInt(MEME_SELF,   "TrueDuration");
    float fDuration  = GetLocalFloat(MEME_SELF, "Duration");

    if (iDuration)
    {
        fDuration = MeGameDuration(iDuration);
        SetLocalFloat(MEME_SELF, "Duration", fDuration);
    }

    SetLocalInt(MEME_SELF, "EndDate", 0);
    SetLocalFloat(MEME_SELF, "EndTime", 0.0);

    _End("Animation", DEBUG_COREAI);
}

void i_animate_go()
{
    _Start("Animation timing='go'", DEBUG_COREAI);

    float fRemaining;
    float fEndTime  = GetLocalFloat(MEME_SELF, "EndTime");
    int   iEndDate  = GetLocalInt(MEME_SELF,   "EndDate");

    float fDuration = GetLocalFloat(MEME_SELF, "Duration");
    float fWaitLag  = GetLocalFloat(MEME_SELF, "WaitLag");
    float fSpeed    = GetLocalFloat(MEME_SELF, "Speed");
    int nAnimation  = GetLocalInt(MEME_SELF,   "Animation");
    int nIsAction   = GetLocalInt(MEME_SELF,   "IsAction");
    int nResume     = GetLocalInt(MEME_SELF,   "IsResumable");
    int nContinue   = GetLocalInt(MEME_SELF,   "IsContinuous");

    if (nAnimation < 1)
    {
        _PrintString("No animation specified. Aborting.");
        _End();
        return;
    }

    if (nResume)
    {
        _PrintString("Adding the MEME_RESUME flag.", DEBUG_COREAI);
        MeAddMemeFlag(MEME_SELF, MEME_RESUME);
    }

    if (fSpeed == 0.0)
    {
        _PrintString("Speed undefined, resetting to 1.0.", DEBUG_COREAI);
        fSpeed = 1.0;
    }

    if (fEndTime <= 0.0)
    {
        iEndDate = MeGetCurrentDate();
        fEndTime = MeGetCurrentGameTime() + fDuration;
        if (fEndTime >= MeGameHours(24))
        {
            int iDays = FloatToInt(fEndTime) / FloatToInt(MeGameHours(24));
            iEndDate += iDays;
            fEndTime -= (MeGameHours(24) * iDays);
        }

        SetLocalInt(MEME_SELF, "EndDate", iEndDate);
        SetLocalFloat(MEME_SELF, "EndTime", fEndTime);
    }

    fRemaining = MeGameInterval(MeGetCurrentGameTime(), fEndTime, MeGetCurrentDate(), iEndDate);

    _PrintString("End date is "+IntToString(iEndDate)+" days.", DEBUG_COREAI);
    _PrintString("End time is "+FloatToString(fEndTime)+" seconds.", DEBUG_COREAI);
    _PrintString("Current date is "+IntToString(MeGetCurrentDate())+" days.", DEBUG_COREAI);
    _PrintString("Current time is "+FloatToString(MeGetCurrentGameTime())+" seconds.", DEBUG_COREAI);
    _PrintString("Duration is "+FloatToString(fDuration)+" seconds.", DEBUG_COREAI);
    _PrintString("Remaining time is "+FloatToString(fRemaining)+" seconds.", DEBUG_COREAI);

    //SpeakString("Animation Duration: " + FloatToString(fRemaining));

    if (fRemaining < 0.5)
    {
        _PrintString("Finished animation, clearing REPEAT flag and reprioritizing meme.", DEBUG_COREAI);
        //SpeakString("Finished animation.");

        if (fRemaining < 0.0)
            fRemaining = 0.0;

        if (nContinue)
            _PrintString("Meme is continous, not clearing the REPEAT flag.", DEBUG_COREAI);
        else
            MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

        ActionWait(fRemaining);

    }
    else
    {
        MeAddMemeFlag(MEME_SELF, MEME_REPEAT);  // be sure we repeat

        switch (nAnimation) {
            case ANIMATION_FIREFORGET_BOW :
            case ANIMATION_FIREFORGET_DODGE_DUCK :
            case ANIMATION_FIREFORGET_DODGE_SIDE :
            case ANIMATION_FIREFORGET_DRINK :
            case ANIMATION_FIREFORGET_GREETING :
            case ANIMATION_FIREFORGET_HEAD_TURN_LEFT :
            case ANIMATION_FIREFORGET_HEAD_TURN_RIGHT :
            case ANIMATION_FIREFORGET_PAUSE_BORED :
            case ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD :
            case ANIMATION_FIREFORGET_READ :
            case ANIMATION_FIREFORGET_SALUTE :
            case ANIMATION_FIREFORGET_STEAL :
            case ANIMATION_FIREFORGET_TAUNT :
            case ANIMATION_FIREFORGET_VICTORY1 :
            case ANIMATION_FIREFORGET_VICTORY2 :
            case ANIMATION_FIREFORGET_VICTORY3 :
                //SpeakString("Fire and Forget");
                ActionPlayAnimation(nAnimation);
                break;
            default :
                //SpeakString("Looping");
                ActionPlayAnimation(nAnimation, fSpeed, fRemaining);
                break;
        }

        //
        if (nIsAction)
        {
            float fWait;
            if (nResume)
                fWait = fRemaining - fWaitLag;
            else
                fWait = fRemaining;

            if (fWait < 0.0)
                fWait = 0.0;
            _PrintString("Waiting for " + FloatToString(fWait) + " seconds.", DEBUG_COREAI);
            //SpeakString("Waiting for " + FloatToString(fWait) + " seconds.");
            ActionWait(fWait);
        }
        else
        {
            _PrintString("Not waiting.", DEBUG_COREAI);
            //SpeakString("Not waiting.");
        }
        //
        //SpeakString("Animation activated.");
        _End();
        return;
    }

    _End();
}

void i_animate_end()
{
    _Start("Animation timing='end'", DEBUG_COREAI);
    SpeakString("Animation ending.");
    /*
    int    iEndDate   = GetLocalInt(MEME_SELF, "EndDate");
    float  fEndTime   = GetLocalFloat(MEME_SELF, "EndTime");
    float  fRemaining = MeGameInterval(MeGetCurrentGameTime(), fEndTime, MeGetCurrentDate(), iEndDate);
    _PrintString("Finished animation, clearing REPEAT flag and reprioritizing meme.", DEBUG_COREAI);
    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    SpeakString("Animation END: clearing repeat flag.");

    MeSetPriority(MEME_SELF, PRIO_NONE);
    */
    _PrintString("Resetting end date and time.");
    SetLocalInt(MEME_SELF, "EndDate", 0);
    SetLocalFloat(MEME_SELF, "EndTime", 0.0);

    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_wait
 *  Author:  William Bull
 *    Date:  September, 2002
 * Purpose:  This is rough example of waiting for a relative or an absolute
 *           amount of time. It does some idle animations, and assumes it is
 *           created with the MEME_REPEAT flag.
 -----------------------------------------------------------------------------
 * Float "Duration": The total time you'd like to wait (optional)
 * Float "EndTime": When you'd like to stop waiting. (optional)
 -----------------------------------------------------------------------------*/

void i_wait_go()
{
    _Start("Wait timing = 'Go'", DEBUG_COREAI);

    float  iDuration  = GetLocalFloat(MEME_SELF, "Duration");
    float  iEndTime   = GetLocalFloat(MEME_SELF, "EndTime");
    float  iPause     = IntToFloat(Random(3)+1);
    float  iRemaining = iEndTime - MeGetFloatTime();

    if (iEndTime == 0.0)
    {
        iEndTime   = MeGetFloatTime() + iDuration;
        iRemaining = iDuration;
        SetLocalFloat(MEME_SELF, "EndTime", iEndTime);
    }

    if (iPause > iRemaining) iPause = iRemaining;

    _PrintString("Waiting for "+FloatToString(iPause)+" seconds.", DEBUG_COREAI);
    _PrintString("Total time to wait is "+FloatToString(iDuration)+" seconds.", DEBUG_COREAI);
    _PrintString("End time is"+FloatToString(iEndTime)+" seconds.", DEBUG_COREAI);
    _PrintString("Current time is "+FloatToString(MeGetFloatTime())+" seconds.", DEBUG_COREAI);
    _PrintString("Remaining time is "+FloatToString(iRemaining)+" seconds.", DEBUG_COREAI);

    if (iRemaining < 0.5)
    {
        _PrintString("Done waiting, clearing end time.", DEBUG_COREAI);
        if (iRemaining < 0.0) iRemaining = 0.0;
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        SetLocalFloat(MEME_SELF, "EndTime", 0.0);
        ActionWait(iRemaining);
    }
    else
    {
        MeSetMemeFlag(MEME_SELF, MEME_REPEAT);
        switch (Random(4))
        {
            case 0:
                ActionPlayAnimation(ANIMATION_LOOPING_LOOK_FAR,1.0, iPause);
                break;
            case 1:
                ActionPlayAnimation(ANIMATION_LOOPING_LISTEN,1.0, iPause);
                break;
            case 2:
                ActionPlayAnimation(ANIMATION_LOOPING_PAUSE2,1.0, iPause);
                break;
            case 3:
                ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
                ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT);
                break;
        }
        ActionWait(iPause);
    }

    _End();
}

void i_wait_brk()
{
    _Start("Wait timing = 'Break'", DEBUG_COREAI);

    //ClearAllActions();
    //ActionDoCommand(MeRestartSystem());

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_pause
 * Purpose:  This is rough example of waiting for an amount of time.
 *           It does some idle animations, and sets the MEME_REPEAT flag
 *           to keep going for the required amount of time.
 *    Note:  This is a modified form of i-wait that uses "h_time" functions
 -----------------------------------------------------------------------------
 * Int   "TrueDuration": The total time you want to be idle, expressed in TrueTime
 * Float "GameDuration": The total time you'd like to wait, expressed in GameTime
 *             note: if both are set TrueDuration takes precedence
-----------------------------------------------------------------------------*/

void i_pause_ini()
{
    _Start("Pause event = 'Ini'", DEBUG_COREAI);

    int   iDuration  = GetLocalInt(MEME_SELF,   "TrueDuration");
    float fDuration  = GetLocalFloat(MEME_SELF, "GameDuration");
    if (iDuration)
        {
            fDuration = MeGameDuration(iDuration);
            SetLocalFloat(MEME_SELF, "GameDuration", fDuration);
        }
    int   iEndDate = MeGetCurrentDate();
    float fEndTime = MeGetCurrentGameTime() + fDuration;
    if (fEndTime >= MeGameHours(24))
        {
            int iDays = FloatToInt(fEndTime) / FloatToInt(MeGameHours(24));
            iEndDate += iDays;
            fEndTime -= (MeGameHours(24) * iDays);
        }

    SetLocalInt(MEME_SELF, "EndDate", iEndDate);
    SetLocalFloat(MEME_SELF, "EndTime", fEndTime);

    MeSetMemeFlag(MEME_SELF, MEME_REPEAT);  // be sure we repeat

    _End("Pause", DEBUG_COREAI);
}

void i_pause_go()
{
    _Start("Pause event = 'Go'", DEBUG_COREAI);

    float  fDuration  = GetLocalFloat(MEME_SELF, "GameDuration");
    int    iEndDate   = GetLocalInt(MEME_SELF, "EndDate");
    float  fEndTime   = GetLocalFloat(MEME_SELF, "EndTime");
    float  fPause     = IntToFloat(Random(3)+1);
    float  fRemaining = MeGameInterval(MeGetCurrentGameTime(), fEndTime,
                                       MeGetCurrentDate(),     iEndDate);

    if (fPause > fRemaining) fPause = fRemaining;

    _PrintString("Pausing for "+FloatToString(fPause)+" seconds.", DEBUG_COREAI);
    _PrintString("Total time to pause is "+FloatToString(fDuration)+" seconds.", DEBUG_COREAI);
    _PrintString("End date is"+IntToString(iEndDate)+" days.", DEBUG_COREAI);
    _PrintString("End time is"+FloatToString(fEndTime)+" seconds.", DEBUG_COREAI);
    _PrintString("Current date is"+IntToString(MeGetCurrentDate())+" days.", DEBUG_COREAI);
    _PrintString("Current time is "+FloatToString(MeGetCurrentGameTime())+" seconds.", DEBUG_COREAI);
    _PrintString("Remaining time is "+FloatToString(fRemaining)+" seconds.", DEBUG_COREAI);

    if (fRemaining < 0.5)
    {
        _PrintString("Done pausing, clearing REPEAT flag.", DEBUG_COREAI);
        if (fRemaining < 0.0) fRemaining = 0.0;
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        ActionWait(fRemaining);
    }
    else
        f_idle_animations(); // fPause

    _End("Pause", DEBUG_COREAI);
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_pause_until
 * Purpose:  This is rough example of waiting until a given time.
 *           It does some idle animations, and sets the MEME_REPEAT flag
 *           to keep going for the required amount of time.
 *    Note:  This is a modified form of i-wait that uses "h_time" functions
 -----------------------------------------------------------------------------
 * Int   "EndTime": The time-of-day you want to wait for, expressed in TrueTime
 * Int   "EndDate": The date the pause will end; if omitted it will be Today,
 *                  or Tomorrow if EndTime is earlier than the moment of Meme
 *                  creation
-----------------------------------------------------------------------------*/

void i_pause_until_ini()
{
    _Start("Pause_until event = 'Ini'", DEBUG_COREAI);

    int    iEndDate   = GetLocalInt(MEME_SELF, "EndDate");
    int    iEndTime   = GetLocalInt(MEME_SELF, "EndTime");
    if (!iEndDate)  // date omitted
       if (iEndTime > MeGetCurrentTime())
            iEndDate = MeGetCurrentDate();
       else
            iEndDate = MeGetCurrentDate() + 1;

    float fEndTime = MeTimeToGameTime(iEndTime);

    SetLocalInt(MEME_SELF, "EndDate", iEndDate);
    SetLocalFloat(MEME_SELF, "EndTime", fEndTime);

    MeSetMemeFlag(MEME_SELF, MEME_REPEAT);  // be sure we repeat

    _End("Pause_until", DEBUG_COREAI);
}

void i_pause_until_go()
{
    _Start("Pause_until event = 'Go'", DEBUG_COREAI);

    int    iEndDate   = GetLocalInt(MEME_SELF, "EndDate");
    float  fEndTime   = GetLocalFloat(MEME_SELF, "EndTime");
    float  fPause     = IntToFloat(Random(3)+1);
    float  fRemaining = MeGameInterval(MeGetCurrentGameTime(), fEndTime,
                                       MeGetCurrentDate(),     iEndDate);

    if (fPause > fRemaining) fPause = fRemaining;

    _PrintString("Pausing for "+FloatToString(fPause)+" seconds.", DEBUG_COREAI);
    _PrintString("End date is"+IntToString(iEndDate)+" days.", DEBUG_COREAI);
    _PrintString("End time is"+FloatToString(fEndTime)+" seconds.", DEBUG_COREAI);
    _PrintString("Current date is"+IntToString(MeGetCurrentDate())+" days.", DEBUG_COREAI);
    _PrintString("Current time is "+FloatToString(MeGetCurrentGameTime())+" seconds.", DEBUG_COREAI);
    _PrintString("Remaining time is "+FloatToString(fRemaining)+" seconds.", DEBUG_COREAI);

    if (fRemaining < 0.5)
    {
        _PrintString("Done pausing, clearing REPEAT flag.", DEBUG_COREAI);
        if (fRemaining < 0.0) fRemaining = 0.0;
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        ActionWait(fRemaining);
    }
    else
        f_idle_animations(); // fPause

    _End("Pause_until", DEBUG_COREAI);
}

// Main: Register Functions & Dispatch -----------------------------------------

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    // Register classes and functions
    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("i_animate",   "_go",   0x0100+0x01);
        //MeLibraryImplements("i_animate",  "_brk", 0x0100+0x02);
        MeLibraryImplements("i_animate",   "_end",  0x0100+0x03);
        MeLibraryImplements("i_animate",   "_ini",  0x0100+0xff);

        MeLibraryImplements("i_wait",      "_go",   0x0200+0x01);
        MeLibraryImplements("i_wait",      "_brk",  0x0200+0x02);

        MeLibraryFunction("f_sit",                  0x0300);
        MeLibraryFunction("f_wait",                 0x0400);
        MeLibraryFunction("f_bored",                0x0500);
        MeLibraryFunction("f_idle_animations",      0x0600);
        MeLibraryFunction("f_chatter",              0x0700);

        MeLibraryImplements("i_pause",     "_go",   0x0800+0x01);
        MeLibraryImplements("i_pause",     "_ini",  0x0800+0xff);

        MeLibraryImplements("i_pause_until", "_go",   0x0900+0x01);
        MeLibraryImplements("i_pause_until", "_ini",  0x0900+0xff);

        _End();
        return;
    }

    // Dispatch to the function
    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_animate_go(); break;
            case 0x03: i_animate_end(); break;
            case 0xff: i_animate_ini(); break;
        }   break;

        case 0x0200: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_wait_go(); break;
            case 0x03: i_wait_brk(); break;
        }   break;

        case 0x0300: MeSetResult(f_sit(MEME_ARGUMENT)); break;
        case 0x0400: MeSetResult(f_wait(MEME_ARGUMENT)); break;
        case 0x0500: MeSetResult(f_bored(MEME_ARGUMENT)); break;
        case 0x0600: MeSetResult(f_idle_animations(MEME_ARGUMENT)); break;
        case 0x0700: MeSetResult(f_chatter(MEME_ARGUMENT)); break;

        case 0x0800: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_pause_go();       break;
            case 0xff: i_pause_ini();      break;
        }   break;

        case 0x0900: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_pause_until_go();   break;
            case 0xff: i_pause_until_ini();  break;
        }   break;
    }
    _End();
}
