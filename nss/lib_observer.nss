/*------------------------------------------------------------------------------
 *  Observer Pattern Library
 *
 *  This is a collection of memetic objects that allow you to actively watch
 *  something. When a creature comes within a perceptable range it begins
 *  actively watching (equivalent to polling). When the visitor leaves the
 *  NPCs perception it stops watching. It can be configured to send a message
 *  when it sees various things. This is a rough draft of a robust tracking
 *  system.
 *
 *  A custom event object needs to be written for each observer. This event will
 *  handle the message sent by this observer generator.
 *
 *  At the end of this library you will find a main() function. This contains
 *  the code that registers and runs the scripts in this library. Read the
 *  instructions to add your own objects to this library or to a new library.
 ------------------------------------------------------------------------------*/

#include "h_library"

/*-----------------------------------------------------------------------------
 *    Meme:  g_observer
 *  Author:  William Bull
 *    Date:  November, 2003
 * Purpose:  This is the generator that actively observes. When necessary, it
 *           creates an event object to track what it sees.
 *           You can specify what you want the NPC to take notice of by setting
 *           variables on this generator. It will watch NPCs/DMs/Players and
 *           and continously check your criteria. You will receive an internal
 *           message "Observer/Noticed" if/when the criteria are met.
 *
 *           Internally, this generator makes a private event to handle two
 *           lower-level messages whenever it visually perceives something
 *           appear or disappear. It's more efficient to let the event filter
 *           the things you don't care about and create your own event that is
 *           sensative to the "Observer/Noticed" message. This will let you
 *           receive dedicated messages about armed (or arming) players or
 *           conceivably on-the-fly faction changed NPCs.
 *
 * Message:  Publicly Sends:  "Observer/See"
 *           Publicly Sends:  "Observer/Vanish"
 *           Privately Sends: "Private/Observer/Vanish"
 *           Privately Sends: "Private/Observer/See"
 -----------------------------------------------------------------------------*/

void g_observer_van()
{
    _Start("Observer timing='Vanish'", DEBUG_COREAI);

    object oSeen;
    struct message stMsg;

    oSeen = GetLastPerceived();
    if (GetIsObjectValid(oSeen))
    {
        // Define and send the observation message.
        stMsg.sMessageName = "Private/Observer/Vanish";
        stMsg.oData = oSeen;
        MeSendMessage(stMsg);
    }
    _End();
}

void g_observer_see()
{
    _Start("Observer timing='See'", DEBUG_COREAI);

    object oSeen;
    object oEvent;
    struct message stMsg;

    oSeen  = GetLastPerceived();
    if (GetIsObjectValid(oSeen))
    {
        // This generator makes an "observation" event -- only one at a time.
        // This event loops, watching things when necessary. If there isn't
        // anything to watch it goes away -- efficient polling.
        oEvent = GetLocalObject(MEME_SELF, "ObserveEvent");

        if (!GetIsObjectValid(oEvent))
        {
            oEvent = MeCreateEvent("e_observer");
            SetLocalObject(MEME_SELF, "ObserveEvent", oEvent);
            SetLocalObject(oEvent, "Generator", MEME_SELF);
            MeSubscribeMessage(oEvent, "Private/Observer/Vanish");
            MeSubscribeMessage(oEvent, "Private/Observer/See");

            // These are the public messages that the event will send when it
            // perceives a qualified creature -- appear / vanish

            // A channel could be supplied if you wanted shared observations
            stMsg.sMessageName = "Observe/See";
            stMsg.sChannelName = "";
            MeSetLocalMessage(oEvent, "See", stMsg);

            // A channel could be supplied if you wanted shared observations
            stMsg.sMessageName = "Observe/Vanish";
            stMsg.sChannelName = "";
            MeSetLocalMessage(oEvent, "Vanish", stMsg);
        }

        // Define and send the observation message.
        stMsg.sMessageName = "Private/Observer/See";
        stMsg.oData = oSeen;
        MeSendMessage(stMsg);
    }

    _End();
}

