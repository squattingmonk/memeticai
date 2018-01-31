/*------------------------------------------------------------------------------
 *  Core Library of Trail Memes
 *
 *  This is the default library of memetic objects. It contains patterns
 *  used to navigate trails and interact with landmarks.
 *
 *  At the end of this library you will find a main() function. This contains
 *  the code that registers and runs the scripts in this library. Read the
 *  instructions to add your own objects to this library or to a new library.
 ------------------------------------------------------------------------------*/

#include "h_library"
#include "h_landmark_cli"

void i_gotoarea_ini()
{
    // Set myself to be repeating
    MeSetMemeFlag(MEME_SELF, MEME_REPEAT);

    // This meme either reads the list of legal destination areas from an NPC's conf string
    // or it get the destination area directly.
    
	// these break sequences....
	//SetLocalObject(MEME_SELF, "Area", OBJECT_INVALID);
    //SetLocalString(MEME_SELF, "AreaConfString", "");
}

// This is a repeating meme that divides the problem of finding an area up
// into segments. The memetic scheduler will keep runnig this meme in a loop
// so it will first look for
void i_gotoarea_go()
{

    _Start("GotoArea", DEBUG_COREAI);

    if (MeIsProcessingLandmarks())
    {
        _PrintString("System is starting up. Waiting.");
        ActionWait(4.0);
        _End();
        return;
    }

    object oDestArea = GetLocalObject(MEME_SELF, "Area");
    object oLandmark = GetLocalObject(MEME_SELF, "LocalLandmark");
    object oLocalGateway = GetLocalObject(MEME_SELF, "LocalGateway");
    object oRemoteGateway = GetLocalObject(MEME_SELF, "RemoteGateway");
    string sConfString = GetLocalString(MEME_SELF, "AreaConfString");

    // End if parameters aren't supplied -- no defaults.
    if ((sConfString == "") && (!GetIsObjectValid(oDestArea)))
    {
        _PrintString("Error, improperly created meme, aborting.");
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        _End();
        return;
    }

    // Step 1: Get Closest Trail & Landmark (Using an increasing radius, not just one fixed radius.)
    if (!GetIsObjectValid(oLandmark))
    {
        _PrintString("Finding closest trail");

        // If, for example you wanted to simulate creatures that can get lost
        // depending on how well they can discover trails you can adjust the
        // different radius tests here. In this example the NPC can find
        // trails within 15m. But it tries to find a trail nearby first.
        struct TrailVect_s stTrail = MeFindNearestTrail(OBJECT_SELF, OBJECT_INVALID, 2.0);
        if (!GetIsObjectValid(stTrail.oWaypoint))
        {
            stTrail = MeFindNearestTrail(OBJECT_SELF, OBJECT_INVALID, 5.0);
            if (!GetIsObjectValid(stTrail.oWaypoint))
            {
                stTrail = MeFindNearestTrail(OBJECT_SELF, OBJECT_INVALID, 15.0);
                if (!GetIsObjectValid(stTrail.oWaypoint))
                {
					stTrail = MeFindNearestTrail(OBJECT_SELF, OBJECT_INVALID, 45.0);
					if (!GetIsObjectValid(stTrail.oWaypoint))
					{
						// If I'm lost I send a message to myself, in case some other internal
						// system wants to handle this situation. This is like "throwing an exception" in C++ or Java.
						_PrintString("I can't find a nearby trail. I'm lost! I'll wander for a bit.");
						MeSendMessage(MeCreateMessage("Lost", "I've been asked to go somewhere but I can't find a trail! Help!"));
						SpeakString("I can't find a trail!");
						ActionRandomWalk();
						MeRestartMeme(MEME_SELF, 0, 20.0);
						_End();
						return;
					}
					else
					{
						_PrintString("I found a trail but it's really far away. I'm practically lost. (45.0m)");
					}
                }
                else
                {
                    _PrintString("I found a trail but it's far away. (15.0m)");
                }
            }
            else
            {
                _PrintString("I found a trail just over the hill. I'll probably go to it. (5.0m)");
            }
        }
        else
        {
            _PrintString("I found a trail very nearby to use. (2.0m)");

        }

        SetLocalObject(MEME_SELF, "LocalTrail", stTrail.oTrail);
        object oXXX = MeGetTrailEnd(stTrail.oWaypoint, 1);
        if (GetIsObjectValid(oXXX)) _PrintString("Trail is good.");
        else _PrintString("Trail is not good.");
        SetLocalObject(MEME_SELF, "LocalLandmark", oXXX);
        switch (Random(9))
        {
            case 0: case 1:
                // Just hang out while you think about getting home
                ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_BORED);
                ActionWait(1.0);
                break;
            case 2:
                // Consider your lost sitation
                ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
                break;
            case 3: case 4:  case 5:
                // Look around a bit
                ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT);
                ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT);
                break;
            case 6: case 7: case 8:
                if (!GetIsAreaInterior(GetArea(OBJECT_SELF)))
                {
                    // Look around a bit, more
                    ActionPlayAnimation(ANIMATION_LOOPING_LOOK_FAR, 1.0, 3.0);
                    float fFacing = GetFacing(OBJECT_SELF);
                    ActionDoCommand(SetFacing(fFacing+20.0));
                    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT);
                    ActionDoCommand(SetFacing(fFacing+40.0));
                    ActionPlayAnimation(ANIMATION_LOOPING_LOOK_FAR, 1.0, 3.0);
                 }
                 else ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
                 break;
         }
    }

    // Step 2: Find Closest Local Gateway
    else if (!GetIsObjectValid(oLocalGateway))
    {
        _PrintString("Finding local gateway.");

        object oArea = GetArea(OBJECT_SELF);
        int iGatewayCount = MeGetObjectCount(oArea, LM_Gateway);
        int i;

        // Go to the closest gateway.
        float fShortest = 9999999.0;
        float fTemp;
        object oTemp;
		for (i = 0; i < iGatewayCount; i++)
        {
			oTemp = MeGetObjectByIndex(oArea, i, LM_Gateway);
			fTemp = MeGetShortestDistance(oLandmark, oTemp, OBJECT_INVALID, OBJECT_INVALID);
			if (fTemp < fShortest)
			{
				oLocalGateway = oTemp;
				fShortest = fTemp;
			}
        }

        if (GetIsObjectValid(oLocalGateway))
        {
            _PrintString("I found a reasonable exit from here. ");
        }
        else
        {
            // If I'm lost I send a message to myself, in case some other internal
            // system wants to handle this situation. This is like "throwing an exception" in C++ or Java.
            _PrintString("Oh my, I have no gateways around me - I'm trapped!");
            MeSendMessage(MeCreateMessage("Lost", "Oh my, I have no gateways around me - I'm trapped!"));
            DeleteLocalObject(MEME_SELF, "LocalGateway");
            ActionRandomWalk();
            MeRestartMeme(MEME_SELF, 0, 20.0);
            _End();
            return;
        }

        // Store whatever we selected.
        SetLocalObject(MEME_SELF, "LocalGateway", oLocalGateway);

        // ASSUMPTION: We assume this gateway only lead out to ONE area, though this
        //             IS NOT a requirement of the landmark system, just this algorithm.
        object oTempTrail = MeGetObjectByIndex(oLocalGateway, 0, LM_GateTrail);
        object oTempRemoteGateway = GetLocalObject(oTempTrail, LM_LandmarkFar);

        // As an optimization. If it turns out that the gateway we're about to take
        // leads to where we want to go -- that's all we need to know. That's also
        // the gateway that we want to use. But we may want to go to more than one area

        // Specific Area vs. ConfStringList
        if (GetIsObjectValid(oDestArea))
        {
            if (GetArea(oTempRemoteGateway) == oDestArea)
            {
                _PrintString("I'm really close to that area, let's go there.");
                oRemoteGateway = oTempRemoteGateway;
                SetLocalObject(MEME_SELF, "RemoteGateway", oRemoteGateway);
            }
            else
            {
                oRemoteGateway = OBJECT_INVALID;
                _PrintString("The gateway I'm standing near doesn't take me home, but I'll deal with it.");
            }
        }
        // Use a conf string to get each legal area and see if we can use this gateway
        // to get to the closest safe place, quickest.
        else
        {
            string sAreaTag = MeGetConfString(OBJECT_SELF, sConfString, 1);
            int i;
            object oRemoteArea = GetArea(oRemoteGateway);
            for (i=2; sAreaTag != ""; i++)
            {
                if (oRemoteArea == GetObjectByTag(sAreaTag))
                {
                    _PrintString("I'm really close to that area, let's go there.");
                    oRemoteGateway = oTempRemoteGateway;
                    SetLocalObject(MEME_SELF, "RemoteGateway", oRemoteGateway);
                    break;
                }
                sAreaTag = MeGetConfString(OBJECT_SELF, sConfString, (i+1));
            }
        }
    }

    // Step 3: Find Closest Remote Gateway
    else if (!GetIsObjectValid(oRemoteGateway))
    {
        if (GetIsObjectValid(oDestArea))
        {
            _PrintString("Finding destination gateway to the specified area.");
            oRemoteGateway = MeGetClosestGatewayInArea(oLocalGateway, oDestArea);
        }
        else
        {
            _PrintString("Checking the gateways on the remote areas...");

            string sAreaTag = MeGetConfString(OBJECT_SELF, sConfString, 1);
            int i;

            float fShortest = 9999999.0;
            float fTemp;
            object oTemp;

            for (i=2; sAreaTag != ""; i++)
            {
                GetObjectByTag(sAreaTag);
                oTemp = MeGetClosestGatewayInArea(oLocalGateway, oDestArea);

                fTemp = MeGetShortestDistance(oLocalGateway, oTemp, oLocalGateway, oTemp);
                if (fTemp < fShortest)
                {
                    fShortest = fTemp;
                    oRemoteGateway = oTemp;
                }

                sAreaTag = MeGetConfString(OBJECT_SELF, sConfString, (i+1));
            }
        }
        // Store whatever we selected.
        SetLocalObject(MEME_SELF, "RemoteGateway", oRemoteGateway);
    }

    // Step 4: Create landmark walking child meme
    if (GetIsObjectValid(oRemoteGateway))
    {
        _PrintString("Acceptable route found, creating child meme to go there.");
        object oMeme = MeCreateMeme("i_gotolandmark", PRIO_MEDIUM, 0, 0, MEME_SELF);
        SetLocalObject(oMeme, "Destination", oRemoteGateway);
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    }

    _End();
}

