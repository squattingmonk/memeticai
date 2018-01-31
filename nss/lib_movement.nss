/*------------------------------------------------------------------------------
 * Core Library of Memes
 *
 * This is a library for movement behavior.
 *
 * Created by Dusty Everman 2/9/04
 * i_goto was inspired by the i_move meme written by Lomin Isilmelind in
 * lib_move.
 *
 * Modified by Senach 3/28/04
 * lib_move and lib_movement merged
 *
 * Modified by Lomin 4/6/04
 * Removed i_move and updated i_walkwp
 *-----------------------------------------------------------------------------*/

#include "h_library"

// Prototypes ------------------------------------------------------------------

//Creates a time of day list, sorted by the current time of day
void CreateTimeOfDayList(int iTimeOfDay);

//Returns the increment based upon the "Reverse" -Flag
int GetIncrement();

//Returns the current time of day and creates a list of
int GetTimeOfDay();

//Saves the nearest waypoint on the meme and counts all valid waypoints
//sTag should have the format: <prefix> + <tag of object>
int InitiateWaypointPath(string sTag);

//Returns if the waypoint with the given tag is valid. If it is, the waypoint is
//saved on the meme.
//sTag should have the format: <prefix> + <tag of object>
int SetWaypoint(string sTag);

// Constants -------------------------------------------------------------------

// Names of locals stored on i_goto meme
const string IGOTO_NOT_FIRST_RUN      = "igoto_first";   // FALSE if the meme hasn't run yet.  TRUE if it has run at least once.
const string IGOTO_ACTIVE         = "igoto_active";  // TRUE if the polling should reschedule itself.
const string IGOTO_EVENTS_QUEUED  = "igoto_queued";  // number of polling events that have been scheduled in the future.  Usually this
                                                     // 0 (polling inactive) or 1 (polling will happen in the future), but it
                                                     // could be greater if the polling might be far out in the future and a second
                                                     // one is scheduled for sooner.
const string IGOTO_GO_LAST_LOC    = "igoto_goloc";   // location of the NPC during the last meme _go run
const string IGOTO_POLL_LAST_LOC  = "igoto_pollloc"; // location of the NPC during the last poll run
const string IGOTO_POLL_LL_VALID  = "igoto_llvalid"; // flag indicating thet IGOTO_POLL_LAST_LOC has been set.
const string IGOTO_OTHER_AREA     = "igoto_otharea"; // TRUE if distance check found target to be in a different area than the NPC


// Miscellanious constants
const float  IGOTO_POLL_PERIOD    = 4.0;             // period in seconds of the polling event used to check i_goto failures.
const float  IGOTO_STUCK_RADIUS   = 0.75;            // the maximum distance between two consecutive polling checks that
                                                     //   are still considered to be "not moved".  This is used so that if an
                                                     //   NPC gets stuck and is being wiggled or moved back and forth in a small
                                                     //   area by the Bioware movement routines, the movement will be marked as "stuck".
const float  IGOTO_FAIL_RADIUS    = 2.0;             // the maximum distance between two consecutive failed i_goto interations to
                                                     //   still be considered a single fail point.  Some fix attempts may move
                                                     //   the NPC slightly from the last stuck point, but it should be considered
                                                     //   the same logical failure so more drastic modes of correction can be performed.
const string IGOTO_HELPER_WP      = "wp_igoto";      // tag for a waypoint to be used as an intermediate step
                                                     //   when i_goto has trouble pathfinding.
const float  IGOTO_HELPER_THRESH  = 10.0;            // max distance away a helper waypoint can be from an NPC
                                                     //   for that NPC to use the helper.

// Local Functions -------------------------------------------------------------

// AbortIfPastMaxDist()
//   by Dusty Everman 2/20/04
//
// This routine will abort an i_goto meme if the maximum distance threshold
// between the NPC and the target is exceeded.
//
// The distance to another area is considered infinity, and will always
// abort. However, the first time this routine is called with the target
// in another area, it will not abort the meme.  Instead, it will give the
// NPC one more chance to travel into the new area before aborting
//
// Inputs:
//   oGotoMeme : the meme to be aborted.
//   lTarget   : location of the destination.
//   lNPC      : location of the NPC that is moving.
//   fMaxDist  : distance threshold.
//   bChatty   : TRUE for the NPC to speak that it's aborting due to distance.
//
// Returns:
//    TRUE if the meme was aborted due to the target being to far away.
//    FALSE if the i_goto meme should continue.

int AbortIfPastMaxDist(object oGotoMeme, location lTarget, location lNPC, float fMaxDist, int bChatty)
{
    int bAbort = FALSE;
    int bRet = FALSE;

    // Check if the destination is in a different area.
    if (GetAreaFromLocation(lTarget) != GetAreaFromLocation(lNPC))
    {
        // The destination is in a different area, so distance can't really
        // be measured   Assume infinity.   However, give this NPC a second
        // chance to get to the new area.
        if (GetLocalInt(oGotoMeme, IGOTO_OTHER_AREA))
        {
            bAbort = TRUE;
        }
        else
        {
            SetLocalInt(oGotoMeme, IGOTO_OTHER_AREA, TRUE);
			if (bChatty) SpeakString("I need to go to another area!");
        }
    }
    else
    {
        // The target is in the same area as the NPC.
        SetLocalInt(oGotoMeme, IGOTO_OTHER_AREA, FALSE);

        if (GetDistanceBetweenLocations(lTarget, lNPC) >= fMaxDist)
        {
            bAbort = TRUE;
        }
    }

    if (bAbort)
    {
        _PrintString("i_goto is being aborted due to the target distance being too far away.");
        if (bChatty) SpeakString("The target is too far away.  I quit.");
        MeDestroyMeme(oGotoMeme);
        MeUpdateActions();
        bRet = TRUE;
    }
    return bRet;
}

//------------------------------------------------------------------------------
// PollIGoto()
//   by Dusty Everman 2/19/04
//
// This routine makes any checks required periodically on a running i_goto meme.
// This includes:
//   * Determining if the NPC is stuck in a MoveTo action that won't complete.
//   * Detecting that the target to move to is too far away.
//
// It is assumed that the i_goto meme is currently active.  If the meme isn't
// active, the polling should have been halted through StopPolling,
// which will set flags such that this routine will do nothing and exit
// quietly.
//
// Inputs:
//   oGotoMeme : the meme to be polled while active

