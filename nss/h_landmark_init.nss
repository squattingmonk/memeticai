/*
 *     file: h_landmark_init
 *  authors: Daryl Low
 * modified: February 14, 2004
 *
 * Copyright 2004. For non-commercial use only.
 * Contact bbull@qnx.com with questions.
 */

#include "h_class"
#include "h_landmark_com"

const string Landmark_ = "LW_";     // Local landmark prefix
const string Gateway_  = "GW_";     // Gateway prefix
const string LTrail_   = "LT_";     // Local trail prefix
const string GTrail_   = "GT_";     // Gateway trail prefix

const int EnumerateLandmarksChunk     = 10;
const int EnumerateGatewaysChunk      = 10;
const int EnumerateTrailsChunk        = 1;
const int EnumerateGatewayTrailsChunk = 1;

void EnumerateLandmarks(int bDone = FALSE);
void _EnumerateLandmarks(int iTagID = 1, int iDupe = 0);

void EnumerateGateways(int bDone = FALSE);
void _EnumerateGateways(int iTagID = 1, int iDupe = 0);

void EnumerateTrails(int bDone = FALSE);
void _EnumerateTrails(int iLM1 = 1, int iLM2 = 1, int iDupe = 0, int iMaxLM = -1);

void EnumerateGatewayTrails(int bDone = FALSE);
void _EnumerateGatewayTrails(int iLMG = 1, int iLML = 1, int iDupe = 0, int iMaxGM = -1, int iMaxLM = -1);

void _UpdateLandmarks(object oModule, int iArea, int iLastArea, object oArea, int iLM, int iLastLM, object oLM, int iAdjTrail, int iLastAdjTrail);
void UpdateLandmarks(int bDone = FALSE);

void _AdjacentGateways(object oModule,
                       int iArea, int iLastArea, object oArea,
                       int iLM,   int iLastLM,   object oLM,
                       int iAdjLM,               object oAdjLM);
void AdjacentGateways(int bDone = FALSE);

void _UpdateGateways(object oModule, int iArea, int iLastArea, object oArea, int iLM, int iLastLM, object oLM, int iAdjLM, int iAdjLM, object oAdjLM);
void UpdateGateways(int bDone = FALSE);

void MeProcessLandmarks(int bDone = FALSE);

void MeAddRoute(object oChanged, object oLandmark, object oDest, object oTrail, float fDist, string sPath, int bGate);

void   MeDumpLandmarks(object oArea);
void   MeDumpLandmark (object oArea, object oLandmark);

/**
  * Area Local Landmark Waypoint Detection "Thread"
  *
  * This function repeatedly self-schedules via DelayCommand() to do the
  * actual landmark detection. When it is complete, it will call
  * EnumerateLandmarks(TRUE) to indicate that it is done.
  */
void _EnumerateLandmarks(int iTagID = 1, int iDupe = 0)
{
/*{{{*/
    _Start("_EnumerateLandmarks iTagID='"+IntToString(iTagID)+"' iDupe='"+IntToString(iDupe)+"'", DEBUG_TOOLKIT);

    object  oModule = GetModule();
    object  oArea;
    object  oLM;
    string  sLM;
    int     i;

    // Only process exactly one chunk to avoid TMI
    for (i = 0; i < EnumerateLandmarksChunk; i++) {
        sLM = LM_LW_ + IntToString(iTagID);
        oLM = GetObjectByTag(sLM, iDupe);

        // If there is no such object
        if (!GetIsObjectValid(oLM)) {
            // If this is the first attempt reading the tag, we're done
            if (iDupe == 0) {
                // Remember the max landmark ID
                SetLocalInt(oModule, LM_LW, iTagID - 1);

                // Schedule EnumerateLandmarks() to run again
                DelayCommand(0.0, EnumerateLandmarks(1));
                _End("_EnumerateLandmarks");
                return;

            // Otherwise, we're done with this tag
            } else {
                ++iTagID;
                iDupe  = 0;
                continue;
            }

        // If this isn't a waypoint object, skip it
        } else if (GetObjectType(oLM) != OBJECT_TYPE_WAYPOINT) {
            _PrintString("WARN: Non-landmark object has a valid landmark name");
            ++iDupe;
            continue;
        }

        // Register the area if not already done
        oArea = GetArea(oLM);
        if (!GetLocalInt(oModule, LM_Area + GetTag(oArea))) {
            _PrintString("New area '" + GetTag(oArea) + "'");
            MeAddObjectRef(oModule, oArea, LM_Area);
            SetLocalInt(oModule, LM_Area + GetTag(oArea), 1);
        }

        _PrintString("New landmark '" + sLM + "' in '" + GetTag(oArea) + "'");

        // Add the landmark to a reverse lookup index
        SetLocalInt(oArea, sLM, MeGetObjectCount(oArea, LM_LW));

        // Add the landmark to it's area's list
        MeAddObjectRef(oArea, oLM, LM_LW);

        // Next duplicate
        iDupe = iDupe + 1;
    }

    // Call myself for another chunk
    DelayCommand(0.0, _EnumerateLandmarks(iTagID, iDupe));

    _End("_EnumerateLandmarks");
/*}}}*/
}

/**
  * Detect Area Local Landmark Waypoints
  *
  * This function schedules the _EnumerateLandmark() "thread" and then "waits"
  * until the processing of _EnumerateLandmarks() is complete. Once complete,
  * it schedules the next phase of landmark processing.
  *
  * Landmarks are junction points for one or more trails. They serve as
  * decision points for characters using the landmark system.
  *
  * Landmarks have tags of the form: "LM_" + <ID>, where <ID> is a number
  * uniquely identifying the landmark within the area. The <ID> numbers
  * should be contiguous for all landmarks within an area, starting at 1.
  * Warnings will be logged if this is not the case.
  */