/*-----------------------------------------------------------------------------
 * Function:  i_gotolandmark (Walks the closest trail)
 *   Author:  Daryl Low
 *     Date:  July, 2003
 *  Purpose:  Takes the shortest path to get to the destination. Is smart
 *            enough to traverse between areas if need be.
 *- Input Arguments -----------------------------------------------------------
 * object "Destination": This is the destination landmark
 *- Local State ---------------------------------------------------------------
 * object "DestGate": Destination landmark's gateway (if applicable)
 *
 * object "CurDest":  Current destination (to detect if destination changes)
 * object "CurGate":  Local gateway destination (if applicable)
 * object "CurLM":    Local landmark destination
 * object "CurTrail": Local trail endpoint destination
 * object "CurWP":    Local trail waypoint
 * int    "CurDir":   Direction from waypoint to next landmark
 *
 * object "CurTarget": Curent object we are heading for
 * int    "CurRetry":  Number of failed attempts for the current target
 *
 * location "LastLocation": Last known location before interruption
 *----------------------------------------------------------------------------*/
/*{{{*/
const string Destination  = "Destination";// Destination gateway

const string DestGate     = "DestGate"; // Gateway in the destination's area (cached)

/*
 * Notes: Copmuting the destination gateway is an expensive comparison, so we
 *        cache this to speed things up.
 */