void PollIGoto(object oGotoMeme)
{
    _Start("GotoPolling", DEBUG_USERAI);

    int iStuckCount;
    float fDist;
    location lLoc;
	int bChatty  = GetLocalInt(oGotoMeme, "Chatty");

    // Only do work if the polling is marked as being active.
    if (GetLocalInt(oGotoMeme, IGOTO_ACTIVE))
    {
        lLoc = GetLocation(OBJECT_SELF);

        // Check to see if the maximum distance has been violated.
        float fMaxDist = GetLocalFloat(oGotoMeme, "MaxDistance");
        if (fMaxDist > 0.0)
        {
            object oObject = GetLocalObject(MEME_SELF, "Object");
            location lTarget = GetIsObjectValid(oObject) ?
				GetLocation(oObject) :
				GetLocalLocation(MEME_SELF, "Location");
            if (AbortIfPastMaxDist(oGotoMeme, lTarget, lLoc, fMaxDist, bChatty))
            {
                _End();
                return;
            }
        }

        // Check to see if the NPC is stuck.
        if (GetLocalInt(oGotoMeme, IGOTO_POLL_LL_VALID))
        {
            fDist = GetDistanceBetweenLocations(GetLocalLocation(oGotoMeme, IGOTO_POLL_LAST_LOC),lLoc);
            if (fDist != -1.0 /* same area */ && fDist <= IGOTO_STUCK_RADIUS)
            {
                // This NPC has been near the same location for two polling loops and the
                // meme hasn't retried (the retry would reset the polling loop)
                // It must be stuck in a MoveTo that isn't returning on failure.
                _PrintString("Detected a non-returning stuck MoveTo. Aborting meme.");
                MeStopMeme(oGotoMeme);
            }
        }

        // Save the current location for the next polling interation.
        SetLocalLocation(oGotoMeme, IGOTO_POLL_LAST_LOC, lLoc);
        SetLocalInt(oGotoMeme,IGOTO_POLL_LL_VALID, TRUE);

        // Schedule up the next poll event if needed.
        int iQueued = GetLocalInt(oGotoMeme, IGOTO_EVENTS_QUEUED);
        if (iQueued <= 1)
        {
            DelayCommand(IGOTO_POLL_PERIOD, PollIGoto(oGotoMeme));
            // Note: we don't touch IGOTO_EVENTS_QUEUED since we are rescheduling it.
        }
        else
        {
            // One is already scheduled, so this run won't schedule up a new one.
            // As presently designed, this should never happen, but is in place for robustness
            // in case a second polling accidently gets run.  This is also for future expansion
            // to allow polling loops to be scheduled earlier than one previously scheduled
            // (queued up command with DelayCommand can't be deleted).
            SetLocalInt(oGotoMeme, IGOTO_EVENTS_QUEUED, iQueued - 1);
        }
    }
    else
    {
        // Polling is finished.
        // Since this isn't rescheduling itself, reduce the count.
        SetLocalInt(oGotoMeme, IGOTO_EVENTS_QUEUED, GetLocalInt(MEME_SELF, IGOTO_EVENTS_QUEUED)-1);
    }
    _End();
}

//------------------------------------------------------------------------------
// StartPolling()
//   by Dusty Everman 2/19/04
//
// This routine will schedule a new polling event
// (i.e. call PollIGoto() after a delay).
// This should only be called when the i_goto meme is the active meme.
// To stop the polling, StopPolling() should be used, and it should be called
// at any point the i_goto meme becomes inactive.
//
// Inputs:
//   oGotoMeme : the meme to be polled while active

void StartPolling(object oGotoMeme)
{
    // If the polling isn't already active, initialize it.
    if (!GetLocalInt(oGotoMeme, IGOTO_ACTIVE))
    {
        SetLocalInt(oGotoMeme, IGOTO_POLL_LL_VALID, FALSE);
    }

    // Schedule up a new polling event if one isn't already.
    int iQueued = GetLocalInt(oGotoMeme, IGOTO_EVENTS_QUEUED);
    if (iQueued <= 0)
    {
        DelayCommand(IGOTO_POLL_PERIOD, PollIGoto(oGotoMeme));
        SetLocalInt(oGotoMeme, IGOTO_EVENTS_QUEUED, 1);
    }

    SetLocalInt(oGotoMeme, IGOTO_ACTIVE, TRUE);
}

//------------------------------------------------------------------------------
// StopPolling()
//   by Dusty Everman 2/19/04
//
// This routine stops the polling started through StartPolling().
// It is safe to call this routine if polling is currently active or not.
//
// Inputs:
//   oGotoMeme : the meme being polled.

void StopPolling(object oGotoMeme)
{
    // Mark the heart beat inactive so it won't be rescheduled.
    SetLocalInt(oGotoMeme, IGOTO_ACTIVE, FALSE);
}

//------------------------------------------------------------------------------
// IGotoTimeout()
//   by Dusty Everman 2/20/04
//
// This routine will abort an i_goto meme due to a timeout occuring.
// Just call this routine from a DelayCommand to abort the meme.
//
// Inputs:
//   oGotoMeme : the meme to be aborted.
//   bChatty   : TRUE for the NPC to speak that it's timing out.

void IGotoTimeout(object oGotoMeme, int bChatty)
{
    _PrintString("Timeout has occured.  Destroy the i_goto meme.");
    if (bChatty) SpeakString("Too long.  I quit.");
    MeDestroyMeme(oGotoMeme);
    MeUpdateActions();
}

//------------------------------------------------------------------------------
// MoveToHelperWaypoint()
//   by Dusty Everman 2/16/04
//
// This function checks to see if a there are helper waypoints
// nearby to the NPC, and will issue an action to move to that waypoint
// if so.
//
// Inputs:
//   index : 1 = nearest, 2 = second nearest, etc.
// Returns:
//   TRUE if the waypoint existed.  FALSE if no actions were issued.
int MoveToHelperWaypoint(int index, int bChatty)
{
    object oHelper;
    int iRet = FALSE;

    oHelper = GetNearestObjectByTag(IGOTO_HELPER_WP, OBJECT_SELF, index);
    if (oHelper != OBJECT_INVALID)
    {
        if (GetDistanceBetween(oHelper, OBJECT_SELF) < IGOTO_HELPER_THRESH)
        {
            // There is a helper waypoint close by.  Try moving to it.
            if (bChatty) ActionSpeakString("Move to helper wp #"+IntToString(index));
            ActionMoveToObject(oHelper, GetLocalInt(MEME_SELF, "Run"));
            iRet = TRUE;
        }
    }
    return iRet;
}

