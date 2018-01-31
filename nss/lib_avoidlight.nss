/*------------------------------------------------------------------------------
 *  Avoid Light Library
 ------------------------------------------------------------------------------*/

#include "h_library"
#include "h_ai"
#include "h_event"

/*-----------------------------------------------------------------------------
 *    Meme:  e_avoidlight
 *  Author:  William Bull
 *    Date:  November, 2003
 * Purpose:  This is an event that looks for a valid enemy that's not dead and
 *           causes an attack meme to attack it. It's really just a sample, not
 *           to be considered perfect and reusable.
 -----------------------------------------------------------------------------
 -----------------------------------------------------------------------------*/

void e_avoidlight_ini()
{
    MeSubscribeMessage(MEME_SELF, "Light/Enter");
    MeSubscribeMessage(MEME_SELF, "Light/Leave");
}

void e_avoidlight_go()
{
    _Start("AvoidLightEventHandler");

    object oMeme    = GetLocalObject(MEME_SELF, "FleeMeme");

    // PoI Emitters send to the source object by via messages
    struct message stMsg = MeGetLastMessage();
    object oSource  = stMsg.oSender;
    _PrintString("Got a signal from "+_GetName(oSource));

    // Emitters send TRUE if you are entering the PoI area
    if (stMsg.sMessageName == "Light/Enter")
    {
        _PrintString("I'm in the light!");
        // We don't need to create two flee memes
        if (!GetIsObjectValid(oMeme))
        {
            // Let's create a meme that makes us run away from the source of the light signal
            oMeme = MeCreateMeme("i_flee", PRIO_VERYHIGH, 0, MEME_RESUME, OBJECT_SELF);
            SetLocalObject(MEME_SELF, "FleeMeme", oMeme);
            MeAddStringRef(oMeme, "eek light!");
            SetLocalObject(oMeme, "Target", oSource);
            SetLocalFloat (oMeme, "Range", 20.0);
            SetLocalInt   (oMeme, "Run", 1);
        }
        else
        {
            SetLocalObject(oMeme, "Target", oSource);
            MeSetPriority(oMeme, PRIO_VERYHIGH, 0);
        }
    }
    // Emitters send FALSE if you are exiting the PoI area
    else
    {
        _PrintString("I've left light!");
        //if (GetIsObjectValid(oMeme)) MeSetPriority(oMeme, PRIO_NONE);
    }

    // When an event or other memetic object makes a (potentially) higher priority
    // meme it needs to call MeUpdateActions() to make sure it preempts existing
    // behaviors. This is done automatically at the end of any generators ... but
    // event and meme code must do this manually:
    MeUpdateActions();

    _End("AvoidLightEventHandler");
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

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("e_avoidlight",  "_go",      0x0100+0x01);
        MeLibraryImplements("e_avoidlight",  "_ini",     0x0100+0xff);

        //MeLibraryImplements("<name>",        "_go",     0x??00+0x01);
        //MeLibraryImplements("<name>",        "_ini",    0x??00+0xff);

        _End();
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
            case 0x01: e_avoidlight_go();   break;
            case 0xff: e_avoidlight_ini();  break;
        }   break;
    }

    _End();
}
