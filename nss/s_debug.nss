#include "h_ai"
#include "h_response"

void main()
{
    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    MeStartDebugging(DEBUG_USERAI, TRUE);
    //MeAddDebugObject();

    NPC_SELF = MeInit();
    MeInstanceOf(NPC_SELF, "generic, debug_npc");

    // Add a local response table.
    MeAddResponse(NPC_SELF, "My Table", "f_debug_mark", 100, RESPONSE_END);
    MeSetActiveResponseTable("Idle", "My Table", "");

    MeSetLocalInt(NPC_SELF, "Repeat", TRUE);
    MeSetLocalInt(NPC_SELF, "NoPrefix", TRUE);
    MeSetLocalString(NPC_SELF, "Tag", "TEST");
    MeSetLocalFloat(NPC_SELF, "Delay", 15.0);

    MeUpdateActions();

    _End();
}