//------------------------------------------------------------------------------
// MoveBackAndToSide()
//   by Dusty Everman 2/20/04
//
// This function commands the NPC to step back a distance from their target
// destination, and then step to the side a given distance.  This is used
// in an attempt to get an NPC unstuck and be able to move around an object.
// If the destination is in another area, the NPCs current facing is used
// instead of facing towards the target.
//
// Note: No error checking is done on the back and side locations to move to.
//   They could be in a wall, a placeable, or off the map.  The move will just fail.
//
// Inputs:
//   lTarget : location that is stepped away from.
//   lNPC    : location of the NPC.
//   fDist   : distance to step back away from target.
//   fDist   : distance to step sideways facing target.
//   bRight  : TRUE = step right (facing target), FALSE = step left

void MoveBackAndToSide(location lTarget, location lNPC, float fDistBack, float fDistSide, int bRight)
{
    vector vToTarget;
    vector vSide;
    vector vBack;
    float  fBackFacing;
    float  fTargetFacing;
    object oNPCArea;
    vector vTemp;

    // Determine the vector to the target.
    oNPCArea = GetAreaFromLocation(lNPC);
    if (GetAreaFromLocation(lTarget) != oNPCArea)
    {
        // The target is in a different area, and it isn't possible to easily
        // determine where the NPC's exit from this area is.
        // Therefore, we just use the NPC's current facing as the vector
        //  to the desired destination.
        vToTarget = AngleToVector(GetFacingFromLocation(lNPC));
    }
    else
    {
        vToTarget = GetPositionFromLocation(lTarget) - GetPositionFromLocation(lNPC);
    }
    fTargetFacing = VectorToAngle(vToTarget);

    // Calculate back vector and facing.
    vBack.x = -vToTarget.x;
    vBack.y = -vToTarget.y;
    vBack = VectorNormalize(vBack) * fDistBack;
    if (fDistBack <= 2.5)
    {
        // When moving backwards a short distance, just walk
        // backwards, don't turn around.
        fBackFacing = fTargetFacing;
    }
    else
    {
        // Turn around.
        fBackFacing = fTargetFacing + 180.0;
    }


    // Calculate side vector.
    if (bRight)
    {
        // Sidestep to the right.
        vSide.x = vToTarget.y;
        vSide.y = -vToTarget.x;
        vSide = VectorNormalize(vSide) * fDistSide;
    }
    else
    {
        // Sidestep to the left.
        vSide.x = -vToTarget.y;
        vSide.y = vToTarget.x;
        vSide = VectorNormalize(vSide) * fDistSide;
    }

    // Step backward.
    vTemp = GetPositionFromLocation(lNPC);
    vTemp.x += vBack.x;
    vTemp.y += vBack.y;
    ActionMoveToLocation(Location(oNPCArea, vTemp, fBackFacing));

    // then step to the side
    vTemp.x += vSide.x;
    vTemp.y += vSide.y;
    ActionMoveToLocation(Location(oNPCArea, vTemp, fTargetFacing));
}

/*------------------------------------------------------------------------------
*        Meme: i_goto
*  Created By: Dusty Everman
*        Date: 02/09/2004
* Description:
*    This meme moves an NPC to an object or a location.
*    This meme robustly handles movement around placeables and other
*    characters.  However, it does not handle getting through doors.
*    Another meme, such as that generated from g_door, needs to be used to
*    to handle getting through blocked doors.
*
*    Any memes used to get past obstacles such as doors need to be created
*    as child memes to i_goto, and return success status through
*    MeSetMemeResult().  If failure is returned, then i_goto will
*    immediately fail.
*
*    To help with path finding in areas with troublesome placeables or
*    complex tile terrain, the builder can place waypoints with the tag
*    "wp_igoto".  When stuck, the NPC may try to move to these waypoints
*    as an intermediate step.
*    For example, if there is a tight doorway partially obscured by barrels, a helper
*    waypoint could be placed out in the room in front of the door.  If a NPC
*    got stuck on the barrels when trying to go through the door, it might be
*    able to get to the waypoint, then walk cleaning through the doorway.
*
* Input Parameters:
* object "Object"    : The object to move to (if used, "Location" should be invalid)
* location "Location": The location to move to (if used, "Object" should be invalid)
* int "Run"          : If this is TRUE, the NPC will run rather than walk.
* float "MinDistance": Minimum distance to object/location (default: 1.0)
*                      1.0 should be the smallest that this is set, since exact movement
*                      increases the chances of getting stuck and being unable to
*                      complete a move.
* int "MaxRetries"   : Maximum number of times the NPC can be blocked in a
*                      path before the NPC just gives up (default 20).
* int "UsePolling"   : set to TRUE to use a polling mechanism to check for
*                      the NPC getting stuck without a MoveTo action failing
*                      (i.e. the NPC's action queue will never advance).
*                      If you feel confident that the area the NPC is in doesn't
*                      have many complex placeables in it or any placeables near
*                      a tile edge, then you may leave this unset (defaults to FALSE)
*                      If not, set this to TRUE, and a polling mechnism will begin
*                      that periodically checks to see if the NPC is stuck in an
*                      on-going MoveTo command, and will abort and retry if that
*                      situation is detected.  This costs more processing power, but
*                      it is the only way to check for these "bugs" in the Bioware
*                      pathfinding code.
* float "Timeout"    : if set, the meme will abort if the given time has ellapsed
*                      without the NPC getting to its destination.  If not set,
*                      the NPC will chase a moving destination forever.
* float "MaxDistance": Maximum distance between the NPC and its destination before
*                      the NPC aborts the move.  If 0.0, this check won't be made.
*                      Note: if MaxDistance is > 0.0, then the polling loop must
8                      be started even if "UsePolling" is false.
* int "Chatty"       : used for debugging.  TRUE = NPC will say what its thinking.
------------------------------------------------------------------------------*/
void i_goto_ini()
{
    _Start("Goto event = 'ini'", DEBUG_USERAI);

    // Set default parameters.
    // These might be overwritten by the user.
    //SetLocalInt(MEME_SELF, "MaxRetries", 20);
    //SetLocalFloat(MEME_SELF, "MinDistance", 1.0);
    //SetLocalLocation(MEME_SELF, IGOTO_GO_LAST_LOC, GetLocation(OBJECT_SELF));
    //SetLocalInt(MEME_SELF, "UsePolling", 0);
    //SetLocalInt(MEME_SELF, "FailAttempt", 0);
    //SetLocalInt(MEME_SELF, "TotalRetries", -1); // The first time _go is run,
       // TotalRetries will be incremented.  To make the count correct, it is
       // initialized to -1, so the first run will bring it to zero.
    //SetLocalInt(MEME_SELF, IGOTO_POLL_LL_VALID, FALSE);
    //SetLocalInt(MEME_SELF, IGOTO_FIRST_RUN, TRUE);

    _End();
}

