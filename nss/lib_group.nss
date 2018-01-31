//::///////////////////////////////////////////////
//:: Neverwinter Nights Flocking script
//:: mje_flocking_01
//:: Copyright (c) 2003 Michael England
//:://////////////////////////////////////////////
/*
    This script is a nwscript implementation of
    Craig Reynold's 1987 a-life classic 'Boids'.

    The intent of the script is to give creatures
    realistic flocking movement. This is done by
    giving each creature a simple set of rules
    to follow:
       -- avoid crowding flockmates
       -- fly in the direction in which flockmates
          are flying
       -- fly towards nearby flockmates
       -- maintain current direction (my rule)

    The interaction of these simple rules results in
    complex behaviour... what the a-life folks like
    to call emergence.
*/
//:://////////////////////////////////////////////
//:: Version: 0.1
//:: Created By: Michael England
//:: Created On: 1/10/2003
//:://////////////////////////////////////////////

/*
 *  Modified for use with the Memetic Toolkit
 *  Senach, 04/01/04
 */

#include "h_library"
#include "h_group"

#include "x0_i0_position"

// Determine the new location to which the current creature should move
location GetGroupLocation(object self);

// Implementation---------------------------------------------------------------
/*
 * Determine the new location to which the current creature
 * should move
 */
location GetFlockLocation(object oTarget = OBJECT_SELF)
{
    _Start("GetFlockLocation", DEBUG_UTILITY);

    // where we are
    location selfLocation = GetLocation(oTarget);
    vector selfVector = GetPositionFromLocation(selfLocation);

    _PrintString("Self Vector: " + VectorToString(selfVector), DEBUG_UTILITY);

    // where we want to go
    location resultLocation;
    vector heading = Vector(0.0f, 0.0f, 0.0f);

    // first calculate the impact of our friends
    heading = CalculateFriendAffectVector(oTarget, selfVector);
    _PrintString("Friend Affect Vector: " + VectorToString(heading), DEBUG_UTILITY);

    // add our current heading into the mix
    // This is optional?
    //vector selfDirection = CalculateSelfDirectionVector(self);
    //heading = heading + selfDirection;
    //_PrintString("Heading + Direction Vector: " + VectorToString(heading), DEBUG_UTILITY);

    // add current waypoint, if available
    vector waypointDirection;
    object oWalk = MeGetMeme("i_walkwp");
    if (oWalk != OBJECT_INVALID)
    {
        object oWP  = GetLocalObject(MEME_SELF, "Waypoint");
        waypointDirection = GetPositionFromLocation(GetLocation(oWP));
        waypointDirection *= MeGetLocalFloat(MEME_SELF, "WaypointWeight");
        heading = heading + waypointDirection;
        _PrintString("Heading + Waypoint Direction Vector: " + VectorToString(heading), DEBUG_UTILITY);
    }
    else
    {
        _PrintString("No waypoints found.", DEBUG_UTILITY);
    }

    // and add the edge-avoidance heading in, too
    vector edgeAvoidance = CalculateEdgeAvoidanceVector(oTarget);
    heading = heading + edgeAvoidance;
    _PrintString("Heading + Edge Vector: " + VectorToString(heading), DEBUG_UTILITY);

    // normalize one last time
    heading = VectorNormalize(heading);

    // and multiply by the step size
    heading = heading * MeGetLocalFloat(MEME_SELF, "StepSize");
    _PrintString("Final Heading Vector: " + VectorToString(heading), DEBUG_UTILITY);

    // and calc the final location towards which we will move
    resultLocation = GetTargetLocation(GetArea(oTarget), selfVector, heading);

    _End();
    return resultLocation;
}

// Memes -----------------------------------------------------------------------