/*-----------------------------------------------------------------------------
 *   Event:  e_observer
 *    Info:  Used to evaluate who has been seen (and if they are still there).
 *  Timing:  Called periodically and in response to a SendSignal call.
 *  Author:  William Bull
 *    Date:  September, 2002
 ------------------------------------------------------------------------------
 *
 ------------------------------------------------------------------------------
 *   Notes:  We use an event because we don't want the process of observation
 *           to interrupt the actions, but we do want it to execute.
 *
 *           This event store variables to remember which NPCs (or players)
 *           it has seen. It store a reference to the seen-object and a number
 *           to remember if the object is a PC, NPC or DM.
 *
 *   Notes:  If you're interested in observation, I would recommend storing
 *           a pair of variables on the observed creature. The first would
 *           be the assertion of its state (ie. armed, dangerous). The second
 *           would be a time that the assertion was made. Use this as a cache
 *           within a period of time. This is cruitial if you had ten guards
 *           in close proximity. It lessens the amount of work they'll all do.
 *
 *           Another approach would be to broadcast the observations on a
 *           channel. Each guard stores what was heard and when it was sent.
 *           The two values used now would turn into three for each seen NPC/PC
 *           on each guard. Obviously the first solution is more efficient but
 *           the second solution is more "correct" and may be lead to other
 *           unforseen benefits.
 */

int HasWeapon     (object oSeen);
int GetShouldWatch(object oSeen, int iWatch);
int GetState      (object oSeen, int iLastState);

