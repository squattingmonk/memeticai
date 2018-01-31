#include "h_ai"

void main()
{
    _Start("OnSpawn name = '" + _GetName(OBJECT_SELF) + "'");

    NPC_SELF = MeInit();

    MeInstanceOf(NPC_SELF, "generic, combat_fighter, bartender");

    // setup for f_chatter()
    MeAddStringRef(NPC_SELF, "Can I get ya a brew?", "Talk Table");
    MeAddStringRef(NPC_SELF, "So, what can I get ya?", "Talk Table");
    MeSetLocalString(NPC_SELF, "TalkTable", "Talk Table");

    // setup for Idle response table
    MeAddResponse(NPC_SELF, "Response Table", "f_idle_animations", 40, RESPONSE_HIGH);
    MeAddResponse(NPC_SELF, "Response Table", "f_chatter", 40, RESPONSE_HIGH);
    MeAddResponse(NPC_SELF, "Response Table", "f_walk_waypoints", 40, RESPONSE_HIGH);
    MeAddResponse(NPC_SELF, "Response Table", "f_say_hello", 40, RESPONSE_HIGH);
    MeAddResponse(NPC_SELF, "Response Table", "f_do_nothing", 100, RESPONSE_END);
    MeSetActiveResponseTable("Idle", "Response Table", "");

    MeUpdateActions();

    _End();
}
