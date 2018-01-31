// h_group

#include "h_library"
#include "x0_i0_position"

// Constants -------------------------------------------------------------------
const float MAX_X = 160.0;
const float MAX_Y = 160.0;
const float MIN_X = 0.0;
const float MIN_Y = 0.0;

// Prototypes-------------------------------------------------------------------
// Return the distance from the current position to the lower-bound X border, scaled onto [0, 1]
float GetScaledX(float x);

// Return the distance from the current position to the lower-bound Y border, scaled onto [0, 1]
float GetScaledY(float y);

// Find the name of a clan for a specific creature,
// set by local variable "Clan_Name") or, if that's not set, the
// creature's tag.
//
// Parameters
// oMember - Creature whose clan name is returned.
string GetGroupName(object oMember);

// Finds the size of the clan specified.
// First tries to find clan size as a local variable to the module.
// Failing that, try to find all creatures with tags matching the
// member provided.
//
// Parameters
// oMember - Creature belonging to clan.
// sGroup - name of the clan to check, by default the creature's tag
int GetGroupSize(object oMember, string sGroup = "Default");

// This function returns the creature acting as leader for the clan specified.
//
// Parameters
// oMember - Creature belonging to clan.
// sGroup - name of clan to check, defaults to the creature's tag
object GetGroupLeader(object oMember, string sGroup="Default");

// Determine the nearest group member
object GetNearestGroupMember(object oMember, string sGroup="Default", float fAttractLimit = 0.0, int bGlobal = FALSE);

// Determine if target is a friend (belongs to the same group)
//int GetIsInGroup(object oSelf, object oTarget);

// Format a vector for debugging statements.
string DebugVector(vector outputVector);

//Get the distance between two points A and B.
float VectorDistance(vector vA, vector vB);

// Spin randomly 45 degrees left or right.
void SetRandomFacing(object target);

// Given an area, a position and a heading, create a new location at position+heading.
location GetTargetLocation(object area, vector selfVector, vector heading);

//Get the facing angle of an object. Result is normalized
vector CalculateFacingVector(object obj);

/*
 * Calculate the affect of our friends. For each of the friends
 *  that we wish to consider, we determine:
 * 1. whether they attract us (a vector towards) or repel
 *    us (a vector away)
 * 2. their current heading, with which we will align ourselves
 *
 * For attraction/repulsion see CalculateAttractRepelVector
 * For heading see CalculateFriendDirectionVector
 */
vector CalculateFriendAffectVector(object self, vector selfVector);

/*
 * Calculate the forces of attraction or repulsion that exist
 * between ourself and a friend.
 *
 * Repulsion occurs when we are too close to our friend, otherwise
 * we are attracted. Beyond the max distance, we are un-affected.
 */
vector CalculateAttractRepelVector(vector selfVector, object friend);

// Calculate the direction in which our friend is moving.
vector CalculateFriendDirectionVector(object friend);

//Calculate the direction in which we are moving.
vector CalculateSelfDirectionVector(object self);

/*
 * Calculate the impact of edge avoidance. The importance of this
 * impact increases the closer we get to the edge of the map.
 * The logic is that if we are close to the left edge, then
 * weightRight-weightLeft>0. So the X portion of the vector
 * will be positive, implying a move to the right. Similar
 * calcs can be made for each edge.
 */
vector CalculateEdgeAvoidanceVector(object self);

// Implementation --------------------------------------------------------------

// Utility Routines ------------------------------------------------------------

/*
string VectorToString(vector outputVector)
{
    string x = FloatToString(outputVector.x, 8, 4);
    string y = FloatToString(outputVector.y, 8, 4);
    string z = FloatToString(outputVector.z, 8, 4);

    return x + ":" + y + ":" + z;
}
*/

float VectorDistance(vector vA, vector vB)
{
    float sum = pow(vA.x-vB.x, 2.0) + pow(vA.y-vB.y, 2.0) + pow(vA.z-vB.z, 2.0);
    return sqrt(sum);
}

void SetRandomFacing(object target)
{
    float facing = GetFacing(target); // GetCorrectFacing(target);
    float delta = IntToFloat(Random(91))-45.0f; // -45 to 45
    float newFacing = facing+delta;
    if (newFacing > 360.0f) newFacing -= 360.0;
    if (newFacing < 0.0f) newFacing += 360.0;
    SetFacing(newFacing);
}

