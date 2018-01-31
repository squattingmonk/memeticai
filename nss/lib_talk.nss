
/*------------------------------------------------------------------------------
*  Core Library of Memes
*
*  This is a library for movement behaviour.
*
*  At the end of this library you will find a main() function. This contains
*  the code that registers and runs the scripts in this library. Read the
*  instructions to add your own objects to this library or to a new library.
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*    Library:  lib_talk
* Created By:  Lomin Isilmelind
*       Date:  11/11/2003
*Last Update:  09/06/2004 by Lomin Isilmelind
*    Purpose:  NPC talk behaviour
*-----------------------------------------------------------------------------*/

// -- Required includes: -------------------------------------------------------

#include "h_talk"

// -- Implementation -----------------------------------------------------------

// -- Source -------------------------------------------------------------------

/*------------------------------------------------------------------------------
*       Meme: i_talk
* Created By: Lomin Isilmelind
*       Date: 12/22/2003
*Last Update: 09/06/2004 by Lomin Isilmelind
*    Purpose: Main talk meme
--------------------------------------------------------------------------------
int "Animation"         : The animation played while talking
int "Broadcast"         : Determines if the transfer string should be broadcasted
int "Go"                : Admits the NPC permission to speak
int "IgnoreInit"        : Ignores the "Init"-entry of a file
int "InterpretEnd"      : Stops interpreting file entries
int "KeepLine"          : At switching to other files, the line won't be reseted but will keep its value
int "Line"              : The current entry of a file. Starting at 0
int "Random"            : Assignes the NPC to interpret entries at random
int "Repeat"            : The
int "Transfer"          : Determines if the commands should be interpreted by the NPC or the converser
string "BreakString"      : The file which will be interpreted when the meme gets interupted
string "File"           : The current filename
string "Prefix"         : The prefix of a filename
string "ResumeString"     : The file which will be interpreted when the meme gets resumed
string "Suffix"         : The suffix of a file
string list <File>      : A list of entries is called file
string list "TalkTables": All files loaded by the NPC. Can be used for later cleanup
object "Converser"      : The current converser
------------------------------------------------------------------------------*/

void i_talk_ini()
{
    _Start("i_talk event='ini'", DEBUG_TALK);

    // Subscribing to the talk event
    string sID = GetLocalString(NPC_SELF, "TalkID");
    object oEvent = MeGetEvent("e_talk");
    if (oEvent == OBJECT_INVALID)
        oEvent = MeCreateEvent("e_talk");
    // Set an entry on oEvent
    SetLocalObject(oEvent, TALK + sID + "Meme", MEME_SELF);
    // Default values:
    SetLocalInt(MEME_SELF, "Animation", ANIMATION_LOOPING_LISTEN);
    SetLocalString(MEME_SELF, "BreakString", "2|lt_break_df|tE~");
    SetLocalString(MEME_SELF, "EndString", "2|lt_end_df|tE~");
    SetLocalString(MEME_SELF, "ConverserDied", "2|lt_cdied_df|~");

    _End();
}

void i_talk_go()
{
    int bWait = !GetLocalInt(MEME_SELF, "Go");
    object oConverser = GetLocalObject(MEME_SELF, "Converser");

    _Start("i_talk event='go' wait='" + IntToString(bWait) + "' converser='" + _GetName(oConverser) + "'", DEBUG_TALK);

    if (!GetIsObjectValid(oConverser))
    {
        // Converser has probably been killed (NPCs tend to stay valid...)
        TalkPart(TRUE, "ConverserDied");
    }
    else
        if (bWait)
            TalkWait(oConverser);
        else
        {
            ActionDoCommand(SetFacingPoint(GetPosition(oConverser)));
            // Interpret received messages first
            TalkInterpretString(GetLocalString(MEME_SELF, "Received"));
            // Interpret entry and define transfer
            TalkInterpret();
            // My speech is finnished, send my converser the signal to speak and additional information
            TalkMessageToConverser(oConverser);
            TalkMessageToAll();
            //Clean up
            TalkReset();
        }

    _End();
}

