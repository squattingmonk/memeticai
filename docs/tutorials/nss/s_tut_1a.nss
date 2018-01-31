#include "h_ai" 

void main()
{
    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    NPC_SELF = MeInit();
    MeInstanceOf(NPC_SELF, "generic, townfolk, defender, guard");

    // Create a new Response Table and add some repsonses
    MeAddResponse(NPC_SELF, "My Table", "f_do_nothing", 100, RESPONSE_END);
    MeAddResponse(NPC_SELF, "My Table", "f_bored", 90, RESPONSE_HIGH);
    MeAddResponse(NPC_SELF, "My Table", "f_wander", 90, RESPONSE_MEDIUM);

    // Set the new Response Table as the "Idle" table
    MeSetActiveResponseTable("Idle", "My Table", "");

    MeUpdateActions();
    _End();
}