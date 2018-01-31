#include "h_util"
#include "h_library"
#include "h_response"

// Event: Respond --------------------------------------------------------------

void e_respond_ini()
{
    _Start("Event type='Respond'", DEBUG_COREAI);

	// Subscribe to the core events.
    MeSubscribeMessage(MEME_SELF, "Door/Blocked");

    _End();
}

void e_respond_go()
{
    _Start("Event type='Respond'", DEBUG_COREAI);

    struct message stMsg = MeGetLastMessage();
    object oResponse;

    _PrintString("Message: " + stMsg.sMessageName, DEBUG_COREAI);

    if (stMsg.sMessageName == "Door/Blocked")
    {
    	oResponse = MeCreateMeme("i_respond", PRIO_HIGH, 0, MEME_RESUME | MEME_REPEAT);
    	MeSetLocalMessage(oResponse, "Message", stMsg);
    }

    _End();
}

// Meme: Respond ---------------------------------------------------------------

void i_respond_go()
{
    _Start("Meme name='Respond' timing='Go'", DEBUG_COREAI);

    int r = 0;
    int result = FALSE;
    object oChild = MeGetChildMeme(MEME_SELF, r);

    if (oChild == OBJECT_INVALID)
    {
        _PrintString("No child memes present.", DEBUG_COREAI);
    }
    else
    {
        while (oChild != OBJECT_INVALID)
        {
            _PrintString("Processing child meme: " + _GetName(oChild), DEBUG_COREAI);
            result = MeGetMemeResult(oChild);
            if (result == TRUE)
            {
                _PrintString("Child meme returned true, stopping all other child memes.", DEBUG_COREAI);
                MeDestroyChildMemes(MEME_SELF);
                break;
            }
            oChild = MeGetChildMeme(MEME_SELF, ++r);
        }
    }

    if (result == FALSE)
    {
        _PrintString("Finished processing child memes.", DEBUG_COREAI);
    }

    string sSituation;
    object oResponseArg;
    int bResume;

    struct message stMsg = MeGetLocalMessage(MEME_SELF, "Message");

    if (stMsg.sMessageName != "")
    {
        sSituation = stMsg.sMessageName;
        oResponseArg = stMsg.oData;
        bResume = stMsg.iData;
    }
    else {
        sSituation = GetLocalString(MEME_SELF, "Situation");
        oResponseArg = GetLocalObject(MEME_SELF, "ResponseArg");
        bResume = GetLocalInt(MEME_SELF, "Resume");
    }

    _PrintString("Situation: " + sSituation, DEBUG_COREAI);

    string sResponse;

    if (sSituation != "")
    {
        sResponse = MeRespond(sSituation, oResponseArg, bResume);
    }

    if (sResponse == "")
    {
        _PrintString("No response was selected, aborting response meme...");
        SpeakString("No responses for '" + sSituation + "'.");
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    }

    MeUpdateActions();
    _End();
}



// Class: Generic --------------------------------------------------------------

void c_generic_ini()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_TOOLKIT);

    // Define the default response tables, shared by all generic creatures.

    // 1. Idle
    MeAddResponse(MEME_SELF, "Generic Idle Table", "f_say_hello",   50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, "Generic Idle Table", "f_wander", 50, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, "Generic Idle Table", "f_do_nothing",  50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, "Generic Idle Table", "f_do_nothing", 100, RESPONSE_END);
    MeSetActiveResponseTable("Idle", "Generic Idle Table");

    // 2. Combat
    MeAddResponse(MEME_SELF, "Generic Combat Table", "f_AttackMelee", 100, RESPONSE_END);
    MeSetActiveResponseTable("Combat", "Generic Combat Table");

    _End();
}

void c_generic_go()
{
    _Start("Instantiate class='"+MEME_CALLED+"'", DEBUG_COREAI);

    // Make variables on NPC_SELF available to OBJECT_SELF
    MeInheritFrom(OBJECT_SELF, NPC_SELF);

    // Setup the default AI level
    object oSetAI = MeCreateEvent("e_setai");
    SetLocalInt(oSetAI, "Normal", AI_LEVEL_LOW);
    SetLocalInt(oSetAI, "Suspend", AI_LEVEL_VERY_LOW);
    SetAILevel(OBJECT_SELF, AI_LEVEL_LOW);

    // An optional heartbeat generator used to kick start braindead NPCs.
    // This will do nothing if you don't have heartbeat scripts on your NPC.
    //object oGenerator = MeCreateGenerator("g_restart");
    //MeStartGenerator(oGenerator);

    MeCreateMeme("i_idle", PRIO_LOW, -100, MEME_REPEAT | MEME_RESUME);
    MeCreateMeme("i_spawn", PRIO_VERYHIGH, 100, MEME_INSTANT);

    object oRespond = MeCreateEvent("e_respond");

    // I don't think UpdateActions() is needed here, as the convention is to
    // call it in the spawn script. Additionally, other classes be instanciating.
    // MeUpdateActions();

    _End();
}