const string CurDest      = "CurDest";  // Detects if destination changes
const string CurGate      = "CurGate";  // Local gateway destination (cached)
const string CurLM        = "CurLM";    // Current landmark we are headed to
const string CurTrail     = "CurTrail"; // Current trail endpoint we are headed to
const string CurWP        = "CurWP";    // Current trail waypoint we are headed to
const string CurDir       = "CurDir";   // Current trail direction we are following

const string CurTarget    = "CurTarget";// Current object we are headed to
const string CurRetry     = "CurRetry"; // Number of failed attempts to get to CurTarget

const string LastLocation = "LastLocation";// Last location before interruption

void _Lost (object oDest)
{
/*{{{*/
    _Start("GotoLandmark state='lost'", DEBUG_COREAI);

    object  oDest   = GetLocalObject(MEME_SELF, Destination);
    object  oChild;

    // Update stored state
    SetLocalObject(MEME_SELF, CurDest, oDest);

    // Clear internal state
    SetLocalObject(MEME_SELF, DestGate,  OBJECT_INVALID);
    SetLocalObject(MEME_SELF, CurGate,   OBJECT_INVALID);
    SetLocalObject(MEME_SELF, CurLM,     OBJECT_INVALID);
    SetLocalObject(MEME_SELF, CurTrail,  OBJECT_INVALID);
    SetLocalObject(MEME_SELF, CurWP,     OBJECT_INVALID);
    SetLocalObject(MEME_SELF, CurTarget, OBJECT_INVALID);
    SetLocalInt   (MEME_SELF, CurDir,    0);

    // Record where we got lost
    SetLocalLocation(MEME_SELF, LastLocation, GetLocation(OBJECT_SELF));

    // Spawn a child to plot our new course
    oChild = MeCreateMeme("i_gotolandmark_lost", PRIO_DEFAULT, 0,
                          MEME_RESUME | MEME_REPEAT, MEME_SELF);
    SetLocalObject(oChild, Destination, oDest);

    _End();
    return;
/*}}}*/
}

void i_gotolandmark_ini()
{
/*{{{*/
    _Start("GotoLandmark event='ini'", DEBUG_COREAI);

    SetLocalLocation(MEME_SELF, LastLocation, GetLocation(OBJECT_SELF));
    SetLocalObject  (MEME_SELF, CurDest,      OBJECT_INVALID);

    /* Must repeat to walk from trail point to trail point. */
    MeAddMemeFlag(MEME_SELF, MEME_REPEAT);

    _End("GotoLandmark", DEBUG_COREAI);
/*}}}*/
}

