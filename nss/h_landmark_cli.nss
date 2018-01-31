/*
 *     file: h_landmark_cli
 *  authors: Daryl Low
 * modified: July 6, 2003
 *
 * Copyright 2003. For non-commercial use only.
 * Contact bbull@qnx.com with questions.
 */

#include "h_landmark_com"

//{{{ --- Public Synchronization Prototypes -----------------------------------
int MeIsProcessingLandmarks();
//}}}

//{{{ --- Public Shortest Path Prototypes -------------------------------------
void MeShortestPathTest(object oObj, string sStart, string sStartArea, string sEnd, string sEndArea, int bDone = FALSE);
int  MeShortestPathInit(object oObj, object oStart, object oEnd, object oStartGate = OBJECT_INVALID, object oEndGate = OBJECT_INVALID);
int  MeShortestPathGo  (object oObj);
int  MeShortestPathDone(object oObj);

void   MeWalkShortestPathTest(object oObj, int bDone = FALSE);
int    MeWalkShortestPathInit(object oObj);
object MeWalkShortestPathNext(object oObj, int bForce = FALSE);
int    MeWalkShortestPathDone(object oObj);
//}}}

//{{{ --- Public Shortest Path Prototypes -------------------------------------
object MeGetClosestGatewayInArea(object oLocalGateway, object oDestArea);
struct TrailVect_s   MeGetShortestTrailFromWP(object oWP, object oDest);

struct GatewayVect_s MeGetShortestGateway  (object oLandmark, object oDest);
struct TrailVect_s   MeGetShortestNextTrail(object oLandmark, object oDest, object oGate = OBJECT_INVALID, object oDestGate = OBJECT_INVALID);

float MeGetShortestDistance(object oLandmark, object oDest, object oGate = OBJECT_INVALID, object oDestGate = OBJECT_INVALID);
//}}}

//{{{ --- Public Trail Prototypes ---------------------------------------------
object MeGetFirstNearestTrail(object oSelf = OBJECT_SELF, int Nth = 1, float fDistance = 5.0);
object MeGetNextNearestTrail (object oSelf = OBJECT_SELF, int Nth = 1, float fDistance = 5.0);

struct TrailVect_s MeFindNearestTrail (object oSelf = OBJECT_SELF, object oLandmark = OBJECT_INVALID, float fDistance = 5.0);

object MeGetTrailEnd      (object oWP, int iDirection);
object MeGetTrailNextWP   (object oWP, int iDirection);

int    MeGetTrailDirection(object oTrail, object oLandmark);
object MeGetTrailLandmark (object oTrail, int iDirection);
float  MeGetTrailLength   (object oTrail, int iDirection);
//}}}

//{{{ --- Public Landmark Prototypes ------------------------------------------
object MeGetReachableLandmarkCount  (object oLandmark);
object MeGetReachableLandmarkByIndex(object oLandmark, int iIndex = 0);

object MeGetReachableGateawyCount  (object oLandmark);
object MeGetReachableGatewayByIndex(object oLandmark, int iIndex = 0);

object MeGetAdjacentLandmarkCount  (object oLandmark);
object MeGetAdjacentLandmarkByIndex(object oLandmark, int iIndex = 0);

object MeGetAdjacentTrailCount   (object oLandmark, object oDest);
object MeGetAdjacentTrailByIndex (object oLandmark, object oDest, int iIndex);
//}}}

//{{{ --- Public Gateway Prototypes -------------------------------------------
int    MeIsGateway(object oLandmark);

object MeGetReachableAreaCount  (object oGateway);
object MeGetReachableAreaByIndex(object oGateway, int iIndex = 0);
//}}}

//{{{ --- Public Synchronization Functions ------------------------------------
int MeIsProcessingLandmarks()
{
/*{{{*/
    _Start("MeIsProcessingLandmarks", DEBUG_TOOLKIT);

    object oModule = GetModule();

    _End("MeIsProcessingLandmarks", DEBUG_TOOLKIT);
    return GetLocalInt(oModule, LM_Busy);
/*}}}*/
}
//}}}

//{{{ --- Public Shortest Path Functions  -------------------------------------
object MeGetClosestGatewayInArea(object oLocalGateway, object oDestArea)
{
    object oRemoteGateway = OBJECT_INVALID;
    int    iGatewayCount = MeGetObjectCount(oDestArea, LM_LWGate);
    float  fShortest = 9999999.0;
    float  fTemp = 999999.0;
    object oTemp = OBJECT_INVALID;
    int i;

    for (i = 0; i < iGatewayCount; i++)
    {
        oTemp = MeGetObjectByIndex(oDestArea, i, LM_LWGate);
        fTemp = MeGetFloatByIndex(oTemp, i, LM_LWGateRouteWeight_+GetTag(oLocalGateway));
        if (fTemp < fShortest) oRemoteGateway = oTemp;
    }
    return oRemoteGateway;
}

struct TrailVect_s MeGetShortestTrailFromWP(object oWP, object oDest)
{
/*{{{*/
    _Start("MeGetShortestTrailFromWP oWP='"+GetTag(oWP)+"' oDest='"+GetTag(oDest)+"'", DEBUG_TOOLKIT);

    struct  TrailVect_s      stTrail;

    object  oLM1 = MeGetTrailLandmark(oWP, 1);
    object  oLM2 = MeGetTrailLandmark(oWP, -1);

    string  sLM1  = GetTag(oLM1);
    string  sLM2  = GetTag(oLM2);
    string  sDest = GetTag(oDest);

