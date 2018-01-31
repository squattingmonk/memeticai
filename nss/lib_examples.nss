#include "h_library"
#include "h_response"
#include "h_util_combat"

object f_arrest_pc(object oPC)
{
    _PrintString("Function: Arrest PC", DEBUG_COREAI);

    object oArrestMeme = GetLocalObject(OBJECT_SELF, "Arrest_Meme");

    if (GetIsObjectValid(oArrestMeme) == TRUE)
    {
        _PrintString("Already arresting someone.", DEBUG_COREAI);
        SpeakString("Stop, lawbreaker! I know you're up to something.");
        return OBJECT_INVALID;

    }

    if (GetIsObjectValid(oPC) == FALSE)
    {
        _PrintString("PC is invalid.", DEBUG_COREAI);
        return OBJECT_SELF;
    }
    else
    {
        _PrintString("Arrest: " + _GetName(oPC), DEBUG_COREAI);
    }

    object oJail = GetObjectByTag(MeGetConfString(OBJECT_SELF, "MT: Jail Door"));
    object oJailWaypoint = GetWaypointByTag(MeGetConfString(OBJECT_SELF, "MT: Jail Waypoint"));
    object oPost = GetWaypointByTag(MeGetConfString(OBJECT_SELF, "MT: Jail Post"));

    if (GetIsObjectValid(oJail) == FALSE)
    {
        _PrintString("Jail Door Object Parameter is invalid.", DEBUG_COREAI);
        return OBJECT_INVALID;
    }
    else if (GetIsObjectValid(oPost) == FALSE)
    {
        _PrintString("Jail Post Waypoint Parameter is invalid.", DEBUG_COREAI);
        return OBJECT_INVALID;
    }
    else if (GetIsObjectValid(oJailWaypoint) == FALSE)
    {
        _PrintString("Jail Waypoint Parameter is invalid.", DEBUG_COREAI);
        return OBJECT_INVALID;
    }
    else
    {
        _PrintString("Jail: " + _GetName(oJail), DEBUG_COREAI);
        _PrintString("Post: " + _GetName(oPost), DEBUG_COREAI);
        _PrintString("Waypoint: " + _GetName(oJailWaypoint), DEBUG_COREAI);
    }

    object oArrestSeq = MeGetSequence("Arrest PC Sequence");

    if (GetIsObjectValid(oArrestSeq) == FALSE)
    {
        _PrintString("Arrest PC Sequence not found. Aborting", DEBUG_COREAI);
        return OBJECT_INVALID;
    }

    //SpeakString("Arresting perp: " + _GetName(oPC));

    SetLocalObject(oArrestSeq, "Perp", oPC);
    SetLocalObject(oArrestSeq, "JailDoor", oJail);
    SetLocalObject(oArrestSeq, "JailWaypoint", oJailWaypoint);
    SetLocalObject(oArrestSeq, "JailPost", oPost);
    SetLocalObject(oArrestSeq, "Follow", OBJECT_SELF);
    MeUpdateLocals(oArrestSeq);

    oArrestMeme = MeStartSequence(oArrestSeq);
    SetLocalObject(OBJECT_SELF, "Arrest_Meme", oArrestMeme);

    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

    _PrintString("Arrest Sequence started.", DEBUG_COREAI);
    return OBJECT_SELF;
}

void i_arrest_pc_go()
{
    _Start("ArrestPC timing='Go'", DEBUG_COREAI);

    object oPC = GetLocalObject(MEME_SELF, "Target");
    object oFollow = GetLocalObject(MEME_SELF, "Follow");

    if (GetIsPC(oPC) == FALSE || GetIsDM(oPC) == TRUE)
    {
        _PrintString("Target is invalid or a DM: " + _GetName(oPC), DEBUG_COREAI);
        _End();
        return;
    }

    if (GetIsObjectValid(oFollow) == FALSE)
    {
        _PrintString("Object to follow is invalid.", DEBUG_COREAI);
        _End();
        return;
    }

    AssignCommand(OBJECT_SELF, SpeakString("You're coming with me!"));
    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, SetCommandable(FALSE, oPC));
    AssignCommand(oPC, ActionForceFollowObject(oFollow, 2.0));

    _End();
}

void i_lockup_go()
{
    _Start("Lockup timing='Go'", DEBUG_COREAI);

    object oPC = GetLocalObject(MEME_SELF, "Target");
    object oJailWaypoint = GetLocalObject(MEME_SELF, "LockupWaypoint");

    if (GetIsObjectValid(oPC) == FALSE || GetIsDM(oPC) == TRUE)
    {
        _PrintString("Target is invalid or a DM: " + _GetName(oPC), DEBUG_COREAI);
        _End();
        return;
    }

    if (GetIsObjectValid(oJailWaypoint) == FALSE)
    {
        _PrintString("JailWaypoint is invalid.", DEBUG_COREAI);
        _End();
        return;
    }

    // Needs a waypoint inside the cage/cell
    AssignCommand(OBJECT_SELF, SpeakString("In ya go!"));

    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ClearAllActions());
    AssignCommand(oPC, ActionForceMoveToObject(oJailWaypoint, TRUE));
    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT));
    AssignCommand(oPC, SetCommandable(FALSE, oPC));

    DelayCommand(6.0, SetCommandable(TRUE, oPC));

    ActionWait(4.5);

    _End();
}