location GetTargetLocation(object area, vector selfVector, vector heading)
{
    vector newPosition = selfVector + heading;
    _PrintString("New Position Vector: " + VectorToString(newPosition), DEBUG_UTILITY);

    // now get the new location to which we will move,
    // using the newPosition, and face in heading direction
    location resultLocation = Location(area, newPosition, VectorToAngle(heading));
    return resultLocation;
}

vector CalculateFacingVector(object obj)
{
    float facing = GetFacing(obj); // GetCorrectFacing(obj);
    return AngleToVector(facing);
}

float GetScaledX(float x)
{
    return (x-MIN_X)/(MAX_X-MIN_X);
}

float GetScaledY(float y)
{
    return (y-MIN_Y)/(MAX_Y-MIN_Y);;
}

//----------------------- Flocking Routines --------------------

/*
 * Calculate the impact of edge avoidance. The importance of this
 * impact increases the closer we get to the edge of the map.
 * The logic is that if we are close to the left edge, then
 * weightRight-weightLeft>0. So the X portion of the vector
 * will be positive, implying a move to the right. Similar
 * calcs can be made for each edge.
 */
vector CalculateEdgeAvoidanceVector(object self)
{
    // get our current pos
    vector selfVector = GetPositionFromLocation(GetLocation(self));

    // get weight for each... falls off with square of dist
    float weightLeft = pow(GetScaledX(selfVector.x), 2.0);
    float weightRight = pow(1-GetScaledX(selfVector.x), 2.0);
    float weightDown = pow(GetScaledY(selfVector.y), 2.0);
    float weightUp = pow(1-GetScaledY(selfVector.y), 2.0);

    vector edgeAvoid = Vector(weightRight-weightLeft, weightUp-weightDown, 0.0f);

    // weight, to overcome other effects
    edgeAvoid *= MeGetLocalFloat(MEME_SELF, "EdgeAvoidWeight");
    _PrintString("Edge Avoid Vector: " + VectorToString(edgeAvoid), DEBUG_UTILITY);

    return edgeAvoid;
}

/*
 * Calculate the direction in which we are moving.
 */
vector CalculateSelfDirectionVector(object self)

{
    // where are we going
    vector direction = CalculateFacingVector(self);

    // weight accordingly
    direction = direction * MeGetLocalFloat(MEME_SELF, "SelfDirectionWeight");
    _PrintString("Self Direction Vector: " + VectorToString(direction), DEBUG_UTILITY);

    // send it home
    return direction;
}

/*
 * Calculate the direction in which our friend is moving.
 */
vector CalculateFriendDirectionVector(object friend)
{
    // where is the friend heading?
    vector direction = CalculateFacingVector(friend);

    // weight accordingly
    direction = direction * MeGetLocalFloat(MEME_SELF, "FriendDirectionWeight");
    _PrintString("Friend Direction Vector: " + VectorToString(direction), DEBUG_UTILITY);

    // send it home
    return direction;
}

/*
 * Calculate the forces of attraction or repulsion that exist
 * between ourself and a friend.
 *
 * Repulsion occurs when we are too close to our friend, otherwise
 * we are attracted. Beyond the max distance, we are un-affected.
 */
vector CalculateAttractRepelVector(vector selfVector, object friend)
{
    _Start("CalculateAttractRepelVector", DEBUG_UTILITY);

    // temp variable for heading
    vector attractRepel = Vector(0.0f, 0.0f, 0.0f);

    // get location of our friend
    location friendLocation = GetLocation(friend);
    vector friendVector = GetPositionFromLocation(friendLocation);
    _PrintString("Friend Vector: " + VectorToString(friendVector), DEBUG_UTILITY);

    // how close is our friend
    float dist = VectorDistance(friendVector, selfVector);
    _PrintString("Distance: " + FloatToString(dist), DEBUG_UTILITY);

    float repelLimit = MeGetLocalFloat(MEME_SELF, "RepelLimit");
    _PrintString("Repel Limit: " + FloatToString(repelLimit), DEBUG_UTILITY);

    if (dist < repelLimit)
    {
        // if repulse, the vector points away from friend
        attractRepel = selfVector - friendVector;

        // normalize result
        attractRepel = VectorNormalize(attractRepel);

        // weight result -- closer gets higher weight
        attractRepel *= pow(1.0-dist/repelLimit, 2.0) * MeGetLocalFloat(MEME_SELF, "RepelWeight");
        _PrintString("Repulse Vector: " + VectorToString(attractRepel), DEBUG_UTILITY);
    }
    else
    {
        // if attract, the vector points towards friend
        attractRepel = friendVector - selfVector;

        // normalize result
        attractRepel = VectorNormalize(attractRepel);

        // weight result -- further gets higher weight
        float attractLimit = MeGetLocalFloat(MEME_SELF, "AttractLimit");
        float temp = pow((dist-repelLimit)/(attractLimit-repelLimit), 2.0);
        attractRepel *= temp * MeGetLocalFloat(MEME_SELF, "AttractWeight");
        _PrintString("Attract Vector: " + VectorToString(attractRepel), DEBUG_UTILITY);
    }

    _End();
    return attractRepel;
}