void i_goto_brk()
{
    _Start("Goto event='brk'", DEBUG_USERAI);

    StopPolling(MEME_SELF);

    // When _go is run from a resume, it can't really tell the
    // difference between a halt/resume or a blocked move/repeat.
    // It will increment the retry count no matter.  However, a resume isn't really
    // a retry from the perspective of aborting the meme, so we
    // decrement on break knowing that it will get incremented
    // back if the meme resumes.
    SetLocalInt(MEME_SELF, "TotalRetries", GetLocalInt(MEME_SELF, "TotalRetries")-1 );

    _End();
}

void i_goto_end()
{
    _Start("Goto event='end'", DEBUG_USERAI);

    StopPolling(MEME_SELF);

    _End();
}

void i_goto_go()
{
    _Start("Goto event='go'", DEBUG_USERAI);

    int iFailAttempt;
    location lCurrent = GetLocation(OBJECT_SELF);
    float fX, fY;
    location lTargetLocation;
    int bDestInSameArea = TRUE;  // until shown otherwise

    int bChatty = GetLocalInt(MEME_SELF, "Chatty");

    // Do work that is only done the first time the meme is run.
    if (!GetLocalInt(MEME_SELF, IGOTO_NOT_FIRST_RUN))
    {
        SetLocalInt(MEME_SELF, IGOTO_NOT_FIRST_RUN, TRUE);
        float fTimeout = GetLocalFloat(MEME_SELF, "Timeout");
        if (fTimeout > 0.0)
        {
            // A timeout has been specified.  Schedule up a command in the
            // future to abort this meme.  If the meme has already finished,
            // the command will just act on an invalid meme.
            DelayCommand(fTimeout, IGotoTimeout(MEME_SELF, bChatty));
        }
		if (GetLocalInt(MEME_SELF, "MaxRetries") == 0)
			SetLocalInt(MEME_SELF, "MaxRetries", 20);
		if (GetLocalFloat(MEME_SELF, "MinDistance") == 0.0f)
			SetLocalFloat(MEME_SELF, "MinDistance", 1.0);
		SetLocalLocation(MEME_SELF, IGOTO_GO_LAST_LOC, GetLocation(OBJECT_SELF));
		SetLocalInt(MEME_SELF, "FailAttempt", 0);
		SetLocalInt(MEME_SELF, "TotalRetries", -1); // The first time _go is run,
		   // TotalRetries will be incremented.  To make the count correct, it is
		   // initialized to -1, so the first run will bring it to zero.
		SetLocalInt(MEME_SELF, IGOTO_POLL_LL_VALID, FALSE);
    }

    // Did a child meme of i_goto fail?  If so, this meme should abort.
    // TODO! Need to find out how to properly read the return value, and abort on failure.

    // Validate that the move is still valid.  Abort the meme if not.
    float fMinDistance = GetLocalFloat(MEME_SELF, "MinDistance");
    object oObject = GetLocalObject(MEME_SELF, "Object");
    if (oObject != OBJECT_INVALID)
    {
        // Trying to move to an object
        if (!GetIsObjectValid(oObject))
        {
            // An object was specified, but is is now invalid.
            // Perhaps it was killed or destroyed?
            // Abort this meme chain.
            MeSetMemeResult(FALSE);
            MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
            if (bChatty) ActionSpeakString("Destination invalid. I quit.");
            _PrintString("Object to move to is invalid. Abort move.", DEBUG_USERAI);
            _End();
            return;
        }
        else
        {
            lTargetLocation = GetLocation(oObject);
        }
    }
    else
    {
        // Trying to move to a location.
        lTargetLocation = GetLocalLocation(MEME_SELF, "Location");
    }
    if (GetAreaFromLocation(lTargetLocation) != GetAreaFromLocation(lCurrent))
    {
        bDestInSameArea = FALSE;
    }
    float fMaxDist = GetLocalFloat(MEME_SELF, "MaxDistance");
    if (fMaxDist > 0.0)
    {
        SetLocalInt(MEME_SELF, IGOTO_OTHER_AREA, FALSE);
        if (AbortIfPastMaxDist(MEME_SELF, lTargetLocation, lCurrent, fMaxDist, bChatty))
        {
            // Distance was too far away.  Aborted.
            _End();
            return;
        }
    }

    // Has the destination been reached?
    // When checking the distance to the final destination, some slop is added.
    // This is because ActionMoveToObject() will get a distance from the edge of the
    // object, not from its center.  A slop value of .8 will work when attempting to goto
    // a character sitting in a chair.
    if (bDestInSameArea && (GetDistanceBetweenLocations(lCurrent, lTargetLocation) < (fMinDistance + 0.8)))
    {
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        if (bChatty) ActionSpeakString("Success.");
        _PrintString("Close enough to the location.  Success.", DEBUG_USERAI);
        _End();
        return;
    }

    // Start up any polling for this meme if required.
    if (GetLocalInt(MEME_SELF, "UsePolling") || fMaxDist > 0.0)
    {
        StartPolling(MEME_SELF);
    }

    // This destination isn't reached, need to keep trying.
    location lLastLoc = GetLocalLocation(MEME_SELF, IGOTO_GO_LAST_LOC);
    if (GetAreaFromLocation(lLastLoc) != GetAreaFromLocation(lCurrent) ||
        GetDistanceBetweenLocations(lLastLoc,lCurrent) > IGOTO_FAIL_RADIUS)
    {
        if (bChatty) ActionSpeakString("I've moved.");
        _PrintString("The NPC has moved enough since execution of i_goto_go.", DEBUG_USERAI);

        // The NPC has moved since last time.  Either this
        // meme was preempted by anther meme and restarted, or
        // this is a brand new stick point.  We'll assume it's a brand
        // new stick point, since the first failure recovery attempt
        // is just a straight move to the destination (i.e. the handling
        // for a restart or a new stick is the same.)
        SetLocalInt(MEME_SELF, "FailAttempt", 0);
        SetLocalLocation(MEME_SELF, IGOTO_GO_LAST_LOC, lCurrent);
    }
    else
    {
        if (bChatty) ActionSpeakString("I haven't moved.");
    }


    // Keep a tally of all the retries during the full path.
    // Abort if the threshold is exceeded.
    // Note: The very first time the meme is run will count as a "retry",
    //       but it is initialize to -1 to account for this.
    //       If the meme is halted and restarted, this will count as
    //       a "retry" as well, but the _brk will have already decremented
    //       the count to make it proper.
    int iTotalRetries = GetLocalInt(MEME_SELF, "TotalRetries");
    int iMaxRetries = GetLocalInt(MEME_SELF, "MaxRetries");
    if (iTotalRetries >= iMaxRetries)
    {
        // There have been too many blocks in this goto
        // attempt.  The NPC might be stuck ping-ponging
        // between two stick points.  Time to just abort.
        MeSetMemeResult(FALSE);
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        if (bChatty) ActionSpeakString("Too many tries("+IntToString(iTotalRetries)+"). I quit.");
        _PrintString("NPC has attempted restarting its move "+IntToString(iTotalRetries)+" times.", DEBUG_USERAI);
        _PrintString("Aborting the move.", DEBUG_USERAI);
        _End();
        return;
    }
    else
    {
        iTotalRetries++;
        SetLocalInt(MEME_SELF, "TotalRetries", iTotalRetries);
    }

    // Keep a tally of the number of failures at the current
    // stick point.  A new fix attempt is tried each time.
    iFailAttempt = GetLocalInt(MEME_SELF, "FailAttempt");
    iFailAttempt++;

    object   oBlocker;
    vector   vAway;
    location lBlockLoc;

    switch(iFailAttempt)
    {
    case 0:
        // This can't happen, since iFailAttempt is always incremented.
        break;
    case 1:
        // The first time the NPC gets stuck, or the first time the NPC
        //   start the move at the beginning or resuming, just do a plain
        //   old retry.  If the NPC previously moved before getting
        //   stuck, sometimes the path finding derived from the new start
        //   point will fix the problem.
        if (bChatty) ActionSpeakString("Trying normal move.");
        break;

    case 2:
        // If stuck, its a good guess the player is stuck on
        // a placeable.  Try moving away from the nearest placeable.
        oBlocker = GetNearestObject(OBJECT_TYPE_PLACEABLE);
        if (oBlocker != OBJECT_INVALID)
        {
            lBlockLoc = GetLocation(oBlocker);
            if (GetDistanceBetweenLocations(lCurrent, lBlockLoc) < 2.0)
            {
                // There is a placeable close.
                // Calculate a vector away from it.
                vAway = GetPositionFromLocation(lCurrent) - GetPositionFromLocation(lBlockLoc);
                vAway = VectorNormalize(vAway)+ GetPositionFromLocation(lCurrent);
                ActionMoveToLocation(Location(GetAreaFromLocation(lCurrent), vAway, GetFacingFromLocation(lCurrent)), FALSE);

                _PrintString("Attempting to move away from nearest placeable.");
                if (bChatty) ActionSpeakString("Moving away from nearest placeable.");

                // The break on this case statement is only on successful use of this failure mode.
                // Otherwise, we fall through and try the next fix in sequence.
                break;
            }
        }
        _PrintString("No blocking placeable nearby.  Ignoring");
        // Note: No break!  If we got here, this correction attempt can't be used.
        //   We purposely fall through to the next case statement to try the
        //   the next fix.
        iFailAttempt++;

    case 3:
        // Try stepping back a little and side stepping left.
        if (bChatty) ActionSpeakString("Stepping a lil back and left.");
        _PrintString("Move back and left: short.");
        MoveBackAndToSide(lTargetLocation, lCurrent, 0.5, 1.0, FALSE);
        break;

    case 4:
        // Try stepping back a little and side stepping right.
        if (bChatty) ActionSpeakString("Stepping a lil back and right.");
        _PrintString("Move back and right: short.");
        MoveBackAndToSide(lTargetLocation, lCurrent, 0.5, 1.0, TRUE);
        break;

    case 5:
        // Perhaps the builder has placed a helper waypoint in a good spot
        // to help get around complex geometry.
        // Move to that if there is one nearby.
        if (MoveToHelperWaypoint(1, bChatty))
        {
            // There was a waypoint close, and action is in the queue to move to it.
            break;
        }

        // Note: No break!  If we got here, this correction attempt was not valid.  We
        //   purposely fall through to the next case statement to try the
        //   the next fix.
        iFailAttempt++;
        _PrintString("No nearest helper waypoint found.");

    case 6:
        // Perhaps the closest helper waypoint wasn't proper.  Try the next nearest.
        if (MoveToHelperWaypoint(2, bChatty))
        {
            // There was a waypoint close, and action is in the queue to move to it.
            break;
        }

        // Note: No break!  If we got here, this correction attempt was not valid.  We
        //   purposely fall through to the next case statement to try the
        //   the next fix.
        iFailAttempt++;
        _PrintString("No second nearest helper waypoint found.");

    case 7:
        // Try stepping back and side stepping left a bit more.
        if (bChatty) ActionSpeakString("Stepping back and left.");
        _PrintString("Move back and left: medium.");
        MoveBackAndToSide(lTargetLocation, lCurrent, 1.0, 3.0, FALSE);
        break;

    case 8:
        // Try stepping back and side stepping right a bit more.
        if (bChatty) ActionSpeakString("Stepping back and right.");
        _PrintString("Move back and right: medium.");
        MoveBackAndToSide(lTargetLocation, lCurrent, 1.0, 3.0, TRUE);
        break;

    case 9:
        // Try stepping back and side stepping right a whole lot more.
        if (bChatty) ActionSpeakString("Stepping WAY back and left.");
        _PrintString("Move back and left: long.");
        MoveBackAndToSide(lTargetLocation, lCurrent, 2.0, 8.0, FALSE);
        break;

    case 10:
        // Try stepping back and side stepping right a whole lot more.
        if (bChatty) ActionSpeakString("Stepping WAY back and right.");
        _PrintString("Move back and right: long.");
        MoveBackAndToSide(lTargetLocation, lCurrent, 2.0, 8.0, TRUE);
        break;

    default:
        // We've tried everything, and failed.  Time to abort.
        if (bChatty) ActionSpeakString("Tried everything.  I quit.");
        _PrintString("Tried everything.  Abort.");
        MeSetMemeResult(FALSE);
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        _End();
        return;
    }

    // Store the fail state after a failure correct has been chosen (the
    //   failAttempt may have been incremented more than once due to
    //   fall through in the case statements above).
    SetLocalInt(MEME_SELF, "FailAttempt", iFailAttempt);


    // Always finish this meme with the actual move to the target.
/*
//// For some reason I couldn't get forced moves to do any warping.
//// I'd like to have the final step be a warp instead of an abort, but
//// I'm punting for the moment.  Dusty
    if (iFailAttempt > 10)
    {
        // The final straw is to just warp there.
        if (oObject != OBJECT_INVALID)
        {
            _PrintString("Warping to the object, dist ="+FloatToString(fMinDistance), DEBUG_USERAI);
            ActionForceMoveToObject(oObject, FALSE, fMinDistance, 0.0);
            ActionSpeakString("Done with force.");
            ActionWait(12.0);
        }
        else
        {
            _PrintString("Warping to the location", DEBUG_USERAI);
            ActionForceMoveToLocation(lTargetLocation, FALSE, 0.0);
            ActionSpeakString("Done with force loc.");
            ActionWait(12.0);
        }
    }
    else
    {
*/
        if (oObject != OBJECT_INVALID)
        {
            _PrintString("Attempting move to the object", DEBUG_USERAI);
            ActionMoveToObject(oObject, GetLocalInt(MEME_SELF, "Run"), fMinDistance);
        }
        else
        {
            _PrintString("Attempting move to the location", DEBUG_USERAI);
            ActionMoveToLocation(lTargetLocation, GetLocalInt(MEME_SELF, "Run"));
        }
//    }

    _End();
}

