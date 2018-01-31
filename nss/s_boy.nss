/*  Script:  Torch Bearing Boy Spawn Script
 *           Copyright (c) 2003 William Bull
 *    Info:  Creates memetic behavior for a boy with a torch surrounded by rats
 *  Timing:  This should be attached to a creature's OnSpawn callback
 *  Author:  William Bull
 *    Date:  April, 2003
 */

#include "h_ai"
#include "h_poi"

void StandAround();

void main()
{
    _Start("Spawn");

    NPC_SELF = MeInit();

    // Because of a bug in the lighting code -- I add a glow on the boy
    // so you can see him.
    object oSelf = OBJECT_SELF;
    DelayCommand(2.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_LIGHT), oSelf));

    object oP = MeCreateMeme("i_wander");
    object oC = MeCreateMeme("i_say", 0, 0, MEME_RESUME, oP);
    MeAddStringRef(oC, "Hello!");
    /* This creates the simplest example of an NPC emitter which communicated
     * to both NPCs and Players. The idea is that this boy holds a torch which
     * keeps some rats at bay. We could
     */
    MeDefineEmitter("Torch Light", // Emitter Name
                    "",            // Player Encounter Dialog
                    "",            // Test Evaluation Function
                    "",            // Enter Function
                    "",            // Exit Function
                    "You enter into the boy's torch light.",   // Enter Text
                    "You leave the boy's torch light.",       // Exit Text
                    EMIT_TO_ALL,   // Who to notify
                    POI_LARGE,     // Distance < 10.0m requires polling -- beware
                    0,             // Amount of time to cache the result of Test Evaluation Function
                    0);            // Amount of time to wait before notifing a second time

    struct message stEnter;
    struct message stLeave;

    // This is the event message that will be sent to NPCs that enter and leave
    // the light area.
    stEnter.sMessageName = "Light/Enter";
    stLeave.sMessageName = "Light/Leave";
    MeDefineEmitterMessage("Torch Light", stEnter, stLeave);

    MeAddEmitterToCreature(OBJECT_SELF, "Torch Light");

    // Let's Chase after these rats
    object oGenerator;
    oGenerator = MeCreateGenerator("g_goto", PRIO_MEDIUM, 20);
    SetLocalString(oGenerator, "SpeakTable", "RatGreet");

    MeDeclareStringRef("RatGreet", oGenerator);
    MeAddStringRef(oGenerator, "Roasted rat!", "RatGreet");
    MeAddStringRef(oGenerator, "Burn icky rats! Burn", "RatGreet");
    MeAddStringRef(oGenerator, "No heartbeat scripts! Hooray!", "RatGreet");
    MeAddStringRef(oGenerator, "Come here ratty!", "RatGreet");
    MeAddStringRef(oGenerator, "Run from my mighty torch!", "RatGreet");
    MeAddStringRef(oGenerator, "Wheeeee!", "RatGreet");
    MeAddStringRef(oGenerator, "Oh yea, rats!", "RatGreet");
    MeAddStringRef(oGenerator, "Go! Go! Go!", "RatGreet");

    MeStartGenerator(oGenerator);

    // Let's occassionally stand around.
    StandAround();
    MeUpdateActions();

    _End("Spawn");
}

// This function declaration is needed so I can call this function inside of
// DelayCommand. See below.
void StandAround();

// So the simple idea is that this function just loops. It calls itself after
// a few seconds, making another meme.
void StandAround()
{
    float iDelay = 7.0 + Random(7);
    object oMeme = GetLocalObject(OBJECT_SELF, "WaitMeme");

    // Once we have "waited" this variable will be invalidated.
    if (!GetIsObjectValid(oMeme))
    {
        oMeme = MeCreateMeme("i_wait", PRIO_MEDIUM, 10, MEME_RESUME | MEME_REPEAT);
        SetLocalFloat(oMeme, "Duration", 3.0);

        // This will make i_say a child of i_wait. As a result, he will first say
        // this, then wait. It's a simple test of the DR5 parent-child code.
        oMeme = MeCreateMeme("i_say", PRIO_MEDIUM, 10, 0, oMeme);
        MeAddStringRef(oMeme, "*whew* Chasing rats is a chore!");

        SetLocalObject(OBJECT_SELF, "WaitMeme", oMeme);
        DelayCommand(15.0, ActionDoCommand(StandAround()));
    }
}