    int     iNextLM1 = GetLocalInt(oLM1, LM_LWRouteShortest_+sDest);
    int     iNextLM2 = GetLocalInt(oLM1, LM_LWRouteShortest_+sDest);

    object  oNextLM1 = MeGetObjectByIndex(oLM1, iNextLM1, LM_LWRouteTrail_+sDest);
    object  oNextLM2 = MeGetObjectByIndex(oLM2, iNextLM2, LM_LWRouteTrail_+sDest);

    float   fNextLM1 = MeGetFloatByIndex(oLM1, iNextLM1, LM_LWRouteWeight_+sDest);
    float   fNextLM2 = MeGetFloatByIndex(oLM2, iNextLM2, LM_LWRouteWeight_+sDest);

    stTrail.oWaypoint  = OBJECT_INVALID;
    stTrail.oTrail     = OBJECT_INVALID;
    stTrail.oLandmark  = OBJECT_INVALID;
    stTrail.iDirection = 0;

    if ((!GetIsObjectValid(oNextLM1)) && (!GetIsObjectValid(oNextLM2)))
    {
        _End("MeGetShortestTrailFromWP", DEBUG_TOOLKIT);
        return (stTrail);
    }

    if (!GetIsObjectValid(oNextLM1))
    {
        stTrail.oTrail     = oNextLM2;
        stTrail.oLandmark  = MeGetTrailLandmark(oWP, -1);
        stTrail.iDirection = -1;
    }
    else if (!GetIsObjectValid(oNextLM2))
    {
        stTrail.oTrail     = oNextLM1;
        stTrail.oLandmark  = MeGetTrailLandmark(oWP, 1);
        stTrail.iDirection = 1;
    }
    else if (fNextLM2 <= fNextLM1)
    {
        stTrail.oTrail     = oNextLM2;
        stTrail.oLandmark  = MeGetTrailLandmark(oWP, -1);
        stTrail.iDirection = -1;
    }
    else
    {
        stTrail.oTrail     = oNextLM1;
        stTrail.oLandmark  = MeGetTrailLandmark(oWP, 1);
        stTrail.iDirection = 1;
    }
    stTrail.oWaypoint = oWP;

    _End("MeGetShortestTrailFromWP", DEBUG_TOOLKIT);
    return (stTrail);
/*}}}*/
}

struct GatewayVect_s MeGetShortestGateway(object oLandmark, object oDest)
{
/*{{{*/
    _Start("MeGetShortestGateway oLandmark='"+GetTag(oLandmark)+"' oDest='"+GetTag(oDest)+"'", DEBUG_TOOLKIT);

    struct GatewayVect_s stBest;

    object  oArea;
    object  oDestArea;
    object  oLGate;
    object  oDGate;
    int     iLGateCount;
    int     iDGateCount;
    int     iLGate;
    int     iDGate;
    float   fDist;
    float   fBestDist;

    // Initialize
    stBest.oGate     = OBJECT_INVALID;
    stBest.oDestGate = OBJECT_INVALID;
    oArea            = GetArea(oLandmark);
    oDestArea        = GetArea(oDest);

    // Of all the local gateways...
    iLGateCount = MeGetObjectCount(oArea, LM_LWGate);
    for (iLGate = 0; iLGate < iLGateCount; iLGate++)
    {
        oLGate = MeGetObjectByIndex(oArea, iLGate, LM_LWGate);

        // ... that we can get to...
        if (MeGetObjectCount(oLandmark, LM_LWRouteTrail_+GetTag(oLGate)))
        {
            // ... Of all the destination gateways...
            iDGateCount = MeGetObjectCount(oDestArea, LM_LWGate);
            for (iDGate = 0; iDGateCount; iDGate++)
            {
                oDGate = MeGetObjectByIndex(oDestArea, iDGate, LM_LWGate);

                // ... that can get to the destination landmark...
                if (MeGetObjectCount(oDest, LM_LWRouteTrail_+GetTag(oDGate)))
                {
                    // ... and reach our local gateway...
                    if (MeGetObjectCount(oDGate, LM_LWGateRouteTrail_+GetTag(oLGate)))
                    {
                        fDist = MeGetShortestDistance(oLandmark, oLGate) +
                                MeGetShortestDistance(oLGate,    oDGate) +
                                MeGetShortestDistance(oDGate,    oDest);

                        // ... and is the shortest so far
                        if (!(GetIsObjectValid(stBest.oGate)) || (fBestDist > fDist))
                        {
                            stBest.oGate     = oLGate;
                            stBest.oDestGate = oDGate;
                            fBestDist        = fDist;
                        }
                    }
                }
            }
        }
    }

    _End("MeGetShortestGateway", DEBUG_TOOLKIT);
    return (stBest);
/*}}}*/
}

struct TrailVect_s MeGetShortestNextTrail(object oLandmark, object oDest, object oGate = OBJECT_INVALID, object oDestGate = OBJECT_INVALID)
{
/*{{{*/
    _Start("MeGetShortestNextTrail oLandmark='"+GetTag(oLandmark)+"' oDest='"+GetTag(oDest)+"' oGate='"+GetTag(oGate)+"' oDestGate='"+GetTag(oDestGate)+"'", DEBUG_TOOLKIT);

    struct TrailVect_s      stTrail;
    struct GatewayVect_s    stGate;

    string  sDest;
    int     index;

    stTrail.oWaypoint = OBJECT_INVALID;