void CreateTimeOfDayList(int iTimeOfDay)
{
    if (GetLocalInt(MEME_SELF, "AvoidOtherTrails"))
        switch (iTimeOfDay)
        {
            case 1: MeExplodeList(MEME_SELF, "DAWN", "TimeOfDayList");
            case 2: MeExplodeList(MEME_SELF, "WP,DAY", "TimeOfDayList");
            case 3: MeExplodeList(MEME_SELF, "DUSK", "TimeOfDayList");
            case 4: MeExplodeList(MEME_SELF, "WN,NIGHT", "TimeOfDayList");
        }
    else
        switch (iTimeOfDay)
        {
            case 1: MeExplodeList(MEME_SELF, "DAWN,WP,DAY,WN,NIGHT,DUSK", "TimeOfDayList");
            case 2: MeExplodeList(MEME_SELF, "WP,DAY,DAWN,DUSK,WN,NIGHT", "TimeOfDayList");
            case 3: MeExplodeList(MEME_SELF, "DUSK,WN,NIGHT,WP,DAY,DAWN", "TimeOfDayList");
            case 4: MeExplodeList(MEME_SELF, "WN,NIGHT,DUSK,DAWN,WP,DAY", "TimeOfDayList");
        }
}

int GetIncrement()
{
    return 1 - 2 * GetLocalInt(MEME_SELF, "Reverse");
}