void EnumerateLandmarks(int bDone = FALSE)
{
/*{{{*/
    _Start("EnumerateLandmarks bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    object oModule = GetModule();

    // If we're being invoked for the first time
    if (!bDone) {
        // Send progress message here

        // Start enumerating landmarks by scheduling _EnumerateLandmarks()
        DelayCommand(0.0, _EnumerateLandmarks());

    // Otherwise, we're being called because _EnumerateLandmarks() is done
    } else {
        // If we found some landmarks
        if (MeGetObjectCount(oModule, LM_Area)) {
            // Call "EnumerateGateways" to enter next phase
            EnumerateGateways();

        } else {
            // Clean-up variables
            DeleteLocalInt(oModule, LM_LW);

            _PrintString("WARN: No landmarks detected!");
        }
    }

    _End("EnumerateLandmarks");
/*}}}*/
}

/**
  * Cross Area Gateway Waypoint Detection "Thread"
  *
  * This function repeatedly self-schedules via DelayCommand() to do the
  * actual gateway detection. When it is complete, it will call
  * EnumerateGateways(TRUE) to indicate that it is done.
  */
void _EnumerateGateways(int iTagID = 1, int iDupe = 0)
{
/*{{{*/
    _Start("_EnumerateGateways iTagID='"+IntToString(iTagID)+"' iDupe='"+IntToString(iDupe)+"'", DEBUG_TOOLKIT);

    object  oModule = GetModule();
    object  oArea;
    object  oGW;
    object  oGWDest;
    object  oGWDestArea;
    string  sGW;
    string  sGWDest;
    string  sGWDestArea;
    int     i, j;

    // Only process exactly one chunk to avoid TMI
    for (i = 0; i < EnumerateGatewaysChunk; i++) {
        sGW = LM_GW_ + IntToString(iTagID);
        oGW = GetObjectByTag(sGW, iDupe);

        // If there is no such object
        if (!GetIsObjectValid(oGW)) {
            // If this is the first attempt reading the tag, we're done
            if (iDupe == 0) {
                // Remember the max gateway ID
                SetLocalInt(oModule, LM_GW, iTagID - 1);

                // Schedule EnumerateGateways() to run again
                DelayCommand(0.0, EnumerateGateways(1));
                _End("_EnumerateGateways");
                return;

            // Otherwise, we're done with this tag
            } else {
                iTagID = iTagID + 1;
                iDupe  = 0;
                continue;
            }

        // If this isn't a waypoint object, skip it
        } else if (GetObjectType(oGW) != OBJECT_TYPE_WAYPOINT) {
            _PrintString("WARN: Non-gateway object has a valid gateway name");
            iDupe = iDupe + 1;
            continue;
        }

        // Register the area if not already done
        oArea = GetArea(oGW);
        if (!GetLocalInt(oModule, LM_Area + GetTag(oArea))) {
            _PrintString("New area '" + GetTag(oArea) + "'");
            MeAddObjectRef(oModule, oArea, LM_Area);
            SetLocalInt(oModule, LM_Area + GetTag(oArea), 1);
        }

        // Find the remote gateway that this gateway connects to
        sGWDestArea = MeGetConfString(oGW, "MT: Destination Area");
        if (sGWDestArea == "") {
            _PrintString("WARN: Gateway '"+ sGW +"' doesn't connect to another area");
            oGWDestArea = OBJECT_INVALID;
        } else {
            for (j = 0;; j++) {
                oGWDestArea = GetObjectByTag(sGWDestArea, j);
                if (!GetIsObjectValid(oGWDestArea)) {
                    _PrintString("WARN: No area called '" + sGWDestArea + "'");
                    break;
                }

                if (GetObjectType(oGWDestArea) == GetObjectType(oArea)) break;
            }

        }

        if (GetIsObjectValid(oGWDestArea)) {
            sGWDest = MeGetConfString(oGW, "MT: Destination GW");
            if (sGWDest == "") {
                _PrintString("WARN: Gateway '" + sGW + "' doesn't connect to another gateway in area '" + sGWDestArea + "'");
                oGWDest = OBJECT_INVALID;
            } else {
                for (j = 0;; j++) {
                    oGWDest = GetObjectByTag(sGWDest, j);
                    if (!GetIsObjectValid(oGWDest)) {
                        _PrintString("WARN: No gateway call '" + sGWDest + "' in area '" + sGWDestArea + "'");
                        break;
                    }

                    if (GetArea(oGWDest) == oGWDestArea) break;
                }
            }
        }

        _PrintString("New gateway '" + sGW + "' in '" + GetTag(oArea) + "' connecting to '" + sGWDest + "' in '" + sGWDestArea + "'");

        // Add the gateway to a reverse lookup index
        SetLocalInt(oArea, sGW, MeGetObjectCount(oArea, LM_GW));

        // Add the gateway to it's area's list
        MeAddObjectRef(oArea, oGW, LM_GW);

        // Connect the two gateways
        SetLocalObject(oGW,     LM_GW, oGWDest);
        SetLocalObject(oGWDest, LM_GW, oGW);

        // Next duplicate
        iDupe = iDupe + 1;
    }

    // Call myself for another chunk
    DelayCommand(0.0, _EnumerateGateways(iTagID, iDupe));

    _End("_EnumerateGateways");
/*}}}*/
}

/**
  * Detect Cross Area Gateway Landmarks Waypoints
  *
  * This function schedules the _EnumerateGateways() "thread" and then "waits"
  * until the processing of _EnumerateGateways() is complete. Once complete,
  * it schedules the next phase of landmark processing.
  *
  * Users place Gateway waypoints at cross-area transitions such as
  * doors. For simplicity sake, a gateway is always connected to a landmark
  * in the same area via a single "gateway trail". There should only ever be
  * one landmark going to a gateway, but you can have many landmarks leading to
  * that preceding landmark. So if it is necessary for several landmarks to
  * lead to a single gateway, make them go to a final landmark which in turn
  * connects to the gateway.
  *
  * Gateways have tags of the form: "GW_" + <ID>, where <ID> is a number
  * uniquely identifying the gateway within the area. The <ID> numbers
  * should be contiguous for all gateways within an area, starting at "1".
  * Warnings will be logged if this is not the case.
  *
  * Gateways have two varable "conf strings" called "MT: Destination Area" and
  * "MT: Destination GW" uniquely identifying a remote gateway, which this
  * gateway connects to. Warnings will be logged for gateways that do not
  * reference other gateways, or for gateways pairs that do not mutually
  * reference each other.
  */
void EnumerateGateways(int bDone = FALSE)
{
/*{{{*/
    _Start("EnumerateGateways bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    object  oModule = GetModule();
    object  oArea;
    int     iCount;
    int     i;

    // If we're being invoked for the first time
    if (!bDone) {
        // Send progress message here

        // Start enumerating landmarks by scheduling _EnumerateLandmarks()
        DelayCommand(0.0, _EnumerateGateways());

    // Otherwise, we're being called because _EnumerateLandmarks() is done
    } else {
        // Clean-up area registration flags, we don't need them anymore
        iCount = MeGetObjectCount(oModule, LM_Area);
        for (i = 0; i < iCount; i++) {
            oArea = MeGetObjectByIndex(oModule, i, LM_Area);
            DeleteLocalInt(oModule, LM_Area + GetTag(oArea));
        }

        // Call "EnumerateTrails" to enter next phase
        EnumerateTrails();
    }

    _End("EnumerateGateways");
/*}}}*/
}

/**
  * Area Local Trail Waypoint Detection "Thread"
  *
  * This function repeatedly self-schedules via DelayCommand() to do the
  * actual trail detection. When it is complete, it will call
  * EnumerateTrails(TRUE) to indicate that it is done.
  *
  * We are simulating the following loop:
  *     for (iLM1 = 1; iLM1 < iMaxLM; iLM1++) {
  *         for (iLM2 = 1; iLM2 < iMaxLM; iLM2++) {
  *             for (iDupe = 0; oTrail != OBJECT_INVALID; iDupe++) {
  *                 for (iTrailLast = 2; oTrailLast != OBJECT_INVALID; iTrailLast++) {
  *                     do {
  *                         // Get next duplicate
  *                     } while (GetArea(oTrailLast) != oArea);
  *
  *                     // Count trail length
  *                 }
  *                 // Cache info on the trails
  *                 // Register trails with both landmarks
  *             }
  *         }
  *     }
  *
  * Unfortunately, this algorithm is O(iArea * iLMCount^2) or O(n^2). The
  * good news is that we only need to so this once to initialize.
  */
void _EnumerateTrails(int iLM1 = 1, int iLM2 = 1, int iDupe = 0, int iMaxLM = -1)
{
/*{{{*/
    _Start("_EnumerateTrails iLM1='"+IntToString(iLM1)+"' iLM2='"+IntToString(iLM2)+"' iDupe='"+IntToString(iDupe)+"' iMaxLM='"+IntToString(iMaxLM)+"'", DEBUG_TOOLKIT);

    object  oModule = GetModule();
    object  oArea;
    object  oLM1;
    object  oLM2;
    object  oTrailFirst;
    object  oTrailLast;
    object  oTrailLastPrev;
    string  sTrail;
    string  sTrailFirst;
    string  sTrailLast;
    float   fTrailLength;
    int     iLM1Idx;
    int     iLM2Idx;
    int     iTrailLast;
    int     iTrailLastDupe;
    int     iChunk = 0;
    int     iTrailDupe;

    // If this is the first run, do some initialization
    if (iMaxLM <= 0) {
        iMaxLM = GetLocalInt(oModule, LM_LW);
    }

    // Only process exactly one chunk to avoid TMI
    for (iChunk = 0; iChunk < EnumerateTrailsChunk; iChunk++) {
        // The trail name is the same, regardless of duplicates
        sTrail      = LTrail_ + IntToString(iLM1) + "_" + IntToString(iLM2) + "_";
        sTrailFirst = sTrail + "01";

        // Get the first trail waypoint (if available)
        oTrailFirst = GetObjectByTag(sTrailFirst, iDupe);
        if (!GetIsObjectValid(oTrailFirst)) {
            // No more duplicates, try the next trail
            iDupe = 0;
            iLM2++;
            if (iLM2 > iMaxLM) {
                iLM2 = 0;
                iLM1++;

                // If we are totally done
                if (iLM1 > iMaxLM) {
                    // Schedule EnumerateTrails() to run again
                    DelayCommand(0.0, EnumerateTrails(TRUE));
                    _End("_EnumerateTrails");
                    return;
                }
            }
            continue;
        }

        // Pseudo exception loop
        do {
            oArea  = GetArea(oTrailFirst);

            // Get the two landmarks being linked together
            iLM1Idx = GetLocalInt(oArea, LM_LW_ + IntToString(iLM1));
            oLM1    = MeGetObjectByIndex(oArea, iLM1Idx, LM_LW);
            if (!GetIsObjectValid(oLM1)) {
                _PrintString("WARN: ["+GetTag(oArea)+"] "+sTrailFirst+" references non-existant "+LM_LW_+IntToString(iLM1)+"!");
                break;
            }

            iLM2Idx = GetLocalInt(oArea, LM_LW_ + IntToString(iLM2));
            oLM2    = MeGetObjectByIndex(oArea, iLM2Idx, LM_LW);
            if (!GetIsObjectValid(oLM2)) {
                _PrintString("WARN: ["+GetTag(oArea)+"] "+sTrailFirst+" references non-existant "+LM_LW_+IntToString(iLM2)+"!");
                break;
            }

            // This sucks, but we need to know the trail length
            fTrailLength   = GetDistanceBetween(oLM1, oTrailFirst);
            oTrailLastPrev = oTrailFirst;
            for (iTrailLast = 2; iTrailLast <= 99; iTrailLast++) {
                sTrailLast = sTrail + MeZeroIntToString(iTrailLast);

                // We need to find the potential trail end in the same area
                for (iTrailLastDupe = 0; ; iTrailLastDupe++) {
                    oTrailLast = GetObjectByTag(sTrailLast, iTrailLastDupe);
                    if (!GetIsObjectValid(oTrailLast)) {
                        // We can't find the next step, we're done
                        iTrailLast = 100;
                        break;
                    }

                    // If we've found the next step in the trail
                    if (GetArea(oTrailLast) == oArea) {
                        fTrailLength += GetDistanceBetween(oTrailLastPrev, oTrailLast);
                        oTrailLastPrev = oTrailLast;
                        break;
                    }
                }
            }
            oTrailLast    = oTrailLastPrev;
            fTrailLength += GetDistanceBetween(oTrailLast, oLM2);

            _PrintString("New local trail '" + sTrailFirst + "' in '" + GetTag(oArea) + "'");

            // Cache results on the "01" waypoint
            SetLocalObject(oTrailFirst, LM_LWNear,     oLM1);
            SetLocalObject(oTrailFirst, LM_LWFar,      oLM2);
            SetLocalObject(oTrailFirst, LM_TWNear,     oTrailFirst);
            SetLocalObject(oTrailFirst, LM_TWFar,      oTrailLast);
            SetLocalFloat (oTrailFirst, LM_WeightDist, fTrailLength);

            // Register the route on the far landmark
            MeAddRoute(oArea, oLM2, oLM1, oTrailFirst, fTrailLength, MeGetSuffix(GetTag(oLM1)), 0);

            // Register adjacent at the destination
            MeAddObjectRef(oLM1, oTrailFirst, LM_LWTrail);

            // Cache results on the "nn" waypoint
            if (oTrailFirst != oTrailLast) {
                SetLocalObject(oTrailLast, LM_LWNear,     oLM2);
                SetLocalObject(oTrailLast, LM_LWFar,      oLM1);
                SetLocalObject(oTrailLast, LM_TWNear,     oTrailLast);
                SetLocalObject(oTrailLast, LM_TWFar,      oTrailFirst);
                SetLocalFloat (oTrailLast, LM_WeightDist, fTrailLength);
            }

            // Register the route on the near landmark
            MeAddRoute(oArea, oLM1, oLM2, oTrailFirst, fTrailLength, MeGetSuffix(GetTag(oLM2)), 0);

            // Register adjacent at the destination
            MeAddObjectRef(oLM2, oTrailLast, LM_LWTrail);
        } while (FALSE);

        // The alternative is to drop the exception loop and increment at the
        // top. But then iDupe does not reflect the current duplicate we're on.

        // We increment the duplicate counter after processing.
        iDupe++;
    }

    // We exceeded our chunk, self-schedule again
    DelayCommand(0.0, _EnumerateTrails(iLM1, iLM2, iDupe, iMaxLM));

    _End("_EnumerateTrails");
/*}}}*/
}

/**
  * Detect Area Local Trail Waypoints
  *
  * This function schedules the _EnumerateTrails() "thread" and then "waits"
  * until the processing of _EnumerateTrails() is complete. Once complete, it
  * schedules the next phase of landmark processing.
  *
  * Trails are single paths that connect landmarks together. Trails are bi-
  * directional.
  *
  * Trails have tags of the form: "LT_" + <ID1> + "_" + <ID2> + <Count>, where
  * <ID1> and <ID2> are numbers identifying the two area-local landmarks that
  * they connect. This implies that a pair of local landmarks cannot be
  * connected by more than one trail. Warnings will be logged if the landmark
  * ID numbers are not valid.
  *
  * The <Count> field is a two-digit number that sets the walking order of
  * waypoints within the same trail. A valid trail must begin with a count of
  * "01". Otherwise it will not be detected properly.
  */
void EnumerateTrails(int bDone = FALSE)
{
/*{{{*/
    _Start("EnumerateTrails bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    object  oModule = GetModule();
    object  oArea;

    // If we're being invoked for the first time
    if (!bDone) {
        // Send progress message here

        // Start enumerating landmarks by scheduling _EnumerateLandmarks()
        DelayCommand(0.0, _EnumerateTrails());

    // Otherwise, we're being called because _EnumerateLandmarks() is done
    } else {
        // Call "EnumerateGatewayTrails" to enter next phase
        EnumerateGatewayTrails();
    }

    _End("EnumerateTrails");
/*}}}*/
}

/**
  * Gateways Trail Waypoints Detection "Thread"
  *
  * This function repeatedly self-schedules via DelayCommand() to do the
  * actual trail detection. When it is complete, it will call
  * EnumerateGatewayTrails(TRUE) to indicate that it is done.
  *
  * We are simulating the following loop:
  *     for (iGM = 1; iGM < iMaxGM; iGM++) {
  *         for (iLM = 1; iLM < iMaxLM; iLM++) {
  *             for (iDupe = 0; oTrail != OBJECT_INVALID; iDupe++) {
  *                 for (iTrailLast = 2; oTrailLast != OBJECT_INVALID; iTrailLast++) {
  *                     do {
  *                         // Get next duplicate
  *                     } while (GetArea(oTrailLast) != oArea);
  *
  *                     // Count trail length
  *                 }
  *                 // Cache info on the trails
  *                 // Register trails with both landmarks
  *             }
  *         }
  *     }
  *
  * Unfortunately, this algorithm is O(iArea * iLMCount^2) or O(n^2). The
  * good news is that we only need to so this once to initialize.
  */
void _EnumerateGatewayTrails(int iGW = 1, int iLM = 1, int iDupe = 0, int iMaxGW = -1, int iMaxLM = -1)
{
/*{{{*/
    _Start("_EnumerateGatewayTrails iGW='"+IntToString(iGW)+"' iLM='"+IntToString(iLM)+"' iDupe='"+IntToString(iDupe)+"' iMaxGW='"+IntToString(iMaxGW)+"' iMaxLM='"+IntToString(iMaxLM)+"'", DEBUG_TOOLKIT);

    object  oModule = GetModule();
    object  oArea;
    object  oGW;
    object  oLM;
    object  oTrailFirst;
    object  oTrailLast;
    object  oTrailLastPrev;
    string  sLM;
    string  sTrail;
    string  sTrailFirst;
    string  sTrailLast;
    float   fTrailLength;
    int     iGWIdx;
    int     iLMIdx;
    int     iTrailLast;
    int     iTrailLastDupe;
    int     iChunk = 0;
    int     iTrailDupe;

    // If this is the first run, do some initialization
    if (iMaxGW <= 0) {
        iMaxGW = GetLocalInt(oModule, LM_GW);
    }
    if (iMaxLM <= 0) {
        iMaxLM = GetLocalInt(oModule, LM_LW);
    }

    // Only process exactly one chunk to avoid TMI
    for (iChunk = 0; iChunk < EnumerateTrailsChunk; iChunk++) {
        // The trail name is the same, regardless of duplicates
        sTrail      = GTrail_ + IntToString(iGW) + "_" + IntToString(iLM) + "_";
        sTrailFirst = sTrail + "01";

        // Get the first trail waypoint (if available)
        oTrailFirst = GetObjectByTag(sTrailFirst, iDupe);
        if (!GetIsObjectValid(oTrailFirst)) {
            // No more duplicates, try the next trail
            iDupe = 0;
            iLM++;
            if (iLM > iMaxLM) {
                iLM = 0;
                iGW++;

                // If we are totally done
                if (iGW > iMaxGW) {
                    // Schedule EnumerateGatewayTrails() to run again
                    DelayCommand(0.0, EnumerateGatewayTrails(TRUE));
                    _End("_EnumerateGatewayTrails");
                    return;
                }
            }
            continue;
        }

        // Pseudo exception loop
        do {
            oArea  = GetArea(oTrailFirst);

            // Get the two landmarks being linked together
            iGWIdx = GetLocalInt(oArea, LM_GW_ + IntToString(iGW));
            oGW    = MeGetObjectByIndex(oArea, iGWIdx, LM_GW);
            if (!GetIsObjectValid(oGW)) {
                _PrintString("WARN: ["+GetTag(oArea)+"] "+sTrailFirst+" references non-existant "+LM_GW_+IntToString(iGW)+"!");
                break;
            }

            iLMIdx = GetLocalInt(oArea, LM_LW_ + IntToString(iLM));
            oLM    = MeGetObjectByIndex(oArea, iLMIdx, LM_LW);
            if (!GetIsObjectValid(oLM)) {
                _PrintString("WARN: ["+GetTag(oArea)+"] "+sTrailFirst+" references non-existant "+LM_LW_+IntToString(iLM)+"!");
                break;
            }
            sLM = GetTag(oLM);

            // This sucks, but we need to know the trail length
            fTrailLength   = GetDistanceBetween(oGW, oTrailFirst);
            oTrailLastPrev = oTrailFirst;
            for (iTrailLast = 2; iTrailLast <= 99; iTrailLast++) {
                sTrailLast = sTrail + MeZeroIntToString(iTrailLast);

                // We need to find the potential trail end in the same area
                for (iTrailLastDupe = 0; ; iTrailLastDupe++) {
                    oTrailLast = GetObjectByTag(sTrailLast, iTrailLastDupe);
                    if (!GetIsObjectValid(oTrailLast)) {
                        // We can't find the next step, we're done
                        iTrailLast = 100;
                        break;
                    }

                    // If we've found the next step in the trail
                    if (GetArea(oTrailLast) == oArea) {
                        fTrailLength += GetDistanceBetween(oTrailLastPrev, oTrailLast);
                        oTrailLastPrev = oTrailLast;
                        break;
                    }
                }
            }
            oTrailLast    = oTrailLastPrev;
            fTrailLength += GetDistanceBetween(oTrailLast, oLM);

            _PrintString("New gateway trail '" + sTrailFirst + "' in '" + GetTag(oArea) + "' from '" + GetTag(oGW) + "' to '" + sLM + "'");

            // If we haven't registered the landmark as a gateway
            if (!GetLocalInt(oArea, LM_LWGate + sLM)) {
                _PrintString("Registering '" + sLM + "' as a gateway landmark");
                MeAddObjectRef(oArea, oLM, LM_LWGate);
                SetLocalInt(oArea, LM_LWGate + sLM, 1);
            }

            MeAddObjectRef(oLM, oGW, LM_GW);

            // Cache results on the "01" waypoint
            SetLocalObject(oTrailFirst, LM_LWNear,     oGW);
            SetLocalObject(oTrailFirst, LM_LWFar,      oLM);
            SetLocalObject(oTrailFirst, LM_TWNear,     oTrailFirst);
            SetLocalObject(oTrailFirst, LM_TWFar,      oTrailLast);
            SetLocalFloat (oTrailFirst, LM_WeightDist, fTrailLength);

            // Register the route on the gateway
            SetLocalObject(oGW, LM_LW,      oLM);
            SetLocalObject(oGW, LM_LWTrail, oTrailFirst);

            // Cache results on the "nn" waypoint
            if (oTrailFirst == oTrailLast) {
                SetLocalObject(oTrailLast, LM_LWFar,      oGW);
                SetLocalObject(oTrailLast, LM_LWNear,     oLM);
                SetLocalObject(oTrailLast, LM_TWNear,     oTrailLast);
                SetLocalObject(oTrailLast, LM_TWFar,      oTrailFirst);
                SetLocalFloat (oTrailLast, LM_WeightDist, fTrailLength);
            }

            // Register the route on the gateway landmark
            SetLocalObject(oLM, LM_GW,      oGW);
            SetLocalObject(oLM, LM_GWTrail, oTrailLast);
        } while (FALSE);

        // The alternative is to drop the exception loop and increment at the
        // top. But then iDupe does not reflect the current duplicate we're on.

        // We increment the duplicate counter after processing.
        iDupe++;
    }

    // We exceeded our chunk, self-schedule again
    DelayCommand(0.0, _EnumerateGatewayTrails(iGW, iLM, iDupe, iMaxGW, iMaxLM));

    _End("_EnumerateGatewayTrails");
/*}}}*/
}

/*
 * Detect Gateways Trail Waypoints
 *
 * This function schedules the _EnumerateGateTrails() "thread" and then
 * enters a self-scheduled "loop" via DelayCommand() until the processing of
 * _EnumerateGateTrails() is complete. Once complete, it schedules the next
 * phase of landmark processing.
 *
 * Gateway trails are single paths that connect an area-local landmark with
 * a cross-area gateway landmark. Gateway trails are bi-directional.
 *
 * Gateway trails have tags of the form: "GT_" + <IDG> + "_" + <IDL> + <Count>,
 * where <IDG> is a two digit number identifying the gateway landmark that
 * the trail connects to. The <IDL> field is a two digit number identifying
 * the area-local landmark that the trail connects to. Warnings will be logged
 * if either <IDG> or <IDL> are not valid.
 *
 * The <Count> field sets the walking order of waypoints within the
 * same trail. A valid trail must begin with a count of "01". Otherwise it
 * will not be detected properly.
 */
void EnumerateGatewayTrails(int bDone = FALSE)
{
/*{{{*/
    _Start("EnumerateGatewayTrails bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    object  oModule = GetModule();
    object  oArea;

    // If we're being invoked for the first time
    if (!bDone) {
        // Send progress message here

        // Start enumerating landmarks by scheduling _EnumerateLandmarks()
        DelayCommand(0.0, _EnumerateGatewayTrails());

    // Otherwise, we're being called because _EnumerateLandmarks() is done
    } else {
        // XXX - Delete flags on area

        // Call "UpdateLandmarks" to enter next phase
        UpdateLandmarks();
    }

    _End("EnumerateGatewayTrails");
/*}}}*/
}

/*
 * Local Landmark Routing Table Construction "Thread"
 *
 * This function repeatedly self-schedules via DelayCommand() to construct each
 * landmark's routing table. When it is complete, it will call
 * UpdateLandmarks(TRUE) to indicate that it is done.
 *
 * We are simulating the following loop:
 *  for (iArea = 0; iArea < iAreas; iArea++) {
 *      while (Area routing tables have not stabilized) {
 *          for (iLM = 0; iLM < iLMs; iLM++) {
 *              for (iAdjLM = 0; iAdjLM < iAdjLMs; iAdjLM++) {
 *                  // Merge routing table
 *              }
 *          }
 *      }
 *  }
 *
 * NOTE: We can trim some fat by just keeping the shortest path info.
 */
void _UpdateLandmarks(object oModule,
                      int iArea,     int iLastArea,     object oArea,
                      int iLM,       int iLastLM,       object oLM,
                      int iAdjTrail, int iLastAdjTrail)
{
/*{{{*/
    _Start("_UpdateLandmarks oModule='"+GetTag(oModule)+"' iArea='"+IntToString(iArea)+"' iLastArea='"+IntToString(iLastArea)+"' oArea='"+GetTag(oArea)+"' iLM='"+IntToString(iLM)+"' iLastLM='"+IntToString(iLastLM)+"' oLM='"+GetTag(oLM)+"' iAdjTrail='"+IntToString(iAdjTrail)+"' iLastAdjTrail='"+IntToString(iLastAdjTrail)+"'", DEBUG_TOOLKIT);

    object  oAdjTrail;
    object  oAdjLM;

    object  oDest;

    string  sRouteTrail;
    string  sRouteWeight;
    string  sRoutePath;
    string  sRouteShortest;
    string  sPath;

    int     iRouteShortest;

    int     reach;
    int     shortest;
    int     i, j;

    float   fAdjLen;
    float   fLen;

    // oAdjTrail changes each time through this function
    oAdjTrail = MeGetObjectByIndex(oLM, iAdjTrail, LM_LWTrail);
    fAdjLen   = GetLocalFloat     (oAdjTrail, LM_WeightDist);
    oAdjLM    = GetLocalObject    (oAdjTrail, LM_LWFar);
    if (oAdjLM == oLM) {
        oAdjLM = GetLocalObject(oAdjTrail, LM_LWNear);
    }
    _PrintString("Looking at adjacent landmark: "+GetTag(oAdjLM));

    // Loop through neighbour's reachable landmarks
    reach = MeGetObjectCount(oAdjLM, LM_LWDest);
    _PrintString("Reachable landmarks: "+IntToString(reach));
    for (i = 0; i < reach; i++) {
        // Get the next reachable landmark
        oDest = MeGetObjectByIndex(oAdjLM, i, LM_LWDest);
        _PrintString("Examining destination: "+GetTag(oDest));

        // Skip route to self
        if (oDest != oLM) {
            // Lookup the reachable landmark in the routing table
            sRouteTrail    = LM_LWRouteTrail_   +GetTag(oDest);
            sRouteWeight   = LM_LWRouteWeight_  +GetTag(oDest);
            sRoutePath     = LM_LWRoutePath_    +GetTag(oDest);
            sRouteShortest = LM_LWRouteShortest_+GetTag(oDest);

            // All of the shortest routes have the same length, get it once
            fLen = MeGetFloatByIndex(oAdjLM, MeGetIntByIndex(oAdjLM, 0, sRouteShortest), sRouteWeight);
            if (fLen == 0.0) {
                _PrintString("WARN: Zero length is the shortest!?!?!");
            }

            // Process the shortest route cache
            shortest = MeGetIntCount(oAdjLM, sRouteShortest);
            _PrintString("Shortest Routes: "+IntToString(shortest));
            for (j = 0; j < shortest; j++) {
                iRouteShortest = MeGetIntByIndex(oAdjLM, j, sRouteShortest);
                sPath = MeGetStringByIndex(oAdjLM, iRouteShortest, sRoutePath);
                _PrintString("1: "+sPath+" ? "+MeGetSuffix(GetTag(oLM)));

                // Prevent routing loops
                if (FindSubString(sPath, MeGetSuffix(GetTag(oLM))) == -1) {
                    // Add the route
                    MeAddRoute(oArea, oLM, oDest, oAdjTrail, fLen + fAdjLen, sPath, 0);
                    break;
                }
            }
        }
    }

    // If we're done this landmark
    if (iAdjTrail >= iLastAdjTrail) {
        // If we're done this area
        if (iLM >= iLastLM) {
            // If the area hadsn't changed
            if (!GetLocalInt(oArea, LM_Changed)) {
                // We don't need LM_Changed anymore
                DeleteLocalInt(oArea, LM_Changed);

                if (iArea >= iLastArea) {
                    // We're done landmark processing
                    DelayCommand(0.0, UpdateLandmarks(TRUE));
                    _End("_UpdateLandmarks");
                    return;
                }

                // Work on the next area
                iArea++;
                oArea   = MeGetObjectByIndex(oModule, iArea, LM_Area);
                iLastLM = MeGetObjectCount(oArea, LM_LW) - 1;
                DeleteLocalInt(oArea, LM_Changed);
            }

            // Regardless of what happens, we're starting an area from scratch
            SetLocalInt(oArea, LM_Changed, 0);
            iLM = 0;

        // Otherwise, more landmarks to go in the area
        } else {
            iLM++;
        }

        // Regardless of what happens, we're working on a different landmark
        oLM = MeGetObjectByIndex(oArea, iLM, LM_LW);
        iLastAdjTrail = MeGetObjectCount(oLM, LM_LWTrail) - 1;
        iAdjTrail = 0;

    // Otherwise, more adjacent trails to go in the landmark
    } else {
        iAdjTrail++;
    }

    // Regardless of what happens, we're working on a different adjacent trail
    MeGetObjectByIndex(oLM, iAdjTrail, LM_LWTrail);

    // Self-schedule
    DelayCommand(0.0, _UpdateLandmarks(oModule,
                                       iArea,     iLastArea, oArea,
                                       iLM,       iLastLM,   oLM,
                                       iAdjTrail, iLastAdjTrail));

    _End("_UpdateLandmarks");
/*}}}*/
}

/*
 * Local Landmark Routing Table Construction
 *
 * This function schedules the _UpdateLandmarks() "thread" and then enters a
 * self-scheduled "loop" via DelayCommand() until the processing of
 * _UpdateLandmarks() is complete. Once complete, it schedules the next phase
 * of landmark processing.
 */
void UpdateLandmarks(int bDone = FALSE)
{
/*{{{*/
    _Start("UpdateLandmarks bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    // If we're being invoked for the first time
    if (!bDone) {
        // Send progress message here

        // Start enumerating landmarks by scheduling _UpdateLandmarks()
        object  oModule = GetModule();
        object  oArea   = MeGetObjectByIndex(oModule, 0, LM_Area);
        object  oLM     = MeGetObjectByIndex(oArea,   0, LM_LW);
        DelayCommand(0.0, _UpdateLandmarks(oModule,
                                           0, MeGetObjectCount(oModule, LM_Area)    - 1, oArea,
                                           0, MeGetObjectCount(oArea,   LM_LW)      - 1, oLM,
                                           0, MeGetObjectCount(oLM,     LM_LWTrail) - 1));

    // Otherwise, we're being called because _EnumerateLandmarks() is done
    } else {
        object  oModule = GetModule();
        object  oArea;
        int     count, i;

        // Dump the routing tables from each area
        //count = MeGetObjectCount(oModule, LM_Area);
        //for (i = 0; i < count; i++)
        //{
        //    oArea = MeGetObjectByIndex(oModule, i, LM_Area);
        //    DelayCommand(0.0, MeDumpLandmarks(oArea));
        //}

        // Call AdjacentGateways() to enter next phase
        AdjacentGateways();

        // XXX - This is where I left off
        // XXX - Finished connecting GW_* points to each other
        // XXX - Finished connecting GW_* to LW_*

        // XXX - Need to establish initial LW_* to LW_* gateway routing tables
        // XXX - Need to compute gateway routing tables

        // XXX - Keep an eye out for variable names because the string constants are changing
        // XXX - Do we really need the gateway specific code in MeAddRoute() anymore?
    }

    _End("UpdateLandmarks");
/*}}}*/
}

void _AdjacentGateways(object oModule,
                       int iArea, int iLastArea, object oArea,
                       int iLM,   int iLastLM,   object oLM,
                       int iAdjLM,               object oAdjLM)
{
/*{{{*/
    _Start("_AdjacentGateways oModule='"+GetTag(oModule)+"' iArea='"+IntToString(iArea)+"' iLastArea='"+IntToString(iLastArea)+"' oArea='"+GetTag(oArea)+"' iLM='"+IntToString(iLM)+"' iLastLM='"+IntToString(iLastLM)+"' oLM='"+GetTag(oLM)+"' iAdjLM='"+IntToString(iAdjLM)+"' oAdjLM='"+GetTag(oAdjLM)+"'", DEBUG_TOOLKIT);

    object  oLMGate;
    string  sArea;
    string  sAdjLM;
    string  sLMGate;
    float   fWeight;
    int     index;

    if (iLM == iAdjLM) {
        _PrintString("Inter-area adjacency");

        // Connect to remote area
        oLMGate = GetLocalObject(GetLocalObject(GetLocalObject(oLM, LM_GW), LM_GW), LM_LW);
        sLMGate = GetTag(oLMGate);
        fWeight = GetLocalFloat(GetLocalObject(oLM,     LM_GWTrail), LM_WeightDist) +
                  GetLocalFloat(GetLocalObject(oLMGate, LM_GWTrail), LM_WeightDist);

        // Register adjacent gateway landmarks
        MeAddObjectRef(oLM, oLMGate, LM_LWGate);
//        MeAddObjectRef(oLMGate, oLM, LM_LWGate);

        MeAddRoute(oModule, oLM, oLMGate, OBJECT_INVALID, fWeight, GetTag(GetArea(oLMGate))+MeGetSuffix(sLMGate), 1);
//        MeAddRoute(oModule, oLMGate, oLM, OBJECT_INVALID, fWeight, GetTag(oArea)+MeGetSuffix(GetTag(oLM)), 1);

    } else {
        _PrintString("Intra-area adjacency");

        /* Only associate with reachable gateways */
        sAdjLM = GetTag(oAdjLM);
        if (MeGetObjectCount(oLM, LM_LWRouteTrail_+sAdjLM))
        {
            index   = MeGetIntByIndex  (oLM, 0,     LM_LWRouteShortest_+sAdjLM);
            fWeight = MeGetFloatByIndex(oLM, index, LM_LWRouteWeight_  +sAdjLM);

            sArea = GetTag(oArea);

            // Register adjacent gateway landmarks
            MeAddObjectRef(oLM, oAdjLM, LM_LWGate);
            MeAddObjectRef(oAdjLM, oLM, LM_LWGate);

            MeAddRoute(oModule, oLM, oAdjLM, OBJECT_INVALID, fWeight, sArea+MeGetSuffix(sAdjLM), 1);
            MeAddRoute(oModule, oAdjLM, oLM, OBJECT_INVALID, fWeight, sArea+MeGetSuffix(GetTag(oLM)), 1);
        }
    }

    // Examine the next adjacent landmark
    if (iAdjLM >= iLastLM) {
        if (iLM >= iLastLM) {
            iLM = 0;
            if (iArea >= iLastArea) {
                // Done
                DelayCommand(0.0, AdjacentGateways(TRUE));
                _End("_AdjacentGateways");
                return;
            } else {
                iArea++;
                oArea   = MeGetObjectByIndex(oModule, iArea, LM_Area);
                iLastLM = MeGetObjectCount  (oArea,          LM_LWGate) - 1;
            }

        } else {
            iLM++;
        }
        oLM = MeGetObjectByIndex(oArea, iLM, LM_LWGate);
        iAdjLM = iLM;

    } else {
        iAdjLM++;
    }
    oAdjLM = MeGetObjectByIndex(oArea, iAdjLM, LM_LWGate);

    // Self-schedule
    DelayCommand(0.0, _AdjacentGateways(oModule,
                                        iArea,  iLastArea, oArea,
                                        iLM,    iLastLM,   oLM,
                                        iAdjLM,            oAdjLM));

    _End("_AdjacentGateways");
/*}}}*/
}

void AdjacentGateways(int bDone = FALSE)
{
/*{{{*/
    _Start("AdjacentGateways bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    // If we're being invoked for the first time
    if (!bDone) {
        // Send progress message here

        // Start processing gateway adjacency by scheduling _AdjacentGateways()
        object  oModule = GetModule();
        object  oArea   = MeGetObjectByIndex(oModule, 0, LM_Area);
        object  oLM     = MeGetObjectByIndex(oArea,   0, LM_LWGate);
        DelayCommand(0.0, _AdjacentGateways(oModule,
                                            0, MeGetObjectCount(oModule, LM_Area)   - 1, oArea,
                                            0, MeGetObjectCount(oArea,   LM_LWGate) - 1, oLM,
                                            0,                                           oLM));

    // Otherwise, we're being called because _EnumerateLandmarks() is done
    } else {
        // Dump the routing tables from each area
//        object  oModule = GetModule();
//        object  oArea   = MeGetObjectByIndex(oModule, 0, LM_Area);
//        int count = MeGetObjectCount(oModule, LM_Area);
//        int i;
//        for (i = 0; i < count; i++)
//        {
//            oArea = MeGetObjectByIndex(oModule, i, LM_Area);
//            DelayCommand(0.0, MeDumpLandmarks(oArea));
//        }

        // Call UpdateGateways() to enter next phase
        UpdateGateways();
    }

    _End("AdjacentGateways");
/*}}}*/
}

void _UpdateGateways(object oModule,
                     int iArea,  int iLastArea,  object oArea,
                     int iLM,    int iLastLM,    object oLM,
                     int iAdjLM, int iLastAdjLM, object oAdjLM)
{
/*{{{*/
    _Start("_UpdateGateways oModule='"+GetTag(oModule)+"' iArea='"+IntToString(iArea)+"' iLastArea='"+IntToString(iLastArea)+"' oArea='"+GetTag(oArea)+"' iLM='"+IntToString(iLM)+"' iLastLM='"+IntToString(iLastLM)+"' oLM='"+GetTag(oLM)+"' iAdjLM='"+IntToString(iAdjLM)+"' iLastAdjLM='"+IntToString(iLastAdjLM)+"' oAdjLM='"+GetTag(oAdjLM)+"'", DEBUG_TOOLKIT);

    object  oAdjArea;
    object  oDest;

    string  sAdjLM;
    string  sRouteTrail;
    string  sRouteWeight;
    string  sRoutePath;
    string  sRouteShortest;
    string  sPath;

    int     iRouteShortest;

    int     reach;
    int     shortest;
    int     i, j;

    float   fAdjLen;
    float   fLen;

    oAdjArea = GetArea(oAdjLM);
    sAdjLM   = GetTag(oAdjLM);
    fAdjLen  = MeGetFloatByIndex(oLM, 0, LM_LWRouteWeight_+GetTag(oAdjArea)+sAdjLM);
    _PrintString("Looking at adjacent gateway landmark: "+sAdjLM+"("+GetTag(oAdjArea)+")");

    // Loop through neighbour's reachable landmarks
    reach = MeGetObjectCount(oAdjLM, LM_LWGateDest);
    _PrintString("Reachable gateway landmarks: "+IntToString(reach));
    for (i = 0; i < reach; i++) {
        // Get the next reachable landmark
        oDest = MeGetObjectByIndex(oAdjLM, i, LM_LWGateDest);
        _PrintString("Examining destination: "+GetTag(oDest)+"("+GetTag(GetArea(oDest))+")");

        // Skip route to self
        if (oDest != oLM) {
            // Lookup the reachable landmark in the routing table
            sRouteTrail    = LM_LWGateRouteTrail_   +GetTag(GetArea(oDest))+GetTag(oDest);
            sRouteWeight   = LM_LWGateRouteWeight_  +GetTag(GetArea(oDest))+GetTag(oDest);
            sRoutePath     = LM_LWGateRoutePath_    +GetTag(GetArea(oDest))+GetTag(oDest);
            sRouteShortest = LM_LWGateRouteShortest_+GetTag(GetArea(oDest))+GetTag(oDest);

            // All of the shortest routes have the same length, get it once
            fLen = MeGetFloatByIndex(oAdjLM, MeGetIntByIndex(oAdjLM, 0, sRouteShortest), sRouteWeight);
            if (fLen == 0.0) _PrintString("WARN: Zero length is the shortest!?!?!");

            // Process the shortest route cache
            shortest = MeGetIntCount(oAdjLM, sRouteShortest);
            _PrintString("Shortest Routes: "+IntToString(shortest));
            for (j = 0; j < shortest; j++) {
                iRouteShortest = MeGetIntByIndex(oAdjLM, j, sRouteShortest);
                sPath = MeGetStringByIndex(oAdjLM, iRouteShortest, sRoutePath);
                _PrintString("1: "+sPath+" ? "+GetTag(GetArea(oLM))+MeGetSuffix(GetTag(oLM)));

                // Prevent routing loops
                if (FindSubString(sPath, GetTag(GetArea(oLM))+MeGetSuffix(GetTag(oLM))) == -1) {
                    // Add the route
                    MeAddRoute(oModule, oLM, oDest, OBJECT_INVALID, fLen + fAdjLen, sPath, 1);
                    break;
                }
            }
        }
    }

    // If we're done this landmark
    if (iAdjLM >= iLastAdjLM) {
        // If we're done this area
        if (iLM >= iLastLM) {
            // If we're done this module
            if (iArea >= iLastArea) {
                // If the module hadsn't changed
                if (!GetLocalInt(oModule, LM_Changed)) {
                    // We don't need LM_Changed anymore
                    DeleteLocalInt(oModule, LM_Changed);

                    // We're done gateway processing
                    DelayCommand(0.0, UpdateGateways(TRUE));
                    _End("_UpdateGateways");
                    return;

                // Otherwise, do the module again
                } else {
                    SetLocalInt(oModule, LM_Changed, 0);
                    iArea = 0;
                }

            // Otherwise, more areas to go in the module
            } else {
                // Work on the next area
                iArea++;
            }

            // Regardless of what happens, we're starting an area from scratch
            oArea   = MeGetObjectByIndex(oModule, iArea, LM_Area);
            iLastLM = MeGetObjectCount(oArea, LM_LW) - 1;
            iLM = 0;

        // Otherwise, more landmarks to go in the area
        } else {
            iLM++;
        }

        // Regardless of what happens, we're working on a different landmark
        oLM = MeGetObjectByIndex(oArea, iLM, LM_LWGate);
        iLastAdjLM = MeGetObjectCount(oLM, LM_LWGate) - 1;
        iAdjLM = 0;

    // Otherwise, more adjacent trails to go in the landmark
    } else {
        iAdjLM++;
    }

    // Regardless of what happens, we're working on a different adjacent landmark
    oAdjLM = MeGetObjectByIndex(oLM, iAdjLM, LM_LWGate);

    // Self-schedule
    DelayCommand(0.0, _UpdateGateways(oModule,
                                      iArea,  iLastArea,  oArea,
                                      iLM,    iLastLM,    oLM,
                                      iAdjLM, iLastAdjLM, oAdjLM));

    _End("_UpdateGateways");
/*}}}*/
}

void UpdateGateways(int bDone = FALSE)
{
/*{{{*/
    _Start("UpdateGateways bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    // If we're being invoked for the first time
    if (!bDone) {
        // Send progress message here

        // Start enumerating landmarks by scheduling _UpdateLandmarks()
        object  oModule  = GetModule();
        object  oArea    = MeGetObjectByIndex(oModule, 0, LM_Area);
        object  oGate    = MeGetObjectByIndex(oArea,   0, LM_LWGate);
        object  oAdjGate = MeGetObjectByIndex(oGate,   0, LM_LWGate);
        DelayCommand(0.0, _UpdateGateways(oModule,
                                          0, MeGetObjectCount(oModule, LM_Area)   - 1, oArea,
                                          0, MeGetObjectCount(oArea,   LM_LWGate) - 1, oGate,
                                          0, MeGetObjectCount(oGate,   LM_LWGate) - 1, oAdjGate));

    // Otherwise, we're being called because _EnumerateLandmarks() is done
    } else {
        // Dump the routing tables from each area
        object  oModule = GetModule();
        object  oArea   = MeGetObjectByIndex(oModule, 0, LM_Area);
        int count = MeGetObjectCount(oModule, LM_Area);
        int i;
        for (i = 0; i < count; i++)
        {
            oArea = MeGetObjectByIndex(oModule, i, LM_Area);
            DelayCommand(0.0, MeDumpLandmarks(oArea));
        }

        // Call MeProcessLandmarks(TRUE) to enter last phase
        MeProcessLandmarks(TRUE);
    }

    _End("UpdateGateways");
/*}}}*/
}

void MeProcessLandmarks(int bDone = FALSE)
{
/*{{{*/
    _Start("MeProcessLandmarks bDone='"+IntToString(bDone)+"'", DEBUG_TOOLKIT);

    object  oModule = GetModule();
    object  oArea;

    // If we're being invoked for the first time
    if (!bDone) {
        // If the landmark system is not present
        if (!GetLocalInt(oModule, LM_Present)) {
            // Send progress message here

            // Indicate that the landmark system is busy
            SetLocalInt(oModule, LM_Busy, 1);

            // Indicate that the landmark system is present
            SetLocalInt(oModule, LM_Present, 1);

            // Start landmark processing by calling EnumerateLandmarks()
            EnumerateLandmarks();
        }

    // Otherwise, we're being called because landmark processing is done
    } else {
        // The landmark system is not busy anymore, done
        DeleteLocalInt(oModule, LM_Busy);
    }

    _End("MeProcessLandmarks");
/*}}}*/
}

/*
 * MeAddRoute
 *
 * Potentially adds / modifies a routing table entry.
 */
void MeAddRoute(object oChanged, object oLandmark, object oDest, object oTrail, float fDist, string sPath, int bGate)
{
/*{{{*/
    _Start("MeAddRoute oChanged='"+GetTag(oChanged)+"' oLandmark='"+GetTag(oLandmark)+"' oDest='"+GetTag(oDest)+"' oTrail='"+GetTag(oTrail)+"' fDist='"+FloatToString(fDist)+"' sPath='"+sPath+"' bGate='"+IntToString(bGate)+"'", DEBUG_TOOLKIT);

    string  sRouteShortest;
    string  sRouteTrail;
    string  sRouteWeight;
    string  sRoutePath;
    string  sDest;
    string  sNewPath;
    object  oEntry;
    float   fShortestLen;
    int     count;
    int     i;

    if (bGate == 0)
    {
        sDest = GetTag(oDest);
        sRouteShortest = LM_LWRouteShortest_+sDest;
        sRouteTrail    = LM_LWRouteTrail_   +sDest;
        sRouteWeight   = LM_LWRouteWeight_  +sDest;
        sRoutePath     = LM_LWRoutePath_    +sDest;
        sDest          = LM_LWDest;
        sNewPath       = sPath+"%"+MeGetSuffix(GetTag(oLandmark));
    }
    else
    {
        sDest = GetTag(GetArea(oDest))+GetTag(oDest);
        sRouteShortest = LM_LWGateRouteShortest_+sDest;
        sRouteTrail    = LM_LWGateRouteTrail_   +sDest;
        sRouteWeight   = LM_LWGateRouteWeight_  +sDest;
        sRoutePath     = LM_LWGateRoutePath_    +sDest;
        sDest          = LM_LWGateDest;
        sNewPath       = sPath+"%"+GetTag(GetArea(oDest))+MeGetSuffix(GetTag(oLandmark));
    }

    // Search for an existing routing table entry
    count = MeGetObjectCount(oLandmark, sRouteTrail);
    _PrintString("count "+IntToString(count));
    for (i = 0; i < count; i++)
    {
        // If we found the matching entry
        oEntry = MeGetObjectByIndex(oLandmark, i, sRouteTrail);
        if (bGate) _PrintString("entry "+IntToString(i)+" "+GetTag(oEntry));
        if ((oEntry == oTrail) ||
            (!(GetIsObjectValid(oEntry)) && !(GetIsObjectValid(oTrail))))
        {
            // Skip larger distances
            if (bGate) _PrintString("entry dist"+FloatToString(MeGetFloatByIndex(oLandmark, i, sRouteWeight)));
            if (fDist >= MeGetFloatByIndex(oLandmark, i, sRouteWeight))
            {
                _PrintString("Skipped");
                _End("MeAddRoute");
                return;
            }

            // Update with smaller distance
            MeSetFloatByIndex (oLandmark, i, fDist,    sRouteWeight);
            MeSetStringByIndex(oLandmark, i, sNewPath, sRoutePath);

            /*
             * Deal with the shortest trail cache
             *
             * If this trail used to be the shortest, it would only change if
             * it got even shorter. In that case, the entire cache would be
             * flushed, so we don't need to worry about duplicates.
             *
             * We are guaranteed that the cache has already been initialized
             */
            fShortestLen = MeGetFloatByIndex(oLandmark, MeGetIntByIndex(oLandmark, 0, sRouteShortest), sRouteWeight);
            if (fDist < fShortestLen)
            {
                // Clear the old list
                MeDeleteIntRefs(oLandmark, sRouteShortest);
            }
            if (fDist == fShortestLen)
            {
                // Register route among shortest
                MeAddIntRef(oLandmark, i, sRouteShortest);
            }

            // Mark the area / module as changed
            SetLocalInt(oChanged, LM_Changed, 1);

            _PrintString("Updated");
            _End("MeAddRoute");
            return;
        }
    }

    // If this destination was not reachable before
    if (count == 0)
    {
        // Register newly reachable landmark
        _PrintString("First");
        MeAddObjectRef(oLandmark, oDest, sDest);

        // Register first route as shortest
        MeAddIntRef(oLandmark, 0, sRouteShortest);
    }
    else
    {
        /*
         * Deal with shortest path cache
         *
         * At this point we know that one exists, because there's already a
         * a route, just that this is a new way to get there.
         */
        fShortestLen = MeGetFloatByIndex(oLandmark, MeGetIntByIndex(oLandmark, 0, sRouteShortest), sRouteWeight);
        if (fDist < fShortestLen)
        {
            // Clear the old list
            MeDeleteIntRefs(oLandmark, sRouteShortest);
            MeAddIntRef(oLandmark, count, sRouteShortest);
            _PrintString("New shortest");
        }
        if (fDist == fShortestLen)
        {
            // Register new route among shortest
            MeAddIntRef(oLandmark, count, sRouteShortest);
            _PrintString("Another shortest");
        }
    }

    // Add new routing table entry
    MeAddObjectRef(oLandmark, oTrail,   sRouteTrail);
    MeAddFloatRef (oLandmark, fDist,    sRouteWeight);
    MeAddStringRef(oLandmark, sNewPath, sRoutePath);

    // Mark the area / module as changed
    SetLocalInt(oChanged, LM_Changed, 1);

    _PrintString("Added");
    _End("MeAddRoute");
/*}}}*/
}

/*
 * MeDumpLandmarks
 *
 * Outputs the current state of the routing table for each landmark in the area
 * to the log. The dump is best read in raw text as the indenting is lost when
 * examined in an XML viewer.
 */
void MeDumpLandmarks(object oArea)
{
/*{{{*/
    // It gets very expensive looping the routing table for no reason
    if (!MeIsDebugging(DEBUG_TOOLKIT)) return;

    _Start("MeDumpLandmarks oArea='"+GetTag(oArea)+"'", DEBUG_TOOLKIT);

    object  oLandmark;
    int     landmark;
    int     i;

    // Dump every landmark in the area
    landmark = MeGetObjectCount(oArea, LM_LW);
    for (i = 0; i < landmark; i++)
    {
        oLandmark = MeGetObjectByIndex(oArea, i, LM_LW);
        DelayCommand(0.0, MeDumpLandmark(oArea, oLandmark));
    }

    _End("MeDumpLandmarks", DEBUG_TOOLKIT);
/*}}}*/
}

void MeDumpLandmark(object oArea, object oLandmark)
{
/*{{{*/
    // It gets very expensive looping the routing table for no reason
    if (!MeIsDebugging(DEBUG_TOOLKIT)) return;

    _Start("MeDumpLandmark oArea='"+GetTag(oArea)+"' oLandmark='"+GetTag(oLandmark)+"'", DEBUG_TOOLKIT);

    string  sRouteShortest;
    string  sRouteTrail;
    string  sRouteWeight;
    string  sRoutePath;
    string  sDest;
    object  oDest;
    object  oTrail;
    float   fLen;
    int     dest;
    int     trail;
    int     j, k;

    // Dump every reachable destination from the landmark
    dest = MeGetObjectCount(oLandmark, LM_LWDest);
    for (j = 0; j < dest; j++)
    {
        oDest = MeGetObjectByIndex(oLandmark, j, LM_LWDest);
        sDest = GetTag(oDest);
        _PrintString("  Destination: "+sDest, DEBUG_TOOLKIT);

        sRouteShortest = LM_LWRouteShortest_+sDest;
        sRouteTrail    = LM_LWRouteTrail_   +sDest;
        sRouteWeight   = LM_LWRouteWeight_  +sDest;
        sRoutePath     = LM_LWRoutePath_    +sDest;

        // Dump all routes to the destination
        trail = MeGetObjectCount(oLandmark, sRouteTrail);
        for (k = 0; k < trail; k++)
        {
            oTrail = MeGetObjectByIndex(oLandmark, k, sRouteTrail);
            fLen   = MeGetFloatByIndex (oLandmark, k, sRouteWeight);
            if (fLen == MeGetFloatByIndex(oLandmark, MeGetIntByIndex(oLandmark, 0, sRouteShortest), sRouteWeight))
            {
                _PrintString("    Via Trail: "+GetTag(oTrail)+" *Distance: "+FloatToString(fLen)+" meters", DEBUG_TOOLKIT);
            }
            else
            {
                _PrintString("    Via Trail: "+GetTag(oTrail)+"  Distance: "+FloatToString(fLen)+" meters", DEBUG_TOOLKIT);
            }
        }
    }

    // Dump every reachable gateway from the landmark
    dest = MeGetObjectCount(oLandmark, LM_LWGateDest);
    for (j = 0; j < dest; j++)
    {
        oDest = MeGetObjectByIndex(oLandmark, j, LM_LWGateDest);
        sDest = GetTag(oDest);
        _PrintString("  Gateway: "+sDest+" ("+GetTag(GetArea(oDest))+")", DEBUG_TOOLKIT);

        sDest = GetTag(GetArea(oDest))+GetTag(oDest);
        sRouteShortest = LM_LWGateRouteShortest_+sDest;
        sRouteTrail    = LM_LWGateRouteTrail_   +sDest;
        sRouteWeight   = LM_LWGateRouteWeight_  +sDest;
        sRoutePath     = LM_LWGateRoutePath_    +sDest;

        // Dump all routes to the destination
        trail = MeGetObjectCount(oLandmark, sRouteTrail);
        for (k = 0; k < trail; k++)
        {
            oTrail = MeGetObjectByIndex(oLandmark, k, sRouteTrail);
            fLen   = MeGetFloatByIndex (oLandmark, k, sRouteWeight);
            if (fLen == MeGetFloatByIndex(oLandmark, MeGetIntByIndex(oLandmark, 0, sRouteShortest), sRouteWeight))
            {
                _PrintString("    Via Trail: "+GetTag(oTrail)+" *Distance: "+FloatToString(fLen)+" meters", DEBUG_TOOLKIT);
            }
            else
            {
                _PrintString("    Via Trail: "+GetTag(oTrail)+"  Distance: "+FloatToString(fLen)+" meters", DEBUG_TOOLKIT);
            }
        }
    }

    _End("MeDumpLandmark", DEBUG_TOOLKIT);
/*}}}*/
}