void e_observer_go()
{
    _Start("Event name='"+GetLocalString(MEME_SELF,"Name")+"'", DEBUG_COREAI);

    float  UPDATE_TIMEOUT   = 2.0;
    struct message stMsg = MeGetLastMessage();
    struct message stMsgOut;

    object oGenerator     = GetLocalObject(MEME_SELF, "Generator");
    int    iWatch         = GetLocalInt(oGenerator, "Watch");
    float  iTime          = MeGetCurrentGameTime();
    float  iTimeStamp;
    object oSeen = stMsg.oData;                                                 // Get who we saw from the event object
    int    iNotify;
    int    iNewState, iLastState;
    int    i, j;
    int    count, count2;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if (stMsg.sMessageName == "Private/Observer/See")
    {
        _PrintString("I see someone.", DEBUG_COREAI);
        if (GetShouldWatch(oSeen, iWatch))                                      // Are we watching this type of NPC?
        {
            if (GetLocalInt(oSeen, "MEME_PCType") == 0)
            {
                if (GetIsDM(oSeen))      iNewState = NOTIFY_DM;                 // DM?
                else if (GetIsPC(oSeen)) iNewState = NOTIFY_PC;                 // PC?
                else                     iNewState = NOTIFY_NPC;                // NPC?
                SetLocalInt(oSeen, "MEME_PCType", iNewState);                   // Figure this out once, cache it.
            }
            else _PrintString("The PC state is cached.", DEBUG_COREAI);
            MeAddObjectRef(MEME_SELF, oSeen);                                     // Track the person, store an object ref
            MeAddIntRef(MEME_SELF, 0);                                            // The last known state of this NPC
        }
        else _PrintString("I'm not watching for this type.", DEBUG_COREAI);
    }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    else if (stMsg.sMessageName == "Private/Observer/Vanish")                   // Did the NPC just vanish?
    {
        _PrintString("I no longer see someone. ("+_GetName(oSeen)+")", DEBUG_COREAI);
        i = MeHasObjectRef(MEME_SELF, oSeen);                                     // Get where we stored our state info
        if (i != -1)                                                            // If we were tracking this NPC...
        {
            iLastState = MeGetIntByIndex(MEME_SELF, i);

            // Send the public vanish message.
            stMsgOut = MeGetLocalMessage(MEME_SELF, "Vanish");
            stMsgOut.iData = iLastState;
            stMsgOut.oData = oSeen;
            MeBroadcastMessage(stMsgOut, stMsgOut.sChannelName);

            MeRemoveObjectByIndex(MEME_SELF, i);                                  // Stop watching them
            MeRemoveIntByIndex(MEME_SELF, i);                                     // Stop tracking their last state
        }

        _End("Event", DEBUG_COREAI);
        return;
    }

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    count = MeGetObjectCount(MEME_SELF);
    if (MeGetIntCount(MEME_SELF) != count) _PrintString("Whoa! My head hurts!", DEBUG_COREAI);
    for (i = 0; i < count; i++)                                                 // Loop through everyone we've seen.
    {
        _PrintString("Looking at creature "+IntToString(i)+".", DEBUG_COREAI);

        oSeen      = MeGetObjectByIndex(MEME_SELF, i);                            // Get the ref from the array
        iLastState = MeGetIntByIndex(MEME_SELF, i);                               // Get the last reported state
        if (!iLastState) _PrintString("This is the first time I've seen this person.", DEBUG_COREAI);
        if (GetIsObjectValid(oSeen))                                            // If it's still around
        {
            iTimeStamp = GetLocalFloat(oSeen, "MEME_ObservedTimeStamp");        // Get when the last state was evaluated
            iNewState  = GetLocalInt  (oSeen, "MEME_ObservedState");            // Get the last observed NPC state
            _PrintString("Start evaluating (NewState:"
                          +IntToString(iNewState)+", MyLastState:"
                          +IntToString(iLastState)+").", DEBUG_COREAI);
            _PrintString("Latest Time:"+FloatToString(iTimeStamp)+" Current Time "
                          +FloatToString(iTime)+").", DEBUG_COREAI);
            if ((iTimeStamp == 0.0) ||
                (MeGameInterval(iTimeStamp, iTime) >= UPDATE_TIMEOUT))// If its time to reevaluate...
            {
                iNewState  = GetState(oSeen, iLastState);                        // Check out the NPC
                _PrintString("Done evaluating (NewState:"
                              +IntToString(iNewState)+", MyLastState:"
                              +IntToString(iLastState)+").", DEBUG_COREAI);
                SetLocalInt(oSeen, "MEME_ObservedState",
                           iNewState & ~(NOTIFY_APPEAR | NOTIFY_VANISH));       // Record what we saw
                SetLocalFloat(oSeen, "MEME_ObservedTimeStamp", iTime);          // Record when we saw it

                if ((iNewState != iLastState) && (iNewState & iWatch))          // If the state has recently changed
                {                                                               // and I'm watching the change
                    _PrintString("This looks like someone I watch.", DEBUG_COREAI);
                    count2 = MeGetIntCount(oGenerator, "Notify");
                    _PrintString("I appear to be have "+IntToString(count2)+" notification entries.");
                    for (j = 0; j < count2; j++)
                    {
                        iNotify  = MeGetIntByIndex(oGenerator, j, "Notify");
                        iNotify &= ~(NOTIFY_APPEAR | NOTIFY_VANISH);
                        _PrintString("iNewState = "+IntToString(iNewState)+" iNotify = "+IntToString(iNotify)+".", DEBUG_COREAI);
                        if (iNewState & iNotify)
                        {
                            _PrintString("Emitting signal="+IntToString(SIGNAL_OBSERVER)+" state="+IntToString(iNewState)+".", DEBUG_COREAI);

                            if (iNewState & NOTIFY_APPEAR)
                            {
                                // Send the public observation message.
                                stMsgOut = MeGetLocalMessage(MEME_SELF, "See");
                                stMsgOut.iData = iNewState;
                                stMsgOut.oData = oSeen;
                            }
                            else if (iNewState & NOTIFY_VANISH)
                            {
                                // Send the public vanish message.
                                stMsgOut = MeGetLocalMessage(MEME_SELF, "Vanish");
                                stMsgOut.iData = iNewState;
                                stMsgOut.oData = oSeen;
                            }
                            MeBroadcastMessage(stMsgOut, stMsgOut.sChannelName);

                            break;
                        }
                    }
                    if ((j >= count2) && (iLastState == 0))
                    {
                        // Send the public observation message.
                        stMsgOut = MeGetLocalMessage(MEME_SELF, "See");
                        stMsgOut.iData = 0;
                        stMsgOut.oData = oSeen;
                        MeBroadcastMessage(stMsgOut, stMsgOut.sChannelName);
                }
                }
                MeSetIntByIndex(MEME_SELF, i, iNewState);                         // Remember the state we just saw
            }
            else _PrintString("I'm not going to look at him right now...", DEBUG_COREAI);
        }
        else
        {
            _PrintString("Oh crud, something's gone... *poof*", DEBUG_COREAI);

            // Send the public vanish message.
            stMsgOut = MeGetLocalMessage(MEME_SELF, "Vanish");
            stMsgOut.iData = NOTIFY_VANISH | iLastState;
            stMsgOut.oData = oSeen;
            MeBroadcastMessage(stMsgOut, stMsgOut.sChannelName);

            MeRemoveObjectByIndex(MEME_SELF, i);                                  // Stop watching them
            MeRemoveIntByIndex(MEME_SELF, i);                                     // Stop tracking their last state
        }
    }

    // Reschedule with an optional jitter.
    if (MeGetObjectCount(MEME_SELF))
    {
        DelayCommand(UPDATE_TIMEOUT, MeActivateEvent(MEME_SELF));
    }

    _End("Event", DEBUG_COREAI);
}