void i_flock_ini()
{
    _Start("Flock timing='ini'"); //, DEBUG_COREAI);

    //------------------ Misc. Control Variables ----------------
    // Step size of each move.
    MeSetLocalFloat(MEME_SELF, "StepSize", 8.0f);

    // The max distance away from friends before running.
    MeSetLocalFloat(MEME_SELF, "MaxDistance", 10.0f);

    // The distance under which attraction turns to repulsion
    MeSetLocalFloat(MEME_SELF, "RepelLimit", 2.0f);

    // the max distance at which friends are noticed
    MeSetLocalFloat(MEME_SELF, "AttractLimit", 40.0f);

    //---------------------- Vector Weights ---------------------
    // importance of avoiding the edge of the map
    MeSetLocalFloat(MEME_SELF, "EdgeAvoidWeight", 2.0f);

    // the importance of our own current direction
    MeSetLocalFloat(MEME_SELF, "SelfDirectionWeight", 1.0f);

    // the importance of the current direction of our friends
    MeSetLocalFloat(MEME_SELF, "FriendDirectionWeight", 5.0f);

    // the importance of avoiding nearby friends
    MeSetLocalFloat(MEME_SELF, "RepelWeight", 2.0f);

    // the importance of moving towards friends
    MeSetLocalFloat(MEME_SELF, "AttractWeight", 5.0f);

    _End();
}

void i_flock_go()
{
    _Start("Flock timing='go'", DEBUG_COREAI);

    // Any group members within perception range?
    float fAttractLimit = MeGetLocalFloat(MEME_SELF, "AttractLimit");
    _PrintString("AttractLimit: " + FloatToString(fAttractLimit), DEBUG_COREAI);

    object oNearest = GetNearestGroupMember(OBJECT_SELF, "Default", fAttractLimit);

    if (oNearest == OBJECT_INVALID)
    {
        _PrintString("No group members perceived nearby. Aborting flock.", DEBUG_COREAI);
        //ActionSpeakString("No group members perceived nearby. Aborting flock.");
        //ActionWait(2.0);
        MeSetPriority(MEME_SELF, PRIO_NONE);
        _End();
        return;
    }

    // Calculate our new location
    location loc = GetFlockLocation(OBJECT_SELF);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_FLAG_GOLD), loc, 1.0f);

    object oGoto = MeCreateMeme("i_goto", PRIO_DEFAULT, 50, MEME_RESUME, MEME_SELF);
    SetLocalLocation(oGoto, "Location", loc);

    /*
    if (fDistance > MeGetLocalFloat(MEME_SELF, "MaxDistance"))
    {
        SetLocalInt(oGoto, "Run", TRUE);
    }
    */

    MeUpdateActions();
    _End();
}

void i_flock_brk()
{
    _Start("Flock timing='brk'", DEBUG_COREAI);

    _PrintString("Setting priority to NONE.", DEBUG_COREAI);
    MeSetPriority(MEME_SELF, PRIO_NONE, 0, TRUE);
    //MeUpdateActions();

    _End();
}

// Classes ---------------------------------------------------------------------

void c_flock_follower_ini()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_TOOLKIT);

    MeAddResponse(MEME_SELF, "Flock Table", "f_flock_tight", 80, RESPONSE_HIGH);
    MeAddResponse(MEME_SELF, "Flock Table", "f_flock_loose", 80, RESPONSE_MEDIUM);
    MeSetActiveResponseTable("Idle", "Flock Table");

    _End();
}

object f_flock_loose(object oArg = OBJECT_INVALID)
{
    _Start("Flock type='Loose'", DEBUG_COREAI);

    // Any group members within perception range?
    object oNearest = GetNearestGroupMember(OBJECT_SELF, "Default");

    if (oNearest == OBJECT_INVALID)
    {
        _PrintString("No group members perceived nearby. Aborting flock.", DEBUG_COREAI);
        //ActionSpeakString("No group members perceived nearby. Aborting flock.");
        //ActionWait(2.0);
        _End();
        return OBJECT_INVALID;
    }

    object oFlock = MeGetMeme("i_flock", 0, PRIO_NONE);