void g_constable_see()
{
    _Start("Generator type='Constable'", DEBUG_COREAI);

    object oSeen = GetLastPerceived();

    object oRight = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oSeen);
    object oLeft  = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oSeen);
    object oHead  = GetItemInSlot(INVENTORY_SLOT_HEAD, oSeen);

    if (GetIsWeapon(oRight) || GetIsWeapon(oLeft))
    {
        struct message stMsg = MeCreateMessage("Weapon/Equipped", "", 0, 0.0, oSeen);
        MeBroadcastMessage(stMsg, "CityLimits");  // Area tag?
    }

    if (GetBaseItemType(oHead) == BASE_ITEM_HELMET)
    {
        SpeakString("No helmets in these parts. Take it off.");
    }

    _End();
}

// Really should be a general 'property' event that takes its channels from the
// vars set on the NPC. Same for weapons, though in a more limited fashion.
void e_jail_ini()
{
    _Start("Event type='Jail'", DEBUG_TOOLKIT);

    MeSubscribeMessage(MEME_SELF, "Property/Disturbed", "GuardedChest");
    MeSubscribeMessage(MEME_SELF, "Property/Disturbed", "TheStocks");
    MeSubscribeMessage(MEME_SELF, "Weapon/Equipped", "CityLimits");  // Area tag?

    _End();
}

void e_jail_go()
{
    _Start("Event type='Jail'", DEBUG_COREAI);

    struct message stMsg = MeGetLastMessage();
    object oResponse;

    _PrintString("Message: " + stMsg.sMessageName, DEBUG_COREAI);

    object oTarget = stMsg.oData;
    if (MeGetIsVisible(oTarget, OBJECT_SELF) == FALSE)
    {
        _PrintString("Ignoring request, thief is not visible.", DEBUG_COREAI);
        //SpeakString("Thief, I cannot see you!");
        _End();
        return;
    }

    object oArrest = GetLocalObject(OBJECT_SELF, "Arrest_Meme");
    if (GetIsObjectValid(oArrest))
    {
        _PrintString(_GetName(oArrest) + " is still around.", DEBUG_COREAI);

       SpeakString("I'll get ya, thief, when I'm done with this one!");
       _PrintString("Still escorting a prisoner: " + _GetName(oArrest), DEBUG_COREAI);
       _End();
       return;
    }

    oResponse = MeCreateMeme("i_respond", PRIO_HIGH, 0, MEME_RESUME | MEME_REPEAT);
    MeSetLocalMessage(oResponse, "Message", stMsg);

    MeUpdateActions();

    _End();
}

void GuardedChest_open()
{
    _Start("GuardedChest timing='Open'", DEBUG_COREAI);

    object oLastUser = GetLastOpenedBy();
    if (GetIsObjectValid(oLastUser) == FALSE)
    {
        _PrintString("Last user is invalid.", DEBUG_COREAI);
    }
    else
    {
        struct message stMsg = MeCreateMessage("Property/Disturbed", "", 0, 0.0, oLastUser);
        MeBroadcastMessage(stMsg, "GuardedChest");
    }
    _End();
}

void TheStocks_use()
{
    _Start("TheStocks timing='Use'", DEBUG_COREAI);

    object oLastUser = GetLastUsedBy();
    if (GetIsObjectValid(oLastUser) == FALSE)
    {
        _PrintString("Last user is invalid.", DEBUG_COREAI);
    }
    else
    {
        struct message stMsg = MeCreateMessage("Property/Disturbed", "", 0, 0.0, oLastUser);
        MeBroadcastMessage(stMsg, "TheStocks");
    }
    _End();
}

void c_constable_ini()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_COREAI);

    MeAddResponse(MEME_SELF, "Arrest Table", "f_chatter", 50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, "Arrest Table", "f_arrest_pc", 0, RESPONSE_END);
    MeAddResponse(MEME_SELF, "Arrest Table", "f_end_response", 0, RESPONSE_END);

    MeAddResponse(MEME_SELF, "Idle Table", "f_bored", 50, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, "Idle Table", "f_idle_animations");
    MeAddResponse(MEME_SELF, "Idle Table", "f_wait", 50, RESPONSE_HIGH);

    MeSetActiveResponseTable("Idle", "Idle Table");
    MeSetActiveResponseTable("Property/Disturbed", "Arrest Table");
    MeSetActiveResponseTable("Weapon/Equipped", "Arrest Table");

    MeSetLocalString(MEME_SELF, "TalkTable", "Grumble");
    MeAddStringRef(MEME_SELF, "Gosh darnit!", "Grumble");
    MeAddStringRef(MEME_SELF, "Ah ha! Redhanded!", "Grumble");
    MeAddStringRef(MEME_SELF, "Come 'ere, ya varmit!", "Grumble");
    MeAddStringRef(MEME_SELF, "A thief, eh?!", "Grumble");

    _End();
}

