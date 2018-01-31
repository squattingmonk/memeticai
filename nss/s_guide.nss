/*  Script:  Guide Spawn Script
 *           Copyright (c) 2002 William Bull
 *    Info:  Creates an NPC that uses the trail system and responds to a conversation.
 *  Timing:  This should be attached to a creature's OnSpawn callback
 *  Author:  William Bull
 *    Date:  January, 2003
 */

#include "h_ai"

// NOTE: This is an incredibly broken spawn script. It is still in-progress.

// Just a convienence function.
void SetupSignalMeme(object oMeme, int iSignal = 1, string sMsg = "", object oData = OBJECT_INVALID, int iData = 0, string sChannel = "");

void main()
{
    SetLocalString(OBJECT_SELF, "Name", _GetName(OBJECT_SELF));

    MeStartDebugging(DEBUG_UTILITY, 0);
    object oMeme, oSequence, oEvent;

    _Start("OnSpawn name = '"+_GetName(OBJECT_SELF)+"'");

    // Let's create a sequence, we can call it whatever we like...
    oSequence = MeCreateSequence("MySequence");

    // In this sequence, we'll go to and fro.
    oMeme = MeCreateSequenceMeme(oSequence, "i_gotolandmark");
    SetLocalObject(oMeme, "Destination", GetWaypointByTag("WP_DarkForest_01"));
    oMeme = MeCreateSequenceMeme(oSequence, "i_sendsignal");
    SetupSignalMeme(oMeme, 99);        // We'll send a signal: 99.

    oMeme = MeCreateSequenceMeme(oSequence, "i_gotolandmark");
    SetLocalObject(oMeme, "Destination", GetWaypointByTag("WP_Daeder_06"));
    oMeme = MeCreateSequenceMeme(oSequence, "i_sendsignal");
    SetupSignalMeme(oMeme, 99);        // We'll send a signal: 99.

    oMeme = MeCreateSequenceMeme(oSequence, "i_gotolandmark");
    SetLocalObject(oMeme, "Destination", GetWaypointByTag("WP_Daeder_14"));
    oMeme = MeCreateSequenceMeme(oSequence, "i_sendsignal");
    SetupSignalMeme(oMeme, 99);        // We'll send a signal: 99.

    oMeme = MeCreateSequenceMeme(oSequence, "i_gotolandmark");
    SetLocalObject(oMeme, "Destination", GetWaypointByTag("WP_Daeder_20"));
    oMeme = MeCreateSequenceMeme(oSequence, "i_sendsignal");
    SetupSignalMeme(oMeme, 99);        // We'll send a signal: 99.

    oMeme = MeCreateSequenceMeme(oSequence, "i_gotolandmark");
    SetLocalObject(oMeme, "Destination", GetWaypointByTag("WP_Daeder_04"));
    oMeme = MeCreateSequenceMeme(oSequence, "i_sendsignal");
    SetupSignalMeme(oMeme, 99);        // We'll send a signal: 99.

    oMeme = MeCreateSequenceMeme(oSequence, "i_gotolandmark");
    SetLocalObject(oMeme, "Destination", GetWaypointByTag("WP_Daeder_17"));
    oMeme = MeCreateSequenceMeme(oSequence, "i_sendsignal");
    SetupSignalMeme(oMeme, 99);        // We'll send a signal: 99.

    oMeme = MeCreateSequenceMeme(oSequence, "i_gotolandmark");
    SetLocalObject(oMeme, "Destination", GetWaypointByTag("WP_Daeder_12"));
    oMeme = MeCreateSequenceMeme(oSequence, "i_sendsignal");
    SetupSignalMeme(oMeme, 99);        // We'll send a signal: 99.

    oMeme = MeCreateSequenceMeme(oSequence, "i_gotolandmark");
    SetLocalObject(oMeme, "Destination", GetWaypointByTag("WP_Daeder_18"));
    oMeme = MeCreateSequenceMeme(oSequence, "i_sendsignal");
    SetupSignalMeme(oMeme, 99);        // We'll send a signal: 99.

    MeStartSequence(oSequence);

    oEvent = MeCreateEvent("e_guide");
//    MeAddTriggerSignal(oEvent, 99);    // We'll listen a signal: 99.
//    MeStartEvent(oEvent);

    // This will cause her to run up to you and say something.
    object oGen = MeCreateGenerator("g_goto", PRIO_HIGH, 10);
//    MeAddStringRef(oGen, "Hello! I'm just walking around, care to join me?");
//    MeStartGenerator(oGen);

    // This is what lets the girl talk, if a player clicks on her.
    oGen = MeCreateGenerator("g_converse", PRIO_HIGH, 10);
    // Cancel conversation after 6 seconds.
    SetLocalFloat (oGen, "Timeout", 6.0);
    SetLocalString(oGen, "Timeout", "I'm bored of you...goodbye!");
    MeStartGenerator(oGen);

    // Now, lets go.
    MeUpdateActions();

    _End("OnSpawn");
}

void SetupSignalMeme(object oMeme, int iSignal = 1, string sMsg = "", object oData = OBJECT_INVALID, int iData = 0, string sChannel = "")
{
    SetLocalInt(oMeme, "Signal", iSignal);
    SetLocalString(oMeme, "Message", sMsg);
    SetLocalObject(oMeme, "oData", oData);
    SetLocalInt(oMeme, "Number", iData);
    SetLocalString(oMeme, "Channel", sChannel);
}
