/*
 *       File: h_talk
 * Created By: Lomin Isilmelind
 *       Date: 12/15/2003
 *Last Update: 09/06/2004 by Lomin Isilmelind
 *
 *    Purpose: Functions for lib_talk
 */
// -- Required includes: -------------------------------------------------------
#include "h_interact"
#include "h_library"
#include "h_string"
// -- Implementation -----------------------------------------------------------

// -- Prototypes ---------------------------------------------------------------

// -- Debug --------------------------------------------------------------------
const int DEBUG_TALK = 0x400;
const int DEBUG_TALK_TOOLS = 0x800;
// -----------------------------------------------------------------------------

// -- General ------------------------------------------------------------------
const float TALK_DURATION  = 2.0;
const float TALK_SPEED     = 0.5;
// -----------------------------------------------------------------------------

// -- Messaging ----------------------------------------------------------------
const int TALK_WAIT         = 0;
const int TALK_GO           = 1;
const int TALK_BROADCAST    = 2;
const int TALK_PART         = 3;
const string TALK          = "Talk";
const string MAIN_SEPARATOR = "|";
const string SUB_SEPARATOR  = "+";
// -----------------------------------------------------------------------------

// TRUE-value for MeSetResult
object _TRUE = GetModule();

// Adds an entry to a file.
// If no file is given, the last file will be used.
void TalkAdd(string sAdd, string sFile = "");
// Deletes all local variables on oMeme
void TalkCleanUp(object oMeme);
// Executes a command specified by a single character and the remaining entry
void TalkCommand(string sEntry);
// Cycles trough the current file and interprets its entries
void TalkInterpret();
// Cycles through the current entry and interpret it
void TalkInterpretString(string sString);
// Broadcasts the talk message
void TalkMessageToAll();
// Sends the talk message to the current converser
void TalkMessageToConverser(object oConverser);
// Ends the talking
void TalkPart(int bSayGoodbye, string sVarName = "");
// Plays an animation for a certain time
void TalkPlayAnimation(float fModifier);
// Resets meme state
void TalkReset();
// Loads a talk table with the name sFile
void TalkTableLoad(string sFile);
// Initializes talktable
void TalkTableInit(string sFile = "" , string sParameter = "");
// Transfers a string to the current converser
void TalkTransfer(string sEntry);
// Faces the converser and plays a waiting animation
void TalkWait(object oConverser);

// -- Source -------------------------------------------------------------------

void TalkAdd(string sAdd, string sFile = "")
{
    object oMeme = MEME_ARGUMENT;
    // Helper variable "AddFile" to save the second parameter
    if (sFile != "")
        SetLocalString(oMeme, "AddFile", sFile);
    else
        sFile = GetLocalString(oMeme, "AddFile");

    _Start("TalkAdd sAdd='" + sAdd + "' sFile='" + sFile + "'", DEBUG_TALK_TOOLS);

    MeAddStringRef(oMeme, sAdd, sFile);

    _End();
}

void TalkCleanUp(object oMeme)
{

    DeleteLocalInt(oMeme, "Animation");
    DeleteLocalInt(oMeme, "Broadcast");
    DeleteLocalInt(oMeme, "Go");
    DeleteLocalInt(oMeme, "IgnoreInit");
    DeleteLocalInt(oMeme, "InterpretEnd");
    DeleteLocalInt(oMeme, "KeepLine");
    DeleteLocalInt(oMeme, "Line");
    DeleteLocalInt(oMeme, "Random");
    DeleteLocalInt(oMeme, "Repeat");
    DeleteLocalInt(oMeme, "TalkID");
    DeleteLocalInt(NPC_SELF, "TalkID");

    DeleteLocalObject(oMeme, "Converser");

    DeleteLocalString(oMeme, "BreakString");
    DeleteLocalString(oMeme, "EndString");
    DeleteLocalString(oMeme, "File");
    DeleteLocalString(oMeme, "Prefix");
    DeleteLocalString(oMeme, "ResumeString");
    DeleteLocalString(oMeme, "Suffix");
    DeleteLocalString(oMeme, "Transfer");

}