void c_constable_go()
{
    _Start("Instantiate class='"+MEME_CALLED+"'", DEBUG_COREAI);

    object oProperty = MeCreateEvent("e_jail");

    object oConversation = MeCreateGenerator("g_converse", PRIO_HIGH, -50);
    MeStartGenerator(oConversation);

    object oObservation = MeCreateGenerator("g_constable", PRIO_HIGH, 50);
    MeStartGenerator(oObservation);

    // Set patrol parameters (should be using MeGetConfString())
    MeSetLocalInt(NPC_SELF, "Repeat", TRUE);
    MeSetLocalInt(NPC_SELF, "Looping", TRUE);
    MeSetLocalInt(NPC_SELF, "AvoidOtherTrails", TRUE);
    MeSetLocalString(NPC_SELF, "Tag", "JAILOR");
    MeSetLocalFloat(NPC_SELF, "WalkDelay", 20.0);

    // Create a sequence
    object oArrestSeq = MeCreateSequence("Arrest PC Sequence", PRIO_HIGH, 0, SEQ_RESUME_LAST);

    // Go to the PC
    object oGotoPC = MeCreateSequenceMeme(oArrestSeq, "i_goto", PRIO_MEDIUM, 100);
    MeBindLocalObject(oArrestSeq, "Perp", oGotoPC, "Object");
    SetLocalFloat(oGotoPC, "MinDistance", 8.0);
    SetLocalInt(oGotoPC, "Run", TRUE);

    // Arrest the PC
    object oArrest = MeCreateSequenceMeme(oArrestSeq, "i_arrest_pc", PRIO_HIGH, 50);
    MeBindLocalObject(oArrestSeq, "Perp", oArrest, "Target");
    MeBindLocalObject(oArrestSeq, "Follow", oArrest, "Follow");

    // Haul the PC to jail
    object oGotoJail = MeCreateSequenceMeme(oArrestSeq, "i_goto", PRIO_MEDIUM, 100);
    MeBindLocalObject(oArrestSeq, "JailDoor", oGotoJail, "Object");

    // Unlock and open the jail cell
    // Needs the key in the creature's inventory for this operation...
    object oUnlock = MeCreateSequenceMeme(oArrestSeq, "i_respond", PRIO_HIGH, 0, MEME_RESUME | MEME_REPEAT);
    SetLocalString(oUnlock, "Situation", "Door/Blocked");
    MeBindLocalObject(oArrestSeq, "JailDoor", oUnlock, "ResponseArg");
    SetLocalInt(oUnlock, "Resume", TRUE);

    // Throw the PC in a jail cell
    object oLockup = MeCreateSequenceMeme(oArrestSeq, "i_lockup", PRIO_HIGH, 0);
    MeBindLocalObject(oArrestSeq, "Perp", oLockup, "Target");
    MeBindLocalObject(oArrestSeq, "JailWaypoint", oLockup, "LockupWaypoint");

    // Close the jail cell
    object oClose = MeCreateSequenceMeme(oArrestSeq, "i_closedoor", PRIO_MEDIUM, 100);
    MeBindLocalObject(oArrestSeq, "JailDoor", oClose, "Door");

    // Lock the jail cell, no need for a key
    object oLock = MeCreateSequenceMeme(oArrestSeq, "i_lockdoor", PRIO_HIGH, 0);
    MeBindLocalObject(oArrestSeq, "JailDoor", oLock, "Door");
    SetLocalInt(oLock, "bHasKey", TRUE);

    // Return to guard post
    object oReturn = MeCreateSequenceMeme(oArrestSeq, "i_goto", PRIO_MEDIUM, 0);
    MeBindLocalObject(oArrestSeq, "JailPost", oReturn, "Object");

    _End();
}

object f_chest_key(object oDoor)
{
    _PrintString("Function: Chest Key", DEBUG_COREAI);

    if (! GetIsObjectValid(oDoor))
    {
        _PrintString("Door is invalid. Aborting.", DEBUG_COREAI);
        return OBJECT_INVALID;
    }

    if (GetLockKeyTag(oDoor) != "CHESTKEY")
    {
        _PrintString("Unknown key. Aborting.", DEBUG_COREAI);
        return OBJECT_INVALID;
    }

    object oChest = GetObjectByTag("KeyChest");
    object oKey = GetObjectByTag("CHESTKEY");

    if (GetIsObjectValid(GetItemPossessedBy(OBJECT_SELF, "CHESTKEY")))
    {
        _PrintString("Key in possession.", DEBUG_COREAI);
        return OBJECT_INVALID;
    }

    _PrintString("Item Possessor: " + _GetName(GetItemPossessor(oKey)), DEBUG_COREAI);

