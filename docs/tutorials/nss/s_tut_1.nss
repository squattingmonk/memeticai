#include "h_ai"

void main()
{
    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    NPC_SELF = MeInit();
    MeInstanceOf(NPC_SELF, "generic, townfolk, defender, guard");

    // Create a new Response Table
    MeAddResponse(NPC_SELF, "My Table", "f_bored", 100, RESPONSE_END);

    // Set the new Response Table as the "Idle" table
    MeSetActiveResponseTable("Idle", "My Table", "");

    MeUpdateActions();

    _End();
}