// Utility for e_observer

int GetShouldWatch(object oSeen, int iWatch)
{
    _Start("GetShouldWatch", DEBUG_COREAI);
    int iResult;

    if (!GetIsObjectValid(oSeen))
    {
        _PrintString("Ick. Don't look at invalid objects, you'll go blind.", DEBUG_COREAI);
        _End("GetShouldWatch", DEBUG_COREAI);
        return 0;
    }

    iResult = 0;
    if ((iWatch & NOTIFY_ENEMY) && (GetIsEnemy(oSeen)))
    {
        _PrintString("Enemy", DEBUG_COREAI);
        _End("GetShouldWatch", DEBUG_COREAI);
        return 1;
    }

    if ((iWatch & NOTIFY_FRIEND) && (!GetIsEnemy(oSeen)))
    {
        _PrintString("Friend", DEBUG_COREAI);
        _End("GetShouldWatch", DEBUG_COREAI);
        return 1;
    }

    if ((iWatch & NOTIFY_DM) && (GetIsPC(oSeen)))
    {
        _PrintString("DM", DEBUG_COREAI);
        _End("GetShouldWatch", DEBUG_COREAI);
        return 1;
    }

    if ((iWatch & NOTIFY_PC) && (GetIsDM(oSeen)))
    {
        _PrintString("PC", DEBUG_COREAI);
        _End("GetShouldWatch", DEBUG_COREAI);
        return 1;
    }

    if ((iWatch & NOTIFY_NPC) && !(GetIsPC(oSeen)) && !(GetIsDM(oSeen)))
    {
        _PrintString("NPC", DEBUG_COREAI);
        _End("GetShouldWatch", DEBUG_COREAI);
        return 1;
    }

    _End("GetShouldWatch", DEBUG_COREAI);
    return 0;
}

// Utility for e_observer

/* We have the opportunity to change how an NPC perceives creatures. If it's
 * dark, if they are hidden, if they are invisible or otherwise enchanted,
 * it may be reasonable for us to overlook them.
 */