    // If we're looking in the same area
    if (GetArea(oLandmark) == GetArea(oDest))
    {
        // Find the shortest route to the destination
        sDest             = GetTag(oDest);
        index             = GetLocalInt       (oLandmark,        LM_LWRouteShortest_+sDest);
        stTrail.oWaypoint = MeGetObjectByIndex(oLandmark, index, LM_LWRouteTrail_   +sDest);

        // Note: If the area is partitioned, we'll fall through to the longer search
    }

    // We're looking for the next step in a long journey (expensive)
    if (!GetIsObjectValid(stTrail.oWaypoint))
    {
        // Determine whether have enough gateway info already
        if ((!GetIsObjectValid(oGate)) || (!GetIsObjectValid(oDestGate)) ||
            (GetArea(oLandmark) != GetArea(oGate)) ||
            (GetArea(oDest) != GetArea(oDestGate)))
        {
            // Do expensive search for where we want to go
            PrintString("ASSERT: Asking for TMI trouble here!");
            //stGate = MeGetShortestGateway(oLandmark, oDest);

            stTrail.oWaypoint  = OBJECT_INVALID;
            stTrail.oTrail     = OBJECT_INVALID;
            stTrail.oLandmark  = OBJECT_INVALID;
            stTrail.iDirection = 0;
            return (stTrail);
        }
        else
        {
            stGate.oGate     = oGate;
            stGate.oDestGate = oDestGate;
        }

        // If we're already at the local gateway
        if (stGate.oGate == oLandmark)
        {
            // Cross into another area
            sDest             = GetTag(stGate.oDestGate);
            index             = GetLocalInt       (oLandmark,        LM_LWGateRouteShortest_+sDest);
            stTrail.oWaypoint = MeGetObjectByIndex(oLandmark, index, LM_LWGateRouteTrail_   +sDest);
        }
        else
        {
            // Head to the local gateway
            sDest             = GetTag(stGate.oGate);
            index             = GetLocalInt       (oLandmark,        LM_LWRouteShortest_+sDest);
            stTrail.oWaypoint = MeGetObjectByIndex(oLandmark, index, LM_LWRouteTrail_   +sDest);
        }
    }

    // Determine the direction
    if (MeGetSuffix(GetTag(stTrail.oWaypoint)) == "01") stTrail.iDirection = 1;
    else                                                stTrail.iDirection = -1;

    // Figure out which endpoint and landmark we are headed to
    stTrail.oTrail    = GetLocalObject(stTrail.oWaypoint, LM_TWFar);
    stTrail.oLandmark = GetLocalObject(stTrail.oWaypoint, LM_LWFar);

    _End("MeGetShortestNextTrail", DEBUG_TOOLKIT);
    return (stTrail);
/*}}}*/
}

float MeGetShortestDistance(object oLandmark, object oDest, object oGate = OBJECT_INVALID, object oDestGate = OBJECT_INVALID)
{
/*{{{*/
    _Start("MeGetShortestDistance oLandmark='"+GetTag(oLandmark)+"' oDest='"+GetTag(oDest)+"' oGate='"+GetTag(oGate)+"' oDestGate='"+GetTag(oDestGate)+"'", DEBUG_TOOLKIT);

    string  sTag;
    object  oArea     = GetArea(oLandmark);
    object  oDestArea = GetArea(oDest);
    float   fDist;
    int     index;

    if (oArea != oDestArea)
    {
        // Sanity checks
        if ((oArea != GetArea(oGate)) || (oDestArea != GetArea(oDestGate)))
        {
            _End("MeGetShortestDistance", DEBUG_TOOLKIT);
            return (-1.0);
        }

        // Distance oLandmark -> oGate
        sTag  = GetTag(oGate);
        index = GetLocalInt      (oLandmark,        LM_LWRouteShortest_+sTag);
        fDist = MeGetFloatByIndex(oLandmark, index, LM_LWRouteWeight_  +sTag);

        // Distance oGate -> oDestGate
        sTag   = GetTag(oDestArea)+GetTag(oDestGate);
        index  = GetLocalInt      (oGate,        LM_LWGateRouteShortest_+sTag);
        fDist += MeGetFloatByIndex(oGate, index, LM_LWGateRouteWeight_  +sTag);

        // Distance oDestGate -> oDest
        sTag   = GetTag(oDest);
        index  = GetLocalInt      (oDestGate,        LM_LWRouteShortest_+sTag);
        fDist += MeGetFloatByIndex(oDestGate, index, LM_LWRouteWeight_  +sTag);
    }
    else if (oLandmark != oDest)
    {
        // Distance oLandmar -> oDest
        sTag  = GetTag(oDest);
        index = GetLocalInt      (oLandmark,        LM_LWRouteShortest_+sTag);
        fDist = MeGetFloatByIndex(oLandmark, index, LM_LWRouteWeight_  +sTag);
    }
    else
    {
        return (0.0);
    }

    _End("MeGetShortestDistance", DEBUG_TOOLKIT);
    return (fDist);
/*}}}*/
}
//}}}

//{{{ --- Public Trail Functions ----------------------------------------------
struct TrailVect_s MeFindNearestTrail(object oSelf, object oDest = OBJECT_INVALID, float fTolerance = 2.0)
{
/*{{{*/
    _Start("MeFindNearestTrail oSelf='"+GetTag(oSelf)+"' oDest='"+GetTag(oDest)+"' fTolerance='"+FloatToString(fTolerance)+"'", DEBUG_TOOLKIT);

