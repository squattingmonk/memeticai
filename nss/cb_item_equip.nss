#include "h_ai"
#include "h_util_combat"
#include "h_item"

void main()
{
    _Start("EquipItem", DEBUG_TOOLKIT);

    object oItem = GetPCItemLastEquipped();
    object oPC = GetPCItemLastEquippedBy();
    string sTag = GetTag(oItem);
    string sBaseTag = GetBaseItemTag(oItem);

    _PrintString(_GetName(oPC) + " equips " + sTag, DEBUG_TOOLKIT);
    MeExecuteScript(sTag, "_eqp", oPC, oItem);

    _PrintString(_GetName(oPC) + " equips a " + sBaseTag, DEBUG_TOOLKIT);
    MeExecuteScript(sBaseTag, "_eqp", oPC, oItem);

    if (GetIsWeapon(oItem) == TRUE)
    {
        struct message stMsg = MeCreateMessage("Weapon/Equipped", "", 0, 0.0, oPC);
        MeBroadcastMessage(stMsg, "CityLimits");  // Area tag, or use Silent Shout/Talk instead...
    }

    _End();
}