    if (GetIsObjectValid(oChest))
    {
        object oFetch = MeCreateSequence("FetchChestKey", PRIO_MEDIUM, 100, SEQ_RESUME_LAST);

        object oGoto = MeCreateSequenceMeme(oFetch, "i_goto", PRIO_DEFAULT, 100, MEME_RESUME | MEME_REPEAT | MEME_CHECKPOINT);
        SetLocalObject(oGoto, "Object", oChest);

        object oItem = MeCreateSequenceMeme(oFetch, "i_retrieve_item", PRIO_DEFAULT, 100, MEME_RESUME);
        SetLocalObject(oItem, "Item", oKey);

        _PrintString("Clearing MEME_REPEAT and starting FetchChestKey sequence.", DEBUG_COREAI);
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

        MeStartSequence(oFetch);

        return OBJECT_SELF;
    }
    else
    {
        _PrintString("No container by that name.", DEBUG_COREAI);
    }

    return OBJECT_INVALID;
}

void i_retrieve_item_go() {
    _Start("Retrieve", DEBUG_COREAI);

    CreateItemOnObject("CHESTKEY", OBJECT_SELF);

    _End();
}

void Stool_use()
{
    _Start("Stool", DEBUG_COREAI);

    object oTarget = GetItemActivator();
    object oChair = GetItemActivated();

    FloatingTextStringOnCreature("MEME_SELF: " + _GetName(MEME_SELF), oTarget, TRUE);
    AssignCommand(oTarget, ActionSit(oChair));

    _End();
}

void c_wolf_pack_ini()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_TOOLKIT);

    MeAddResponse(MEME_SELF, "Flock Table", "f_flock_loose", 50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, "Flock Table", "f_walk_test", 50, RESPONSE_HIGH);
    MeSetActiveResponseTable("Idle", "Flock Table");

    _End();
}

void c_penguin_flock_ini()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_TOOLKIT);

    MeAddResponse(MEME_SELF, "Flock Table", "f_flock_tight", 70, RESPONSE_HIGH);
    //MeAddResponse(MEME_SELF, "Flock Table", "f_walk_test", 50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, "Flock Table", "f_flock_tight", 70, RESPONSE_MEDIUM);
    //MeAddResponse(MEME_SELF, "Flock Table", "f_walk_test", 50, RESPONSE_MEDIUM);
    MeSetActiveResponseTable("Idle", "Flock Table");

    _End();
}

object f_start_band(object oArg = OBJECT_INVALID)
{
    SpeakString("Start band");
    return OBJECT_INVALID;
}

object f_high_band(object oArg = OBJECT_INVALID)
{
    SpeakString("High band");
    return OBJECT_INVALID;
}

object f_medium_band(object oArg = OBJECT_INVALID)
{
    SpeakString("Medium band");
    return OBJECT_INVALID;
}

object f_low_band(object oArg = OBJECT_INVALID)
{
    SpeakString("Low band");
    return OBJECT_INVALID;
}

object f_end_band(object oArg = OBJECT_INVALID)
{
    SpeakString("End band -- waiting 2 seconds.");
    ActionWait(2.0);
    return OBJECT_INVALID;
}

void c_merge_test_ini()
{
    MeAddResponse(MEME_SELF, "Merge Test Idle Table", "f_start_band",  50, RESPONSE_START);
    MeAddResponse(MEME_SELF, "Merge Test Idle Table", "f_high_band",   50, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, "Merge Test Idle Table", "f_medium_band", 50, RESPONSE_MEDIUM);
    MeAddResponse(MEME_SELF, "Merge Test Idle Table", "f_low_band",    50, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, "Merge Test Idle Table", "f_end_band",   100, RESPONSE_END);

    MeSetActiveResponseTable("Idle", "Merge Test Idle Table", "*");
}

// This function checks to see if this NPC is supposed to be in a particular area.
// The names of the areas are stored on the NPC. You can have more than one list
// of legal area tags. Like this: "Home Area at Night 1", "Home Area at Dawn 1".
// You tell this function which list to use by setting "Home State".
// You can also list a series of home objects that the NPC will try and stand
// if, they are around. Like this: "Home Object at Night 1", "Home Object at Work 1".
object f_go_home(object oArg = OBJECT_INVALID)
{
    // First, if there are no areas listed for the given "Home State" then
    // the NPC is allowed to be anywhere.

    string sHomeState = MeGetConfString(OBJECT_SELF, "MT: Home State");
    if (sHomeState == "") return OBJECT_INVALID;

    object oMeme = MeCreateMeme("i_gotoarea");
    SetLocalString(oMeme, "AreaConfString", "MT: Home Area at "+sHomeState);

    return oMeme;
}

// ---- Greeter Class ----------------------------------------------------------
void c_greeter_ini()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_COREAI);

    _End();
}

void c_greeter_go()
{
    _Start("Instantiate class='"+MEME_CALLED+"'", DEBUG_COREAI);

    object o = MeCreateGenerator("g_goto", PRIO_MEDIUM, 20);
    SetLocalString(o, "SpeakTable", "GreetingText");
    MeDeclareStringRef("GreetingText", o);
    MeAddStringRef(o, "Hello!", "GreetingText");
    MeAddStringRef(o, "Good Day!", "GreetingText");

    MeStartGenerator(o);
    MeUpdateActions();

    _End();
}

// ---- Walker Class -----------------------------------------------------------

