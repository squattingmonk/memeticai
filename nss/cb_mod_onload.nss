#include "h_ai"
#include "h_landmark_init"

void TestMoment();
void SetupDailyMoments();

void main()
{
    /*
     *  Uncomment MeStartDebugging to generate a compresive trace log.
     *
     *  After running your module, look in your NWN log directory.
     *
     *  1. Remove the Bioware text at the top of the module.
     *  2. Add <Log> to the top and </Log> to the bottom.
     *  3. Change the file extension from .txt to .xml
     *  4. View it in Internet Explorer
     *
     */
    // PrintString("]]></header>");
    // MeStartDebugging(DEBUG_USERAI, TRUE);
    // MeStartDebugging(USER_AI | DEBUG_COREAI, TRUE);
    // MeStartDebugging(USER_AI | DEBUG_COREAI | DEBUG_TOOLKIT , TRUE);
    MeStartDebugging(DEBUG_ALL, TRUE); // Debug what the module does.

    // DelayCommand(2.0, MeStartDebugging(DEBUG_ALL, TRUE)); // Debug what the module does.

    // This initialization script uses the function DelayCommand...
    // I want to print out <ModuleLoad> then have the DelayCommands
    // print their debugging output. Then print </ModuleLoad
    if (MeIsDebugging(DEBUG_ALL))
    {
        PrintString("<ModuleLoad>");
        DelayCommand(0.1, PrintString("</ModuleLoad>"));
    }

    // Register each area by supplying the tag of ONE waypoint from each area.
    // We have to do this because there are number NWScript functions to iterate
    // over the areas.
    //MeRegisterArea("LM_Lodge_01", "");
    //MeRegisterArea("LM_LodgeRoom_01", "");
    //MeRegisterArea("LM_Chasm_01", "");
    //MeRegisterArea("LM_Woodlands_01", "");

    // Build the landmark routing table structures.
    MeProcessLandmarks();

    // Setup Daily Schedule
    SetupDailyMoments();

    // Load Memetic libraries.

    // The following routines execute these scripts in a special mode, to
    // register the contents of the library. A library is a single script
    // that holds other scripts. You should create your own libraries and
    // initialize them here. These libraries will be updated with each
    // release.

    DelayCommand(0.0, MeLoadLibrary("lib_memes"));
    DelayCommand(0.0, MeLoadLibrary("lib_animation"));
    DelayCommand(0.0, MeLoadLibrary("lib_observer"));
    DelayCommand(0.0, MeLoadLibrary("lib_converse"));
    DelayCommand(0.0, MeLoadLibrary("lib_landmark"));
    DelayCommand(0.0, MeLoadLibrary("lib_movement"));
    DelayCommand(0.0, MeLoadLibrary("lib_door"));
    DelayCommand(0.0, MeLoadLibrary("lib_skillcheck"));
    DelayCommand(0.0, MeLoadLibrary("lib_death"));
    DelayCommand(0.0, MeLoadLibrary("lib_generic"));

    //DelayCommand(0.0, MeLoadLibrary("lib_combat"));
    //DelayCommand(0.0, MeLoadLibrary("lib_combat_f"));

    DelayCommand(0.0, MeLoadLibrary("lib_examples"));
    DelayCommand(0.0, MeLoadLibrary("lib_debug"));

    //DelayCommand(0.0, MeLoadLibrary("lib_avoidlight"));

	// Olias's bartender
	DelayCommand(0.0, MeLoadLibrary("lib_bartender"));

    // This is just a small test of the scheduler. It sends out periodic message.
    // This message may be caught by any NPC that has an event object that
    // receives these messages. If no NPCs subscribe to the channel then nothing
    // happens.
    //DelayCommand(0.0, TestMoment());
}

