/*------------------------------------------------------------------------------
 *  Core Library of Memes
 *
 *  This is the default library of memetic objects. It contains some sample
 *  memes. All of these should be easy to understand, execept for i_sequence,
 *  this is a private meme stored in h_ai. This library will grow and ultimately
 *  be shipped as a standard collection of reuseable higher-order behaviors.
 -----------------------------------------------------------------------------*/

#include "h_library"

/*-----------------------------------------------------------------------------
 *    Meme:  i_flee
 *  Author:  William Bull
 *    Date:  April, 2003
 * Purpose:  This is a simple meme that has the creature move away from
 *           something, then sets its priority to NONE.
 -----------------------------------------------------------------------------
 * No data.
 -----------------------------------------------------------------------------*/

void i_flee_go()
{
    _Start("Flee timing='Go'", DEBUG_COREAI);
    object oTarget = GetLocalObject(MEME_SELF, "Target");
    int    iRun    = GetLocalInt   (MEME_SELF, "Run");
    float  fRange  = GetLocalFloat (MEME_SELF, "Range");
    int    iCount = MeGetStringCount  (MEME_SELF);
    string sText  = MeGetStringByIndex(MEME_SELF, Random(iCount));

    if (sText != " " && sText != "")
    {
        _PrintString("Saying: '"+sText+"'.", DEBUG_COREAI);
        ActionSpeakString(sText);
    }

    ActionMoveAwayFromObject(oTarget, iRun, fRange);
    _End();
    return;
}

