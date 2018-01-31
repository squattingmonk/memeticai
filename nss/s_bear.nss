/*  Script:  Bear Spawn Script
 *           Copyright (c) 2002 William Bull
 *    Info:  Creates memetic behavior for a meandering bear.
 *  Timing:  This should be attached to a creature's OnSpawn callback
 *  Author:  William Bull
 *    Date:  September, 2002
 */

#include "h_ai"

void GoTo();
void Wander();
void BoxWalk();

void main()
{
    SetLocalString(OBJECT_SELF, "Name", _GetName(OBJECT_SELF));

    // This will make sure I only trace one dog, to the log.
    //if (GetLocalInt(GetModule(), "TraceDog"))
    //{
    //    MeStartDebugging(DEBUG_UTILITY);
    //    MeAddDebugObject(OBJECT_SELF);
    //}

    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    NPC_SELF = MeInit();
    MeInstanceOf(NPC_SELF, "generic, greeter");

/*
    BoxWalk();        // 1. Walk the four example waypoints.
    Wander();         // 2. Create a reprioritizing wander behavior.
    GoTo();           // 3. React to things you see.
    MeUpdateActions();  // 4. Start the memetic toolkit.

*/
    _End("OnSpawn");
}

//--------- Memetic Setup Functions --------------------------------------------

// This is a trivial generator -- when it sees something, it creates a
// high priority meme that forces the dog to go to it.
// Refer to the script: "g_goto_see" if you are interested in how it does this.

void GoTo()
{
    object oGenerator;

    oGenerator = MeCreateGenerator("g_goto", PRIO_MEDIUM, 20);
    MeAddStringRef(oGenerator, "*sniff*");
    MeAddStringRef(oGenerator, "*hmm...you are very attractive.*");
    MeStartGenerator(oGenerator);
}


// ---- Let's simulate a distracted nature by occassionally wandering... -------
//
// Events can fire at a scheduled time (i.e. in five minutes or at 5:00pm). This will
// demonstrate how the e_prioritize event can cause a behavior to cycle between
// being more or less important.
//
// Notice that the i_wander meme is created with the MEME_REPEAT flag.
// This means that this will continuously loop - wandering forever. But the
// MEME_RESUME flag means that if some other behavior interrupts it, it should
// stay around, dormant, waiting for its chance to continue wandering.
//
// In this example, the wander behavior will get interrupted because the
// prioritization event makes the it less important than other behaviors,
// such as walking around.
//
// -----------------------------------------------------------------------------

void Wander()
{
    object oMeme, oEvent;

    oMeme = MeCreateMeme("i_wander", PRIO_LOW, 0, MEME_RESUME | MEME_REPEAT);

    // We want this event to keep changing the priority up and down
    // so we add the MEME_REPEAT flag. Not every event repeats, this
    // particular event is coded to honor the flag.
    oEvent = MeCreateEvent("e_prioritize");

    // Attach memes to be reprioritized
    MeAddObjectRef(oEvent, oMeme, "Meme");

/* Here's what the meme's priority values will look like, over time:

       0----1----2----3----4----5----6----7----8----9---10---11---12---13---14--
       .                                                          |
    VH .                                                          |
       . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . .
       .                                                          |
     H .                                                          |
       . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|. . . . . . .
       .                                                          |
     M (------------------,                                       |               -50
       . . . . . . . . . .|_______________ . . . . .______________|. . . . . . .  -100
       .                                  |         |             |
     L .                                  |_________|             Restart         -50
       . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .| . . . . . . . -100
       .                                                          |
     N .                                                          |
       0----1----2----3----4----5----6----7----8----9---10---11---12---13---14--   Seconds

                             Oscillating Reprioritization Schedule
                          (It goes: ...up and down...up and down...)
*/

    // The jitter value slightly adjusts the amount of delay -- this prevents
    // a few dogs from getting into obvious sync. You don't want behavioral
    // changes to be apparent. After all, they are supposed to look natural.

    // First step...
    MeAddIntRef(oEvent, PRIO_MEDIUM, "Priority");
    MeAddIntRef(oEvent, -50, "Modifier");
    MeAddFloatRef(oEvent, 4.0, "Delay");
    MeAddIntRef(oEvent, 4, "DelayJitter");

    // Second step...
    MeAddIntRef(oEvent, PRIO_MEDIUM, "Priority");
    MeAddIntRef(oEvent, -100, "Modifier");
    MeAddFloatRef(oEvent, 3.0, "Delay");
    MeAddIntRef(oEvent, 3, "DelayJitter");

    // Third step...
    MeAddIntRef(oEvent, PRIO_LOW, "Priority");
    MeAddIntRef(oEvent, -50, "Modifier");
    MeAddFloatRef(oEvent, 3.5, "Delay");
    MeAddIntRef(oEvent, 1, "DelayJitter");

    // Fourth step...
    MeAddIntRef(oEvent, PRIO_MEDIUM, "Priority");
    MeAddIntRef(oEvent, -100, "Modifier");
    MeAddFloatRef(oEvent, 3.0, "Delay");
    MeAddIntRef(oEvent, 3, "DelayJitter");

    // Important

    // The next line of code will kick off a reprioritization loop based on the
    // delays.

    MeActivateEvent(oEvent);
}

// ---- Set up a simplest series of straight line movements... -----------------
//
// This is normally done with a WalkWP meme, but this is just an example to
// demonstrate sequences that can be interrupted by other behaviors and
// resumed. When this runs, the dog may decide to wander or go check something
// out. It will autoresume doing this behavior once those behaviors complete.
//
// -----------------------------------------------------------------------------
void BoxWalk()
{
    object oSequence;
    object oMeme;
    oSequence = MeCreateSequence("box walk");

    oMeme = MeCreateSequenceMeme(oSequence, "i_goto");
    MeAddObjectRef(oMeme, GetWaypointByTag("WP_01"), "TargetObject");
    MeAddStringRef(oMeme, "*growl* A corner!", "SuccessString");

    oMeme = MeCreateSequenceMeme(oSequence, "i_goto");
    MeAddObjectRef(oMeme, GetWaypointByTag("WP_02"), "TargetObject");
    MeAddStringRef(oMeme, "*snort* A corner!", "SuccessString");

    oMeme = MeCreateSequenceMeme(oSequence, "i_goto");
    MeAddObjectRef(oMeme, GetWaypointByTag("WP_03"), "TargetObject");
    MeAddStringRef(oMeme, "*arf* A corner!", "SuccessString");

    oMeme = MeCreateSequenceMeme(oSequence, "i_goto");
    MeAddObjectRef(oMeme, GetWaypointByTag("WP_04"), "TargetObject");
    MeAddStringRef(oMeme, "*snarl* A corner!", "SuccessString");

    MeStartSequence(oSequence);
}