int GetTimeOfDay()
{
    if (GetIsDawn())
    {
        return 1;
    }
    if (GetIsDay())
    {
        return 2;
    }
    if (GetIsDusk())
    {
        return 3;
    }
    return GetIsNight();
}

int InitiateWaypointPath(string sTag)
{
    _Start("InitiateWaypointPath sTag = '" + sTag + "'", DEBUG_COREAI);

    int iIndex = 0;
    float fClosestWP, fCurrentWP;
    object oWaypoint;
    string sSuffix = "_01";
    if (GetLocalInt(MEME_SELF, "NoSuffix"))
        oWaypoint = GetObjectByTag(sTag, 0);
    else
        oWaypoint = GetObjectByTag(sTag + sSuffix);
    fClosestWP = GetDistanceBetween(OBJECT_SELF, oWaypoint);
    while (oWaypoint != OBJECT_INVALID)
    {
        fCurrentWP = GetDistanceBetween(OBJECT_SELF, oWaypoint);
        if (fCurrentWP <= fClosestWP)
        {
            _PrintString("Closest Waypoint: " + GetTag(oWaypoint), DEBUG_COREAI);
            fClosestWP = fCurrentWP;
            SetLocalObject(MEME_SELF, "Waypoint", oWaypoint);
            SetLocalInt(MEME_SELF, "Index", iIndex); //= index of current waypoint
        }
        ++iIndex;
        if (GetLocalInt(MEME_SELF, "NoSuffix"))
            oWaypoint = GetObjectByTag(sTag, iIndex);
        else //suffix formatting
        {
            if (iIndex < 9)
                sSuffix = "_0" + IntToString(iIndex + 1);
            else
                sSuffix = "_" + IntToString(iIndex + 1);
            oWaypoint = GetObjectByTag(sTag + sSuffix);
        }
    }
    _PrintString("Initial Waypoint: " + GetTag(GetLocalObject(MEME_SELF, "Waypoint")), DEBUG_COREAI);
    _End();

    if (iIndex > 0)
    {
        SetLocalInt(MEME_SELF, sTag, iIndex); //f.E. "WP_Hans", "WN_Hans" or "Hans"
        return TRUE;
    }
    else
        return FALSE;
}

int SetWaypoint(string sTag)
{
    _Start("SetWaypoint", DEBUG_COREAI);

    object oWaypoint;
    string sWaypointTag;

    int bNoSuffix = GetLocalInt(MEME_SELF, "NoSuffix");
    int iIndex = GetLocalInt(MEME_SELF, "Index");
    if (!bNoSuffix)
    {
        int iSuffix;
        if (GetLocalInt(MEME_SELF, "Random"))
            iSuffix = Random(GetLocalInt(MEME_SELF, sTag)) + 1;
        else
            iSuffix = iIndex + 1; //BW waypoints start with _01
        string sSuffix;
        if (iSuffix < 9)
            sSuffix = "_0" + IntToString(iSuffix);
        else
            sSuffix = "_" + IntToString(iSuffix);
        sWaypointTag = sTag + sSuffix;
    }
    _PrintString("Searching for Waypoint: " + sWaypointTag, DEBUG_COREAI);

    if (GetLocalInt(MEME_SELF, "Random"))
        oWaypoint = GetObjectByTag(sWaypointTag, Random(GetLocalInt(MEME_SELF, sTag)) * bNoSuffix);
    else
        oWaypoint = GetObjectByTag(sWaypointTag, iIndex * bNoSuffix);

    _PrintString("Waypoint Set: " + GetTag(oWaypoint), DEBUG_COREAI);
    SetLocalObject(MEME_SELF, "Waypoint", oWaypoint);
    _End();
    return GetIsObjectValid(oWaypoint);
}