void c_walker_go()
{
    object oWP = MeCreateMeme("i_walkwp", PRIO_LOW, PRIO_DEFAULT, MEME_RESUME | MEME_REPEAT);
}

/*-----------------------------------------------------------------------------
 *    Meme:  e_fight
 *  Author:  William Bull
 *    Date:  September, 2002
 * Purpose:  This is an event that looks for a valid enemy that's not dead and
 *           causes an attack meme to attack it. It's really just a sample, not
 *           to be considered perfect and reusable.
 -----------------------------------------------------------------------------
 * Object "AttackMeme": This is a dormant, PRIO_NONE meme that represents how
 *                      this creature attacks. The event will set the "Enemy"
 *                      object ref and increase it to medium priority.
 -----------------------------------------------------------------------------*/


void e_fight_go()
{
    _Start("FightEvent");

    object oMeme   = GetLocalObject(MEME_SELF, "AttackMeme");
    object oTarget = OBJECT_INVALID;

    // An enemy has either been seen, damaged us, or died.  Look for a new enemy
    oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
    if(GetIsObjectValid(oTarget) && !GetIsDead(oTarget))
    {
        if (GetLocalObject(oMeme, "Enemy") != oTarget)
        {
            SetLocalObject(oMeme, "Enemy", oTarget);
            if (MeGetPriority(oMeme) == PRIO_MEDIUM)
            {
                MeRestartMeme(oMeme);
            }
            else
            {
                MeSetPriority(oMeme, PRIO_MEDIUM);
                MeUpdateActions();
            }
        }
    }


    _End("FightEvent");
}

/*-----------------------------------------------------------------------------
 *    Meme:  e_prioritize
 *  Author:  William Bull
 *    Date:  September, 2002
 * Purpose:  This is an event that's used to gradually change the priority
 *           of another meme, over time. A list of adjustment values can
 *           be added to this repeating event. It will iterate over this
 *           list, gradually changing the priority. Be wary of setting the
 *           interval too short; this was intended to change a behavior over
 *           the course of several minutes or hours.
 -----------------------------------------------------------------------------
 * Int[]   "Modifier"   : The priority the meme should be set to.
 * Int[]   "Priority"   : The modifier the meme should be set to.
 * Float[] "Delay"      : The amount of time to wait for the next priority adjustment
 * Int[]   "DelayJitter": A random factor to default "in sync" priority changes
 * Object[] ""          : A list of memes to be adjusted.
 -----------------------------------------------------------------------------*/

void e_prioritize_go()
{
    _Start("Event name='"+GetLocalString(MEME_SELF,"Name")+"'", DEBUG_COREAI);

    object oMeme;
    int    iModifier;
    int    iPriority;
    int    iJitter;
    float  iDelay;
    int    i, j;

    i         = GetLocalInt      (MEME_SELF,    "MEME_Counter");
    iModifier = MeGetIntByIndex  (MEME_SELF, i, "Modifier");
    iPriority = MeGetIntByIndex  (MEME_SELF, i, "Priority");
    iDelay    = MeGetFloatByIndex(MEME_SELF, i, "Delay");
    iJitter   = MeGetIntByIndex  (MEME_SELF, i, "DelayJitter");

    j = 0;
    while(1)
    {
        oMeme = MeGetObjectByIndex(MEME_SELF, j, "Meme");
        if (!GetIsObjectValid(oMeme)) break;

        _PrintString("Set prio "+IntToString(iPriority*100+iModifier)+".");
        MeSetPriority(oMeme, iPriority, iModifier);

        j++;
    }
    MeUpdateActions(); // Inside an event, whenever you call MeSetPriority, you must call UpdateActions();

    i++;

    if (i >= MeGetIntCount(MEME_SELF, "Priority"))
    {
        if (!MeGetMemeFlag(MEME_SELF, MEME_REPEAT))
        {
            SetLocalInt(MEME_SELF, "MEME_HasTimeTrigger", 0);
            _End();
            return;
        }

        i = 0;
    }

    SetLocalInt(MEME_SELF, "MEME_Counter", i);

    // Reschedule with an optional jitter.
    DelayCommand(iDelay+Random(iJitter+1) - iJitter, MeActivateEvent(MEME_SELF));

    _End("Event", DEBUG_COREAI);
}


/*
 */
void e_home_go()
{
    // Document the "home state variable"
    // Receives message like Time of Day, take string data, and sets
    // home state variable. Then it kickstars a meme.
    // Then the meme appends the home state variable onto some string
    // to get lists of areas, etc.
    // The meme looks at "Home Area at <state> 1..2...3"
    // If he searches the home area and he's not there ... he needs to
    // spawn a child meme.
    // Is there a warp time envelop? We'll need an autoincrementing guid
    // that can be checked by the delay command to see if the current
    // process of moving is happening. We need to invalidate this id
    // on meme_brk (?) of the meme is interrupted by a higher meme -- but not
    // a child meme interruption. (Need to double check that a child meme
    // does not call _brk in the conventional manner.) (Need a function
    // to kill off child memes and restart the suspended parent.)
    // The first thing to do is see if any of the gateways in the immediate
    // area connect to an area I'm allowed to go to, starting with the closest
    // gateway.
    // If you are in an area you're ok with ... you need to see if you need
    // to be near any particular objects. If so, you need to find a landmark
    // object that's close to it.
}

