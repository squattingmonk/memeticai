#include "h_ai"

void main()
{
    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    NPC_SELF = MeInit();
    MeInstanceOf(NPC_SELF, "generic");

    object oArea = GetObjectByTag("chasm");
    object oMeme = MeCreateMeme("i_gotoarea");
    SetLocalObject(oMeme, "Area", oArea);

    MeUpdateActions();

    _End("OnSpawn");
}
