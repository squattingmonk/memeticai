// Yraen's script really. Modified some things in it though, trying to speed it up
// Changed things like if statements to switches, tried (somewhat unsucessfully) to
// Add the magical staff (never equips it?) and the values are now much cleaner and
// better valued.
// Used as an include for OnSpawn, and for the disturbed executed file
// This will set the weapons of oTarget. SW is for Set Weapon, just in case
// any are included somewhere else.

/**** MAIN CALLS ****/
// Start of the whole thing...
void SetWeapons(object oTarget = OBJECT_INVALID);
// Goes through and sets a value and then a weopen to all weopen items
void SWSortInventory(object oTarget, int nSize = 0);
// This returns the size of oItem
int SWGetWeaponSize(object oItem = OBJECT_INVALID);

/**** SETTING ****/
// Ranged weopen is set - final one to use.
void SWSetRangedWeapon(object oTarget);
// Sets the primary weopen to use.
void SWSetPrimaryWeapon(object oTarget, object oItem = OBJECT_INVALID);
// Secondary weopen is set on self - final one that is used.
void SWSetSecondaryWeapon(object oTarget);
// sets the Two Handed Weopen to use.
void SWSetTwoHandedWeapon(object oTarget, object oItem = OBJECT_INVALID);
// Ammo counters are set, although I do not think they specifically are equipped.
// May remove...no idea.
void SWSetAmmoCounters(object oTarget, int nBase = 0);
// Sets the object shield to use.
void SWSetShield(object oTarget, object oItem = OBJECT_INVALID);

/**** STORING ****/
// Stores the ranged weopen - it also needs to check ammo before choosing one.
void SWStoreRangedWeapon(object oTarget, object oItem = OBJECT_INVALID);
// This adds the maximum damage onto the value
void SWBaseLargeWeapons(object oTarget, object oItem = OBJECT_INVALID, int nSize = 0);
// This adds the maximum damage onto the value.
void SWBaseMediumWeapons(object oTarget, object oItem = OBJECT_INVALID, int nSize = 0);
// This adds the maximum damage onto the value
void SWBaseSmallWeapons(object oTarget, object oItem = OBJECT_INVALID, int nSize = 0);
// This adds the maximum damage onto the value
void SWBaseTinyWeapons(object oTarget, object oItem = OBJECT_INVALID, int nSize = 0);
// This adds the effects onto the value
void SWBaseEffects(object oTarget, object oItem = OBJECT_INVALID, int nSize = 0, int nWSize = 0);
// This will take the weapon size, and things, and apply the right base effects.
void SWDoEffectsOf(object oTarget, object oItem, int nBase, int nWeaponSize, int nSize);

/*** OTHER ****/
// Erm...deletes the ints. Like wizard and so on.
void SWDeleteInts(object oTarget);
// This returns DW_STATE local int
int SWGetState(object oTarget);

int WEAPON_SIZE_INVALID = 0;
int WEAPON_SIZE_TINY    = 1;
int WEAPON_SIZE_SMALL   = 2;
int WEAPON_SIZE_MEDIUM  = 3;
int WEAPON_SIZE_LARGE   = 4;

//int CREATURE_SIZE_INVALID = 0;
//int CREATURE_SIZE_TINY =    1;
//int CREATURE_SIZE_SMALL =   2;
//int CREATURE_SIZE_MEDIUM =  3;
//int CREATURE_SIZE_LARGE =   4;
//int CREATURE_SIZE_HUGE =    5;