// We set up standard daily moments that fire every three game hours.
// Then we send out messages so that NPCs can react by subscribing to the
// "Time of Day" message channel. To see an example, look at the "e_home" event.
// An NPC will subscribe e_home to the Time of Day channel. When a message is
// received, it will look at a variable named "Home Area "+<string data>. In
// this case the string data will be times like, "Dawn, Morning", etc.
// Once every three hours each NPC will check to see if they should be in a
// different place.
void SetupDailyMoments()
{
    _Start("SetupDailyMoments", DEBUG_UTILITY);
    // Daily events are a chain of moments:
    // dawn, morning, noon, afternoon, sunset, evening, midnight, moondark
    int iTime = FloatToInt(HoursToSeconds(3));

    // These are daily moments that happen
    MeScheduleMoment("Dawn",      iTime, "Moondark",  TRUE);
    MeScheduleMoment("Morning",   iTime, "Dawn",      TRUE);
    MeScheduleMoment("Noon",      iTime, "Morning",   TRUE);
    MeScheduleMoment("Afternoon", iTime, "Noon",      TRUE);
    MeScheduleMoment("Sunset",    iTime, "Afternoon", TRUE);
    MeScheduleMoment("Evening",   iTime, "Sunset",    TRUE);
    MeScheduleMoment("Midnight",  iTime, "Evening",   TRUE);
    MeScheduleMoment("Moondark",  iTime, "Midnight",  TRUE);

    struct message msgTimeOfDay = MeCreateMessage("Time of Day");

    msgTimeOfDay.sData = "Dawn";
    MeScheduleMessage(msgTimeOfDay, OBJECT_INVALID, "Time of Day", 0, "Dawn", TRUE);
    msgTimeOfDay.sData = "Morning";
    MeScheduleMessage(msgTimeOfDay, OBJECT_INVALID, "Time of Day", 0, "Morning", TRUE);
    msgTimeOfDay.sData = "Noon";
    MeScheduleMessage(msgTimeOfDay, OBJECT_INVALID, "Time of Day", 0, "Noon", TRUE);
    msgTimeOfDay.sData = "Afternoon";
    MeScheduleMessage(msgTimeOfDay, OBJECT_INVALID, "Time of Day", 0, "Afternoon", TRUE);
    msgTimeOfDay.sData = "Sunset";
    MeScheduleMessage(msgTimeOfDay, OBJECT_INVALID, "Time of Day", 0, "Sunset", TRUE);
    msgTimeOfDay.sData = "Evening";
    MeScheduleMessage(msgTimeOfDay, OBJECT_INVALID, "Time of Day", 0, "Evening", TRUE);
    msgTimeOfDay.sData = "Midnight";
    MeScheduleMessage(msgTimeOfDay, OBJECT_INVALID, "Time of Day", 0, "Midnight", TRUE);
    msgTimeOfDay.sData = "Moondark";
    MeScheduleMessage(msgTimeOfDay, OBJECT_INVALID, "Time of Day", 0, "Moondark", TRUE);

    int iHour = GetTimeHour();

    if (iHour >= 21)
    {
        DelayCommand(0.0, MeActivateMoment("Midnight"));
    }
    else if (iHour >= 18)
    {
        DelayCommand(0.0, MeActivateMoment("Evening"));
    }
    else if (iHour >= 15)
    {
        DelayCommand(0.0, MeActivateMoment("Sunset"));
    }
    else if (iHour >= 12)
    {
        DelayCommand(0.0, MeActivateMoment("Afternoon"));
    }
    else if (iHour >= 9)
    {
        DelayCommand(0.0, MeActivateMoment("Noon"));
    }
    else if (iHour >= 6)
    {
        DelayCommand(0.0, MeActivateMoment("Morning"));
    }
    else if (iHour >= 3)
    {
        DelayCommand(0.0, MeActivateMoment("Dawn"));
    }
    else if (iHour >= 0)
    {
        DelayCommand(0.0, MeActivateMoment("Moondark"));
    }
    _End();
}

// This is an example of the scheduler with a ten second ping moment.
// One second after this moment fires, a "Mimic/Hear" message is sent out
// with the data "Ping" on the channel named "Mimic_Channel". If any NPC
// has registered an event object, it will execute, receiving the ping message.

// This is just an example of a periodic message, used for testing.
void TestMoment()
{
    _Start("moment_ini", DEBUG_UTILITY);

    MeScheduleMoment("Ping", 10, "", TRUE);

    struct message stMsg;
    stMsg.sMessageName = "Mimic/Hear";
    stMsg.sData        = "Ping";
    MeScheduleMessage(stMsg, OBJECT_INVALID, "Mimic_Channel", 1, "Ping", TRUE);

    _End();
}