void i_gotolandmark_go()
{
/*{{{*/
    _Start("GotoLandmark event='go'", DEBUG_COREAI);

    location lLastLoc = GetLocalLocation(MEME_SELF, LastLocation);

    object oDest      = GetLocalObject(MEME_SELF, Destination);
    object oCurDest   = GetLocalObject(MEME_SELF, CurDest);
    object oCurTarget = GetLocalObject(MEME_SELF, CurTarget);

    // XXX - We can get very confused if we use incomplete landmark info
    if (MeIsProcessingLandmarks())
    {
        _PrintString("Waiting for landmarks to finish processing", DEBUG_COREAI);
        _End("GotoLandmark", DEBUG_COREAI);
        return;
    }

    // If we have nowhere to go
    if (!GetIsObjectValid(oDest))
    {
		// added by Olias; 2004/06/02
		// if the local object wasn't valid, maybe the local string is
		string sDest = GetLocalString(MEME_SELF, Destination);
		oDest = GetWaypointByTag(sDest);

		if (sDest == "" || !GetIsObjectValid(oDest))
		{
			// nope, neither one is valid
			_PrintString("Nowhere to go", DEBUG_COREAI);
			_End("GotoLandmark", DEBUG_COREAI);
			return;
		}
    }

    // If we're going to the wrong destination, or going nowhere
    if ((oCurDest != oDest) || (!GetIsObjectValid(oCurTarget)))
    {
        // Try to get unlost
        _Lost(oDest);
        _End("GotoLandmark", DEBUG_COREAI);
        return;
    }

    // If we were going somewhere, use our last known location to see if we're lost
    if (GetIsObjectValid(oCurTarget))
    {
        // Don't bother with distance for cross-area targets
        if (GetArea(OBJECT_SELF) == GetArea(oCurTarget))
        {
            // If we're farther than our last location and beyond reach of our last location
            if (GetDistanceBetween         (OBJECT_SELF, oCurTarget) >
                GetDistanceBetweenLocations(lLastLoc,    GetLocation(oCurTarget)))
            {
                // Go to our last known location first
                ActionDoCommand(ActionMoveToLocation(lLastLoc));
            }
        }

        // Go to our last target object
        _PrintString("Walking to: '"+GetTag(oCurTarget)+"'");
        ActionDoCommand(ActionMoveToObject(oCurTarget));
    }

    _End("GotoLandmark", DEBUG_COREAI);
/*}}}*/
}

void i_gotolandmark_end()
{
/*{{{*/
    _Start("GotoLandmark event='end'", DEBUG_COREAI);

    struct GatewayVect_s    stGateVect;
    struct TrailVect_s      stTrailVect;

    location lLastLoc = GetLocalLocation(MEME_SELF, LastLocation);

    object oDest      = GetLocalObject(MEME_SELF, Destination);
    object oDestGate  = GetLocalObject(MEME_SELF, DestGate);
    object oCurDest   = GetLocalObject(MEME_SELF, CurDest);
    object oCurGate   = GetLocalObject(MEME_SELF, CurGate);
    object oCurLM     = GetLocalObject(MEME_SELF, CurLM);
    object oCurTrail  = GetLocalObject(MEME_SELF, CurTrail);
    object oCurWP     = GetLocalObject(MEME_SELF, CurWP);
    object oCurTarget = GetLocalObject(MEME_SELF, CurTarget);
    int    iDir       = GetLocalInt   (MEME_SELF, CurDir);
    int    iRetry     = GetLocalInt   (MEME_SELF, CurRetry);
    int    bLost      = FALSE;

    // XXX - We can get very confused if we use incomplete landmark info
    if (MeIsProcessingLandmarks())
    {
        _PrintString("Waiting for landmarks to finish processing", DEBUG_COREAI);
        _End("GotoLandmark", DEBUG_COREAI);
        return;
    }

    // If we have nowhere to go
    if (!GetIsObjectValid(oDest))
    {
        _PrintString("I don't have anywhere to go!", DEBUG_COREAI);
        MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
        _End("GotoLandmark", DEBUG_COREAI);
        return;
    }

    // If we're going to the wrong destination, or going nowhere
    if ((oCurDest != oDest) || (!GetIsObjectValid(oCurTarget)))
    {
        _PrintString("Destination has changed!");
        bLost = TRUE;
    }
    // If we're not at our target destination, try again
    else if (GetDistanceBetween(OBJECT_SELF, oCurTarget) > 2.0)
    {
        // If we haven't exceeded our retry count
        if (iRetry < 5)
        {
            _PrintString("Didn't get there yet, trying again");
            SetLocalInt(MEME_SELF, CurRetry, iRetry + 1);
            _End("GotoLandmark", DEBUG_COREAI);
            return;
        }

        bLost = TRUE;
    }

    // Whether we're lost or not, we're done retrying the same spot
    iRetry = 0;
    SetLocalLocation(MEME_SELF, LastLocation, GetLocation(OBJECT_SELF));

    // If we're lost
    if (bLost)
    {
        // Try to get unlost
        _Lost(oDest);
        _End("GotoLandmark", DEBUG_COREAI);
        return;
    }

    // If this is the trail waypoint we were headed to
    if (oCurTarget == oCurWP)
    {
        _PrintString("Got to waypoint");

        // Select the next waypoint
        oCurWP = MeGetTrailNextWP(oCurWP, iDir);
        if (GetIsObjectValid(oCurWP))
        {
            oCurTarget = oCurWP;
        }
        else
        {
            // We're at the end of the trail, walk to the landmark itself
            //oCurTarget = oCurLM;

            // If this is the gateway we were headed to
            if (oCurLM == oCurGate)
            {
                _PrintString("Got to gateway");

                // If we're done
                if (oCurLM == oDest)
                {
                    _PrintString("I'm at my destination, woot!", DEBUG_COREAI);
                    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
                    _End("GotoLandmark", DEBUG_COREAI);
                    return;
                }

                // Figure out what the next gateway is
                stTrailVect = MeGetShortestNextTrail(oCurGate, oDest, oCurGate, oDestGate);

                // Update our course
                oCurWP    = stTrailVect.oWaypoint;
                oCurTrail = stTrailVect.oTrail;
                oCurGate  = stTrailVect.oLandmark;
                oCurLM    = stTrailVect.oLandmark;  // Gateways are landmarks too!
                iDir      = stTrailVect.iDirection;

                oCurTarget = oCurWP;
            }
            // This is the landmark we were headed to
            else
            {
                _PrintString("Got to landmark");

                // If we're done
                if (oCurLM == oDest)
                {
                    _PrintString("I'm at my destination, woot!", DEBUG_COREAI);
                    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
                    _End("GotoLandmark", DEBUG_COREAI);
                    return;
                }

                // Figure out what the next gateway is
                stTrailVect = MeGetShortestNextTrail(oCurLM, oDest, oCurGate, oDestGate);

                // Update our course
                oCurWP    = stTrailVect.oWaypoint;
                oCurTrail = stTrailVect.oTrail;
                oCurLM    = stTrailVect.oLandmark;  // Gateways are landmarks too!
                iDir      = stTrailVect.iDirection;

                oCurTarget = oCurWP;
            }
        }
    }

    _PrintString("New course: oCurWP='"+GetTag(oCurWP)+"' oCurTrail='"+GetTag(oCurTrail)+"' oCurLM='"+GetTag(oCurLM)+"' iDir='"+IntToString(iDir)+"'");

    // Update stored state
    SetLocalObject(MEME_SELF, DestGate,  oDestGate);
    SetLocalObject(MEME_SELF, CurDest,   oCurDest);
    SetLocalObject(MEME_SELF, CurGate,   oCurGate);
    SetLocalObject(MEME_SELF, CurLM,     oCurLM);
    SetLocalObject(MEME_SELF, CurTrail,  oCurTrail);
    SetLocalObject(MEME_SELF, CurWP,     oCurWP);
    SetLocalObject(MEME_SELF, CurTarget, oCurTarget);
    SetLocalInt   (MEME_SELF, CurDir,    iDir);
    SetLocalInt   (MEME_SELF, CurRetry,  iRetry);

    _End("GotoLandmark", DEBUG_COREAI);
/*}}}*/
}