/*
 * Calculate the affect of our friends. For each of the friends
 * that we wish to consider, we determine:
 * 1. whether they attract us (a vector towards) or repel
 *    us (a vector away)
 * 2. their current heading, with which we will align ourselves
 *
 * For attraction/repulsion see CalculateAttractRepelVector
 * For heading see CalculateFriendDirectionVector
 */
vector CalculateFriendAffectVector(object self, vector selfVector)
{
    _Start("CalculateFriendAffectVector", DEBUG_UTILITY);

    // declare local variables -- do this because of 'break' bug
    object friend;
    vector attractRepel;
    vector align;
    int countFriends = 0;

    string sGroupName = GetGroupName(self);

    // the vector to hold the results
    vector friendAffectVector = Vector(0.0f, 0.0f, 0.0f);

    // obtain a creature within attractLimit meters
    float attractLimit = MeGetLocalFloat(MEME_SELF, "AttractLimit");
    friend = GetFirstObjectInShape(SHAPE_SPHERE, attractLimit,
        GetLocation(self), TRUE, OBJECT_TYPE_CREATURE);

    // Set the group member limit
    int iMemberLimit = MeGetLocalInt(MEME_SELF, "MemberLimit");
    if (iMemberLimit == 0) iMemberLimit = 3;

    while (friend != OBJECT_INVALID && GetGroupName(friend) == sGroupName) //GetIsInGroup(friend, self))
    {
        if (friend != OBJECT_SELF)
        {
            // we've found a friend
            _PrintString("Friend(s) Index: " + IntToString(countFriends) + " (" + _GetName(friend) + ").", DEBUG_UTILITY);

            // Constant time fakey!
            if (countFriends > iMemberLimit)
            {
                _PrintString("Member limit reached.", DEBUG_COREAI);
                break;
            }

            // determine the contribution of attraction/repulsion
            attractRepel = CalculateAttractRepelVector(selfVector, friend);
            friendAffectVector += attractRepel;

            // determine the contribution of friend's direction
            align = CalculateFriendDirectionVector(friend);
            friendAffectVector += align;

            // and increment the number of friends found
            countFriends++;
            _PrintString("Friend Affect Vector: " + VectorToString(friendAffectVector), DEBUG_UTILITY);
        }
        else
        {
            _PrintString("Skipping self.", DEBUG_UTILITY);
        }

        // get the next creature
        friend = GetNextObjectInShape(SHAPE_SPHERE, attractLimit,
            GetLocation(self), TRUE, OBJECT_TYPE_CREATURE);

    } // end loop

    _PrintString("Finished evaluating creatures in area.", DEBUG_UTILITY);

    // weight by number of friends found
    if (countFriends > 0)
    {
        friendAffectVector /= IntToFloat(countFriends);
    }
    else
    {
        // ??? What to do if no friends?
        _PrintString("No friends found.", DEBUG_UTILITY);
    }

    _PrintString("Friend Affect (final) Vector: " + VectorToString(friendAffectVector), DEBUG_UTILITY);

    _End();
    return friendAffectVector;
}

// Find the name of a clan for a specific creature,
// set by local variable "GroupName") or, failing that, the creature's
// tag.
string GetGroupName(object oMember = OBJECT_SELF)
{
    _Start("GetGroupName member='" + _GetName(oMember) + "'", DEBUG_COREAI);

    string sGroup = MeGetLocalString(oMember, "GroupName");

    if (sGroup == "")
    {
        sGroup = GetTag(oMember);
        _PrintString("Defaulting to tag: " + sGroup);
        MeSetLocalString(oMember, "GroupName", sGroup);
    }

    _End();
    return sGroup;
}

