#include "h_ai"

void main()
{
    _Start("Trigger timing='Enter'", DEBUG_COREAI);

    object oEnter = GetEnteringObject();
    string sTag = GetTag(OBJECT_SELF);

    MeExecuteScript(sTag, "_ent", oEnter);

    _End();
}