/*------------------------------------------------------------------------------
*       Meme:  i_walkwp
* Created By:  Lomin Isilmelind
*       Date:  09/23/2003
*Last Update:  01/25/2004 by Lomin Isilmelind
*    Purpose:  Enhanced walk waypoint behaviour
--------------------------------------------------------------------------------
* int "AvoidOtherTrails": If this is TRUE, NPCs will only walk on the trails
                          matching to the current day of time. All other trails
                          will be ignored
* int "NoPrefix": If this is TRUE, standard bioware prefix is turned off
* int "NoSuffix": If this is TRUE, standard bioware suffix is turned off
* int "Random"  : If this is TRUE, the action subject will walk to waypoints at
                  random
* int "Repeat"  : If this is TRUE, the action subject will repeat the waypoints
* int "Loop"    : If this is TRUE, the action subject will loop through the
                  waypoints. Requires 'repeat' to be TRUE
* int "Run"     : If this is TRUE, the action subject will run rather than walk
* string "Tag"  : The tag of the waypoint
------------------------------------------------------------------------------*/

void i_walkwp_ini()
{
    //Local variables saved on a meme are not available in its ini-state, when
    //created for the first time.
    //Considering this, the initiation must be done manually.
    if (!GetLocalInt(MEME_SELF, "InitiationDone"))
        return;

    _Start("WalkWP event = 'Ini'", DEBUG_COREAI);

    //Reset time of day
    int iTimeOfDay = GetTimeOfDay();
    MeDeleteIntRefs(MEME_SELF, "TimeOfDayList");
    CreateTimeOfDayList(iTimeOfDay);
    SetLocalInt(MEME_SELF, "TimeOfDay", iTimeOfDay);
    //Initiating waypoint search
    SetLocalInt(MEME_SELF, "Index", 0);
    string sTag = GetLocalString(MEME_SELF, "Tag");
    if (sTag == "")
    {
        sTag = GetTag(OBJECT_SELF);
        SetLocalString(MEME_SELF, "Tag", sTag);
    }

    // Set previous direction if repeating
    if (GetLocalInt(MEME_SELF, "Repeat"))
    {
        int iPrevious = GetLocalInt(NPC_SELF, sTag + "Reverse");
        if (iPrevious > 0)
        {
            SetLocalInt(MEME_SELF, "Reverse", iPrevious - 1);
            _PrintString("Setting Reverse: " + IntToString(iPrevious - 1), DEBUG_COREAI);
        }
        else
        {
            _PrintString("Initializing " + sTag + "Reverse: " +
                IntToString(GetLocalInt(MEME_SELF, "Reverse")), DEBUG_COREAI);
            SetLocalInt(NPC_SELF, sTag + "Reverse", GetLocalInt(MEME_SELF, "Reverse") + 1);
        }
    }

    //Find first waypoint
    if (!GetLocalInt(MEME_SELF, "NoPrefix"))
    {
        int i = 0;
        string sPrefix = MeGetStringByIndex(MEME_SELF, 0, "TimeOfDayList");
        while (sPrefix != "" && !InitiateWaypointPath(sPrefix + "_" + sTag))
            sPrefix = MeGetStringByIndex(MEME_SELF, ++i, "TimeOfDayList");
        if (i == MeGetStringCount(MEME_SELF, "TimeOfDayList")) //no waypoints found
        {
            InitiateWaypointPath("Post_" + sTag);
            MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        }
    }
    else if (!InitiateWaypointPath(sTag)) //Find waypoints without prefix
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);

    _End();
}

void i_walkwp_go()
{
    //Local variables saved on a meme are not available in its ini-state, when
    //created for the first time.
    //Considering this, the initiation must be done manually.
    if (!GetLocalInt(MEME_SELF, "InitiationDone"))
    {
        i_walkwp_ini();
        SetLocalInt(MEME_SELF, "InitiationDone", TRUE);
    }

    object oWP  = GetLocalObject(MEME_SELF, "Waypoint");
    _Start("WalkWP event = 'Go' Waypoint = '" + GetTag(oWP) + "'", DEBUG_COREAI);

    int iRun = GetLocalInt(MEME_SELF, "Run");

    if (GetLocalInt(MEME_SELF, "StealthMode"))
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);

    if (GetLocalInt(MEME_SELF, "SearchMode"))
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);

    if (GetIsObjectValid(oWP))
    {
        if (!GetLocalInt(MEME_SELF, "Moved"))
        {
            object oMeme = MeCreateMeme("i_goto", PRIO_DEFAULT, 0, MEME_RESUME | MEME_REPEAT, MEME_SELF);
            SetLocalObject(oMeme, "Object", oWP);
            SetLocalInt(oMeme, "Run", iRun);
            //Lock i_move-childmeme
            SetLocalInt(MEME_SELF, "Moved", TRUE);
            MeUpdateActions();
        }
    }

    _End();
}

