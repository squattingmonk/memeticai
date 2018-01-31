#include "h_ai" 
void main()
{
    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    NPC_SELF = MeInit();
    MeInstanceOf(NPC_SELF, "generic, townfolk, defender, guard");

    MeAddStringRef(NPC_SELF, "I'm memetic!", "My Talk Table");
    MeAddStringRef(NPC_SELF, "Isn't this fun?", "My Talk Table");
    MeAddStringRef(NPC_SELF, "Wheee!", "My Talk Table");

    MeSetLocalString(NPC_SELF, "TalkTable", "My Talk Table");

    MeAddResponse(NPC_SELF, "My Table", "f_bored", 100, RESPONSE_END);
    MeAddResponse(NPC_SELF, "My Table", "f_chatter", 90, RESPONSE_HIGH);
    MeAddResponse(NPC_SELF, "My Table", "f_wander", 90, RESPONSE_MEDIUM);

    MeSetActiveResponseTable("Idle", "My Table", "");

    MeUpdateActions();
    _End();
}