// GetGroupSize - Finds the size of the clan specified.
// First tries to find clan size as a local variable to the module.
// Failing that, try to find all creatures with tags matching the
// member provided.
//
// Parameters
// oMember - Creature belonging to clan.
// sGroup - name of the clan to check, by default the creature's clan
int GetGroupSize(object oMember, string sGroup = "Default")
{
    _Start("GetGroupSize clan='" + sGroup + "'", DEBUG_COREAI);

    if (sGroup == "Default")
    {
        _PrintString("Checking default group.", DEBUG_COREAI);
        sGroup = GetGroupName(oMember);
    }

    int nGroupSize = GetLocalInt(GetModule(),"Group_" + sGroup + "_Size");
    if (nGroupSize != 0)
    {
        _PrintString("Group size already set to " + IntToString(nGroupSize));
    }
    else
    {
        nGroupSize = MeGetObjectCount(GetModule(),"Group_" + sGroup + "_Members");
    }

    _PrintString("Returning size " + IntToString(nGroupSize));

    _End();
    return nGroupSize;
}

// GetGroupLeader
// This function returns the creature acting as leader for the Group specified.
object GetGroupLeader(object oMember, string sGroup="Default")
{
    _Start("GetGroupLeader Group='" + sGroup + "'", DEBUG_COREAI);

    object oLeader;
    if (sGroup == "Default")
    {
        _PrintString("Checking Default Group", DEBUG_COREAI);
        sGroup = GetGroupName(oMember);
    }

    int nMembersCount = MeGetObjectCount(GetModule(), "Group_" + sGroup + "_Members");
    if (nMembersCount < GetGroupSize(oMember, sGroup))
    {
        _PrintString("Should be " + IntToString(GetGroupSize(oMember,sGroup))
            + " members " + "found " + IntToString(nMembersCount), DEBUG_COREAI);
        oLeader = OBJECT_INVALID;
    }
    else
    {
        _PrintString("Returning member " + IntToString(nMembersCount - 1), DEBUG_COREAI);
        oLeader = MeGetObjectByIndex(GetModule(),nMembersCount - 1,
            "Group_" + sGroup + "_Members");
    }
    _PrintString("Final leader " + _GetName(oLeader), DEBUG_COREAI);

    _End();
    return oLeader;
}

// GroupJoin
// Adds the specified creature to the Group named.
void JoinGroup(string sGroup = "Default")
{
    _Start("Join Group='" + sGroup + "'", DEBUG_COREAI);

    if (sGroup == "Default")
    {
        _PrintString("Checking Default Group");
        sGroup = GetGroupName(OBJECT_SELF);
    }

    MeAddObjectRef(GetModule(), OBJECT_SELF,"Group_" + sGroup + "_Members");
    _PrintString("I've joined " + "Group_" + sGroup + "_Members");

    int nMembersCount = MeGetObjectCount(GetModule(), "Group_" + sGroup + "_Members");
    int nFinalMembers = GetGroupSize(OBJECT_SELF,sGroup);
    _PrintString("Member " + IntToString(nMembersCount) + " of " + IntToString(nFinalMembers));
    if (nMembersCount == nFinalMembers)
    {
        _PrintString("I'm the leader of Group " + sGroup);

        struct message sJoin;
        sJoin.sMessageName = "PACK/JOIN";
        sJoin.sChannelName = "Group_" + sGroup;
        sJoin.oData = OBJECT_SELF;
        sJoin.iData = nMembersCount;

        DelayCommand(0.1, MeBroadcastMessage(sJoin, "Group_" + sGroup));
    }

    _End();
}

object GetNearestGroupMember(object oMember, string sGroup="Default", float fAttractLimit = 40.0, int bGlobal = FALSE)
{
    _Start("GetNearestMember Group='" + sGroup + "'", DEBUG_COREAI);

    object oFriend;
    string sGroup;
    int iCriteria;
    int i = 1;

    sGroup = GetGroupName(oMember);

    if (bGlobal)
        oFriend = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oMember, i);
    else
        oFriend = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN | PERCEPTION_HEARD, oMember, i,
            CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND);

    while (oFriend != OBJECT_INVALID && GetGroupName(oFriend) != sGroup)
    {
        if (bGlobal)
            oFriend = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, oMember, ++i);
        else
            oFriend = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN | PERCEPTION_HEARD, oMember, ++i,
            CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND);
    }

    if (oFriend != OBJECT_INVALID)
    {
        _PrintString("AttractLimit: " + FloatToString(fAttractLimit), DEBUG_UTILITY);

        float fDistance = GetDistanceBetween(oMember, oFriend);

        if (fDistance < fAttractLimit)
        {
            _PrintString("Nearest group member is within AttractLimit: " + _GetName(oFriend), DEBUG_UTILITY);
            _End();
            return oFriend;
        }
        else
        {
            _PrintString("Nearest group member is outside of AttractLimit: " + _GetName(oFriend), DEBUG_UTILITY);
        }
    }

    _End();
    return OBJECT_INVALID;
}