/*
 *  If we are interrupted, we risk being drawn off our path. We want to
 *  remember where we got interrupted. If we stray too far, we really should
 *  look around for another trail that might be closer and will take us to our
 *  destination.
 */
void i_gotolandmark_brk()
{
/*{{{*/
    _Start("GotoLandmark event = 'Break'", DEBUG_COREAI);

    // Interruptions don't count as a retry
    SetLocalInt(MEME_SELF, CurRetry, 0);

    SetLocalLocation(MEME_SELF, LastLocation, GetLocation(OBJECT_SELF));

    _End("GotoLandmark", DEBUG_COREAI);
/*}}}*/
}
/*}}}*/

/*-----------------------------------------------------------------------------
 * Function:  i_gotolandmark_lost (Computes best path to destination)
 *   Author:  Daryl Low
 *     Date:  July, 2003
 *  Purpose:  Takes the shortest path to get to the destination. Is smart
 *            enough to traverse between areas if need be.
 *- Input Arguments -----------------------------------------------------------
 * object "Destination": This is the destination landmark
 *- Output Results (on parent) ------------------------------------------------
 * object "DestGate": Destination landmark's gateway (if applicable)
 * object "CurGate":   First local gateway destination (if applicable)
 * object "CurLM":     First local landmark destination
 * object "CurTrail":  First local trail endpoint destination
 * object "CurWP":     First local trail waypoint
 * object "CurTarget": Will be set to the first local waypoint
 * int    "CurDir":    Direction from first waypoint to first landmark
 *- Local State ---------------------------------------------------------------
 * object "CurDest":   Desintation landmark
 * object "CurLM":     Nearest landmark
 * object "CurWP":     Nearest waypoint
 * int    "CurDir":    Final direction from the waypoint
 *
 * object "LArea":     Local landmark's area
 * object "DArea":     Destination landmark's area
 *
 * object "LGate":     Local candidate gateway
 * object "DGate":     Destination candidate gateway
 * int    "LGate":     Index of local candidate gateway
 * int    "DGate":     Index of destination candidate gateway
 *
 * object "BestLGate": Best local gateway so far
 * object "BestDGate": Best destination gateway so far
 * float  "BestDist":  Best total trip distance so far
 *----------------------------------------------------------------------------*/
/*{{{*/
const string LostState = "LostState";

const string LArea     = "LArea";
const string DArea     = "DArea";
const string LGate     = "LGate";
const string DGate     = "DGate";
const string BestLGate = "BestLGate";
const string BestDGate = "BestDGate";
const string BestDist  = "BestDist";

const int    LOST_ERROR       = -1;
const int    LOST_INIT        = 0;
const int    LOST_SEARCH_INIT = 1;
const int    LOST_SEARCH      = 2;
const int    LOST_DONE        = 3;

