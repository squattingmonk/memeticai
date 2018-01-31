#include "h_ai"

void main()
{
    _Start("UnequipItem", DEBUG_TOOLKIT);

    object oItem = GetPCItemLastUnequipped();
    object oPC = GetPCItemLastUnequippedBy();
    string sTag = GetTag(oItem);

    _PrintString(_GetName(oPC) + " unequips " + sTag, DEBUG_COREAI);
    MeExecuteScript(sTag, "_unq", oPC, oItem);

    _End();
}
