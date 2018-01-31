#include "h_ai"

void main()
{
    _Start("Trigger event='Heartbeat'", DEBUG_COREAI);

    string sTag = GetTag(OBJECT_SELF);
    MeExecuteScript(sTag, "_hbt", OBJECT_SELF);

    _End();
}