void _gotolandmark_lost_init();
void _gotolandmark_lost_done();

void _gotolandmark_lost_init()
{
/*{{{*/
    _Start("_gotolandmark_lost_init", DEBUG_COREAI);

    struct TrailVect_s  stTrailVect;

    object  oParent  = MeGetParentMeme(MEME_SELF);
    object  oCurDest = GetLocalObject(MEME_SELF, Destination);
    object  oCurWP;

    // Find the nearest trail waypoint
    stTrailVect = MeFindNearestTrail (OBJECT_SELF, oCurDest);
    if (!GetIsObjectValid(stTrailVect.oWaypoint))
    {
        _PrintString("Can't find any trails nearby!", DEBUG_COREAI);

        SetLocalInt(MEME_SELF, LostState, LOST_ERROR);
        _PrintString("State: ERROR ("+IntToString(LOST_ERROR)+")");
        _End("_gotolandmark_lost_init", DEBUG_COREAI);
        return;
    }

    // If we've already found a direct route
    if (GetIsObjectValid(stTrailVect.oTrail))
    {
        _PrintString("Found a local route", DEBUG_COREAI);

        // Store the final values
        SetLocalObject(MEME_SELF, CurLM,    stTrailVect.oLandmark);
        SetLocalObject(MEME_SELF, CurWP,    stTrailVect.oWaypoint);
        SetLocalInt   (MEME_SELF, CurDir,   stTrailVect.iDirection);

        SetLocalObject(MEME_SELF, BestLGate, OBJECT_INVALID);
        SetLocalObject(MEME_SELF, BestDGate, OBJECT_INVALID);

        SetLocalInt(MEME_SELF, LostState, LOST_DONE);
        _PrintString("State: DONE ("+IntToString(LOST_DONE)+")");
        _End("_gotolandmark_lost_init", DEBUG_COREAI);
        return;
    }

    // Store the first local trail waypoint
    oCurWP = stTrailVect.oWaypoint;

    // Cache the nearest waypoint and one of the landmarks it leads to
    // This indicates that the initialization completed successfully
    SetLocalObject(MEME_SELF, CurDest, oCurDest);
    SetLocalObject(MEME_SELF, CurLM,   MeGetTrailLandmark(oCurWP, -1));
    SetLocalObject(MEME_SELF, CurWP,   oCurWP);
    SetLocalInt   (MEME_SELF, CurDir,  0);
    _PrintString("CurLM='"+GetTag(MeGetTrailLandmark(oCurWP, -1))+"'");

    // Cache the local and destination areas
    SetLocalObject(MEME_SELF, LArea, GetArea(OBJECT_SELF));
    SetLocalObject(MEME_SELF, DArea, GetArea(oCurDest));

    // Initialize the rest of the internal state
    SetLocalInt(MEME_SELF, LGate, 0);
    SetLocalInt(MEME_SELF, DGate, 0);

    SetLocalObject(MEME_SELF, BestLGate, OBJECT_INVALID);
    SetLocalObject(MEME_SELF, BestDGate, OBJECT_INVALID);

    SetLocalInt(MEME_SELF, LostState, LOST_SEARCH_INIT);
    _PrintString("State: SEARCH_INIT ("+IntToString(LOST_SEARCH_INIT)+")");
    MeAddMemeFlag(MEME_SELF, MEME_RESUME | MEME_REPEAT);
    _End("_gotolandmark_lost_init", DEBUG_COREAI);
    return;
/*}}}*/
}

void _gotolandmark_lost_done()
{
    _Start("_gotolandmark_lost_done", DEBUG_COREAI);

    struct TrailVect_s  stTrailVect;

    object  oParent = MeGetParentMeme(MEME_SELF);
    object  oCurGate;
    object  oCurWP;
    int     iCurDir;

    // Update parent
    if (GetLocalInt(MEME_SELF, LostState) == LOST_DONE)
    {
        _PrintString("Updating Parent");

        oCurGate = GetLocalObject(MEME_SELF, BestLGate);
        oCurWP   = GetLocalObject(MEME_SELF, CurWP);
        iCurDir  = GetLocalInt   (MEME_SELF, CurDir);

        SetLocalObject(oParent, DestGate,  GetLocalObject(MEME_SELF, BestDGate));
        SetLocalObject(oParent, CurGate,   oCurGate);
        SetLocalObject(oParent, CurWP,     oCurWP);
        SetLocalObject(oParent, CurTarget, oCurWP);

        // Decide which way to go on the trail
        if (GetIsObjectValid(oCurGate))
        {
            _PrintString("CurGate is valid.");
            stTrailVect = MeGetShortestTrailFromWP(oCurWP, oCurGate);
        }
        else
        {
            _PrintString("CurGate is not valid.");
            stTrailVect = MeGetShortestTrailFromWP(oCurWP, GetLocalObject(MEME_SELF, CurDest));
        }
        SetLocalObject(oParent, CurLM,    stTrailVect.oLandmark);
        SetLocalObject(oParent, CurTrail, stTrailVect.oTrail);
        SetLocalInt   (oParent, CurDir,   stTrailVect.iDirection);
        MeSetMemeResult(TRUE);
    }

    // Clean-up local variables
    DeleteLocalObject(MEME_SELF, CurDest);
    DeleteLocalObject(MEME_SELF, CurLM);
    DeleteLocalObject(MEME_SELF, CurTrail);
    DeleteLocalObject(MEME_SELF, CurWP);
    DeleteLocalInt   (MEME_SELF, CurDir);

    DeleteLocalObject(MEME_SELF, LArea);
    DeleteLocalObject(MEME_SELF, DArea);

    DeleteLocalObject(MEME_SELF, LGate);
    DeleteLocalObject(MEME_SELF, DGate);
    DeleteLocalInt   (MEME_SELF, LGate);
    DeleteLocalInt   (MEME_SELF, DGate);

    DeleteLocalObject(MEME_SELF, BestLGate);
    DeleteLocalObject(MEME_SELF, BestDGate);
    DeleteLocalFloat (MEME_SELF, BestDist);

    MeClearMemeFlag(MEME_SELF, MEME_REPEAT);
    _End("_gotolandmark_lost_done", DEBUG_COREAI);
}