void i_walkwp_end()
{
    _Start("WalkWP event = 'End'", DEBUG_COREAI);

    //Unlock i_move-childmeme
    DeleteLocalInt(MEME_SELF, "Moved");
    //Check time of day
    if (GetLocalInt(MEME_SELF, "TimeOfDay") != GetTimeOfDay())
    {
        _PrintString("Time of day has changed in the meanwhile");
        _End();
        i_walkwp_ini();
        return;
    }
    //Get next waypoint
    int iIndex = GetLocalInt(MEME_SELF, "Index") + GetIncrement();
    SetLocalInt(MEME_SELF, "Index", iIndex);
    //Tag without prefix nor suffix
    string sTag = GetLocalString(MEME_SELF, "Tag");
    //Search for waypoints with prefix
    if (!GetLocalInt(MEME_SELF, "NoPrefix"))
    {
        int i = 0;
        string sPrefix = MeGetStringByIndex(MEME_SELF, 0, "TimeOfDayList");
        while (sPrefix != "" && !SetWaypoint(sPrefix + "_" + sTag))
            sPrefix = MeGetStringByIndex(MEME_SELF, ++i, "TimeOfDayList");
        if (sPrefix == "") //no waypoints found
        {
            _PrintString("Reseting path");
            // If repeating
            if (GetLocalInt(MEME_SELF, "Repeat"))
            {
                // Flip the order if not looping.
                if (!GetLocalInt(MEME_SELF, "Loop"))
                {
                    int bReverse = !GetLocalInt(MEME_SELF, "Reverse");
                    SetLocalInt(NPC_SELF, sTag + "Reverse", bReverse + 1);
                    SetLocalInt(MEME_SELF, "Reverse", bReverse);
                    _PrintString(sTag + "Reverse switched: " + IntToString(bReverse), DEBUG_COREAI);
                }


                int bReverse = GetLocalInt(MEME_SELF, "Reverse");
                i = 0;
                string sPrefix = MeGetStringByIndex(MEME_SELF, 0, "TimeOfDayList");
                if (bReverse)
                    SetLocalInt(MEME_SELF, "Index", GetLocalInt(MEME_SELF, sPrefix + "_" + sTag) - 1);
                else
                    SetLocalInt(MEME_SELF, "Index", 0);
                while (sPrefix != "" && !SetWaypoint(sPrefix + "_" + sTag))
                {
                    sPrefix = MeGetStringByIndex(MEME_SELF, ++i, "TimeOfDayList");
                    if (bReverse)
                        SetLocalInt(MEME_SELF, "Index", GetLocalInt(MEME_SELF, sPrefix + "_" + sTag) - 1);
                }
                if (sPrefix == "")
                {
                    _PrintString("No valid waypoints or waypoint " + sPrefix + sTag + "_01 is missing!", DEBUG_COREAI);
                    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
                }
            }
            else
            {
                _PrintString("End of waypoints reached, not repeating.", DEBUG_COREAI);
                MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
            }

        }
    }
    //Search for waypoints without prefix
    else if (!SetWaypoint(sTag))
    {
        _PrintString("Resetting Path", DEBUG_COREAI);

        if (GetLocalInt(MEME_SELF, "Repeat"))
        {
            if (!GetLocalInt(MEME_SELF, "Loop"))
            {
                int bReverse = !GetLocalInt(MEME_SELF, "Reverse");
                SetLocalInt(NPC_SELF, sTag + "Reverse", bReverse + 1);
                SetLocalInt(MEME_SELF, "Reverse", bReverse);
                _PrintString(sTag + "Reverse saved: " + IntToString(bReverse), DEBUG_COREAI);
            }
            else
                _PrintString("Looping, Reverse not changed.", DEBUG_COREAI);

            if (GetLocalInt(MEME_SELF, "Reverse"))
                SetLocalInt(MEME_SELF, "Index", GetLocalInt(MEME_SELF, sTag) - 1);
            else
                SetLocalInt(MEME_SELF, "Index", 0);
            if (!SetWaypoint(sTag))
            {
                _PrintString("No valid waypoints or wrong indexing!", DEBUG_COREAI);
                MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
            }
        }
        else
        {
            _PrintString("No more waypoints and not repeating!", DEBUG_COREAI);
            MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        }
    }

    _End();
}

// Should look for Me*Conf() instead.
object f_walk_waypoints(object oArg = OBJECT_INVALID)
{
    _Start("WalkWaypoints", DEBUG_USERAI);

    //SpeakString("Walking waypoints.");

    object oTrail = MeCreateMeme("i_walkwp", PRIO_DEFAULT, 0, MEME_RESUME | MEME_REPEAT);
    SetLocalString(oTrail, "Tag", MeGetLocalString(NPC_SELF, "Tag"));
    SetLocalInt(oTrail, "AvoidOtherTrails", MeGetLocalInt(NPC_SELF, "AvoidOtherTrails"));
    SetLocalInt(oTrail, "NoPrefix", MeGetLocalInt(NPC_SELF, "NoPrefix"));
    SetLocalInt(oTrail, "Repeat", MeGetLocalInt(NPC_SELF, "Repeat"));
    SetLocalInt(oTrail, "Reverse", MeGetLocalInt(NPC_SELF, "Reverse"));
    SetLocalInt(oTrail, "Loop", MeGetLocalInt(NPC_SELF, "Loop"));
    SetLocalInt(oTrail, "Random", MeGetLocalInt(NPC_SELF, "Random"));
    SetLocalInt(oTrail, "Run", MeGetLocalInt(NPC_SELF, "Run"));

    float fTimeout = MeGetLocalFloat(NPC_SELF, "WalkTimeout");
    if (fTimeout == 0.0f) fTimeout = 300.0;
    _PrintString("Stopping walking meme in " + FloatToString(fTimeout) + " secs.", DEBUG_USERAI);

    MeStopMeme(oTrail, fTimeout);

    _End();
    return NPC_SELF;
}

/*----------------------------------------------------------------------------*
 * Script: Library Initialization and Scheduling                              *
 *----------------------------------------------------------------------------*/

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("i_goto",   "_go",  0x0100+0x01);
        MeLibraryImplements("i_goto",   "_brk", 0x0100+0x02);
        MeLibraryImplements("i_goto",   "_end", 0x0100+0x03);
        MeLibraryImplements("i_goto",   "_ini", 0x0100+0xff);

        MeLibraryImplements("i_walkwp", "_go",  0x0300+0x01);
        MeLibraryImplements("i_walkwp", "_end", 0x0300+0x03);
        MeLibraryImplements("i_walkwp", "_ini", 0x0300+0xff);

        MeLibraryFunction("f_walk_waypoints",    0x0400);

        _End();
        return;
    }

    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_goto_go(); break;
            case 0x02: i_goto_brk(); break;
            case 0x03: i_goto_end(); break;
            case 0xff: i_goto_ini(); break;
        }
        break;

        case 0x0300: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: i_walkwp_go(); break;
            case 0x03: i_walkwp_end(); break;
            case 0xff: i_walkwp_ini(); break;
        }
        break;

        case 0x0400: MeSetResult(f_walk_waypoints(MEME_ARGUMENT)); break;
    }
    _End();
}