    struct TrailVect_s  stTrail;
    string              sDest;
    string              sWP;
    string              sPrefix;
    string              sSuffix;
    object              oWP;
    object              oFirstWP;
    object              oStartLM;
    object              oEndLM;
    location            lLandmark;
    float               fStartDist;
    float               fEndDist;
    float               fTrailDist;

    // Get the nearest trail
    lLandmark = GetLocation(oSelf);
    oWP = GetFirstObjectInShape(SHAPE_CUBE, fTolerance, lLandmark, FALSE, OBJECT_TYPE_WAYPOINT);
    while (GetIsObjectValid(oWP))
    {
        // Don't mistake any ordinary waypoint for a trail waypoint
        sWP = GetTag(oWP);
		// Olias: was originally "Trail_"
        if (GetStringLeft(sWP, 3) == LM_LT_) break;

        oWP = GetNextObjectInShape(SHAPE_CUBE, fTolerance, lLandmark, FALSE, OBJECT_TYPE_WAYPOINT);
    }

    stTrail.oWaypoint  = OBJECT_INVALID;
    stTrail.oTrail     = OBJECT_INVALID;
    stTrail.oLandmark  = OBJECT_INVALID;
    stTrail.iDirection = 0;

    // Handle not found case
    if (!GetIsObjectValid(oWP))
    {
        _End("MeFindNearestTrail", DEBUG_TOOLKIT);
        return (stTrail);
    }

    // If we just want any trail
    if (!GetIsObjectValid(oDest))
    {
        stTrail.oWaypoint = oWP;
    }
    // Otherwise, find the best trail to get us where we want to go
    else
    {
        // Just in case there's no better way
        stTrail.oWaypoint  = oWP;

        sDest = GetTag(oDest);
        while (GetIsObjectValid(oWP))
        {
            sPrefix = MeGetPrefix(sWP);
            sSuffix = MeGetSuffix(sWP);

            oFirstWP = GetWaypointByTag(sPrefix + "01");
            oStartLM = GetLocalObject(oFirstWP, LM_LWNear);
            oEndLM   = GetLocalObject(oFirstWP, LM_LWFar);

            // Get the distance from both ends of the trail
            fStartDist = MeGetFloatByIndex(oStartLM, GetLocalInt(oStartLM, LM_LWRouteWeight_+sDest));
            fEndDist   = MeGetFloatByIndex(oEndLM,   GetLocalInt(oEndLM,   LM_LWRouteWeight_+sDest));

            // If the landmark on the starting end is not 0.0 and closer
            if ((fStartDist > 0.0) &&
                ((!GetIsObjectValid(stTrail.oTrail)) || (fStartDist < fTrailDist)))
            {
                stTrail.oWaypoint  = oWP;
                stTrail.oLandmark  = GetLocalObject(oFirstWP, LM_LWNear);
                stTrail.oTrail     = oFirstWP;
                stTrail.iDirection = -1;
            }

            // If the landmark on the ending end is closer and is not 0.0
            if ((fEndDist > 0.0) &&
                ((!GetIsObjectValid(stTrail.oTrail)) || (fEndDist < fTrailDist)))
            {
                stTrail.oWaypoint  = oWP;
                stTrail.oLandmark  = GetLocalObject(oFirstWP, LM_LWFar);
                stTrail.oTrail     = GetLocalObject(oFirstWP, LM_TWFar);
                stTrail.iDirection = 1;
            }

            // Advance to next trail
            oWP = GetNextObjectInShape(SHAPE_CUBE, fTolerance, lLandmark, FALSE, OBJECT_TYPE_WAYPOINT);
        }
    }

    _End("MeFindNearestTrail", DEBUG_TOOLKIT);
    return (stTrail);
/*}}}*/
}

object MeGetTrailNextWP(object oWP, int iDir)
{
/*{{{*/
    _Start("MeGetTrailNextWP oWP='"+GetTag(oWP)+"' iDir='"+IntToString(iDir)+"'", DEBUG_TOOLKIT);

    string  sWP     = GetTag(oWP);
    string  sPrefix = MeGetPrefix(sWP);
    string  sSuffix = MeGetSuffix(sWP);

    object  oNextWP;

    if      (iDir > 0) iDir = 1;
    else if (iDir < 0) iDir = -1;

    _End("MeGetTrailNextWP", DEBUG_TOOLKIT);
    return GetWaypointByTag(sPrefix + MeZeroIntToString(StringToInt(sSuffix) + iDir));
/*}}}*/
}

object MeGetTrailLandmark(object oWP, int iDir)
{
/*{{{*/
    _Start("MeGetTrailLandmark oWP='"+GetTag(oWP)+"' iDir='"+IntToString(iDir)+"'", DEBUG_TOOLKIT);

    string  sWP     = GetTag(oWP);
    string  sPrefix = MeGetPrefix(sWP);

    object  oFirstWP = GetWaypointByTag(sPrefix + "01");

    _End("MeGetTrailLandmark", DEBUG_TOOLKIT);
    if      (iDir > 0) {return GetLocalObject(oFirstWP, LM_LWFar); }
    else if (iDir < 0) {return GetLocalObject(oFirstWP, LM_LWNear);}
    else               {return GetLocalObject(oWP,      LM_LWNear);}
/*}}}*/
}

object MeGetTrailEnd (object oWP, int iDir)
{
/*{{{*/
    _Start("MeGetTrailEnd oWP='"+GetTag(oWP)+"' iDir='"+IntToString(iDir)+"'", DEBUG_TOOLKIT);

    string  sWP     = GetTag(oWP);
    string  sPrefix = MeGetPrefix(sWP);