/*-----------------------------------------------------------------------------
 * Generator:  g_goto
 *    Author:  William Bull
 *      Date:  September, 2002
 *   Purpose:  This is an example of a perception generator - it causes
 *             the NPC to go to something it sees and randomly say a string.
 *             It's currently hardcoded with debugging bear messages. This is
 *             not a practical generator - mostly used for examples.
 -----------------------------------------------------------------------------
 *    Timing:  OnPerception
 -----------------------------------------------------------------------------*/

void g_goto_see()
{
    _Start("Generator name='GoTo' timing='See'", DEBUG_COREAI);
    object oSeen;
    object oMeme;

    string sSpeakTable = GetLocalString(MEME_SELF, "SpeakTable");
    int iCount = MeGetStringCount (MEME_SELF, sSpeakTable);
    string sText = MeGetStringByIndex(MEME_SELF, Random(iCount), sSpeakTable);

    if (GetLocalObject(NPC_SELF, "MEME_Parent") == OBJECT_INVALID) _PrintString("NPC_SELF is not inheriting.", DEBUG_UTILITY);
    else _PrintString("NPC_SELF *is* inheriting.", DEBUG_UTILITY);

    _PrintString("Got text "+sText+".", DEBUG_COREAI);
    _PrintString("MEME_SELF name = '"+GetLocalString(MEME_SELF, "Name")+"'", DEBUG_COREAI);

    oSeen = GetLastPerceived();

    if (GetLocalInt(MEME_SELF, "TargetPC"))
    {
        if (!GetIsPC(oSeen))
        {
            _End("Generator", DEBUG_COREAI);
            return;
        }
    }

    // Don't go to something we've already gone to in the past six seconds.
    if (MeGetTemporaryFlag(oSeen, "IveGoneToThis"))
    {
        _PrintString("I've seen this thing before.", DEBUG_COREAI);
        _End("Generator");
        return;
    }
    else
    {
        _PrintString("I've never seen you before...", DEBUG_COREAI);
        MeSetTemporaryFlag(oSeen, "IveGoneToThis", 1, 60);
    }

    // So what we do is store the "go" behavior on the generator.
    // This behavior takes a list of people to go to; we only add
    // the person on the list if they aren't already on it.
    oMeme = GetLocalObject(MEME_SELF, "GoMeme");
    if (!GetIsObjectValid(oMeme))
    {
        if (GetLocalInt(MEME_SELF, "NoResume"))
        {
            oMeme = MeCreateMeme("i_goto", PRIO_DEFAULT, PRIO_DEFAULT, 0, MEME_SELF);
        }
        else
        {
            oMeme = MeCreateMeme("i_goto", PRIO_DEFAULT, PRIO_DEFAULT, MEME_RESUME|MEME_REPEAT, MEME_SELF);
        }
        SetLocalObject(MEME_SELF, "GoMeme", oMeme);
        SetLocalInt(oMeme, "Run", 1);
    }

    // If I'm not already going to the thing...add to the go list.
    if (MeHasObjectRef(oMeme, oSeen, "Target") == -1)
    {
        _PrintString("Adding "+_GetName(oSeen), DEBUG_COREAI);
        MeAddObjectRef(oMeme, oSeen, "Target");
        MeAddStringRef(oMeme, sText, "End");
    }

    /*
       This is what the "bears example" used to say,
       this should be moved into their spawn script,
       referencing the generator, not the meme:

    MeAddStringRef(oMeme, "Oh that's interesting...");
    MeAddStringRef(oMeme, "Well, what have we here...");
    MeAddStringRef(oMeme, "Are you a tastey tid bit?");
    MeAddStringRef(oMeme, "Ah something for the tummy...");
    MeAddStringRef(oMeme, "Have I see you before?");
    MeAddStringRef(oMeme, "If I were a dog, I'd sniff your butt.");
    MeAddStringRef(oMeme, "I'm strangely drawn to you.");
    MeAddStringRef(oMeme, "I can see you better up close...");
    MeAddStringRef(oMeme, "Stand still I'll check you out.");
    MeAddStringRef(oMeme, "My bear eyes bare down on you.");
    MeAddStringRef(oMeme, "Bears like to inspect things like you.");
    MeAddStringRef(oMeme, "Lemme get a closer look...");
    MeAddStringRef(oMeme, "I have to look at you again...");
    MeAddStringRef(oMeme, "How many times am I going to have to look at you?");
    MeAddStringRef(oMeme, "Stay close so I don't forget I saw you.");
    MeAddStringRef(oMeme, "Ho hum, here I come.");
    MeAddStringRef(oMeme, "Be right there, then I'll keep walking.");
    MeAddStringRef(oMeme, "Checkin' you out...");
    MeAddStringRef(oMeme, "Do all bears check things out like us?");
    MeAddStringRef(oMeme, "Whew all this new stuff to see.");
    MeAddStringRef(oMeme, "Wish I could remember if I saw you before...");
    MeAddStringRef(oMeme, "Hmm...what's that?");
    MeAddStringRef(oMeme, "Walk walk walk, that's my life...that and berries.");
    MeAddStringRef(oMeme, "*snort*");
    MeAddStringRef(oMeme, "*sniff*");
    MeAddStringRef(oMeme, "*snarl*");
    */

    _End("Generator", DEBUG_COREAI);
}


