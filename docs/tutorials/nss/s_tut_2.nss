#include "h_ai" 
void main()
{

    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    NPC_SELF = MeInit();
    MeInstanceOf(NPC_SELF, "generic, townfolk, defender, guard");

    // Set up the response table to chat whenever idle
    MeAddResponse(NPC_SELF, "My Table", "f_chatter", 100, RESPONSE_END);
    MeSetActiveResponseTable("Idle", "My Table", "");

    MeAddStringRef(NPC_SELF, "I'm memetic!", "My Talk Table");
    MeAddStringRef(NPC_SELF, "Isn't this fun?", "My Talk Table");
    MeAddStringRef(NPC_SELF, "Wheee!", "My Talk Table");

    MeSetLocalString(NPC_SELF, "TalkTable", "My Talk Table");

    MeUpdateActions();
    _End();
}