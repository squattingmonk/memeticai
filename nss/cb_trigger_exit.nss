#include "h_ai"

void main()
{
    _Start("Trigger event='Exit'", DEBUG_COREAI);

    object oExit = GetExitingObject();
    string sTag = GetTag(OBJECT_SELF);

    MeExecuteScript(sTag, "_ext", oExit);

    _End();
}