void i_talk_brk()
{
    _Start("i_talk event='brk'", DEBUG_TALK);

    TalkPart(TRUE, "BreakString");

    _End();
}

/*------------------------------------------------------------------------------
*       Meme:   e_talk
* Created By:   Lomin Isilmelind
*       Date:   12/23/2003
*Last Update:   09/02/2004 by Lomin Isilmelind
*    Purpose:   This event receives and processes incoming messages.
                It grants and refuses permission to talk.
--------------------------------------------------------------------------------
On oMeme:
            int "Go"            : Permission to speak
            string "Received"   : The string received from the converser
On NPC_SELF:
            "TalkID"            : The current ID
------------------------------------------------------------------------------*/

void e_talk_ini()
{
    _Start("e_talk event='ini'", DEBUG_TALK);

    string sID = GetLocalString(NPC_SELF, "TalkID");
    string sTalkSubscribe = TALK + sID;
    MeSubscribeMessage(MEME_SELF, sTalkSubscribe, sTalkSubscribe);

    _End();
}

void e_talk_go()
{
    struct message scMessage = MeGetLastMessage();

    _Start("e_talk event='go' signal='" + IntToString(scMessage.iData) + "'", DEBUG_TALK);

    _PrintString("Received: name='" + scMessage.sMessageName + "' sData='" + scMessage.sData + "'");
    // scMessage.sMessagename : TALK_ + <ID>
    object oMeme = GetLocalObject(MEME_SELF, scMessage.sMessageName + "Meme");
    switch (scMessage.iData)
    {
        case TALK_BROADCAST: // to avoid interpreting of own broadcast messages:
            if (scMessage.oSender != OBJECT_SELF)
                SetLocalString(oMeme, "Received", GetLocalString(oMeme, "Received") + scMessage.sData);
            break;
        case TALK_GO    :   SetLocalString(oMeme, "Received", GetLocalString(oMeme, "Received") + scMessage.sData);
                            SetLocalInt(oMeme, "Go", TRUE);
                            break;
        case TALK_WAIT  :   DeleteLocalInt(oMeme, "Go");
                            break;
        case TALK_PART  :   DeleteLocalObject(MEME_SELF, scMessage.sMessageName + "Meme");
                            MeUnsubscribeMessage(MEME_SELF, scMessage.sMessageName, scMessage.sMessageName);
                            break;
    }

    _End();
}

/*------------------------------------------------------------------------------
*       Meme: ia_talk_execute
* Created By: Lomin Isilmelind
*       Date: 01/24/2004
*Last Update: 09/02/2004 by Lomin Isilmelind
*    Purpose: Execute function for interaction
              This function sets required variables on the returned meme
--------------------------------------------------------------------------------
On oMeme:
            int     "Go"        : Permission to speak
            object  "Converser" : The object to talk with
            string  "File"      : The talk table
            string  "TalkID"    : The specific ID of the meme

On NPC_SELF:
            string "TalkID"     : The ID of the current talk meme
------------------------------------------------------------------------------*/

void ia_talk_execute()
{
    _Start("f_talk_execute", DEBUG_TALK);

    struct message scMessage = MeGetLastMessage();
    string sRequest = scMessage.sData;
    // Save ID for e_talk_ini message and channel subscription
    SetLocalString(NPC_SELF, "TalkID", sRequest);
    int iPriority = IaGetPriority(scMessage.oData, sRequest);
    int iModifier = IaGetModifier(scMessage.oData, sRequest);
    int iFlag = MEME_RESUME | MEME_REPEAT;
    object oConverser;
    if (scMessage.oSender == OBJECT_SELF)
        oConverser = GetLocalObject(scMessage.oData, TALK + sRequest + "Converser");
    else
        oConverser = scMessage.oSender;
    object oSeq = MeCreateSequence("s_talk", iPriority, iModifier, SEQ_RESUME_FIRST);
    object oMeme = MeCreateSequenceMeme(oSeq, "i_move", PRIO_DEFAULT, 0, iFlag);
    SetLocalObject(oMeme, "Object", oConverser);
    oMeme = MeCreateSequenceMeme(oSeq, "i_talk", PRIO_DEFAULT, 0, iFlag);
    // Save ID to identify meme in e_talk
    SetLocalString(oMeme, "TalkID", sRequest);
    if (scMessage.oSender == OBJECT_SELF)
        SetLocalObject(oMeme, "Converser", oConverser);
    else
    {
        SetLocalString(oMeme, "File", "Greeting");
        SetLocalInt(oMeme, "Go", TRUE);
        SetLocalObject(oMeme, "Converser", scMessage.oSender);
        // Request completed. Deallocate memory used by interaction protocol
        IaCleanUp(scMessage.oData, sRequest);
    }
    MeStartSequence(oSeq);

    MeUpdateActions();

    _End();
}