// Meme: Spawn------------------------------------------------------------------

void i_spawn_end()
{
    _Start("Spawn timing='end'", DEBUG_COREAI);

    struct message stSpawn;
    stSpawn.sMessageName = "Area/Enter/Self";
    stSpawn.oData = GetArea(OBJECT_SELF);

    _PrintString(_GetName(OBJECT_SELF) + " entered area.", DEBUG_COREAI);
    MeSendMessage(stSpawn, "");

    _End();
}

// Meme: Idle ------------------------------------------------------------------

void i_idle_go()
{
    _Start("Idle", DEBUG_COREAI);

    string sResponse = MeRespond("Idle");
    if (sResponse == "")
    {
        _PrintString("No response was selected, waiting...");
        ActionWait(6.0);
    }

    _End();
}

// Functions: Generic Idle Animations ------------------------------------------

object f_do_nothing(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Do Nothing", DEBUG_COREAI);

    //ActionSpeakString("Do nothing.");
    ActionWait(6.0);    // Wait approximately one round
    return OBJECT_SELF; // Return a valid object to signal we're done
}

object f_say_hello(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Say Hello", DEBUG_COREAI);

    ActionSpeakString("Hello");
    ActionWait(3.0);    // Wait approximately one round
    return OBJECT_SELF; // Return a valid object to signal we're done
}

object f_wander(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Wander", DEBUG_COREAI);

    object oMeme = MeCreateMeme("i_wander", PRIO_DEFAULT, 0, 0);
    MeStopMeme(oMeme, 6.0+6.0*Random(2)); // Approx. one to three rounds

    return OBJECT_SELF;
}

object f_random_walk(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: Random Walk (deprecated: use f_wander)", DEBUG_COREAI);

    return (f_wander(oArg));
}

object f_end_response(object oArg = OBJECT_INVALID)
{
    _PrintString("Function: End Response", DEBUG_COREAI);
    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    return OBJECT_SELF;
}

/*-----------------------------------------------------------------------------
 *   Event:  e_setai
 *  Author:  William Bull
 *    Date:  November, 2003
 * Purpose:  This is an event that listens for the last exiting PC and causes
 *           the NPC to reduce its AI level -- putting its asleep.
 *
 *           This event works in conjunction with the memetic cb scripts for
 *           OnAreaEnter and OnAreaExit. These scripts send messages to NPCs
 *           as they enter and leave an area, keeping there AI level in sync.
 -----------------------------------------------------------------------------
 * int "Suspend": This is the AI level the NPC takes when the last PC leaves
 *                   its area. By default this is AI_LEVEL_VERY_LOW.
 * int "Normal": This is the AI level the NPC takes when a PC enters its area
 *                   its area. By default this is AI_LEVEL_LOW.
 * int "Combat": This is the AI level the NPC takes when it engages in combat.
 *                   By default this is AI_LEVEL_NORMAL.
 -----------------------------------------------------------------------------*/

void e_setai_ini()
{
    _Start("Event type='Set AI'", DEBUG_COREAI);

    SetLocalInt(MEME_SELF, "Suspend", AI_LEVEL_VERY_LOW);
    SetLocalInt(MEME_SELF, "Normal", AI_LEVEL_LOW);
    SetLocalInt(MEME_SELF, "Combat", AI_LEVEL_NORMAL);

    MeSubscribeMessage(MEME_SELF, "Area/Enter/Self");
    MeSubscribeMessage(MEME_SELF, "Area/Exit/Self");
    MeSubscribeMessage(MEME_SELF, "SetAI");

    _End();
}