void TalkCommand(string sEntry)
{
    string sCommand = StringGetFirstChar(sEntry);
    _Start("TalkCommand Command='" + sCommand + "' Entry='" + StringDeleteFirstChar(sEntry) + "'", DEBUG_TALK_TOOLS);

    string sParameter = StringGetSegment(sEntry, 1);
    object oConverser = GetLocalObject(MEME_SELF, "Converser");
    if (GetLocalInt(MEME_SELF, "Transfer"))
    {
        if (sCommand == "~")
        {
            _PrintString("End = TRUE");
            SetLocalInt(MEME_SELF, "InterpretEnd", TRUE);
        }
        else
        if (sCommand == "T")
        {
             _PrintString("Transfer = FALSE");
            SetLocalInt(MEME_SELF, "Transfer", FALSE);
        }
        else
            TalkTransfer(sEntry);
    }
    else
    if (FindSubString("0123456789", sCommand) != -1)
    {
        float fModifier = StringToFloat(sCommand);
        ActionDoCommand(SpeakOneLinerConversation(sParameter, oConverser));
        TalkPlayAnimation(fModifier);
    }
    else
    if (sCommand == "@")
    {
        _PrintString("Converser = " + sParameter);
        SetLocalObject(MEME_SELF, "Converser", GetObjectByTag(sParameter));
    }
    else
    if (sCommand == "#")
    {
        _PrintString("File = " + sParameter);
        TalkTableLoad(sParameter);
    }
    else
    if (sCommand == "-")
    {
        _PrintString("BreakString = " + sParameter);
        SetLocalString(MEME_SELF, "BreakString", sParameter);
        SetLocalInt(MEME_SELF, "Line", GetLocalInt(MEME_SELF, "Line") + 1);
    }
    else
    if (sCommand == "_")
    {
        _PrintString("ResumeString = " + sParameter);
        SetLocalString(MEME_SELF, "ResumeString", sParameter);
        SetLocalInt(MEME_SELF, "Line", GetLocalInt(MEME_SELF, "Line") + 1);
    }
    else
    if (sCommand == "/")
    {
        _PrintString("EndString = " + sParameter);
        SetLocalString(MEME_SELF, "EndString", sParameter);
        SetLocalInt(MEME_SELF, "Line", GetLocalInt(MEME_SELF, "Line") + 1);
    }
    else
    if (sCommand == "?")
    {
        _PrintString("Random = TRUE");
        SetLocalInt(MEME_SELF, "Random", TRUE);
    }
    else
    if (sCommand == "!")
    {
        _PrintString("Random = FALSE");
        SetLocalInt(MEME_SELF, "Random", FALSE);
    }
    else
    if (sCommand == "~")
    {
        _PrintString("End = TRUE");
        SetLocalInt(MEME_SELF, "InterpretEnd", TRUE);
    }
    else
    if (sCommand == "$")
    {
        _PrintString("Animation = FORCEFUL");
        SetLocalInt(MEME_SELF, "Animation", ANIMATION_LOOPING_TALK_FORCEFUL);
    }
    else
    if (sCommand == "%")
    {
        _PrintString("Animation = LAUGHING");
        SetLocalInt(MEME_SELF, "Animation", ANIMATION_LOOPING_TALK_LAUGHING);
    }
    else
    if (sCommand == "&")
    {
        _PrintString("Animation = PLEADING");
        SetLocalInt(MEME_SELF, "Animation", ANIMATION_LOOPING_TALK_PLEADING);
    }
    else
    if (sCommand == "E")
    {
        _PrintString("Ending meme");
        TalkPart(TRUE);
    }
    else
    if (sCommand == "t")
    {
        _PrintString("Transfer = TRUE");
        SetLocalInt(MEME_SELF, "Transfer", TRUE);
    }
    else
    if (sCommand == "x")
    {
        _PrintString("Executing script = '" + sParameter + "'");
        object oResult = MeCallFunction(sParameter, MEME_SELF);
        if (oResult == OBJECT_INVALID)
            _PrintString("Function invalid or failed");
    }

    _End();
}

