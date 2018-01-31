/*
 *     file: h_landmark_com
 *  authors: Daryl Low
 * modified: July 5, 2003
 *
 * Copyright 2003. For non-commercial use only.
 * Contact bbull@qnx.com with questions.
 */
 /*
  *{{{ Notes
  *}}}
  */

#include "h_util"

//{{{ --- Data Structure String Constants -------------------------------------
// Waypoint prefix
const string LM_LW_ = "LW_";     // Local landmark prefix
const string LM_GW_ = "GW_";     // Gateway prefix
const string LM_LT_ = "LT_";     // Local trail prefix
const string LM_GT_ = "GT_";     // Gateway trail prefix

// Synchronization counters
const string LM_Present       = "LM_Present";
const string LM_Busy          = "LM_Busy";

// Module specific
const string LM_GW = "LM_GW";

const string LM_Prefix = "LM_Prefix";
const string LM_Area   = "LM_Area";

// Area specific
const string LM_LW     = "LM_LW";
const string LM_LWGate = "LM_LWGate";

const string LM_AreaInit = "LM_AreaInit";
const string LM_Changed  = "LM_Changed";

// Landmark specific
const string LM_GWTrail   = "LM_GWTW";

// Reachable landmarks / gateways
const string LM_LWTrail  = "LM_LWTW";

const string LM_LWDest     = "LM_LWDest";
const string LM_LWGateDest = "LM_LWGDest";

// Index to shortest route to a particular destination
const string LM_LWRouteShortest_     = "LM_LWRShort_";
const string LM_LWGateRouteShortest_ = "LM_LWGRShort_";

// Local landmark routing table
const string LM_LWRouteTrail_  = "LM_LWRTrail_";
const string LM_LWRoutePath_   = "LM_LWRPath_";
const string LM_LWRouteWeight_ = "LM_LWRWeight_";

// Gateway routing table
const string LM_LWGateRouteTrail_  = "LM_LWGRTrail_";
const string LM_LWGateRoutePath_   = "LM_LWGRPath_";
const string LM_LWGateRouteWeight_ = "LM_LWGRWeight_";

// Trail specific
const string LM_FarArea        = "LM_FarArea";
const string LM_LWNear         = "LM_LandmarkNear";
const string LM_LWFar          = "LM_LandmarkFar";
const string LM_TWNear         = "LM_WaypointNear";
const string LM_TWFar          = "LM_WaypointFar";
const string LM_WeightDist     = "LM_WeightDist";
const string LM_WeightGateDist = "LM_WeightGateDist";
//}}}

struct GatewayVect_s {
/*{{{*/
    object  oGate;      // Local gateway
    object  oDestGate;  // Destination gateway
/*}}}*/
};

struct TrailVect_s {
/*{{{*/
    object  oWaypoint;  // Next trail waypoint to head to
    object  oTrail;     // Trail endpoint we are headed to
    object  oLandmark;  // Landmark we are heading towards
    int     iDirection; // -1 go back, 0 there, 1 go forward
/*}}}*/
};

//{{{ --- Utility Functions ---------------------------------------------------
string MeZeroIntToString(int i)
{
/*{{{*/
    if (i < 10) return ("0"+IntToString(i));
    else        return (IntToString(i));
/*}}}*/
}

string MeGetSuffix(string s)
{
/*{{{*/
    return (GetStringRight(s, 2));
/*}}}*/
}

string MeGetPrefix(string s)
{
/*{{{*/
    return (GetStringLeft(s, GetStringLength(s) - 2));
/*}}}*/
}
//}}}

/*
 *{{{ Data Structures
 *
 * Module
 *  int      LM_Busy - Indicates that landmarks are being computed
 *
 *  string[] LM_Prefix - List of landmark and trail prefixes
 *  object[] LM_Area   - List of areas
 *
 * Area
 *  string   LM_Prefix   - Unique landmark prefix for the area
 *  string   LM_AreaInit - Init script for the area
 *
 *  object[] LM_GW       - List of gateways
 *  object[] LM_LW       - List of internal landmarks
 *  object[] LM_LWGate   - List of internal gateway landmarks
 *
 *  int      LM_Changed - A routing table entry has changed in the current
 *                        routing table construction pass
 *
 * Gateway
 *  object LM_GW - Connected remote gateway
 *
 *  object LM_LW      - Connected local landmark
 *  object LM_LWTrail - Trail to connected local landmark
 *
 * Landmark
 *  object LM_GW      - Adjacent gateway
 *  object LM_GWTrail - Trail to adjacent gateway
 *
 *  object[] LM_LWTrail - List of adjacent local trails
 *  object[] LM_LWGate  - List of adjacent local gateway landmarks
 *
 *  // Weighting class dependent
 *  object[] LM_LWDest - List of reachable landmarks
 *
 *  int[]    LM_LWRouteShortest_<Dest> - Index of shortest trail to the destination
 *  object[] LM_LWRouteTrail_<Dest>    - List of trails that lead to the destination
 *  string[] LM_LWRoutePath_<Dest>     - List of delimited path to destination via the trail
 *  float[]  LM_LWRouteWeight_<Dest>   - List of distance to the destination via the trail
 *
 *  object[] LM_LWGateDest - List of reachable gateway landmarks
 *
 *  int[]    LM_LWGateRouteShortest_<Dest> - Index of shortest trail to the destination gateway
 *  object[] LM_LWGateRouteTrail_<Dest>    - List of trails that lead to the destination gateway
 *  string[] LM_LWGateRoutePath_<Dest>     - List of delimited path to destination gateway via the trail
 *  float[]  LM_LWGateRouteWeight_<Dest>   - List of distance to the destination gateway via the trail
 *
 * Trail
 *  object LM_FarArea - Area of landmark on opposite end of trail (gateway only)
 *  object LM_LWNear  - Landmark closest to trail waypoint
 *  object LM_LWFar   - Landmark closest to opposite end of trail
 *  object LM_TWFar   - Waypoint on opposite end of trail
 *
 *  // Weighting class dependent
 *  float  LM_WeightDist   - Length of trail in meters
 *}}}
 */