void i_gotolandmark_lost_ini()
{
/*{{{*/
    _Start("GotoLandmark_Lost state='ini'", DEBUG_COREAI);

    // Default to failure
    MeSetMemeResult(FALSE);

    // Do real initialization when the meme runs
    SetLocalInt(MEME_SELF, LostState, LOST_INIT);

    MeAddMemeFlag(MEME_SELF, MEME_RESUME | MEME_REPEAT);
    _End("GotoLandmark_Lost", DEBUG_COREAI);
/*}}}*/
}

void i_gotolandmark_lost_go()
{
/*{{{*/
    _Start("GotoLandmark_Lost state='go'", DEBUG_COREAI);

    // Do nothing unless we're really searching
    if (GetLocalInt(MEME_SELF, LostState) != LOST_SEARCH)
    {
        _End("GotoLandmark_Lost", DEBUG_COREAI);
        return;
    }

    object  oParent = MeGetParentMeme(MEME_SELF);

    object  oCurLM;
    object  oCurDest;

    object  oLGate;
    object  oDGate;

    string  sLGate;
    string  sDGate;

    object  oBestLGate;
    object  oBestDGate;
    float   fBestDist;

    float   fDist;

    oCurLM = GetLocalObject(MEME_SELF, CurLM);
    oLGate = GetLocalObject(MEME_SELF, LGate);
    sLGate = GetTag(oLGate);

    // If we can get to the local gateway...
    _PrintString("Can '"+GetTag(oCurLM)+"' get to '"+sLGate+"'?");
    if ((oCurLM == oLGate) || (MeGetObjectCount(oCurLM, LM_RouteTrail_+sLGate)))
    {
        oDGate = GetLocalObject(MEME_SELF, DGate);
        sDGate = GetTag(oDGate);

        // ... that can get to the destination gateway...
        _PrintString("Can '"+sLGate+"' get to '"+sDGate+"'?");
        if (MeGetObjectCount(oDGate, LM_GateRouteTrail_+sLGate))
        {
            oCurDest = GetLocalObject(oParent, CurDest);

            // ... that can get to the destination landmark...
            _PrintString("Can '"+sDGate+"' get to '"+GetTag(oCurDest)+"'?");
            if ((oCurDest == oDGate) || (MeGetObjectCount(oCurDest, LM_RouteTrail_+sDGate)))
            {
                oBestLGate = GetLocalObject(MEME_SELF, BestLGate);
                oBestDGate = GetLocalObject(MEME_SELF, BestDGate);
                fBestDist  = GetLocalFloat (MEME_SELF, BestDist);

                fDist = MeGetShortestDistance(oCurLM, oLGate) +
                        MeGetShortestDistance(oLGate, oDGate) +
                        MeGetShortestDistance(oDGate, oCurDest);
                _PrintString("fDist: "+FloatToString(fDist));

                // ... finally is the best so far
                if (!(GetIsObjectValid(oBestLGate)) || (fBestDist > fDist))
                {
                    _PrintString("Candidate: ['"+sLGate+"','"+sDGate+","+FloatToString(fDist)+"]");
                    SetLocalObject(MEME_SELF, BestLGate, oLGate);
                    SetLocalObject(MEME_SELF, BestDGate, oDGate);
                    SetLocalFloat (MEME_SELF, BestDist,  fDist);
                }
            }
        }
    }
    // Otherwise, don't bother with this local gateway
    else
    {
        SetLocalInt(MEME_SELF, CurDir, -1);
    }

    _End("GotoLandmark_Lost", DEBUG_COREAI);
/*}}}*/
}

