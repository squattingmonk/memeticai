#include "h_ai"

void main()
{
    _Start("Trigger event='Clicked'", DEBUG_COREAI);

    object oClick = GetClickingObject();
    string sTag = GetTag(OBJECT_SELF);

    MeExecuteScript(sTag, "_clk", oClick);

    _End();
}