/*-----------------------------------------------------------------------------
 * Generator:  g_combat
 *    Author:  William Bull
 *      Date:  September, 2002
 *   Purpose:  This is a trivial sample of an attack response generator.
 *             It sends some hardcoded signals; has been replaced by
 *             lib_combat. It's to be used for demonstration purposes only.
 -----------------------------------------------------------------------------
 *    Timing:  OnAttack, OnPerception
 *   Message:  Publicly Sends:  "Combat/Attacked"
 *             Publicly Sends:  "Combat/See Enemy"
 -----------------------------------------------------------------------------*/

void g_combat_atk()
{
    _Start("Generator name='Combat' timing='Attacked'");

    struct message stMsg;
    object oSeen = GetLastAttacker();
    if (GetIsEnemy(oSeen))
    {
        stMsg.sMessageName = "Combat/Attacked";
        stMsg.oData = oSeen;
        MeSendMessage(stMsg);
    }

    _End("Generator");
}

void g_combat_see()
{
    _Start("Generator name='Combat' timing='See'");

    struct message stMsg;
    object oSeen = GetLastPerceived();

    if (GetIsEnemy(oSeen))
    {
        _PrintString("I see an enemy.");
        stMsg.sMessageName = "Combat/See Enemy";
        stMsg.oData = oSeen;
        MeSendMessage(stMsg);
    }
    else _PrintString("I see something, but it's not an enemy.");

    _End("Generator");
}

/*-----------------------------------------------------------------------------
 * Generator:  g_mimic
 *    Author:  William Bull
 *      Date:  September, 2002 - November 2003
 *   Purpose:  This is a demonstration librarys which causes two NPCs to echo
 *             what each hears. (Over great distances.) The mimic'ing creatures
 *             must have the same tag. Any number of NPCs can mimic.
 *
 *             This generator makes an e_mimic event handler to speak what is
 *             heard on a channel. This generator listens to what a PC or DM
 *             says and sends a message on a channel. (The channel name is
 *             the tag of the creature.) e_mimic receives the text message and
 *             says it aloud. Basically, this generator is a microphone that
 *             broadcasts PC's words across the channel. This was written to
 *             test communication on multiple channels with multiple NPCs.
 *             Seems to work. :)
 -----------------------------------------------------------------------------
 *    Timing:  Initialization, Conversation
 -----------------------------------------------------------------------------*/

#include "h_library"

void g_mimic_ini()
{
    _Start("MimicText event = 'Initialize' name = '"+_GetName(OBJECT_SELF)+"'", DEBUG_COREAI);

    SetListening(OBJECT_SELF, 1);
    SetListenPattern(OBJECT_SELF, "**");

    object oEvent = MeCreateEvent("e_mimic");
    MeSubscribeMessage(oEvent, "Mimic/Hear", "Mimic_"+GetTag(OBJECT_SELF));

    _End();
}

void g_mimic_tlk()
{
    _Start("MimicText event = 'Hear' name = '"+_GetName(OBJECT_SELF)+"'", DEBUG_COREAI);

    struct message stMsg;

    if (GetIsPC(GetLastSpeaker()) || GetIsDM(GetLastSpeaker()))
    {
        _PrintString("I hear something...", DEBUG_COREAI);

        int nMatch = GetListenPatternNumber();
        int i;
        string s;
        string channel;

        if (nMatch == 0)
        {
            nMatch = GetMatchedSubstringsCount();
            while(i<nMatch)
            {
                s += GetMatchedSubstring(i);
                i++;
            }

            _PrintString("Sending a signal because I heard "+s+".");
            stMsg.sMessageName = "Mimic/Hear";
            stMsg.sData = s;
            MeBroadcastMessage(stMsg, "Mimic_"+GetTag(OBJECT_SELF));
        }
        else _PrintString("I don't know what I heard...", DEBUG_COREAI);
    }

    _End();
}

/*-----------------------------------------------------------------------------
 *    Meme:  e_mimic
 *  Author:  William Bull
 *    Date:  September, 2002
 * Purpose:  This is a cheap debugging event, it just speaks the string that
 *           was sent with the signal. Notice is just adds it to the action queue.
 *           It's used for debugging purposes only.
 -----------------------------------------------------------------------------*/

void e_mimic_go()
{
    struct message stMsg = MeGetLastMessage();

    _PrintString("Speaking "+ stMsg.sData +".", DEBUG_COREAI);

    if (stMsg.sData != "")
    {
        object oMeme = MeCreateMeme("i_say", PRIO_VERYHIGH, 0, MEME_INSTANT);
        MeAddStringRef(oMeme, stMsg.sData);
    }
    MeUpdateActions();
}