/*------------------------------------------------------------------------------
*       Meme: g_talk
* Created By: Lomin Isilmelind
*       Date: 08/30/2004
*Last Update: 09/01/2004 by Lomin Isilmelind
*    Purpose: Talk to a NPC at visual perception
--------------------------------------------------------------------------------
On NPC_SELF:
            int "Modifier"
            + <Key>             : "i_talk" modifier
            int "Priority"
            + <Key>             : "i_talk" priority
            object "Converser"
            + TALK_
            + <Key>             : The current converser
            string CONDITIONAL
            + <Key>             : <Conditional function>
            string DENIAL
            + <Key>             : <Denial function>
            string EXECUTE
            + <Key>             : <Execute function>
            string RESPONSE
            + <Key>             : <Response function>
------------------------------------------------------------------------------*/
void g_talk_see()
{
    _Start("Generator name='talk' timing='See'", DEBUG_TALK);

    object oSeen = GetLastPerceived();
    if (!GetIsPC(oSeen))
    {
        struct message scMessage = IaCreateRequest(oSeen, NPC_SELF, "ia_response_default", "ia_conditional_default", "ia_talk_execute");
        IaSetPriority(scMessage.oData, scMessage.sData, PRIO_LOW);
        IaSetModifier(scMessage.oData, scMessage.sData, 50);
        SetLocalObject(scMessage.oData, TALK + scMessage.sData + "Converser", oSeen);
        MeSendMessage(scMessage, "", oSeen);
    }

    _End();
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
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    //  Step 1: Library Setup
    //
    //  This is run once to bind your scripts to a unique number.
    //  The number is composed of a top half - for the "class" and lower half
    //  for the specific "method". If you are adding your own scripts, copy
    //  the example, make sure to change the first number. Then edit the
    //  switch statement following this if statement.

    if (MEME_DECLARE_LIBRARY)
    {
            MeLibraryImplements("i_talk",       "_go",     0x0100+0x01);
            MeLibraryImplements("i_talk",       "_brk",    0x0100+0x02);
            MeLibraryImplements("i_talk",       "_ini",    0x0100+0xff);

            MeLibraryImplements("e_talk",       "_go",     0x0300+0x01);
            MeLibraryImplements("e_talk",       "_ini",    0x0300+0xff);

            MeLibraryImplements("g_talk",       "_see",    0x0400+0x01);

            MeLibraryFunction("ia_talk_execute",           0x0500+0x01);

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
        case 0x0100:    switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01:  i_talk_go();    break;
            case 0x02:  i_talk_brk();   break;
            case 0xff:  i_talk_ini();   break;
        }
        break;

        case 0x0300:    switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01:  e_talk_go();    break;
            case 0xff:  e_talk_ini();   break;
        }
        break;

        case 0x0400: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: g_talk_see();     break;
        }
        break;

        case 0x0500:    ia_talk_execute();   break;

            /*
            case 0x??00:    switch (MEME_ENTRYPOINT & 0x00ff)
            {
            case 0x01: <name>_go();     break;
            case 0x02: <name>_brk();    break;
            case 0x03: <name>_end();    break;
            case 0xff: <name>_ini();    break;
            }
            break;
            */
    }

    _End("Library");
}
