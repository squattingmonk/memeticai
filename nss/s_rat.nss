/*  Script:  Sample Rat Script
 *           Copyright (c) 2003 William Bull
 *    Info:  Creates memetic behavior for a rat that avoids the light.
 *  Timing:  This should be attached to a creature's OnSpawn callback
 *  Author:  William Bull
 *    Date:  April, 2003
 */

#include "h_ai"

void main()
{
    _Start("Spawn");

    NPC_SELF = MeInit();

    // Some of the rats wander, some go after the kid
    object oMeme = MeCreateMeme("i_walkwp", 0, 0, MEME_RESUME | MEME_REPEAT);
    object oEvent = MeCreateEvent("e_avoidlight");

    object oGenerator;
    oGenerator = MeCreateGenerator("g_goto", PRIO_MEDIUM, 10);
    // Only goto and growl at players
    SetLocalInt(oGenerator, "TargetPC", 1);
    SetLocalInt(oGenerator, "NoResume", 1);
    MeAddStringRef(oGenerator, "*grrrrr*");
    MeStartGenerator(oGenerator);

    MeUpdateActions();
    _End("Spawn");
}