void TalkInterpret()
{
    _Start("TalkInterpret", DEBUG_TALK_TOOLS);

    string sEntry, sFile = GetLocalString(MEME_SELF, "File");
    int iLine = GetLocalInt(MEME_SELF, "Line");
    TalkTableLoad(sFile); // Initialize
    while (!GetLocalInt(MEME_SELF, "InterpretEnd")) // Cycle through entries
    {
        if (iLine > MeGetStringCount(MEME_SELF, sFile))
            if (GetLocalInt(MEME_SELF, "Repeat"))
                SetLocalInt(MEME_SELF, "Line", 0);
            else
                SetLocalInt(MEME_SELF, "InterpretEnd", TRUE);
        else
        {
            // Fetching the entry:
            if (GetLocalInt(MEME_SELF, "Random"))
                sEntry = MeGetStringByIndex(MEME_SELF, Random(MeGetStringCount(MEME_SELF, sFile)), sFile);
            else
                sEntry = MeGetStringByIndex(MEME_SELF, iLine, sFile);
            _PrintString("Entry = " + sEntry);
            TalkInterpretString(sEntry);// Interpreting the entry
            // Updating key variables:
            sFile = GetLocalString(MEME_SELF, "File");
            iLine = GetLocalInt(MEME_SELF, "Line");
            if (!GetLocalInt(MEME_SELF, "Random"))
                SetLocalInt(MEME_SELF, "Line", ++iLine); // Necessary for line access in the interpreter
        }
    }

    _End();
}

void TalkInterpretString(string sString)
{
    _Start("TalkInterpretString String='" + sString + "'", DEBUG_TALK_TOOLS);

    while (sString != "")
    {
        TalkCommand(sString);
        sString = StringDeleteFirstChar(sString);
        if (StringGetFirstChar(sString) == MAIN_SEPARATOR)
        {
            sString = StringDeleteFirstChar(sString);
            sString = StringDeleteSegment(sString, 0);
        }
    }

    _End();
}

void TalkMessageToAll()
{
    string sTransfer = GetLocalString(MEME_SELF, "Broadcast");
    if (sTransfer != "")
    {
        struct message scMessage;
        scMessage.sMessageName = TALK + GetLocalString(MEME_SELF, "TalkID");
        scMessage.iData = TALK_BROADCAST;
        scMessage.sData = sTransfer;
        // Send message after all actions are performed
        ActionDoCommand(MeBroadcastMessage(scMessage, scMessage.sMessageName));
    }
}

void TalkMessageToConverser(object oConverser)
{
    string sTransfer = GetLocalString(MEME_SELF, "Transfer");
    struct message scMessage;
    scMessage.sMessageName = TALK + GetLocalString(MEME_SELF, "TalkID");
    scMessage.iData = TALK_GO;
    scMessage.sData = sTransfer;
     // Send message after all actions are performed
    ActionDoCommand(MeSendMessage(scMessage, scMessage.sMessageName, oConverser));
}

void TalkPart(int bSayGoodbye, string sVarName = "")
{
    if (bSayGoodbye)
    {
        if (sVarName == "")
            sVarName = "EndString";
        TalkInterpretString(GetLocalString(MEME_SELF, sVarName));
    }
    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    struct message scMessage;
    scMessage.sMessageName = TALK + GetLocalString(MEME_SELF, "TalkID");
    scMessage.iData = TALK_PART;
    MeSendMessage(scMessage, scMessage.sMessageName, OBJECT_SELF);
    TalkCleanUp(MEME_SELF);
}

void TalkPlayAnimation(float fModifier)
{
    ActionPlayAnimation(GetLocalInt(MEME_SELF, "Animation"),
                        TALK_SPEED,
                        TALK_DURATION * fModifier);
}

void TalkReset()
{
    DeleteLocalInt(MEME_SELF, "Go");
    DeleteLocalInt(MEME_SELF, "InterpretEnd");
    DeleteLocalInt(MEME_SELF, "Random");
    DeleteLocalString(MEME_SELF, "Transfer");
    DeleteLocalString(MEME_SELF, "Received");
    DeleteLocalString(MEME_SELF, "Broadcast");
    SetLocalInt(MEME_SELF, "Animation", ANIMATION_LOOPING_LISTEN);
}

