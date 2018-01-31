/*

    I have just made a background behavior that determines that the NPC
    is in the wrong area. It's job is to create a meme that looks for a
    route to go to the right area. If it can't find one then it wanders
    around for about 30 seconds and emits an "I'm lost" internal message.
    If it does find a reasonable route it creates a child meme and clears
    its repeating behavior.

    I believe we should concentrat on getting Daryl's landmark code written
    to a DB as soon as possible. Additional tools will be build to analyze
    this and display the map using OpenGL. We can approximate the XYZ location
    of each area and matain these with an external editor. The landmark analysis
    routines should also attempt to discover the area width and height by
    creating dummy waypoints and testing for failure. Area qualities, such as
    interior, etc. can be represented visual. All in all the goal is to give
    some overall 3D visual representation of the connected nature of the areas
    and allow for external tweaking of paths -- such as private or public and
    the distance between gateways.

    We also need to address the issue of non-movement triggered gateways.
    The landmark meme needs to see if the meme is responsible for warping the
    NPC to the location and should specify how long it takes the NPC to get
    there or what type of animation or sequence should activate before transporting
    them. This will allow NPC's to disappear while they are "in transit" and
    do animations like haggling over transport, or pulling levers to use a door.

*/

// These high-level functions cause the NPC to go to an place using either
// Bioware's default walk mesh or the Trail & Landmark code.

void MeGotoArea(object oNPC, object oDest, int iPriority, int iModifier)
{
    // This must be translated into a gateway that is most appropriate.
    // Attempt to find out where the NPC currently is, in terms of trails.
    // Then check to see if any gateway for this area can go to the given area.
    // If so, goto the corresponding gateway in the other ware.

    // If there are no immediately connecting gateways in an adjacent area, then
    // compute the distance from the nearby trail to the each of the gateways
    // in the remote area. Select the shortest remote gateway path and go to it.
}

void MeGotoObject(object oNPC, object oDest, int iPriority, int iModifier)
{
    // Call MeGotoLocation using the location of the object.
}

void MeGotoLocation(object oNPC, location lLoc, int iPriority, int iModifier)
{
    // First select the closest trail point to the given object. We will have to
    // assume that the NPC can walk from this point to the given object.

    // To find the closest trail we must use an expanding search via
    // GetFirstObjectInShape() with a fairly large search radius. Alternatively,
    // we can look for landmarks in the given area that have a well-known name.
    // I will refer to Daryl's code to see how he finds nearyby trails and
    // landmarks when lost. Because the GetFist/GetNext cannot be broken up, we
    // must do this without TMI'ing -- very tricky. It is recommended that this
    // be done in passes with an ever-increasing radius.

    // We must mark on the landmark meme that after the NPC reaches their
    // destination landmark, they are to go to the object using Bioware's
    // default walk routines.
}

void MeGotoLandmark(object oNPC, object oLandmark, int iPriority, int iModifier)
{
    // Simple; use the meme.
}
