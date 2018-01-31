/*------------------------------------------------------------------------------
 *  Conversation Library
 *
 *  This is a library for conversation subroutines. It consists of a generator
 *  and a conversation meme.
 *
 *  Many memes read variables from the NPC directly. This allows builders to
 *  tweak the NPC behavior through the toolkit. When an NPC becomes an instance
 *  of a class, the class _go script may set these variables on the NPC to
 *  auto-configure them for the user. Unfortunately these settings won't be
 *  visible in the toolkit and may be overridden by the class.
 *
 *  At the end of this library you will find a main() function. This contains
 *  the code that registers and runs the scripts in this library. Read the
 *  instructions to add your own objects to this library or to a new library.
 ------------------------------------------------------------------------------*/

#include "h_library"
#include "x0_i0_anims"

/*-----------------------------------------------------------------------------
 *    Meme:  i_converse (Start a conversation)
 *  Author:  William Bull
 *    Date:  September, 2002 - March, 2004
 * Purpose:  This brings up a conversation dialog and optionally performs
 *           conversation animations. It can preserve a sitting NPC's posture.
 -----------------------------------------------------------------------------
 * Variables read from the NPC:
 *
 *        MT: Talk Standing      MT: Talk Animated
 *        MT: Talk Busy          MT: Talk Timeout
 *        MT: Talk Sendoff       MT: Talk ResRef
 *
 -----------------------------------------------------------------------------
 * Variables set on the Meme:
 *
 * object "Speaker": the PC engage in a conversation.
 * int    "Stand"  : 1/0 - the NPC should stand when a conversation start
 * float  "Timeout": the amount of seconds the NPC will talk before
 *                   auto-terminating the dialog.
 * string "Sendoff": the string to say when the conversation times out,
 *                   prematurely ending the conversation.
 * int    "Private": 1/0 - the conversation is private
 * string "sResRef": the resref of the conversation dialog, if empty the
 *                   default NPC dialog is used (the one set in the toolkit).
 -----------------------------------------------------------------------------*/

void _EndConversation(object oSpeaker, object oMeme)
{
    // If the conversation meme ended, is was preempted, ignore this delay command.
    if ((!GetIsObjectValid(oMeme)) || (MeGetActiveMeme() != oMeme))
    {
        return;
    }

    ClearAllActions();

    // We say a string when we've been in this conversation too long.
    string sSendOff = MeGetConfString(MEME_SELF, "Sendoff");
    if (sSendOff != "") ActionSpeakString(sSendOff);

    // Use Bioware's function, found in x0_i0_anims, to do conversation animations
    if (MeGetLocalInt(MEME_SELF, "Animate"))
    {
        int iHD = GetHitDice(OBJECT_SELF) - GetHitDice(oSpeaker);
        AnimActionPlayRandomGoodbye(iHD);
    }

    // The module must have a dialog called "c_null". This dialog has one node
    // which ends the conversation. It's an awkward way to
    SetLocalString(MEME_SELF, "ResRef", "c_null");
    ActionDoCommand(MeRestartSystem());
}

