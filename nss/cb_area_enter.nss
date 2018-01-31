#include "h_event"

/*  Script:  Enter Area Callback
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
    object oEnter = GetEnteringObject();
    _Start("OnAreaEnter object='" + _GetName(oEnter) + "'", DEBUG_TOOLKIT);

    int iPlayerCount = GetLocalInt(OBJECT_SELF, "AreaPlayerCount");
    struct message stMsg;

    // If this is the first DM or PC to enter this area, notify the NPCs to
    // have the option of livening up.
    if (GetIsPC(oEnter) == TRUE && GetIsDM(oEnter) == FALSE)
    {
        if (iPlayerCount == 0)
        {
            stMsg.sMessageName = "Area/Enter/First PC";
            stMsg.oData = oEnter;
            // This sends a broadcast message on the channel named after this area.
            MeBroadcastMessage(stMsg, "AI_" + GetTag(OBJECT_SELF), TRUE);
        }
        SetLocalInt(OBJECT_SELF, "AreaPlayerCount", iPlayerCount+1);
    }
    // Notify NPCs they've just entered an area so they can (optionally)
    // subscribe to this area's messages. NPCs do this to receive information
    // that is local to this area, including when PCs first enter or all leave
    // an area.
    else
    {
        if (MeGetNPCSelf(oEnter) == OBJECT_INVALID)
        {
            _PrintString(_GetName(oEnter) + " spawning into area.", DEBUG_COREAI);
            _End();
            return;
        }
        else
            _PrintString(_GetName(oEnter) + " is not spawning, just entering.", DEBUG_COREAI);

        stMsg.sMessageName = "Area/Enter/Self";
        stMsg.oData = OBJECT_SELF;
        MeSendMessage(stMsg, "", oEnter, OBJECT_SELF, TRUE);
    }

    // Run any area-specific generators
    string sTag = GetTag(OBJECT_SELF);
    MeExecuteScript(sTag, "_ent");

    _End();
}