    object  oFirstWP = GetWaypointByTag(sPrefix + "01");

    _End("MeGetTrailEnd", DEBUG_TOOLKIT);
    if      (iDir > 0) {return GetLocalObject(oFirstWP, LM_TWFar);}
    else if (iDir < 0) {return oFirstWP;                          }
    else               {return oWP;                               }
/*}}}*/
}
//}}}

const string LM_ShortestPathInit = "LM_ShortestPathInit";
const string LM_ShortestPathDone = "LM_ShortestPathDone";
const string LM_Start         = "LM_Start";
const string LM_End           = "LM_End";
const string LM_StartGate     = "LM_StartGate";
const string LM_EndGate       = "LM_EndGate";
const string LM_BestStartGate = "LM_BestStartGate";
const string LM_BestEndGate   = "LM_BestEndGate";
const string LM_BestDistance  = "LM_BestDistance";

//{{{ --- Public Shortest Path Functions--------------------------------------
void _MeShortestPathTest(object oObj, object oStart, object oEnd)
{
/*{{{*/
    _Start("_MeShortestPathTest", DEBUG_TOOLKIT);

    int     bResult;

    // Do some work
    bResult = MeShortestPathGo(oObj);
    if (bResult == TRUE) {
        // Done processing
        DelayCommand(0.0, MeShortestPathTest(oObj,
                                             GetTag(oStart), GetTag(GetArea(oStart)),
                                             GetTag(oEnd),   GetTag(GetArea(oEnd)), TRUE));

    } else {
        // Keep processing
        DelayCommand(0.0, _MeShortestPathTest(oObj, oStart, oEnd));
    }

    _End("_MeShortestPathTest", DEBUG_TOOLKIT);
/*}}}*/
}