//::///////////////////////////////////////////////
//:: Name SetWeopens
//:://////////////////////////////////////////////
/*
  Main call - it starts the process of checking
  Inventory, and so on
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SetWeapons(object oTarget = OBJECT_INVALID)
{
    if(oTarget == OBJECT_INVALID)
        oTarget = OBJECT_SELF;
    // Gets the creature size, stores it...
    int nSize = GetCreatureSize(oTarget);
    // Ints. That are deleted above are stored again
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oTarget))
        SetLocalInt(oTarget, "DRUID", 1);
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oTarget))
        SetLocalInt(oTarget, "ELF", 1);
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oTarget))
        SetLocalInt(oTarget, "EXOTIC", 1);
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oTarget))
        SetLocalInt(oTarget, "MARTIAL", 1);
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oTarget))
        SetLocalInt(oTarget, "MONK", 1);
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oTarget))
        SetLocalInt(oTarget, "ROGUE", 1);
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oTarget))
        SetLocalInt(oTarget, "SIMPLE", 1);
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oTarget))
        SetLocalInt(oTarget, "WIZARD", 1);
    SetLocalInt(oTarget, "DW_PRIMARY", 0);
    SetLocalInt(oTarget, "DW_SECONDARY", 0);
    SetLocalInt(oTarget, "DW_TWO_HANDED", 0);
    SetLocalInt(oTarget, "DW_RANGED", 0);
    SetLocalInt(oTarget, "DW_SHIELD", 0);
    // Sorts the inventory, on oTarget, with nSize of creature
    SWSortInventory(oTarget, nSize);
}

//::///////////////////////////////////////////////
//:: Name SortInventory
//:://////////////////////////////////////////////
/*
  Right - Goes through all items in the inventory
  It, based in Weopen size and creature size,
  do base effects of it (value it), if a weopen
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWSortInventory(object oTarget, int nSize)
{
    int nBase, nWeaponSize, iCnt;
    object oItem;
    // Slots 4 and 5. (HTH weapons)
    for(iCnt = 4; iCnt < 6; iCnt++)
    {
        oItem  = GetItemInSlot(iCnt, oTarget);
        if(GetIsObjectValid(oItem))
        {
            nBase = GetBaseItemType(oItem);
            nWeaponSize = SWGetWeaponSize(oItem);
            SWDoEffectsOf(oTarget, oItem, nBase, nWeaponSize, nSize);
        }
    }
    // Slots 11, 12 and 13. (some ammo slots)
    for(iCnt = 11; iCnt < 14; iCnt++)
    {
        oItem  = GetItemInSlot(iCnt, oTarget);
        if(GetIsObjectValid(oItem))
        {
            nBase = GetBaseItemType(oItem);
            nWeaponSize = SWGetWeaponSize(oItem);
            SWDoEffectsOf(oTarget, oItem, nBase, nWeaponSize, nSize);
        }
    }
    oItem = GetFirstItemInInventory(oTarget);
    while(GetIsObjectValid(oItem))
    {
        // Added some else statements to speed it up
        nBase = GetBaseItemType(oItem);
        nWeaponSize = SWGetWeaponSize(oItem);
        if(nWeaponSize > 0)
        {
            // Do the appropriate enchantment issuse and so on.
            SWDoEffectsOf(oTarget, oItem, nBase, nWeaponSize, nSize);
        }
        oItem = GetNextItemInInventory(oTarget);
    }
    // If we want to...set a secondary weapon!
    if(GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oTarget) || GetHasFeat(FEAT_AMBIDEXTERITY, oTarget)
         || GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oTarget))
        SWSetSecondaryWeapon(oTarget);
    SWSetRangedWeapon(oTarget);
}

void SWDoEffectsOf(object oTarget, object oItem, int nBase, int nWeaponSize, int nSize)
{
    // Tiny weapons - If we are under large size, and is a dagger or similar
    if(nSize < 4 && nWeaponSize == 1)
    {   SWBaseEffects(oTarget, oItem, nSize, nWeaponSize);    }
    // Small Weapons - If we are large (not giant) and size is like a shortsword
    else if(nSize < 5 && nWeaponSize == 2)
    {   SWBaseEffects(oTarget, oItem, nSize, nWeaponSize);    }
    // Medium weapons - If we are over tiny, and size is like a longsword
    else if(nSize > 1 && nWeaponSize == 3)
    {   SWBaseEffects(oTarget, oItem, nSize, nWeaponSize);    }
    // Large weapons - anything that is over small, and the size is like a spear
    else if(nSize > 2 && nWeaponSize == 4)
    {   SWBaseEffects(oTarget, oItem, nSize, nWeaponSize);    }
    // ammo
    if(nBase == 20 || nBase == 25 || nBase == 27)
    {   SWSetAmmoCounters(oTarget, nBase);    }
}

//::///////////////////////////////////////////////
//:: Name BaseEffects
//:://////////////////////////////////////////////
/*
    Sets the value (+/- int) of the item
    Things like haste are worth more...
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWBaseEffects(object oTarget, object oItem, int nSize, int nWSize)
{
    // the weopen size of oItem...
    int nWeaponSize = nWSize;
    int iValue = 0;
    if(GetIsObjectValid(oItem))
    {
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ABILITY_BONUS))
            iValue += 9;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS))
            iValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP))
            iValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE))
            iValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP))
            iValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT))
            iValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS))
            iValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP))
            iValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP))
            iValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT))
            iValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION))
            iValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BONUS_FEAT))
            iValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N))
            iValue += 2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_CAST_SPELL))
            iValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS))
            iValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP))
            iValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP))
            iValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT))
            iValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_REDUCTION))
            iValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_RESISTANCE))
            iValue += 9;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_VULNERABILITY))
            iValue -= 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DARKVISION))
            iValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ABILITY_SCORE))
            iValue -= 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_AC))
            iValue -= 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER))
            iValue -= 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_DAMAGE))
            iValue -= 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER))
            iValue -= 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SAVING_THROWS))
            iValue -= 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC))
            iValue -= 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SKILL_MODIFIER))
            iValue -= 2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS))
            iValue += 7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP))
            iValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP))
            iValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT))
            iValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE))
            iValue += 1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE))
            iValue += 1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_FREEDOM_OF_MOVEMENT))
            iValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_HASTE))
            iValue += 12;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_HOLY_AVENGER))
            iValue += 10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE))
            iValue += 9;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS))
            iValue += 10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL))
            iValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL))
            iValue += 12;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMPROVED_EVASION))
            iValue += 10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_KEEN))
            iValue += 7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_LIGHT))
            iValue += 1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MASSIVE_CRITICALS))
            iValue += 2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MIGHTY))
            iValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MIND_BLANK))
            iValue += 4;// Do not think It exsists.
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MONSTER_DAMAGE))
            iValue += 1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_NO_DAMAGE))
            iValue -= 10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ON_HIT_PROPERTIES))
            iValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ON_MONSTER_HIT))
            iValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_POISON))
            iValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_REGENERATION))
            iValue += 9;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_REGENERATION_VAMPIRIC))
            iValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SAVING_THROW_BONUS))
            iValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC))
            iValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SKILL_BONUS))
            iValue += 2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SPELL_RESISTANCE))
            iValue += 7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_TRUE_SEEING))
            iValue += 11;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_TURN_RESISTANCE))
            iValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_UNLIMITED_AMMUNITION))
            iValue += 10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_VORPAL))
            iValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_WOUNDING))
            iValue += 8;
        SetLocalInt(oItem, "VALUE", iValue);
        switch (nWeaponSize)
        {
            case 0:// Invalid Size
                return;
            break;
            case 1:// Tiny weapons
            {   SWBaseTinyWeapons(oTarget, oItem, nSize);
                return;    }
            break;
            case 2:// Small Weapons
            {   SWBaseSmallWeapons(oTarget, oItem, nSize);
                return;    }
            break;
            case 3: // Medium weapons
            {   SWBaseMediumWeapons(oTarget, oItem, nSize);
                return;    }
            break;
            case 4: // Large Weapons
            {   SWBaseLargeWeapons(oTarget, oItem, nSize);
                return;    }
            break;
        }
    }
}

//::///////////////////////////////////////////////
//:: Name BaseLargeWeapons
//:://////////////////////////////////////////////
/*
    This adds the maximum damage onto the value
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWBaseLargeWeapons(object oTarget, object oItem, int nSize)
{
    int nDruid = GetLocalInt(oTarget, "DRUID");
    int nElf = GetLocalInt(oTarget, "ELF");
    int nExotic = GetLocalInt(oTarget, "EXOTIC");
    int nMartial = GetLocalInt(oTarget, "MARTIAL");
    int nMonk = GetLocalInt(oTarget, "MONK");
    int nRogue = GetLocalInt(oTarget, "ROGUE");
    int nSimple = GetLocalInt(oTarget, "SIMPLE");
    int nWizard = GetLocalInt(oTarget, "WIZARD");
    int iType = GetBaseItemType(oItem);
    // No need for weopen size...
    switch (iType)
    {
        case BASE_ITEM_DIREMACE:
        {
            if(nExotic == 1)
            {
                if(nSize >= 4)// If a very big creature - set as a primary weopen
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 16);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)// If a medium creature - set as a two-handed weopen
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 16);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_DOUBLEAXE:
        {
            if(nExotic == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 16);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 16);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_TWOBLADEDSWORD:
        {
            if(nExotic == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 16);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 16);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_GREATAXE:
        {
            if(nMartial == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 12);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 12);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_GREATSWORD:
        {
            if(nMartial == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 12);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 12);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HALBERD:
        {
            if(nMartial == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HEAVYFLAIL:
        {
            if(nMartial == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SCYTHE:
        {
            if(nExotic == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SHORTSPEAR:
        {
            if(nSimple == 1 || nDruid == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_QUARTERSTAFF:
        {
            if(nWizard == 1 || nSimple == 1 || nRogue == 1 || nMonk == 1 || nDruid == 1)
            {
                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_MAGICSTAFF:
        {
            if(nWizard == 1 || nSimple == 1 || nRogue == 1 || nMonk == 1 || nDruid == 1)
            {

                if(nSize >= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LONGBOW:
        {
            if(nSize >= 3 && (nMartial == 1 || nElf == 1))
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                SWStoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_TOWERSHIELD:
        {
            if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oTarget) && nSize >= 3)
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + GetItemACValue(oItem));
                SWSetShield(oTarget, oItem);
            }
        }
        break;
    }
}

//::///////////////////////////////////////////////
//:: Name BaseMediumWeapons
//:://////////////////////////////////////////////
/*
    Adds the damage to the value
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWBaseMediumWeapons(object oTarget, object oItem, int nSize)
{
    int nDruid = GetLocalInt(oTarget, "DRUID");
    int nElf = GetLocalInt(oTarget, "ELF");
    int nExotic = GetLocalInt(oTarget, "EXOTIC");
    int nMartial = GetLocalInt(oTarget, "MARTIAL");
    int nMonk = GetLocalInt(oTarget, "MONK");
    int nRogue = GetLocalInt(oTarget, "ROGUE");
    int nSimple = GetLocalInt(oTarget, "SIMPLE");
    int nWizard = GetLocalInt(oTarget, "WIZARD");
    int iType = GetBaseItemType(oItem);
    // No need for weopen size...
    switch (iType)
    {
        case BASE_ITEM_BASTARDSWORD:
        {
            if(nExotic == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_BATTLEAXE:
        {
            if(nMartial == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_CLUB:
        {
            if(nWizard == 1 || nSimple == 1 || nMonk == 1 || nDruid == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_KATANA:
        {
            if(nExotic == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTFLAIL:
        {
            if(nMartial == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LONGSWORD:
        {
            if(nMartial == 1 || nElf == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_MORNINGSTAR:
        {
            if(nSimple == 1 || nRogue == 1) // Primary only
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_RAPIER:
        {
            if(nRogue == 1 || nMartial == 1 || nElf == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SCIMITAR:
        {
            if(nMartial == 1 || nDruid == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_WARHAMMER:
        {
            if(nMartial == 1)
            {
                if(nSize >= 3)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 2)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HEAVYCROSSBOW:
        {
            if(nSize >=2 && (nWizard == 1 || nSimple == 1 || nRogue == 1 || nMonk == 1))
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 10);
                SWStoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SHORTBOW:
        {
            if(nSize >=2 && (nRogue == 1 || nMartial == 1 || nElf == 1))
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                SWStoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_LARGESHIELD:
        {
            if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oTarget) && nSize >= 2)
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + GetItemACValue(oItem));
                SWSetShield(oTarget, oItem);
            }
        }
        break;
    }
}

//::///////////////////////////////////////////////
//:: Name BaseSmallWeapons
//:://////////////////////////////////////////////
/*
    Adds the damage to the value...then sets it
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWBaseSmallWeapons(object oTarget, object oItem, int nSize)
{
    int nDruid = GetLocalInt(oTarget, "DRUID");
    int nElf = GetLocalInt(oTarget, "ELF");
    int nExotic = GetLocalInt(oTarget, "EXOTIC");
    int nMartial = GetLocalInt(oTarget, "MARTIAL");
    int nMonk = GetLocalInt(oTarget, "MONK");
    int nRogue = GetLocalInt(oTarget, "ROGUE");
    int nSimple = GetLocalInt(oTarget, "SIMPLE");
    int nWizard = GetLocalInt(oTarget, "WIZARD");
    int iType = GetBaseItemType(oItem);
    // No need for weopen size...
    switch (iType)
    {
        case BASE_ITEM_HANDAXE:
        {
            if(nMonk == 1 || nMartial == 1)
            {
                if(nSize >= 2 && nSize <= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 1)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_KAMA:
        {
            if(nMonk == 1 || nExotic == 1)
            {
                if(nSize >= 2 && nSize <= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 1)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTHAMMER:
        {
            if(nMartial == 1)
            {
                if(nSize >= 2 && nSize <= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 4);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 1)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 4);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTMACE:
        {
            if(nSimple == 1 || nRogue == 1)
            {
                if(nSize >= 2 && nSize <= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 1)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SHORTSWORD:
        {
            if(nRogue == 1 || nMartial == 1)
            {
                if(nSize >= 2 && nSize <= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 1)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SICKLE:
        {
            if(nSimple == 1 || nDruid == 1)
            {
                if(nSize >= 2 && nSize <= 4)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetPrimaryWeapon(oTarget, oItem);
                }
                else if(nSize == 1)
                {
                    SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                    SWSetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_DART:
        {
            // Ranged weapons below
            if(nSize <= 4 && (nSimple == 1 || nRogue == 1 || nDruid == 1))
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 4);
                SWStoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_LIGHTCROSSBOW:
        {
            if(nSize <= 4 && (nWizard == 1 || nSimple == 1 || nRogue == 1 || nMonk == 1))
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 8);
                SWStoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SLING:
        {
            if(nSize <= 4 && (nSimple == 1 || nMonk == 1 || nDruid == 1))
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 4);
                SWStoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_THROWINGAXE:
        {
            if(nSize <= 4 && nMartial == 1)
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 6);
                SWStoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SMALLSHIELD:
        {
            if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oTarget))
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + GetItemACValue(oItem));
                SWSetShield(oTarget, oItem);
            }
        }
        break;
    }
}

//::///////////////////////////////////////////////
//:: Name BaseTinyWeapons
//:://////////////////////////////////////////////
/*
    Adds damage to the value, and sets it.
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWBaseTinyWeapons(object oTarget, object oItem, int nSize)
{
    int nDruid = GetLocalInt(oTarget, "DRUID");
    int nElf = GetLocalInt(oTarget, "ELF");
    int nExotic = GetLocalInt(oTarget, "EXOTIC");
    int nMartial = GetLocalInt(oTarget, "MARTIAL");
    int nMonk = GetLocalInt(oTarget, "MONK");
    int nRogue = GetLocalInt(oTarget, "ROGUE");
    int nSimple = GetLocalInt(oTarget, "SIMPLE");
    int nWizard = GetLocalInt(oTarget, "WIZARD");
    int iType = GetBaseItemType(oItem);
    // No need for weopen size...
    switch (iType)
    {
        case BASE_ITEM_DAGGER:
        {
            if(nSize <= 3 && (nWizard == 1 || nSimple == 1 || nRogue == 1 ||
                    nMonk == 1 || nDruid == 1))
            {
                SetLocalInt(oItem, "VALUE", GetLocalInt(oItem, "VALUE") + 4);
                SWSetPrimaryWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_KUKRI:
        {
            if(nSize <= 3 && nExotic == 1)
            {
                SetLocalInt(oItem, "VALUE",  GetLocalInt(oItem, "VALUE") + 4);
                SWSetPrimaryWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SHURIKEN:
        {
            // Ranged weapons below
            if(nSize <= 3 && (nMonk == 1 || nExotic == 1))
            {
                SetLocalInt(oItem, "VALUE",  GetLocalInt(oItem, "VALUE") + 3);
                SWStoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
    }
}

// Then the item is stored, if the value if greater then previous weopens
//::///////////////////////////////////////////////
//:: Name SetPrimaryWeapon
//:://////////////////////////////////////////////
/*
    If the value of the object is greater than the
    stored one, set it.
    If the weopen is of lesser value, and can deul
    wield, then set it as a weopen that can be deul wielded.
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWSetPrimaryWeapon(object oTarget, object oItem)
{
    // If the value is greater than stored one, set the weopen as it...
    if(GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_PRIMARY"))
    {
        SetLocalInt(oTarget, "DW_PRIMARY", GetLocalInt(oItem, "VALUE"));
        SetLocalObject(oTarget, "DW_PRIMARY", oItem);
        // Of course, the weopen can be a deul one... (if it is removed by a later weopen...
        // ... it COULD be set as a secondary one instead...
        // Check and see if they have the ability to dual wield and store the object if they do
        if(GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oTarget) || GetHasFeat(FEAT_AMBIDEXTERITY, oTarget)
         || GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oTarget))
        {
            int nNth = GetLocalInt(oTarget, "DUAL");
            nNth++;
            string sNth = IntToString(nNth);
            SetLocalInt(oTarget, "DUAL", nNth);
            SetLocalObject(oTarget, "DUAL"+sNth, oItem);
        }
        else // Else, delete the un-useful int.
        {
            DeleteLocalInt(oItem, "VALUE");
        }
    }
    else
    {
    // Check and see if they have the ability to dual wield and store the object if they do
        if(GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oTarget) || GetHasFeat(FEAT_AMBIDEXTERITY, oTarget)
         || GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oTarget))
        {
            int nNth = GetLocalInt(oTarget, "DUAL");
            nNth++;
            string sNth = IntToString(nNth);
            SetLocalInt(oTarget, "DUAL", nNth);
            SetLocalObject(oTarget, "DUAL"+sNth, oItem);
        }
        else
        {
            DeleteLocalInt(oItem, "VALUE");
        }
    }
}

//::///////////////////////////////////////////////
//:: Name SetSecondaryWeapon
//:://////////////////////////////////////////////
/*
    Sets a secondary weopen
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWSetSecondaryWeapon(object oTarget)
{
    int nNth = 1;
    string sNth = IntToString(nNth);
    object oPrimary = GetLocalObject(oTarget, "DW_PRIMARY");
    object oItem = GetLocalObject(oTarget, "DUAL"+sNth);

    while(GetIsObjectValid(oItem))
    {
        int nBase = GetBaseItemType(oItem);
        int nWeaponSize = SWGetWeaponSize(oItem);
        // If a large weopen
        if(nWeaponSize == 4)
        {   // 58 = Shortspear
            if(nBase == 58 && GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_SECONDARY") && oPrimary != oItem)
            {
                SetLocalInt(oTarget, "DW_SECONDARY", GetLocalInt(oItem, "VALUE"));
                SetLocalObject(oTarget, "DW_SECONDARY", oItem);
                DeleteLocalInt(oItem, "VALUE");
            }
            else
            {
                DeleteLocalInt(oItem, "VALUE");
            }
        }
        else
        {   // 4 = Light flail, 47 = Morningstar
            if(nBase != 4 && nBase != 47 && GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_SECONDARY") && oPrimary != oItem)
            {
                SetLocalInt(oTarget, "DW_SECONDARY", GetLocalInt(oItem, "VALUE"));
                SetLocalObject(oTarget, "DW_SECONDARY", oItem);
                DeleteLocalInt(oItem, "VALUE");
            }
            else
            {
                DeleteLocalInt(oItem, "VALUE");
            }
        }
        DeleteLocalObject(oTarget, "DUAL"+sNth);
        nNth++;
        sNth = IntToString(nNth);
        oItem = GetLocalObject(oTarget, "DUAL"+sNth);
    }
}

//::///////////////////////////////////////////////
//:: Name SetTwoHandedWeapon
//:://////////////////////////////////////////////
/*
    Sets a two-handed weopen to use.
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWSetTwoHandedWeapon(object oTarget, object oItem)
{
    if(GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_TWO_HANDED"))
    {
        SetLocalInt(oTarget, "DW_TWO_HANDED", GetLocalInt(oItem, "VALUE"));
        SetLocalObject(oTarget, "DW_TWO_HANDED", oItem);
    }
    DeleteLocalInt(oItem, "VALUE");
}

//::///////////////////////////////////////////////
//:: Name StoreRangedWeapon
//:://////////////////////////////////////////////
/*
    First part of setting ranged weopen. Stores it!
    It needs to check for ammo when it is set, you see
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWStoreRangedWeapon(object oTarget, object oItem)
{
    int nNth = GetLocalInt(oTarget, "DISTANCE");
    nNth++;
    string sNth = IntToString(nNth);

    SetLocalObject(oTarget, "DISTANCE"+sNth, oItem);
    SetLocalInt(oTarget, "DISTANCE", nNth);
}

//::///////////////////////////////////////////////
//:: Name SetAmmoCounters
//:://////////////////////////////////////////////
/*
    Used to check ammo - for setting ranged weopen
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWSetAmmoCounters(object oTarget, int nBase)
{
    switch(nBase)
    {
        case 20:
        {
            SetLocalInt(oTarget, "ARROW", TRUE);
            return;
        }
        case 25:
        {
            SetLocalInt(oTarget, "BOLT", TRUE);
            return;
        }
        case 27:
        {
            SetLocalInt(oTarget, "BULLET", TRUE);
            return;
        }
    }
}

//::///////////////////////////////////////////////
//:: Name SetRangedWeapon
//:://////////////////////////////////////////////
/*
    Sets a ranged weopen - based on ammo as well
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWSetRangedWeapon(object oTarget)
{
    int nNth = 1;
    int nArrow = GetLocalInt(oTarget, "ARROW");
    int nBolt = GetLocalInt(oTarget, "BOLT");
    int nBullet = GetLocalInt(oTarget, "BULLET");
    string sNth = IntToString(nNth);
    object oItem = GetLocalObject(oTarget, "DISTANCE"+sNth);

    while(GetIsObjectValid(oItem))
    {
        int nBase = GetBaseItemType(oItem);

        if(nBase == 31 || nBase == 59 || nBase == 63)// 31 = Dart, 59 = Shuriken, 63 = Throwing axe
        {
            if(GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_RANGED"))
            {
                SetLocalInt(oTarget, "DW_RANGED", GetLocalInt(oItem, "VALUE"));
                SetLocalObject(oTarget, "DW_RANGED", oItem);
                DeleteLocalInt(oItem, "VALUE");
            }
            else
            {
                DeleteLocalInt(oItem, "VALUE");
            }
        }
        if(nBase == 6 || nBase == 7)// 6 = Heavy, 7 = Light X-bow
        {
            if(nBolt == TRUE && GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_RANGED"))
            {
                SetLocalInt(oTarget, "DW_RANGED", GetLocalInt(oItem, "VALUE"));
                SetLocalObject(oTarget, "DW_RANGED", oItem);
                DeleteLocalInt(oItem, "VALUE");
            }
            else
            {
                DeleteLocalInt(oItem, "VALUE");
            }
        }
        if(nBase == 8 || nBase == 11)// 8 = Long, 11 = Short bow
        {
            if(nArrow == TRUE && GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_RANGED"))
            {
                SetLocalInt(oTarget, "DW_RANGED", GetLocalInt(oItem, "VALUE"));
                SetLocalObject(oTarget, "DW_RANGED", oItem);
                DeleteLocalInt(oItem, "VALUE");
            }
            else
            {
                DeleteLocalInt(oItem, "VALUE");
            }
        }
        if(nBase == 61)// 61 = Sling
        {
            if(nBullet == TRUE && GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_RANGED"))
            {
                SetLocalInt(oTarget, "DW_RANGED", GetLocalInt(oItem, "VALUE"));
                SetLocalObject(oTarget, "DW_RANGED", oItem);
                DeleteLocalInt(oItem, "VALUE");
            }
            else
            {
                DeleteLocalInt(oItem, "VALUE");
            }
        }
        DeleteLocalObject(oTarget, "DISTANCE"+sNth);
        nNth++;
        sNth = IntToString(nNth);
        oItem = GetLocalObject(oTarget, "DISTANCE"+sNth);
    }
    DelayCommand(0.1, SWDeleteInts(oTarget));
}

//::///////////////////////////////////////////////
//:: Name SetShield
//:://////////////////////////////////////////////
/*
    V. Simple. If value is higher, set the shield
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWSetShield(object oTarget, object oItem)
{
    if(GetLocalInt(oItem, "VALUE") > GetLocalInt(oTarget, "DW_SHIELD"))
    {
        SetLocalInt(oTarget, "DW_SHIELD", GetLocalInt(oItem, "VALUE"));
        SetLocalObject(oTarget, "DW_SHIELD", oItem);
    }
    DeleteLocalInt(oItem, "VALUE");
}

//::///////////////////////////////////////////////
//:: Name GetState
//:://////////////////////////////////////////////
/*
    Returns the int DW_STATE
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

int SWGetState(object oTarget)
{
    int nState = GetLocalInt(oTarget, "DW_STATE");
    return nState;
}

//::///////////////////////////////////////////////
//:: Name GetWeopenSize
//:://////////////////////////////////////////////
/*
    Returns the Base Weopen size of oItem
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

int SWGetWeaponSize(object oItem)
{
    int nBase = GetBaseItemType(oItem);
    int nSize = 0;

    if(nBase == 22 || nBase == 42 || nBase == 59)
    {
        nSize = 1;
    }
    if(nBase == 0 || nBase == 7 || nBase == 9 || nBase == 14 || nBase == 31 ||
    nBase == 37 || nBase == 38 || nBase == 40 || nBase == 60 || nBase == 61 ||
    nBase ==63)
    {
        nSize = 2;
    }
    if(nBase == 1 || nBase == 2 || nBase == 3 || nBase == 4 || nBase == 5 ||
    nBase == 6 || nBase == 11 || nBase == 28 || nBase == 41 || nBase == 47 ||
    nBase == 51 || nBase == 53 || nBase == 56)
    {
        nSize = 3;
    }
    // Large weapons
    if(nBase == 8 || nBase == 10 || nBase == 12 || nBase == 13 || nBase == 18 ||
    nBase == 32 || nBase == 33 || nBase == 35 || nBase == 50 || nBase == 55 ||
    nBase == 57 || nBase == 58 || nBase == 45)
    {
        nSize = 4;
    }
    return nSize;
}

//::///////////////////////////////////////////////
//:: Name DeleteInts
//:://////////////////////////////////////////////
/*
    Deletes everything, like what weopen they are using
    and what proficiencies they have that may be stored.
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SWDeleteInts(object oTarget)
{
    DeleteLocalInt(oTarget, "DW_PRIMARY");
    DeleteLocalInt(oTarget, "DW_SECONDARY");
    DeleteLocalInt(oTarget, "DW_TWO_HANDED");
    DeleteLocalInt(oTarget, "DW_RANGED");
    DeleteLocalInt(oTarget, "DW_SHIELD");
    DeleteLocalInt(oTarget, "DISTANCE");
    DeleteLocalInt(oTarget, "DUAL");
    DeleteLocalInt(oTarget, "ARROW");
    DeleteLocalInt(oTarget, "BOLT");
    DeleteLocalInt(oTarget, "BULLET");
    DeleteLocalInt(oTarget, "DRUID");
    DeleteLocalInt(oTarget, "ELF");
    DeleteLocalInt(oTarget, "EXOTIC");
    DeleteLocalInt(oTarget, "MARTIAL");
    DeleteLocalInt(oTarget, "MONK");
    DeleteLocalInt(oTarget, "ROGUE");
    DeleteLocalInt(oTarget, "SIMPLE");
    DeleteLocalInt(oTarget, "WIZARD");
}
//void main(){}