/* == TODO ==
+ Check a local config for default active and suspend AI level.
+ Add combat AI response? Is it needed?
+ Exempt NPCs from receiving SetAI requests by using level- or class-based
+ filters and flags.
*/
void e_setai_go()
{
    _Start("Event type='Set AI'", DEBUG_COREAI);

    struct message stMsg = MeGetLastMessage();

    object oArea = stMsg.oData;

    string sChannel = "AI_" + GetTag(oArea);
    _PrintString("Channel: " + sChannel, DEBUG_COREAI);

    int iPlayerCount = GetLocalInt(oArea, "AreaPlayerCount");
    _PrintString("Player Count: " + IntToString(iPlayerCount), DEBUG_COREAI);

    int iLevel;

    if (stMsg.sMessageName == "Area/Enter/Self")
    {
        _PrintString("Entering " + _GetName(oArea), DEBUG_COREAI);

        MeSubscribeMessage(MEME_SELF, "Area/Enter/First PC", sChannel);
        MeSubscribeMessage(MEME_SELF, "Area/Exit/Last PC",   sChannel);

        if (iPlayerCount > 0)
            iLevel = GetLocalInt(MEME_SELF, "Normal");
        else
        {
            _PrintString("Suspending AI.", DEBUG_COREAI);
            iLevel = GetLocalInt(MEME_SELF, "Suspend");
        }
    }
    else if (stMsg.sMessageName == "Area/Exit/Self")
    {
        _PrintString("Exiting " + _GetName(oArea), DEBUG_COREAI);

        MeUnsubscribeMessage(MEME_SELF, "Area/Enter/First PC", sChannel);
        MeUnsubscribeMessage(MEME_SELF, "Area/Exit/Last PC",   sChannel);

        if (iPlayerCount > 0)
            iLevel = GetLocalInt(MEME_SELF, "Normal");
        else
            iLevel = GetLocalInt(MEME_SELF, "Suspend");
    }
    else if (stMsg.sMessageName == "Area/Enter/First PC")
    {
        _PrintString("First PC entered.", DEBUG_COREAI);
        iLevel = GetLocalInt(MEME_SELF, "Normal");
    }
    else if (stMsg.sMessageName == "Area/Exit/Last PC")
    {
        _PrintString("Last PC exited.", DEBUG_COREAI);
        iLevel = GetLocalInt(MEME_SELF, "Suspend");
    }
    else if (stMsg.sMessageName == "SetAI")
    {
        iLevel = stMsg.iData;
        //_PrintString("Setting AI level to '" + IntToString(iLevel) + "'.", DEBUG_COREAI);
    }

    string sMsg;
    switch (iLevel)
    {
        case AI_LEVEL_VERY_LOW : sMsg = "AI: Very low"; break;
        case AI_LEVEL_LOW :  sMsg = "AI: Low"; break;
        case AI_LEVEL_NORMAL :  sMsg = "AI: Normal"; break;
        case AI_LEVEL_HIGH :  sMsg = "AI: High"; break;
        case AI_LEVEL_VERY_HIGH :  sMsg = "AI: Very high"; break;
        case AI_LEVEL_INVALID : sMsg = "AI: Invalid"; break;
        default :
            sMsg = "AI: Unknown, setting to NWN default.";
            iLevel = AI_LEVEL_DEFAULT;
            break;
    }
    _PrintString(sMsg, DEBUG_COREAI);

    SendMessageToAllDMs(_GetName(OBJECT_SELF) + " " + sMsg);
    SetAILevel(OBJECT_SELF, iLevel);

    if (GetLocalInt(NPC_SELF, "MEME_Paused") == TRUE)
    {
        _PrintString("Resuming paused NPC.", DEBUG_COREAI);
        MeResumeSystem();
    }

    if (iLevel == AI_LEVEL_VERY_LOW)
    {
        _PrintString("Paused NPC.", DEBUG_COREAI);
        MePauseSystem();
    }

    _End();
}

/*
 * The restart generators are highly subject to change and should be
 * used with the utmost caution.
 *
 * The choice: run g_restart_HB alone, or run g_restart and use a DM wand to
 * restart recently-unpossessed NPCs.
 *
 * Need to check for a paused system now that SetAI is working.
 */
void g_restart_HB_hbt()
{
    _Start("Heartbeat class='"+MEME_CALLED+"'", DEBUG_COREAI);

    string sMsg;
    int nAI = GetAILevel(OBJECT_SELF);
    switch (nAI)
    {
        case AI_LEVEL_VERY_LOW : sMsg = "AI: Very low"; break;
        case AI_LEVEL_LOW :  sMsg = "AI: Low"; break;
        case AI_LEVEL_NORMAL :  sMsg = "AI: Normal"; break;
        case AI_LEVEL_HIGH :  sMsg = "AI: High"; break;
        case AI_LEVEL_VERY_HIGH :  sMsg = "AI: Very high"; break;
        case AI_LEVEL_INVALID : sMsg = "AI: Invalid"; break;
    }

    SpeakString(sMsg);

    object oActive = MeGetActiveMeme();
    _PrintString("Active meme is " + _GetName(oActive), DEBUG_COREAI);
    SpeakString("Active meme is " + _GetName(oActive));
    SpeakString("Current action is " + IntToString(GetCurrentAction(OBJECT_SELF)));

    if (oActive == OBJECT_INVALID)
    {
        _PrintString("No active memes. Restarting system.", DEBUG_COREAI);
        MeRestartSystem();
    }
    else if (GetCurrentAction(OBJECT_SELF) == ACTION_INVALID)
    {
        _PrintString("Stopping meme. Restarting system.", DEBUG_COREAI);
        MeRestartSystem();
    }

    _End();
}