void i_flee_end()
{
    _Start("Flee timing='End'", DEBUG_COREAI);
    MeSetPriority(MEME_SELF, PRIO_NONE);
    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_say
 *  Author:  William Bull
 *    Date:  September, 2002
 * Purpose:  This randomly selects on thing and says it.
 -----------------------------------------------------------------------------
 * String List "": Strings to be said.
 -----------------------------------------------------------------------------*/

void i_say_go()
{
    _Start("Say event = 'Go'", DEBUG_COREAI);

    int    iCount = MeGetStringCount  (MEME_SELF);
    string sText  = MeGetStringByIndex(MEME_SELF, Random(iCount));

    if (sText != " " && sText != "")
    {
        _PrintString("Saying: '"+sText+"'.", DEBUG_COREAI);
        ActionSpeakString(sText);
        ActionWait(3.0);
    }

    _End("Say", DEBUG_COREAI);
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_wander
 -----------------------------------------------------------------------------*/

void i_wander_go()
{
    _Start("Wander event = 'Go'", DEBUG_COREAI);

    effect e = EffectVisualEffect(VFX_DUR_GLOW_GREEN);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, e, OBJECT_SELF, 1.0);

    ActionRandomWalk();

    _End();
}

void i_wander_brk()
{
    _Start("Wander event='Break'");

    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

    effect e = EffectVisualEffect(VFX_DUR_GLOW_RED);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, e, OBJECT_SELF, 1.0);

    ClearAllActions();
    ActionDoCommand(MeRestartSystem());

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_sit; Olias 2004/06/04: untested, may not work
 *		code derived from Dusty Everman's.
 -----------------------------------------------------------------------------*/

void i_sit_go()
{
	_Start("Sit timing = 'go'", DEBUG_COREAI);

	// get parameters
	string sSeat = GetLocalString(MEME_SELF, "Seat");
	string sNoSeat = GetLocalString(MEME_SELF, "Complain");

	object oSeat = OBJECT_INVALID;
	int i = 1;

	// find a suitable seat
	for (i = 1; ; ++i)
	{
		// get the nth nearest seat
		oSeat = GetNearestObjectByTag(sSeat, NPC_SELF, i);

		// did we find one?
		if (!GetIsObjectValid(oSeat))
		{
			// no more seats; complain & finish (REPEAT?)
			SpeakString(sNoSeat);
			break;
		}

		// is anyone already sitting in it?
		if (!GetIsObjectValid(GetSittingCreature(oSeat)))
		{
			// no; use this seat

			// align orientation with the seat
			AssignCommand(NPC_SELF, SetFacing(GetFacing(oSeat)));
			// actually sit; problem: ActionSit clears the action
			//	queue, so we must arrange to restart
			DelayCommand(0.1, MeRestartSystem());
			AssignCommand(NPC_SELF, ActionSit(oSeat));
			// we're done
			break;
		}
	}

	_End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_sleep; Olias 2005/06/05: untested, may not work
 *		code derived from Dusty Everman's.
 -----------------------------------------------------------------------------*/

void i_sleep_go()
{
	_Start("Sleep timing = 'go'", DEBUG_COREAI);

	// get parameters
	string sBed = GetLocalString(MEME_SELF, "Bed");
	string sNoBed = GetLocalString(MEME_SELF, "Complain");
	float fDuration = GetLocalFloat(MEME_SELF, "Duration");

	object oBed = OBJECT_INVALID;
	int i = 1;

	// find a suitable bed
	for (i = 1; ; ++i)
	{
		// get the nth nearest bed
		oBed = GetNearestObjectByTag(sBed, NPC_SELF, i);

		// did we find one?
		if (!GetIsObjectValid(oBed))
		{
			// no more beds; complain & finish (REPEAT?)
			SpeakString(sNoBed);
			break;
		}

		// FIXME: need to see if anyone is already sleeping in it

		// align orientation with the bed
		AssignCommand(NPC_SELF, SetFacing(GetFacing(oBed)));
		// actually get in/on it
		AssignCommand(NPC_SELF,
			ActionDoCommand(JumpToLocation(GetLocation(oBed))));
		// actually lie down
		DelayCommand(fDuration + 0.1, MeRestartSystem());
		AssignCommand(NPC_SELF,
			ActionDoCommand(ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0f, fDuration)));
		// we're done
		break;
	}

	_End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_undress; Olias 2005/06/05: untested, may not work
 -----------------------------------------------------------------------------*/

// helper function to do the actual work
void unequip_save(int iSlot, string sName)
{
	// get the equipped item
	object oItem = GetItemInSlot(iSlot, NPC_SELF);

	// is it valid?
	if (GetIsObjectValid(oItem))
		// unequip it
		AssignCommand(NPC_SELF, ActionUnequipItem(oItem));

	// remember what (if anything) we unequipped
	SetLocalObject(NPC_SELF, sName, oItem);
}

void i_undress_go()
{
	int iBits = GetLocalInt(MEME_SELF, "Clothing");

	// if unset, the default is to unequip all slots
	if (iBits == 0)
		iBits = -1;

	// weapon/shield?
	if (iBits & (1 << INVENTORY_SLOT_LEFTHAND))
		unequip_save(INVENTORY_SLOT_LEFTHAND, "SlotLHand");
	if (iBits & (1 << INVENTORY_SLOT_RIGHTHAND))
		unequip_save(INVENTORY_SLOT_RIGHTHAND, "SlotRHand");

	// gloves/bracers?
	if (iBits & (1 << INVENTORY_SLOT_ARMS))
		unequip_save(INVENTORY_SLOT_ARMS, "SlotArms");

	// rings?
	if (iBits & (1 << INVENTORY_SLOT_LEFTRING))
		unequip_save(INVENTORY_SLOT_LEFTRING, "SlotLRing");
	if (iBits & (1 << INVENTORY_SLOT_RIGHTRING))
		unequip_save(INVENTORY_SLOT_RIGHTRING, "SlotRRing");

	// helmet/hat?
	if (iBits & (1 << INVENTORY_SLOT_HEAD))
		unequip_save(INVENTORY_SLOT_HEAD, "SlotHead");

	// cloak/armor?
	if (iBits & (1 << INVENTORY_SLOT_CLOAK))
		unequip_save(INVENTORY_SLOT_CLOAK, "SlotCloak");
	if (iBits & (1 << INVENTORY_SLOT_CHEST))
		unequip_save(INVENTORY_SLOT_CHEST, "SlotChest");

	// amulet?
	if (iBits & (1 << INVENTORY_SLOT_NECK))
		unequip_save(INVENTORY_SLOT_NECK, "SlotNeck");

	// belt?
	if (iBits & (1 << INVENTORY_SLOT_BELT))
		unequip_save(INVENTORY_SLOT_BELT, "SlotBelt");

	// boots?
	if (iBits & (1 << INVENTORY_SLOT_BOOTS))
		unequip_save(INVENTORY_SLOT_BOOTS, "SlotBoots");
}

/*-----------------------------------------------------------------------------
 *    Meme:  i_dress; Olias 2005/06/05: untested, may not work
 -----------------------------------------------------------------------------*/

// helper function to do the actual work
void equip(int iSlot, string sName)
{
	// get the item we had equipped before i_undress
	object oItem = GetLocalObject(NPC_SELF, sName);

	// is it valid?
	if (GetIsObjectValid(oItem))
		// yes, equip it
		AssignCommand(NPC_SELF, ActionEquipItem(oItem, iSlot));

	// we don't need that any more
	DeleteLocalObject(NPC_SELF, sName);
}

void i_dress_go()
{
	// we always re-equip everything we unequipped from i_undress

	// boots?
	equip(INVENTORY_SLOT_BOOTS, "SlotBoots");

	// belt?
	equip(INVENTORY_SLOT_BELT, "SlotBelt");

	// amulet?
	equip(INVENTORY_SLOT_NECK, "SlotNeck");

	// armor/cloak?
	equip(INVENTORY_SLOT_CHEST, "SlotChest");
	equip(INVENTORY_SLOT_CLOAK, "SlotCloak");

	// helmet?
	equip(INVENTORY_SLOT_HEAD, "SlotHead");

	// rings?
	equip(INVENTORY_SLOT_LEFTRING, "SlotLRing");
	equip(INVENTORY_SLOT_RIGHTRING, "SlotRRing");

	// bracers/gloves?
	equip(INVENTORY_SLOT_ARMS, "SlotArms");

	// weapon/shield?
	equip(INVENTORY_SLOT_LEFTHAND, "SlotLHand");
	equip(INVENTORY_SLOT_RIGHTHAND, "SlotRHand");
}

/*------------------------------------------------------------------------------
 *   Script: Library Initialization and Scheduling
 ------------------------------------------------------------------------------*/

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("i_sequence",  "_go",     0x0100+0x01);
        MeLibraryImplements("i_sequence",  "_brk",    0x0100+0x02);
        MeLibraryImplements("i_sequence",  "_end",    0x0100+0x03);
        MeLibraryImplements("i_sequence",  "_ini",    0x0100+0xff);

        MeLibraryImplements("i_say",       "_go",     0x0200);

        MeLibraryImplements("i_flee",      "_go",     0x0300+0x01);
        MeLibraryImplements("i_flee",      "_end",    0x0300+0x02);

        MeLibraryImplements("i_wander",    "_go",     0x0400+0x01);
        MeLibraryImplements("i_wander",    "_brk",    0x0400+0x02);

		MeLibraryImplements("i_sit",		"_go",		0x0500+0x01);

		MeLibraryImplements("i_sleep",		"_go",		0x0600+0x01);

		MeLibraryImplements("i_undress",	"_go",		0x0700+0x01);

		MeLibraryImplements("i_dress",		"_go",		0x0800+0x01);

        _End();
        return;
    }

    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_sequence_go();    break;
            case 0x02: i_sequence_brk();   break;
            case 0x03: i_sequence_end();   break;
            case 0xff: i_sequence_ini();   break;
        }   break;

        case 0x0200: i_say_go(); break;

        case 0x0300: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_flee_go();   break;
            case 0x02: i_flee_end();  break;
        }   break;

        case 0x0400: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_wander_go(); break;
            case 0x02: i_wander_brk(); break;
        } break;

		case 0x0500: switch (MEME_ENTRYPOINT & 0x00ff)
		{
			case 0x01:	i_sit_go(); break;
		} break;

		case 0x0600: switch (MEME_ENTRYPOINT & 0x00ff)
		{
			case 0x01:	i_sleep_go(); break;
		} break;

		case 0x0700: switch (MEME_ENTRYPOINT & 0x00ff)
		{
			case 0x01:	i_undress_go(); break;
		} break;

		case 0x0800: switch (MEME_ENTRYPOINT & 0x00ff)
		{
			case 0x01:	i_dress_go(); break;
		} break;
    }

    _End();
}
