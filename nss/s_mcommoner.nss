#include "h_ai"

void main()
{
    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    // initialize the NPC's memetic infrastructure
    NPC_SELF = MeInit();

    // assign behavior classes to the NPC
    MeInstanceOf(NPC_SELF, "generic,walker");

    // build talk table

    MeAddStringRef(NPC_SELF, "Daryl says my world is way too small and I should try to find another Area to walk around.", "Talk Table");
	MeAddStringRef(NPC_SELF, "I could really use a drink, but I can't get the bartender to fetch me one!", "Talk Table");
    MeAddStringRef(NPC_SELF, "...if I only had a brain...", "Talk Table");
	MeAddStringRef(NPC_SELF, "I had an idea once, but I don't remember what it was....", "Talk Table");
    MeAddStringRef(NPC_SELF, "I really wish I had something useful to do....", "Talk Table");
	MeAddStringRef(NPC_SELF, "Jasperre says I should learn to defend myself.", "Talk Table");
	MeAddStringRef(NPC_SELF, "Kilkonie says I should learn some magic so I can make people do things.", "Talk Table");
    MeAddStringRef(NPC_SELF, "Maybe I should just go take a nap.", "Talk Table");
    MeAddStringRef(NPC_SELF, "Olias says I'm getting smarter every day!", "Talk Table");
    MeAddStringRef(NPC_SELF, "Senach says I'm still a moron because I can't get past a door.", "Talk Table");
	MeAddStringRef(NPC_SELF, "The service in this establishment is just appalling!", "Talk Table");
    MeAddStringRef(NPC_SELF, "The weather sure is great!", "Talk Table");
	MeAddStringRef(NPC_SELF, "Weilding weapons in civilized areas is just a bad idea.", "Talk Table");
    MeAddStringRef(NPC_SELF, "Olias told me that when my script is improved, I could know rumors to tell people!  What's a script?", "Talk Table");
    MeSetLocalString(NPC_SELF, "TalkTable", "Talk Table");

    // build response table

    // chatter (54%)
    MeAddResponse(NPC_SELF, "RT:myDefault", "f_chatter", 40, RESPONSE_HIGH);
    // be bored (25%)
    MeAddResponse(NPC_SELF, "RT:myDefault", "f_bored", 40, RESPONSE_HIGH);
    // wander (11%)
    MeAddResponse(NPC_SELF, "RT:myDefault", "f_wander", 90, RESPONSE_HIGH);
    // say hello
    MeAddResponse(NPC_SELF, "RT:myDefault", "f_sayhello", 40, RESPONSE_HIGH);

    // activate the response table
    MeSetActiveResponseTable("Idle", "RT:myDefault", "");

    // force memetics to evaluate current response
    MeUpdateActions();

    _End("OnSpawn");
}