int GetState(object oSeen, int iLastState)
{
    int iResult = 0;

    if (iLastState == 0) iResult |= NOTIFY_APPEAR;                              // Appeared?
    if (MeGetIsVisible(oSeen) == 0) iResult |= NOTIFY_VANISH;                     // Disappeared?

    if (GetIsEnemy(oSeen))  iResult |= NOTIFY_ENEMY;                            // Bad?
    else iResult |= NOTIFY_FRIEND;                                              // Good?

    iResult |= GetLocalInt(oSeen, "MEME_PCType");                               // PC, NPC, or DM?

    if (HasWeapon(oSeen)) iResult |= NOTIFY_ARM;                                // Armed?
    else iResult |= NOTIFY_DISARM;                                              // Disarmed?

    if (GetLocalInt(oSeen, "MEME_IsDead") || GetIsDead(oSeen)) iResult |= NOTIFY_DEAD;
    else  iResult |= NOTIFY_ALIVE;

    return iResult;
}

// Utility for e_observer

/* Magic staffs look like walking sticks to guards. */
int HasWeapon(object oSeen)
{
    int iType;

    iType = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oSeen));
    if (iType != BASE_ITEM_INVALID &&
        iType != BASE_ITEM_TOWERSHIELD &&
        iType != BASE_ITEM_SMALLSHIELD &&
        iType != BASE_ITEM_LARGESHIELD &&
        iType != BASE_ITEM_TORCH &&
        iType != BASE_ITEM_QUARTERSTAFF &&
        iType != BASE_ITEM_MAGICSTAFF)
    {
        return 1;
    }

    iType = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oSeen));
    if (iType != BASE_ITEM_INVALID &&
        iType != BASE_ITEM_TOWERSHIELD &&
        iType != BASE_ITEM_SMALLSHIELD &&
        iType != BASE_ITEM_LARGESHIELD &&
        iType != BASE_ITEM_TORCH &&
        iType != BASE_ITEM_QUARTERSTAFF &&
        iType != BASE_ITEM_MAGICSTAFF)
    {
        return 1;
    }

    return 0;
}

/*------------------------------------------------------------------------------
 *   Script: Library Initialization and Scheduling
 *
 *   This main() defines this script as a library. The following two steps
 *   handle registration and execution of the scripts inside this library. It
 *   is assumed that a call to MeLoadLibrary() has occured in the ModuleLoad
 *   callback. This lets the MeExecuteScript() function know how to find the
 *   functions in this library. You can create your own library by copying this
 *   file and editing "cb_mod_onload" to register the name of your new library.
 ------------------------------------------------------------------------------*/

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'");

    //  Step 1: Library Setup
    //
    //  This is run once to bind your scripts to a unique number.
    //  The number is composed of a top half - for the "class" and lower half
    //  for the specific "method". If you are adding your own scripts, copy
    //  the example, make sure to change the first number. Then edit the
    //  switch statement following this if statement.

    if (MEME_DECLARE_LIBRARY)
    {
        // The Observer Event
        MeLibraryImplements("e_observer",   "_go",      0x0100+0x01);

        // The Observer Generator
        MeLibraryImplements("g_observer",   "_see",     0x0200+0x01);
        MeLibraryImplements("g_observer",   "_van",     0x0200+0x02);

        _End("Library");
        return;
    }

    //  Step 2: Library Dispatcher
    //
    //  These switch statements are what decide to run your scripts, based
    //  on the numbers you provided in Step 1. Notice that you only need
    //  an inner switch statement if you exported more than one method
    //  (like go and end). Also notice that the value used by the case statement
    //  is the two numbers added up.

    switch (MEME_ENTRYPOINT & 0xff00)
    {
        // The Observer Event
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
                    {
                        case 0x01: e_observer_go();   break;
                    }   break;

        // The Observer Generator
        case 0x0200: switch (MEME_ENTRYPOINT & 0x00ff)
                    {
                        case 0x01: g_observer_see();     break;
                        case 0x02: g_observer_van();     break;
                    }   break;
    }

    _End("Library");
}