void i_converse_go()
{
    _Start("Converse timing='go'", DEBUG_COREAI);

    // NPC Configurable Variables
    int    bMakeSpeakerStand = GetLocalInt    (MEME_SELF,   "Stand");
    int    bMakeMeStand      = GetLocalInt    (MEME_SELF,   "Stand");
    int    bPrivate          = MeGetLocalInt  (MEME_SELF,   "Private");
    int    bAnimate          = MeGetLocalInt  (MEME_SELF,   "Animate");
    float  fTimeout          = MeGetLocalFloat(OBJECT_SELF, "Timeout");
    string sResRef           = MeGetConfString(MEME_SELF,   "ResRef");

    // Meme Specific Variables
    object oSpeaker = GetLocalObject(MEME_SELF, "Speaker");

    if (!GetIsObjectValid(oSpeaker))
    {
        _End();
        return;
    }

    if (fTimeout == 0.0) fTimeout = 120.0;

    // These wrappers work around the sitting bugs to allow
    // conversations to start without interruption.
    if (!bMakeMeStand)      ActionDoCommand(SetCommandable(FALSE));
    if (!bMakeSpeakerStand) ActionDoCommand(SetCommandable(FALSE, oSpeaker));

    ActionStartConversation(oSpeaker, sResRef, bPrivate);

    if (!bMakeMeStand)      ActionDoCommand(DelayCommand(0.0, SetCommandable(TRUE)));
    if (!bMakeSpeakerStand) ActionDoCommand(DelayCommand(0.0, SetCommandable(TRUE, oSpeaker)));

    // Bioware function, found in x0_i0_anims
    if (bAnimate) AnimActionPlayRandomTalkAnimation(GetHitDice(OBJECT_SELF) - GetHitDice(oSpeaker));
    else ActionWait(fTimeout);

    DelayCommand(fTimeout,_EndConversation(oSpeaker, MEME_SELF));

    _End("Converse", DEBUG_COREAI);
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_converse (Start a conversation)
 *  Timing:  Meme Initialized
 * Purpose:  This makes sure local variables are reset.
 -----------------------------------------------------------------------------*/

void i_converse_ini()
{
    _Start("Converse timing='ini'", DEBUG_COREAI);

    MeInheritFrom(MEME_SELF, OBJECT_SELF);

    // Should you get up when you talk? Perform basic animations?
    MeMapInt("Stand",   "MT: Talk Standing", MEME_SELF);
    MeMapInt("Animate", "MT: Talk Animated", MEME_SELF);

    // While engaged in a conversating, what do you say?
    MeMapString("Goodbye", "MT: Talk Busy", MEME_SELF);
    MeMapString("ResRef",  "MT: Talk ResRef", MEME_SELF);

    // How long do you talk? What do you say when you timeout?
    MeMapFloat ("Timeout", "MT: Talk Timeout", MEME_SELF);
    MeMapString("Goodbye", "MT: Talk Sendoff", MEME_SELF);

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_converse (Start a conversation)
 *  Timing:  Meme Interrupted
 * Purpose:  This cancels the conversation dialog and resumes the memetic code.
 *           This would be nicer if there was a function EndConversation().
 -----------------------------------------------------------------------------*/

void i_converse_end()
{
    _Start("Converse timing='interrupted'", DEBUG_COREAI);
    DelayCommand(0.0, MeRestartSystem());
    _End("Converse", DEBUG_COREAI);
}

void i_converse_brk()
{
    _Start("Converse timing='interrupted'", DEBUG_COREAI);

    ClearAllActions();
    //AssignCommand(oSpeaker, ClearAllActions());
    SetLocalString(MEME_SELF, "ResRef", "c_null");
    ActionDoCommand(MeRestartSystem());

    _End("Converse", DEBUG_COREAI);
}

/*-----------------------------------------------------------------------------
 *  Generator:  g_converse_optimized (Start a conversation)
 *     Author:  William Bull
 *       Date:  September, 2002
 *    Purpose:  This is an experimental efficient conversation generator.
 *              It disables the NPC's memetic behavior and manually causes
 *              a conversation to start. You still have to
 *---------------------------------------------------------------------------*/

void g_converse_optimized_tlk()
{
    object oSpeaker = GetLastSpeaker();
    if (!GetIsPC(oSpeaker) && !GetIsDM(oSpeaker)) return;

    _Start("Generator name='Optimized Converse' timing='Talk'");

    string sBusy   = MeGetConfString(OBJECT_SELF, "ME: Talk Interrupted");
    if (sBusy == "") sBusy = "I'm too busy to talk at the moment.";

    if ((MeGetPriority(MeGetActiveMeme()) * 100) + MeGetModifier(MeGetActiveMeme()) > 350)
    {
        _PrintString(sBusy);
        _End();
        return;
    }

    ClearAllActions();

    string sFriendly = MeGetConfString(OBJECT_SELF, "MT: Dialog Friendly");
    string sNeutral = MeGetConfString(OBJECT_SELF, "MT: Dialog Neutral");
    string sEnemy = MeGetConfString(OBJECT_SELF, "MT: Dialog Enemy");
    string sResRef = MeGetLocalString(MEME_SELF, "sResRef");

    // If we're not already talking to someone...perhaps we should.
    if (IsInConversation(OBJECT_SELF) == FALSE)
    {
        // Let's find out who the speaker is, and select the
        // right dialog.
        if (GetIsEnemy(OBJECT_SELF, oSpeaker) && sEnemy != "")
        {
            if (sEnemy != "None") sResRef = sEnemy;
            else
            {
                _End();
                return;
            }
        }
        else if (!GetIsFriend(OBJECT_SELF, oSpeaker))
        {
            if (sNeutral != "None") sResRef = sNeutral;
            else
            {
                _End();
                return;
            }
        }
        else
        {
            if (sFriendly != "None") sResRef = sFriendly;
            else
            {
                _End();
                return;
            }
        }

        // Do the converations
        ActionStartConversation(oSpeaker, sResRef);

        if (MeGetConfString(OBJECT_SELF, "MT: Talk Animated") == "True")
        {
            int iHD = GetHitDice(OBJECT_SELF) - GetHitDice(oSpeaker);
            // Bioware function, found in x0_i0_anims
            AnimActionPlayRandomTalkAnimation(iHD);
        }
        else
        {
            ActionWait(9999.9);
        }
        SetLocalObject(MEME_SELF, "Speaker", GetLastSpeaker());
    }
    else
    {
        if (GetPCSpeaker() != GetLocalObject(MEME_SELF, "Speaker"))
        {
            SpeakString(sBusy);
        }
    }

    _End("Generator");
}


/*-----------------------------------------------------------------------------
 *  Generator:  g_converse (Start a conversation)
 *     Author:  William Bull
 *       Date:  September, 2002
 *    Purpose:  This causes a conversation to start. It reads variables from
 *              the NPC to see what conversation it should start.
 -----------------------------------------------------------------------------
 *    Timing:  Conversation
 *-----------------------------------------------------------------------------
 *  String "Busy":    This is what is said when the NPC is busy.
 *  float  "Timeout": The maximum time they'll talk to the PC.
 *  String "Timeout": The message they say when the time expires.
 *  String "ResRef":  The name of the converation dialog. If none is provided,
 *                    it will use the default one.
 *  int "Private":    The conversation is private.
 -----------------------------------------------------------------------------*/

// Incidently this entire thing could be optimized to just clear all actions,
// handle the dialog and do an MeUpdateActions() when the conversation is
// done. And have nothing to do with memes. If you wanted to be nice you
// could even just check the priority of the active meme and see if it's
// at a certain level. The only possible benefit here is that we've developed
// a meme for talking that is useful at different times. But player-engaged
// dialogs might just be better off done by disabling and enabling the memetic
// toolkit, rather than going through all this bloody rigamorole. I mean we
// have to be honest -- just because we built a giant machine to drive through
// cities and crush down buildings doesn't mean we need to use it to get from
// out front porch to the park on the other side of town.  -w. bull
void g_converse_tlk()
{
    object oSpeaker = GetLastSpeaker();
    if (!GetIsPC(oSpeaker) && !GetIsDM(oSpeaker)) return;

    _Start("Generator name='Converse' timing='Talk'");

    string sBusy = GetLocalString(MEME_SELF, "Busy");
    object oMeme = GetLocalObject(MEME_SELF, "Meme");
    string sTimeout = GetLocalString(MEME_SELF, "Timeout");
    float  fTimeout = GetLocalFloat(MEME_SELF, "Timeout");
    int bPrivate = GetLocalInt(MEME_SELF, "Private");
    string sResRef = GetLocalString(MEME_SELF, "ResRef");

    string sFriendly = MeGetConfString(OBJECT_SELF, "MT: Dialog Friendly");
    string sNeutral = MeGetConfString(OBJECT_SELF, "MT: Dialog Neutral");
    string sEnemy = MeGetConfString(OBJECT_SELF, "MT: Dialog Enemy");

    // If we're not already talking to someone...perhaps we should.
    if (oMeme == OBJECT_INVALID)
    {
        if (sResRef == "")
        {
            // Let's find out who the speaker is, and select the
            // right dialog.
            if (GetIsEnemy(OBJECT_SELF, oSpeaker) && sEnemy != "")
            {
                if (sEnemy != "None") sResRef = sEnemy;
                else _End();
            }
            else if (!GetIsFriend(OBJECT_SELF, oSpeaker))
            {
                if (sNeutral != "None") sResRef = sNeutral;
                else _End();
            }
            else
            {
                if (sFriendly != "None") sResRef = sFriendly;
                else _End();
            }
        }

        oMeme = MeCreateMeme("i_converse", PRIO_MEDIUM, 30, MEME_INSTANT, MEME_SELF);
        SetLocalObject(MEME_SELF, "Meme", oMeme);
        _PrintString("The speaker is "+GetName(GetLastSpeaker())+".", DEBUG_COREAI);
        SetLocalObject(oMeme, "Speaker", GetLastSpeaker());
        if (sTimeout != "") SetLocalString(oMeme, "Timeout", sTimeout);
        if (fTimeout != 0.0) SetLocalFloat(oMeme, "Timeout", fTimeout);
        SetLocalString(oMeme, "ResRef", sResRef);
        SetLocalInt(oMeme, "Private", bPrivate);
    }
    else
    {
        if (GetPCSpeaker() != GetLocalObject(oMeme, "Speaker"))
        {
            if (sBusy == "") sBusy = "One moment, I'm busy right now.";
            SpeakString(sBusy);
        }
    }
    _End("Generator");
}

/*-----------------------------------------------------------------------------
 *  Generator:  g_converse (Start a conversation)
 *     Author:  William Bull
 *       Date:  September, 2002
 *    Purpose:  This causes a conversation to start
 -----------------------------------------------------------------------------
 *    Timing:  Aborted Conversation
 -----------------------------------------------------------------------------*/

void _end_conversation()
{
    object oActive = MeGetActiveMeme();
    if (GetLocalString(oActive, "Name") == "i_converse")
    {
        // If the conversation was created by the generator, disassociate it.
        if (oActive == GetLocalObject(MEME_SELF, "Meme"))
        {
            DeleteLocalObject(MEME_SELF, "Meme");
        }
        MeDestroyMeme(oActive);
    }
}

void g_converse_abt()
{
    _Start("Generator name='Converse' timing='DialogAborted'");

    _end_conversation();

    _End("Generator");
}

/*-----------------------------------------------------------------------------
 *  Generator:  g_converse (Start a conversation)
 *     Author:  William Bull
 *       Date:  September, 2002
 *    Purpose:  This causes a conversation to start
 -----------------------------------------------------------------------------
 *    Timing:  Successfully Ended Conversation
 -----------------------------------------------------------------------------*/

void g_converse_bye()
{
    _Start("Generator name='Converse' timing='DialogEnded'");

    _end_conversation();

    _End("Generator");
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
        MeLibraryImplements("g_converse",    "_tlk",       0x0100+0x01);
        MeLibraryImplements("g_converse",    "_bye",       0x0100+0x02);
        MeLibraryImplements("g_converse",    "_abt",       0x0100+0x03);
        MeLibraryImplements("i_converse",    "_go",        0x0200+0x01);
        MeLibraryImplements("i_converse",    "_end",       0x0200+0x02);
        MeLibraryImplements("i_converse",    "_brk",       0x0200+0x03);
        MeLibraryImplements("i_converse",    "_ini",       0x0200+0xff);
        MeLibraryImplements("g_converse_optimized", "_tlk",0x0300+0x01);

        //MeLibraryImplements("<name>",        "_go",     0x??00+0x01);
        //MeLibraryImplements("<name>",        "_brk",    0x??00+0x02);
        //MeLibraryImplements("<name>",        "_end",    0x??00+0x03);
        //MeLibraryImplements("<name>",        "_ini",    0x??00+0xff);

        _End("Library");
        return;
    }

    //  Step 2: Library Dispatcher
    //
    //  These switch statements are what decide to run your scripts, based
    //  on the numbers you provided in Step 1. Notice that you only need
    //  an inner switch statement if you exported more than one method
    //  (like go and end). Also notice that the value used by the case statement
    //  is the two numbers added up.

    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
                    {
                        case 0x01: g_converse_tlk();   break;
                        case 0x02: g_converse_bye();   break;
                        case 0x03: g_converse_abt();   break;
                    }   break;

        case 0x0200: switch (MEME_ENTRYPOINT & 0x00ff)
                    {
                        case 0x01: i_converse_go();     break;
                        case 0x02: i_converse_end();    break;
                        case 0x03: i_converse_brk();    break;
                        case 0xff: i_converse_ini();    break;
                    }   break;

        case 0x0300: switch (MEME_ENTRYPOINT & 0x00ff)
                    {
                        case 0x01: g_converse_optimized_tlk();   break;
                    }   break;
    }

    _End("Library");
}
