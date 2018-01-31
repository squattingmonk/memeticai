#include "h_event"

/*  Script:  Exit Area Callback
 *           Copyright (c) 2003 William Bull
 *    Info:  Notifies NPCs about things entering, leaving an area.
 *  Timing:  This should be attached to each area OnEnter callback.
 *  Author:  William Bull
 *    Date:  November, 2003
 *
 *   Notes:  This will eventually be loaded via Lucullo's modular bindings (DEH)
 *           library.
 */

void main()
{
    object oExit = GetExitingObject();
    _Start("OnAreaExit object='" + _GetName(oExit) + "'", DEBUG_TOOLKIT);

    int iPlayerCount = GetLocalInt(OBJECT_SELF, "AreaPlayerCount");
    struct message stMsg;

    // If this is the last DM or PC to exit this area, notify the NPCs to
    // have the option of going to sleep.
    if (GetIsPC(oExit) && GetIsDM(oExit) == FALSE)
    {
        SetLocalInt(OBJECT_SELF, "AreaPlayerCount", iPlayerCount-1);
        if (iPlayerCount == 1)
        {
            stMsg.sMessageName = "Area/Exit/Last PC";
            stMsg.oData = oExit;
            // This sends a broadcast message on the channel named after this area.
            MeBroadcastMessage(stMsg, "AI_" + GetTag(OBJECT_SELF), TRUE);
        }
    }
    // Notify NPCs they're just leaving an area so they can (optionally)
    // unsubscribe from this area's messages.
    else
    {
        stMsg.sMessageName = "Area/Exit/Self";
        stMsg.oData = OBJECT_SELF;
        MeSendMessage(stMsg, "", oExit, OBJECT_SELF, TRUE);
    }

    // Run any area-specific generators
    string sTag = GetTag(OBJECT_SELF);
    MeExecuteScript(sTag, "_ext");
    _End();
}
