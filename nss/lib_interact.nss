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
*    Library:  lib_interact
* Created By:  Lomin Isilmelind
*       Date:  10/31/2003
*Last Update:  08/30/2004 by Lomin Isilmelind
*    Purpose:  This library contains the interaction protocol
*-----------------------------------------------------------------------------*/
// -- Required includes: -------------------------------------------------------
#include "h_library"
#include "h_interact"
// -- Implementation -----------------------------------------------------------

// -- Prototypes ---------------------------------------------------------------

const int DEBUG_INTERACT = 0x40;

// This is the event, which controls all interaction behaviour
void e_interact_go();
// This functions handles the response
void ia_conditional_default();
// This function executes the creation of the requested meme
void ia_execute();
// This function handles the request
void ia_response();


/*------------------------------------------------------------------------------
* This event represents a protocol for negotiating interaction. It compares the
* priority of the active meme on OBJECT_SELF with the priority at which the
* requested meme should run. This information is specified in the recieved
* message. If the attached meme has higher priority than the active meme,
* f_request() sends a message with an affirmation back to the sender, otherwise
* the message will be interpreted as a denial.
* To start a request, create a message, name it "Request", provide a
* function, that should be triggered when recieving an response to that request
* and that may send an "Execute" message. Additionaly, specifiy the priority,
* at which the meme should be run and attach the meme to the message.
*-----------------------------------------------------------------------------*/
void e_interact_ini()
{
    _Start("e_interact_ini", DEBUG_INTERACT);

        MeSubscribeMessage(MEME_SELF, CONDITIONAL);
        MeSubscribeMessage(MEME_SELF, DENIAL);
        MeSubscribeMessage(MEME_SELF, EXECUTE);
        MeSubscribeMessage(MEME_SELF, RESPONSE);

    _End();
}

void e_interact_go()
{
    _Start("e_interact_go", DEBUG_INTERACT);

    struct message scMessage = MeGetLastMessage();
    string sFunction = scMessage.sMessageName;
    string sRequest = scMessage.sData;

    _PrintString("Calling function " + sFunction);

    MeCallFunction(IaGetFunction(scMessage.oData, sFunction, sRequest));

    _End();
}

void ia_response_default()
{
    _Start("ia_response_default", DEBUG_INTERACT);

    struct message scMessage = MeGetLastMessage();
    string sRequest = scMessage.sData;
    object oActiveMeme = MeGetActiveMeme();
    int iPriority = IaGetPriority(scMessage.oData, sRequest);
    int iModifier = IaGetModifier(scMessage.oData, sRequest);
    int iRequestValue = iPriority * 1000 + iModifier;
    int iCurrentState = MeGetPriority(oActiveMeme) * 1000 + MeGetModifier(oActiveMeme);
    _PrintString("comparing request value = " + IntToString(iRequestValue) +
                 " with value of current state = " + IntToString(iCurrentState));

    if (iRequestValue > iCurrentState)
    {
        scMessage.iData = TRUE;
        _PrintString("Request accepted. The request is more important than my current behaviour.");
    }
    else
    {
        scMessage.iData = FALSE;
        _PrintString("Request denied. My current behaviour is more important than the request.");
    }
    object oTarget = scMessage.oSender;
    scMessage.sMessageName = CONDITIONAL;
    MeSendMessage(scMessage, "", oTarget);

    _End();
}

void ia_conditional_default()
{
    _Start("ia_conditional_default", DEBUG_INTERACT);

    struct message scMessage = MeGetLastMessage();
    string sRequest = scMessage.sData;

    if (scMessage.iData == TRUE)
    {
        object oActiveMeme = MeGetActiveMeme();
        int iPriority = IaGetPriority(scMessage.oData, sRequest);
        int iModifier = IaGetModifier(scMessage.oData, sRequest);
        int iRequestValue = iPriority * 1000 + iModifier;
        int iCurrentState = MeGetPriority(oActiveMeme) * 1000 + MeGetModifier(oActiveMeme);
        _PrintString("comparing request value = " + IntToString(iRequestValue) +
                 " with value of current state = " + IntToString(iCurrentState));
        if (iRequestValue > iCurrentState)
        {
            scMessage.sMessageName = EXECUTE;
            MeSendMessage(scMessage, "", scMessage.oSender);
            MeSendMessage(scMessage, "", OBJECT_SELF);
        }
    }
    else
    {
        string sDenial = IaGetFunction(scMessage.oData, DENIAL, sRequest);
        if (sDenial != "")
        {
            scMessage.sMessageName = DENIAL;
            MeSendMessage(scMessage, "", scMessage.oSender);
            MeSendMessage(scMessage, "", OBJECT_SELF);
        }
    }

    _End();
}

void ia_execute_default()
{
    _Start("ia_execute", DEBUG_INTERACT);

    struct message scMessage = MeGetLastMessage();
    string sRequest = scMessage.sData;
    object oSave = scMessage.oData;
    string sMeme = IaGetMemeName(oSave, sRequest);
    int iPriority = IaGetPriority(oSave, sRequest);
    int iModifier = IaGetModifier(oSave, sRequest);
    int iFlag = IaGetMemeFlag(oSave, sRequest);

    object oMeme = MeGetMeme(sMeme, 0, PRIO_NONE); // looking for dormant memes
    // Create or reactivate
    if (oMeme == OBJECT_INVALID)
    {
        oMeme = MeCreateMeme(sMeme, iPriority, iModifier, iFlag);
    }
    else
    {
        MeSetPriority(oMeme, iPriority, iModifier);
        MeSetMemeFlag(oMeme, iFlag);
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
            MeLibraryImplements("e_interact",    "_ini",    0x0100+0xff);
            MeLibraryImplements("e_interact",    "_go",     0x0100+0x01);

            MeLibraryFunction("ia_conditional_default",  0x0200);
            MeLibraryFunction("ia_execute_default",      0x0300);
            MeLibraryFunction("ia_response_default",     0x0400);

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
                case 0xff: e_interact_ini();    break;
                case 0x01: e_interact_go();     break;
            }
            break;
            case 0x0200:    ia_conditional_default();  break;
            case 0x0300:    ia_execute_default();      break;
            case 0x0400:    ia_response_default();     break;

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