void i_gotolandmark_lost_end()
{
/*{{{*/
    _Start("GotoLandmark_Lost state='end'", DEBUG_COREAI);

    object  oLArea = GetLocalObject(MEME_SELF, LArea);
    object  oDArea = GetLocalObject(MEME_SELF, DArea);

    int     iLGate;
    int     iDGate;

    int     iState = GetLocalInt(MEME_SELF, LostState);
    _PrintString("State: "+IntToString(iState));

    // Perform initialization here, where we have less chance of TMI
    if (iState == LOST_INIT)
    {
        // Initialize
        _gotolandmark_lost_init();
        _End("GotoLandmark_Lost", DEBUG_COREAI);
        return;
    }

    // If we've already found a destination
    if (iState == LOST_DONE)
    {
        // We're done
        _gotolandmark_lost_done();
        _End("GotoLandmark_Lost", DEBUG_COREAI);
        return;
    }

    // If we've already found a destination
    if (iState == LOST_SEARCH_INIT)
    {
        // Start at [0,0]
        _PrintString("'"+GetTag(oLArea)+"' has "+IntToString(MeGetObjectCount(oLArea, LM_Gateway))+" gateways");
        SetLocalInt   (MEME_SELF, LGate, 0);
        SetLocalObject(MEME_SELF, LGate, MeGetObjectByIndex(oLArea, 0, LM_Gateway));
        SetLocalInt   (MEME_SELF, DGate, 0);
        SetLocalObject(MEME_SELF, DGate, MeGetObjectByIndex(oDArea, 0, LM_Gateway));

        SetLocalInt(MEME_SELF, LostState, LOST_SEARCH);
        _PrintString("State: SEARCH ("+IntToString(LOST_SEARCH)+")");
        _End("GotoLandmark_Lost", DEBUG_COREAI);
        return;
    }

    // Update the for loop counters
    iDGate = GetLocalInt(MEME_SELF, DGate);
    iDGate++;
    if ((iDGate == 0) || (iDGate >= MeGetObjectCount(oDArea, LM_Gateway)))
    {
        iDGate = 0;
        iLGate = GetLocalInt(MEME_SELF, LGate);
        iLGate++;
        if (iLGate >= MeGetObjectCount(oLArea, LM_Gateway))
        {
            // We're done
            SetLocalInt(MEME_SELF, LostState, LOST_DONE);
            _PrintString("State: DONE ("+IntToString(LOST_DONE)+")");
            _End("GotoLandmark_Lost", DEBUG_COREAI);
            return;
        }
        SetLocalInt   (MEME_SELF, LGate, iLGate);
        SetLocalObject(MEME_SELF, LGate, MeGetObjectByIndex(oLArea, iLGate, LM_Gateway));
    }
    SetLocalInt   (MEME_SELF, DGate, iDGate);
    SetLocalObject(MEME_SELF, DGate, MeGetObjectByIndex(oDArea, iDGate, LM_Gateway));

    _PrintString("Will examine: ['"+GetTag(GetLocalObject(MEME_SELF, LGate))+"','"+GetTag(GetLocalObject(MEME_SELF, DGate))+"']");

    _End("GotoLandmark_Lost", DEBUG_COREAI);
/*}}}*/
}
/*}}}*/

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
/*{{{*/
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
        MeLibraryImplements("i_gotolandmark",      "_go",  0x0100+0x01);
        MeLibraryImplements("i_gotolandmark",      "_brk", 0x0100+0x02);
        MeLibraryImplements("i_gotolandmark",      "_end", 0x0100+0x03);
        MeLibraryImplements("i_gotolandmark",      "_ini", 0x0100+0xff);

        MeLibraryImplements("i_gotolandmark_lost", "_go",  0x0200+0x01);
        MeLibraryImplements("i_gotolandmark_lost", "_end", 0x0200+0x03);
        MeLibraryImplements("i_gotolandmark_lost", "_ini", 0x0200+0xff);

        MeLibraryImplements("i_gotoarea",          "_go",  0x0300+0x01);
        MeLibraryImplements("i_gotoarea",          "_ini", 0x0300+0xff);

        //MeLibraryImplements("<name>",        "_go",     0x??00+0x01);
        //MeLibraryImplements("<name>",        "_brk",    0x??00+0x02);
        //MeLibraryImplements("<name>",        "_end",    0x??00+0x03);
        //MeLibraryImplements("<name>",        "_ini",    0x??00+0xff);

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
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
                    {
                        case 0x01: i_gotolandmark_go();  break;
                        case 0x02: i_gotolandmark_brk(); break;
                        case 0x03: i_gotolandmark_end(); break;
                        case 0xff: i_gotolandmark_ini(); break;
                    }   break;

        case 0x0200: switch (MEME_ENTRYPOINT & 0x00ff)
                    {
                        case 0x01: i_gotolandmark_lost_go();  break;
                        case 0x03: i_gotolandmark_lost_end(); break;
                        case 0xff: i_gotolandmark_lost_ini(); break;
                    }   break;

        case 0x0300: switch (MEME_ENTRYPOINT & 0x00ff)
                    {
                        case 0x01: i_gotoarea_go();  break;
                        case 0xff: i_gotoarea_ini(); break;
                    }   break;

        /*
        case 0x??00: switch (MEME_ENTRYPOINT & 0x00ff)
                      {
                          case 0x01: <name>_go();     break;
                          case 0x02: <name>_brk();    break;
                          case 0x03: <name>_end();    break;
                          case 0xff: <name>_ini();    break;
                      }   break;
        */
    }

    _End("Library");
/*}}}*/
}

