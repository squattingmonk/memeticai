#include "h_ai"

void main()
{
    _Start("Spawn name = '"+_GetName(OBJECT_SELF)+"'", DEBUG_USERAI);

    object NPC_SELF = MeInit();

    string sClass = MeGetConfString(OBJECT_SELF, "MT Class");
    if (sClass != "") MeInstanceOf(NPC_SELF, sClass);

    ExecuteScript("s_"+GetTag(OBJECT_SELF), OBJECT_SELF);

    _End();
}