// Main: Register Functions & Dispatch -----------------------------------------

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    // Register classes and functions
    if (MEME_DECLARE_LIBRARY)
    {
        MeRegisterClass("greeter");
        MeLibraryImplements("c_greeter",    "_ini", 0x0100+0xff);
        MeLibraryImplements("c_greeter",    "_go",  0x0100+0x01);

        MeRegisterClass("walker");
        MeLibraryImplements("c_walker",     "_go",  0x0200);

        MeLibraryImplements("e_fight",      "_go",  0x0300);

        MeLibraryImplements("e_prioritize", "_go",  0x0400);

        MeLibraryImplements("g_combat",     "_atk", 0x0500+0x01);
        MeLibraryImplements("g_combat",     "_see", 0x0500+0x02);

        MeLibraryImplements("g_goto",       "_see", 0x0600);

        MeLibraryImplements("g_mimic",      "_tlk", 0x0700+0x01);
        MeLibraryImplements("g_mimic",      "_ini", 0x0700+0xff);

        MeLibraryImplements("e_mimic",      "_go",  0x0800);

        MeLibraryFunction("f_go_home",       0x0900);

        MeRegisterClass("merge_test");
        MeLibraryImplements("c_merge_test", "_ini", 0x0a00);
        MeLibraryFunction("f_start_band",    0x0b00);
        MeLibraryFunction("f_high_band",     0x0c00);
        MeLibraryFunction("f_medium_band",   0x0d00);
        MeLibraryFunction("f_low_band",      0x0e00);
        MeLibraryFunction("f_end_band",      0x0f00);

        MeRegisterClass("wolf_pack");
        MeLibraryImplements("c_wolf_pack", "_ini",      0x1000);

        MeRegisterClass("penguin_flock");
        MeLibraryImplements("c_penguin_flock", "_ini",  0x1100);

        MeLibraryImplements("Stool", "_use",            0x1200);

        MeLibraryFunction("f_chest_key",                0x1300);
        MeLibraryImplements("i_retrieve_item", "_go",   0x1400);

        MeLibraryFunction("f_arrest_pc",                0x1500);

        MeRegisterClass("constable");
        MeLibraryImplements("c_constable", "_ini",      0x1600+0xff);
        MeLibraryImplements("c_constable", "_go",       0x1600+0x01);

        MeLibraryImplements("GuardedChest", "_open",    0x1700);

        MeLibraryImplements("e_jail", "_go",            0x1800+0x01);
        MeLibraryImplements("e_jail", "_ini",           0x1800+0xff);

        MeLibraryImplements("i_arrest_pc", "_go",       0x1900+0x01);

        MeLibraryImplements("i_lockup", "_go",          0x1a00+0x01);

        MeLibraryImplements("g_constable", "_see",      0x1b00);

        MeLibraryImplements("TheStocks", "_use",        0x1c00);

        _End();
        return;
    }

    // Dispatch to the function
    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_greeter_ini(); break;
            case 0x01: c_greeter_go(); break;
        }   break;

        case 0x0200: c_walker_go(); break;

        case 0x0300: e_fight_go(); break;

        case 0x0400: e_prioritize_go(); break;

        case 0x0500: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: g_combat_atk();   break;
            case 0x02: g_combat_see();   break;
        }   break;

        case 0x0600: g_goto_see(); break;

        case 0x0700: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: g_mimic_tlk(); break;
            case 0xff: g_mimic_ini(); break;
        }   break;

        case 0x0800: e_mimic_go(); break;

        case 0x0900: MeSetResult(f_go_home(MeGetArgument())); break;

        case 0x0a00: c_merge_test_ini(); break;
        case 0x0b00: MeSetResult(f_start_band(MeGetArgument())); break;
        case 0x0c00: MeSetResult(f_high_band(MeGetArgument())); break;
        case 0x0d00: MeSetResult(f_medium_band(MeGetArgument())); break;
        case 0x0e00: MeSetResult(f_low_band(MeGetArgument())); break;
        case 0x0f00: MeSetResult(f_end_band(MeGetArgument())); break;

        case 0x1000: c_wolf_pack_ini(); break;
        case 0x1100: c_penguin_flock_ini(); break;

        case 0x1200: Stool_use(); break;

        case 0x1300: MeSetResult(f_chest_key(MeGetArgument())); break;
        case 0x1400: i_retrieve_item_go(); break;

        case 0x1500: MeSetResult(f_arrest_pc(MeGetArgument())); break;

        case 0x1600: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: c_constable_go(); break;
            case 0xff: c_constable_ini(); break;
        }   break;

        case 0x1700: GuardedChest_open(); break;

        case 0x1800: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: e_jail_go(); break;
            case 0xff: e_jail_ini(); break;
        }   break;

        case 0x1900: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_arrest_pc_go(); break;
        }   break;

        case 0x1a00: switch (MEME_ENTRYPOINT  & 0x00ff)
        {
            case 0x01: i_lockup_go(); break;
        }   break;

        case 0x1b00: g_constable_see(); break;

        case 0x1c00: TheStocks_use(); break;
    }
    _End();
}
