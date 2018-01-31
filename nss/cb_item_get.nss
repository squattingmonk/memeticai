#include "h_ai"

void main()
{
    object oItem = GetItemActivated();
    string sTag = GetTag(oItem);
    MeExecuteScript(sTag, "_get", OBJECT_SELF, oItem);
}