    if (oFlock == OBJECT_INVALID)
    {
        _PrintString("Creating new Flock meme.", DEBUG_COREAI);
        oFlock = MeCreateMeme("i_flock", PRIO_DEFAULT, 0, MEME_RESUME | MEME_REPEAT);
    }
    else
    {
        _PrintString("Reprioritizing existing Flock meme.", DEBUG_COREAI);
        MeSetPriority(oFlock, PRIO_DEFAULT, 0, TRUE);
    }

    MeSetLocalFloat(oFlock, "StepSize", 15.0f);
    MeSetLocalFloat(oFlock, "MaxDistance", 8.0f);
    MeSetLocalFloat(oFlock, "SelfDirectionWeight", 2.0f);
    MeSetLocalFloat(oFlock, "FriendDirectionWeight", 3.0f);
    MeSetLocalFloat(oFlock, "RepelWeight", 5.0f);
    MeSetLocalFloat(oFlock, "AttractWeight", 2.0f);
    //MeSetLocalInt(oFlock, "MemberLimit", 6);

    MeStopMeme(oFlock, 6.0+3.0*Random(6));

    _End();
    return oFlock;
}

object f_flock_tight(object oArg = OBJECT_INVALID)
{
    _Start("Flock type='Tight'", DEBUG_COREAI);

    // Any group members within perception range?
    object oNearest = GetNearestGroupMember(OBJECT_SELF, "Default");

    if (oNearest == OBJECT_INVALID)
    {
        _PrintString("No group members perceived nearby. Aborting flock.", DEBUG_COREAI);
        //ActionSpeakString("No group members perceived nearby. Aborting flock.");
        //ActionWait(2.0);
        _End();
        return OBJECT_INVALID;
    }

    object oFlock = MeGetMeme("i_flock", 0, PRIO_NONE);

    if (oFlock == OBJECT_INVALID)
    {
        _PrintString("Creating new Flock meme.", DEBUG_COREAI);
        oFlock = MeCreateMeme("i_flock", PRIO_DEFAULT, 0, MEME_RESUME | MEME_REPEAT);
    }
    else
    {
        _PrintString("Reprioritizing existing Flock meme.", DEBUG_COREAI);
        MeSetPriority(oFlock, PRIO_DEFAULT, 0, TRUE);
    }
    MeSetLocalFloat(oFlock, "StepSize", 8.0f);
    MeSetLocalFloat(oFlock, "MaxDistance", 5.0f);
    MeSetLocalFloat(oFlock, "AttractLimit", 40.0f);

    MeSetLocalFloat(oFlock, "SelfDirectionWeight", 1.0f);
    MeSetLocalFloat(oFlock, "FriendDirectionWeight", 2.0f);
    MeSetLocalFloat(oFlock, "RepelWeight", 5.0f);
    MeSetLocalFloat(oFlock, "AttractWeight", 6.0f);
    MeSetLocalFloat(oFlock, "WaypointWeight", 3.0f);

    MeStopMeme(oFlock, 6.0+3.0*Random(6));

    _End();
    return oFlock;
}

/*------------------------------------------------------------------------------
 * Library Functions
 -----------------------------------------------------------------------------*/

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("i_flock",          "_go",      0x0100+0x01);
        MeLibraryImplements("i_flock",          "_brk",     0x0100+0x02);
        MeLibraryImplements("i_flock",          "_ini",     0x0100+0xff);

        MeRegisterClass("flock_follower");
        MeLibraryImplements("c_flock_follower", "_ini",     0x0200+0xff);

        MeLibraryFunction("f_flock_loose",      0x0300);
        MeLibraryFunction("f_flock_tight",      0x0400);

        _End();
        return;
    }

    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_flock_go(); break;
            case 0x02: i_flock_brk(); break;
            case 0xff: i_flock_ini(); break;
        }   break;

        case 0x0200: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_flock_follower_ini(); break;
        }   break;

        case 0x0300: MeSetResult(f_flock_loose(MEME_ARGUMENT)); break;
        case 0x0400: MeSetResult(f_flock_tight(MEME_ARGUMENT)); break;
    }

    _End();
}