void MeShortestPathTest(object oObj, string sStart, string sStartArea, string sEnd, string sEndArea, int bDone = FALSE)
{
/*{{{*/
    _Start("MeShortestPathTest oObj='"+GetTag(oObj)+"' sStart='"+sStart+"' sStartArea='"+sStartArea+"' sEnd='"+sEnd+"' sEndArea='"+sEndArea+"' bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    object  oStart;
    object  oStartArea;
    object  oEnd;
    object  oEndArea;
    int     i;

    if (!bDone) {
        // Figure out the start and end areas
        oStartArea = GetObjectByTag(sStartArea);
        if (!GetIsObjectValid(oStartArea)) {
            _PrintString("Error: Bad start area");
            _End("MeShortestPathTest", DEBUG_TOOLKIT);
            return;
        }
        oEndArea = GetObjectByTag(sEndArea);
        if (!GetIsObjectValid(oEndArea)) {
            _PrintString("Error: Bad end area");
            _End("MeShortestPathTest", DEBUG_TOOLKIT);
            return;
        }

        // Figure out the start and end landmarks
        for (i = 0;; i++) {
            oStart = GetObjectByTag(sStart, i);
            if (!GetIsObjectValid(oStart)) {
                _PrintString("Error: Bad start landmark");
                _End("MeShortestPathTest", DEBUG_TOOLKIT);
                return;
            }
            if (GetArea(oStart) == oStartArea) break;
        }
        for (i = 0;; i++) {
            oEnd = GetObjectByTag(sEnd, i);
            if (!GetIsObjectValid(oEnd)) {
                _PrintString("Error: Bad end landmark");
                _End("MeShortestPathTest", DEBUG_TOOLKIT);
                return;
            }
            if (GetArea(oEnd) == oEndArea) break;
        }

        // Initialize processing
        MeShortestPathInit(oObj, oStart, oEnd);

        // Start processing
        DelayCommand(0.0, _MeShortestPathTest(oObj, oStart, oEnd));

    } else {
        _PrintString("Shortest path: '"+GetTag(GetLocalObject(oObj, LM_Start))+"' -> '"+GetTag(GetLocalObject(oObj, LM_StartGate))+"' -> '"+GetTag(GetLocalObject(oObj, LM_EndGate))+"' -> '"+GetTag(GetLocalObject(oObj, LM_End))+"'");

        // Cleanup
        MeShortestPathDone(oObj);
    }

    _End("MeShortestPathTest", DEBUG_TOOLKIT);
/*}}}*/
}

int MeShortestPathInit(object oObj, object oStart, object oEnd, object oStartGate = OBJECT_INVALID, object oEndGate = OBJECT_INVALID)
{
/*{{{*/
    _Start("MeShortestPathInit oObj='"+GetTag(oObj)+"' oStart='"+GetTag(oStart)+"' oEnd='"+GetTag(oEnd)+"' oStartGate='"+GetTag(oStartGate)+"' oEndGate='"+GetTag(oEndGate)+"'", DEBUG_TOOLKIT);

    // Avoid double init
    if (GetLocalInt(oObj, LM_ShortestPathInit)) return FALSE;

    // Initialize the object
    SetLocalObject(oObj, LM_Start,         oStart);
    SetLocalObject(oObj, LM_End,           oEnd);
    SetLocalObject(oObj, LM_StartGate,     oStartGate);
    SetLocalObject(oObj, LM_EndGate,       oEndGate);
    SetLocalObject(oObj, LM_BestStartGate, OBJECT_INVALID);
    SetLocalObject(oObj, LM_BestEndGate,   OBJECT_INVALID);

    SetLocalInt(oObj, LM_StartGate, 0);
    SetLocalInt(oObj, LM_EndGate,   0);

    SetLocalInt(oObj, LM_ShortestPathDone, 0);

    // If oStart and oEnd are in the same area and no particular gateways are given
    if ((GetArea(oStart) == GetArea(oEnd)) &&
        (!GetIsObjectValid(oStartGate)) && (!GetIsObjectValid(oEndGate)))
    {
        // If you can go directly from oStart to oEnd
        if (MeGetObjectCount(oStart, LM_LWRouteShortest_+GetTag(oEnd)))
        {
            // We're already done
            SetLocalInt(oObj, LM_ShortestPathDone, 1);
        }
    }

    SetLocalInt(oObj, LM_StartGate, 0);
    SetLocalInt(oObj, LM_EndGate,   0);

    // Mark the object as initialized
    SetLocalInt(oObj, LM_ShortestPathInit, 1);

    _End("MeShortestPathInit", DEBUG_TOOLKIT);
    return TRUE;
/*}}}*/
}

int MeShortestPathGo(object oObj)
{
/*{{{*/
    _Start("MeShortestPathGo oObj='"+GetTag(oObj)+"'", DEBUG_TOOLKIT);

    // Wait for busy landmark processing to finish
    if (GetLocalInt(oObj, LM_Busy)) {
        _End("MeShortestPathGo", DEBUG_TOOLKIT);
        return FALSE;
    }

    // Are we done yet?
    if (GetLocalInt(oObj, LM_ShortestPathDone)) {
        _End("MeShortestPathGo", DEBUG_TOOLKIT);
        return TRUE;
    }

    object  oStart     = GetLocalObject(oObj, LM_Start);
    object  oEnd       = GetLocalObject(oObj, LM_End);
    object  oStartArea = GetArea(oStart);
    object  oEndArea   = GetArea(oEnd);
    object  oStartGate;
    object  oEndGate;

    float   fDist;

    int     iStartGate = GetLocalInt(oObj, LM_StartGate);
    int     iEndGate   = GetLocalInt(oObj, LM_EndGate);
    int     iLastStartGate;
    int     iLastEndGate;

    // Load the current start and end gates
    oStartGate = MeGetObjectByIndex(oStartArea, iStartGate, LM_LWGate);
    oEndGate   = MeGetObjectByIndex(oEndArea,   iEndGate,   LM_LWGate);

    _PrintString("Examining: '"+GetTag(oStart)+"' -> '"+GetTag(oStartGate)+"' ('"+GetTag(GetArea(oStartGate))+"') -> '"+GetTag(oEndGate)+"' ('"+GetTag(GetArea(oEndGate))+"') -> '"+GetTag(oEnd)+"'");

    // If oStart -> oStartGate...
    if ((oStart == oStartGate) ||
        (MeGetObjectCount(oStart, LM_LWRouteShortest_+GetTag(oStartGate))))
    {
        // ... And oEndGate -> oEnd...
        if ((oEndGate == oEnd) ||
            (MeGetObjectCount(oEndGate, LM_LWRouteShortest_+GetTag(oEnd))))
        {
            // ... And oStartGate -> oEndGate
            if (MeGetObjectCount(oStartGate, LM_LWGateRouteTrail_+GetTag(oEndArea)+GetTag(oEndGate))) {
                // ... And is the shortest so far
                fDist = MeGetShortestDistance(oStart, oEndGate, oStartGate, oEndGate);
                if ((!GetIsObjectValid(GetLocalObject(oObj, LM_BestStartGate))) ||
                    (GetLocalFloat(oObj, LM_BestDistance) > fDist))
                {
                    _PrintString("New best path");
                    SetLocalObject(oObj, LM_BestStartGate, oStartGate);
                    SetLocalObject(oObj, LM_BestEndGate,   oEndGate);
                    SetLocalFloat (oObj, LM_BestDistance,  fDist);
                } else {
                    _PrintString("Path too long "+FloatToString(GetLocalFloat(oObj, LM_BestDistance))+" <= "+FloatToString(fDist));
                }
            } else {
                _PrintString("oStartGate !> oEndGate");
            }
        } else {
            _PrintString("oEndGate !> oEnd");
        }
    } else {
        _PrintString("oStart !> oStartGate");
    }

    // If we're done end gateway
    if (iStartGate >= MeGetObjectCount(oStartArea, LM_LWGate) - 1) {
        // If we're done searching
        if (iEndGate >= MeGetObjectCount(oEndArea, LM_LWGate) - 1) {
            // Transfer best gateways
            SetLocalObject(oObj, LM_StartGate, GetLocalObject(oObj, LM_BestStartGate));
            SetLocalObject(oObj, LM_EndGate,   GetLocalObject(oObj, LM_BestEndGate));

            // Clean-up temporary variables
            DeleteLocalObject(oObj, LM_BestStartGate);
            DeleteLocalObject(oObj, LM_BestEndGate);
            DeleteLocalFloat (oObj, LM_BestDistance);

            // Done
            SetLocalInt(oObj, LM_ShortestPathDone, 1);
            _End("MeShortestPathGo", DEBUG_TOOLKIT);
            return TRUE;

        // Otherwise, more end gateways to look at
        } else {
            iEndGate++;
        }

        // Regardless of what happens, we're working on a different landmark
        oEndGate = MeGetObjectByIndex(oEndArea, iEndGate, LM_LWGate);
        iStartGate = 0;

    // Otherwise, more start gateways to look at
    } else {
        iStartGate++;
    }

    // Regardless of what happens, we're working on a different start gateway
    oStartGate = MeGetObjectByIndex(oStartArea, iStartGate, LM_LWGate);

    // Update state
    SetLocalInt(oObj, LM_StartGate, iStartGate);
    SetLocalInt(oObj, LM_EndGate,   iEndGate);

    // Not done yet
    _End("MeShortestPathGo", DEBUG_TOOLKIT);
    return FALSE;
/*}}}*/
}

int MeShortestPathDone(object oObj)
{
/*{{{*/
    _Start("MeShortestPathDone oObj='"+GetTag(oObj)+"'", DEBUG_TOOLKIT);

    // Avoid uninitialized host objects
    if (!GetLocalInt(oObj, LM_ShortestPathInit)) return FALSE;

    // Cleanup the object
    DeleteLocalObject(oObj, LM_Start);
    DeleteLocalObject(oObj, LM_End);
    DeleteLocalObject(oObj, LM_StartGate);
    DeleteLocalObject(oObj, LM_EndGate);
    DeleteLocalObject(oObj, LM_BestStartGate);
    DeleteLocalObject(oObj, LM_BestEndGate);

    DeleteLocalInt(oObj, LM_StartGate);
    DeleteLocalInt(oObj, LM_EndGate);

    DeleteLocalInt(oObj, LM_ShortestPathDone);
    DeleteLocalInt(oObj, LM_ShortestPathInit);

    _End("MeShortestPathDone", DEBUG_TOOLKIT);
    return TRUE;
/*}}}*/
}

const string LM_WalkShortestPathInit = "LM_WalkShortestPathInit";
const string LM_WalkShortestPathDone = "LM_WalkShortestPathDone";

const string LM_Current      = "LM_Current";        // Waypoint we are headed to
const string LM_CurrentTrail = "LM_CurrentTrail";   // Trail we are headed to
const string LM_CurrentLM    = "LM_CurrentLM";      // Landmark we are headed to
const string LM_CurrentGate  = "LM_CurrentGate";    // Gateway or gateway landmark we are headed to

const string LM_RouteTrail_ = "LM_RouteTrail_";
const string LM_GateRouteTrail_ = "LM_GateRouteTrail_";
const string LM_Gateway = "LM_Gateway";
const string LM_GateTrail = "LM_GateTrail";
const string LM_LandmarkFar = "LM_LandmarkFar";

void _MeWalkShortestPathTest(object oObj)
{
/*{{{*/
    _Start("_MeWalkShortestPathTest", DEBUG_TOOLKIT);

    int     bResult;

    // Do some work
    bResult = TRUE;
    if (bResult == TRUE) {
        // Done processing
        DelayCommand(0.0, MeWalkShortestPathTest(oObj, TRUE));

    } else {
        // Keep processing
        DelayCommand(0.0, _MeWalkShortestPathTest(oObj));
    }

    _End("_MeWalkShortestPathTest", DEBUG_TOOLKIT);
/*}}}*/
}

void MeWalkShortestPathTest(object oObj, int bDone = FALSE)
{
/*{{{*/
    _Start("MeWalkShortestPathTest oObj='"+GetTag(oObj)+"' bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    if (!bDone) {
        // Initialize processing
        MeWalkShortestPathInit(oObj);

        // Start processing
        DelayCommand(0.0, _MeWalkShortestPathTest(oObj));

    } else {
        _PrintString("Done");

        // Cleanup
        MeWalkShortestPathDone(oObj);
    }

    _End("MeWalkShortestPathTest", DEBUG_TOOLKIT);
/*}}}*/
}

int MeWalkShortestPathInit(object oObj)
{
/*{{{*/
    _Start("MeWalkShortestPathInit oObj='"+GetTag(oObj)+"'", DEBUG_TOOLKIT);

    object  oStart;
    object  oStartGate;

    // Avoid double init
    if (GetLocalInt(oObj, LM_WalkShortestPathInit)) return FALSE;

    // We need shortest path computed already
    if (!GetLocalInt(oObj, LM_ShortestPathInit)) return FALSE;

    // Start at the very beginning
    oStartGate = GetLocalObject(oObj, LM_StartGate);
    SetLocalObject(oObj, LM_CurrentGate, oStartGate);

    oStart = GetLocalObject(oObj, LM_Start);
    SetLocalObject(oObj, LM_CurrentLM, oStart);
    SetLocalObject(oObj, LM_Current,   oStart);

    // Mark the object as initialized
    SetLocalInt(oObj, LM_WalkShortestPathInit, 1);

    _End("MeWalkShortestPathInit", DEBUG_TOOLKIT);
    return TRUE;
/*}}}*/
}

object MeWalkShortestPathNext(object oObj, int bForce = FALSE)
{
/*{{{*/
    _Start("MeWalkShortestPathNext oObj='"+GetTag(oObj)+"'", DEBUG_TOOLKIT);

    object  oCurr = GetLocalObject(oObj, LM_Current);
    object  oDest;

    // Try going to the next landmark
    oDest = GetLocalObject(oObj, LM_CurrentLM);
    if ((!GetIsObjectValid(oDest)) || (oCurr == oDest)) {
        // Try going to the local gateway
        oDest = GetLocalObject(oObj, LM_CurrentGate);
        if ((!GetIsObjectValid(oDest)) || (oCurr == oDest)) {
            // Try going to the end gateway
            oDest = GetLocalObject(oObj, LM_EndGate);
            if ((!GetIsObjectValid(oDest)) || (oCurr == oDest)) {
                // Try going to the final destination
                oDest = GetLocalObject(oObj, LM_End);
                if (GetArea(oCurr) != GetArea(oDest)) {
                    // We're lost!!!
                    _PrintString("WARN: We're lost!");
                    _End("MeWalkShortestPathNext", DEBUG_TOOLKIT);
                    return OBJECT_INVALID;

                // We are a the end gateway headed to the end landmark
                } else {
                }

            // We are at a local gateway headed to another area
            } else {
                string  sCurr = GetTag(oCurr);

                // If this is gateway landmark
                if (GetStringLeft(sCurr, GetStringLength(LM_GW_)) == LM_GW_) {

                // If this is a real gateway
                } else if (GetStringLeft(sCurr, GetStringLength(LM_GW_)) == LM_GW_) {
                    // Figure out the next gateway in the next area

                    // Find the gateway landmark in the other area we will connect to

                    // Trail connects remote gateway to its landmark

                    // Area transition to the gateway in the next area
                    SetLocalObject(oObj, LM_Current, GetLocalObject(oCurr, LM_GW));

                // This is not either!!!
                } else {
                    _PrintString("ERROR: Not a gateway or gateway landmark: '"+sCurr+"'");
                    _End("MeWalkShortestPathNext", DEBUG_TOOLKIT);
                    return OBJECT_INVALID;
                }

            }

        // We are at a local landmark headed to a local gateway
        } else {
        /*{{{*/
            object  oTemp;
            string  sRouteShortest;
            string  sRouteTrail;
            string  sDest;

            // Precompute common strings
            sDest = GetTag(oDest);
            sRouteShortest = LM_LWRouteShortest_+sDest;
            sRouteTrail    = LM_LWRouteTrail_   +sDest;

            // Find the trail to follow to the next landmark
            oTemp = MeGetObjectByIndex(oCurr, MeGetIntByIndex(oCurr, 0, sRouteShortest), sRouteTrail);
            SetLocalObject(oObj, LM_CurrentTrail, oTemp);

            // Find the next landmark to go to
            oTemp = GetLocalObject(oTemp, LM_LWFar);
            if (oTemp == oCurr) {
                oTemp = GetLocalObject(oTemp, LM_LWNear);
            }
            SetLocalObject(oObj, LM_CurrentLM, oTemp);

            oCurr = GetLocalObject(oObj, LM_CurrentTrail);
        /*}}}*/
        }

    // We are on a local trail headed to a local landmark
    } else {
    /*{{{*/
        object  oCurrArea = GetArea(oCurr);
        object  oTemp;
        string  sCurr     = GetTag(oCurr);
        string  sDest;
        int     iCurrLen  = GetStringLength(sCurr);
        int     i;

        // If we are on a local trail
        if (GetStringLeft(sCurr, GetStringLength(LM_LT_)) == LM_LT_) {
            // Figure out the name of the next trail
            sDest = GetStringLeft(sCurr, GetStringLength(sCurr) - 2) +
                    MeZeroIntToString(StringToInt(GetStringRight(sCurr, 2)) + 1);

        // If we are on a gateway trail
        } else if (GetStringLeft(sCurr, GetStringLength(LM_GT_)) == LM_GT_) {
            // If we're headed out of the area
            sDest = GetTag(GetLocalObject(oObj, LM_CurrentLM));
            if (GetStringLeft(sDest, GetStringLength(LM_GW_)) == LM_GW_) {
                // Figure out the name of the next trail (decrement)
                sDest = GetStringLeft(sCurr, GetStringLength(sCurr) - 2) +
                        MeZeroIntToString(StringToInt(GetStringRight(sCurr, 2)) - 1);

           // Otherwise, we're headed into the area
            } else {
                // Figure out the name of the next trail (increment)
                sDest = GetStringLeft(sCurr, GetStringLength(sCurr) - 2) +
                        MeZeroIntToString(StringToInt(GetStringRight(sCurr, 2)) + 1);
            }

        // Otherwise, we're not on a trail!!!
        } else {
            _PrintString("ERROR: Not a trail: '"+sCurr+"'");
            _End("MeWalkShortestPathNext", DEBUG_TOOLKIT);
            return OBJECT_INVALID;
        }

        // Find the next trail
        for (i = 0;; i++) {
            oTemp = GetObjectByTag(sDest, i);

            // There no more trail waypoints, head to the next landmark
            if (!GetIsObjectValid(oTemp)) {
                oCurr = GetLocalObject(oObj, LM_CurrentLM);
                break;

            // We found the next trail waypoint
            } else if (GetArea(oTemp) == GetArea(oCurr)) {
                oCurr = oTemp;
                break;
            }
        }

        // Store the results
        SetLocalObject(oObj, LM_CurrentTrail, oCurr);
        SetLocalObject(oObj, LM_Current,      oCurr);
    /*}}}*/
    }

    _End("MeWalkShortestPathNext", DEBUG_TOOLKIT);
    return oCurr;
/*}}}*/
}

int MeWalkShortestPathDone(object oObj)
{
/*{{{*/
    _Start("MeWalkShortestPathDone oObj='"+GetTag(oObj)+"'", DEBUG_TOOLKIT);

    // Avoid uninitialized host objects
    if (!GetLocalInt(oObj, LM_WalkShortestPathInit)) return FALSE;

    // Cleanup the object
    DeleteLocalObject(oObj, LM_Current);

    DeleteLocalInt(oObj, LM_WalkShortestPathDone);
    DeleteLocalInt(oObj, LM_WalkShortestPathInit);

    _End("MeWalkShortestPathDone", DEBUG_TOOLKIT);
    return TRUE;
/*}}}*/
}
//}}}