void g_restart_per()
{
    _Start("Perceive class='"+MEME_CALLED+"'", DEBUG_COREAI);

    string sMsg;
    int nAI = GetAILevel(OBJECT_SELF);
    switch (nAI)
    {
        case AI_LEVEL_VERY_LOW : sMsg = "AI: Very low"; break;
        case AI_LEVEL_LOW :  sMsg = "AI: Low"; break;
        case AI_LEVEL_NORMAL :  sMsg = "AI: Normal"; break;
        case AI_LEVEL_HIGH :  sMsg = "AI: High"; break;
        case AI_LEVEL_VERY_HIGH :  sMsg = "AI: Very high"; break;
        case AI_LEVEL_INVALID : sMsg = "AI: Invalid"; break;
    }

    SpeakString("Current " + sMsg);

    object oActive = MeGetActiveMeme();
    _PrintString("Active meme is " + _GetName(oActive), DEBUG_COREAI);
    SpeakString("Active meme is " + _GetName(oActive));
    SpeakString("Current action is " + IntToString(GetCurrentAction(OBJECT_SELF)));

    if (oActive == OBJECT_INVALID)
    {
        _PrintString("No active memes. Restarting system.", DEBUG_COREAI);
        MeRestartSystem();
    }
    else if (GetCurrentAction(OBJECT_SELF) == ACTION_INVALID)
    {
        _PrintString("Stopping meme. Restarting system.", DEBUG_COREAI);
        MeRestartSystem();
    }

    _End();
}

// Main: Register Functions & Dispatch -----------------------------------------

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    // Register classes and functions
    if (MEME_DECLARE_LIBRARY)
    {
        // Class Declarations
        MeRegisterClass("generic");
        MeLibraryImplements("c_generic",    "_ini", 0x0100+0xff);
        MeLibraryImplements("c_generic",    "_go",  0x0100+0x01);

        // Meme Declarations
        MeLibraryImplements("i_idle",       "_go",  0x0200);
        MeLibraryImplements("i_spawn",      "_end", 0x0300);

        // Generator Declarations
        MeLibraryImplements("g_restart_HB", "_hbt", 0x0400+0x0f);
        MeLibraryImplements("g_restart",    "_per", 0x0500+0x0d);

        // Event Declarations
        MeLibraryImplements("e_setai",      "_ini", 0x0600+0xff);
        MeLibraryImplements("e_setai",      "_go",  0x0600+0x01);

        // Function Declarations
        MeLibraryFunction("f_do_nothing",           0x0700);
        MeLibraryFunction("f_say_hello",            0x0800);
        MeLibraryFunction("f_wander",               0x0900);
        MeLibraryFunction("f_random_walk",          0x0a00);

        // Respond
        MeLibraryImplements("e_respond",    "_ini", 0x0b00+0xff);
        MeLibraryImplements("e_respond",    "_go",  0x0b00+0x01);
        MeLibraryImplements("i_respond",    "_go",  0x0c00);

        MeLibraryFunction("f_end_response",         0x0d00);

        _End();
        return;
    }

    // Dispatch to the function
    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_generic_ini(); break;
            case 0x01: c_generic_go(); break;
        } break;

        case 0x0200: i_idle_go(); break;
        case 0x0300: i_spawn_end(); break;

        case 0x0400: g_restart_HB_hbt(); break;
        case 0x0500: g_restart_per(); break;

        case 0x0600: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: e_setai_ini(); break;
            case 0x01: e_setai_go(); break;
        } break;

        case 0x0700: MeSetResult(f_do_nothing(MEME_ARGUMENT)); break;
        case 0x0800: MeSetResult(f_say_hello(MEME_ARGUMENT)); break;
        case 0x0900: MeSetResult(f_wander(MEME_ARGUMENT)); break;
        case 0x0a00: MeSetResult(f_random_walk(MEME_ARGUMENT)); break;

        case 0x0b00: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: e_respond_ini(); break;
            case 0x01: e_respond_go(); break;
        } break;

        case 0x0c00: i_respond_go(); break;

        case 0x0d00: MeSetResult(f_end_response(MEME_ARGUMENT)); break;
    }
    _End();
}