void TalkTableInit(string sFile, string sParameter = "")
{
    _Start("TalkTableInit sFile='" + sFile + "' sParameter='" + sParameter + "'", DEBUG_TALK_TOOLS);

    MeSetResult(_TRUE);
    object oMeme = MEME_ARGUMENT;
    // Helper variable "AddFile" to save the second parameter for TalkAdd
    SetLocalString(oMeme, "AddFile", sFile);
    if (sParameter != "")
        SetLocalString(oMeme, sFile + "Init", sParameter);

    _End();
}

void TalkTableLoad(string sFile)
{
    _Start("TalkTableLoad File='" + sFile + "'", DEBUG_TALK_TOOLS);

    SetLocalString(MEME_SELF, "File", sFile);
    // Prefix and suffix addition (Prefix+File+Suffix)
    string sPFS = GetLocalString(MEME_SELF, "Prefix")
                  + sFile
                  + GetLocalString(MEME_SELF, "Suffix");
    // If File is empty
    if (MeGetStringCount(MEME_SELF, sPFS) == 0)
    {
        object oResult = MeCallFunction("TalkTable_" + sPFS, MEME_SELF);
        if (oResult == OBJECT_INVALID)
        {
            _PrintString("Loading of " + sPFS + " failed");
            oResult = MeCallFunction("TalkTable_" + sFile, MEME_SELF);
            if (oResult == OBJECT_INVALID)
                _PrintString("Loading of " + sFile + " failed");
            else
                MeAddStringRef(MEME_SELF, sFile, "TalkTables"); // Remember loaded talk table for later clean up
        }
        else
        {
            MeAddStringRef(MEME_SELF, sPFS, "TalkTables"); // Remember loaded talk table for later clean up
            sFile = sPFS;
            SetLocalString(MEME_SELF, "File", sFile);
        }
    }
    if (!GetLocalInt(MEME_SELF, "IgnoreInit"))
    {
        _PrintString("Initialization of " + sFile);
        TalkInterpretString(GetLocalString(MEME_SELF, sFile + "Init"));
    }
    if (!GetLocalInt(MEME_SELF, "KeepLine"))
    {
        _PrintString("Line = '0'");
        SetLocalInt(MEME_SELF, "Line", 0);
    }
    _End();
}

string TalkTransfer(string sEntry)
{
    _Start("TalkTransfer TransferString='" + sEntry + "'", DEBUG_TALK_TOOLS);

    // Defines the transfer string and removes it from the entry
    string sTransfer = GetLocalString(MEME_SELF, "Transfer") + StringGetFirstChar(sEntry);
    sEntry = StringDeleteFirstChar(sEntry);
    if (StringGetFirstChar(sEntry) == MAIN_SEPARATOR)
    {
        sEntry = StringDeleteFirstChar(sEntry);
        sTransfer = sTransfer + MAIN_SEPARATOR + StringGetSegment(sEntry, 0) + MAIN_SEPARATOR;
        sEntry = StringDeleteSegment(sEntry, 0);
    }
    SetLocalString(MEME_SELF, "Transfer", sTransfer);

    _End();

    return sEntry;
}

void TalkWait(object oConverser)
{
    if (oConverser != OBJECT_INVALID)
        ActionDoCommand(SetFacingPoint(GetPosition(oConverser)));
    int iWaitingAnimation = Random(4);
    switch (iWaitingAnimation)
    {
        case 0: iWaitingAnimation = ANIMATION_LOOPING_LISTEN;       break;
        case 1: iWaitingAnimation = ANIMATION_LOOPING_PAUSE;        break;
        case 2: iWaitingAnimation = ANIMATION_LOOPING_PAUSE2;       break;
        case 3: iWaitingAnimation = ANIMATION_LOOPING_TALK_NORMAL;  break;
    }
    ActionPlayAnimation(iWaitingAnimation, 1.0, 3.0);
}
