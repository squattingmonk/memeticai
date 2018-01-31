/*
lib_bartender: Memetic AI Toolkit library to implement a generic bartender.
Author: Marty Shannon (a.k.a. Olias of Sunhillow)
Copyright 2004, Marty Shannon
*/

#include "h_library"
#include "h_fifo"

/*
Implementation components:
	Triggers:
		BarPatron: describes an area where patrons wishing to be
			served stand.

Bartender (Creature) Parameterization Variables:
	"MT: Breakfast Area"; string; no default; an Area name
	"MT: Breakfast ETime"; int; default: 659
	"MT: Breakfast Room"; string; no default; a local landmark Waypoint Tag
	"MT: Breakfast Seat"; string; no default; a Placeable seat Tag
	"MT: Breakfast STime"; int; default: 601
	"MT: Dinner Area"; string; no default; an Area name
	"MT: Dinner ETime"; int; default: 1900
	"MT: Dinner Room"; string; no default; a local landmark Waypoint Tag
	"MT: Dinner Seat"; string; no default; a Placeable seat Tag
	"MT: Dinner STime"; int; default: 1801
	"MT: Lunch Area"; string; no default; an Area name
	"MT: Lunch ETime"; int; default: 1259
	"MT: Lunch Room"; string; no default; a local landmark Waypoint Tag
	"MT: Lunch Seat"; string; no default; a Placeable seat Tag
	"MT: Lunch STime"; int; default: 1200
	"MT: OffWork Area"; string; no default; an Area name
	"MT: OffWork Room"; string; no default; a local landmark Waypoint Tag
	"MT: Shift Pay"; int; default: 30
	"MT: Sleep Area"; string; no default; an Area name
	"MT: Sleep Bed"; string; no default; a Placeable bed Tag
	"MT: Sleep ETime"; int; default: 600
	"MT: Sleep Room"; string; no default; a local landmark Waypoint Tag
	"MT: Sleep STime"; int; default: 2200
	"MT: Work Area"; string; no default; an Area name
	"MT: Work ETime"; int; default: 1800
	"MT: Work Room"; string; no default; a local landmark Waypoint Tag
	"MT: Work STime"; int; default: 700

Bartender (Creature) State Variables:
	int "Bartender:AtWork"; 0 -> not at work; 1 -> at work
(the following might want to be part of a more generic class)
	String[]: "Times"; times of day
	String[]: "Moments"; "active" moment at that time of day

BarPatron (Trigger) State Variables:
	string[] "BarPatron"; a fifo of names of people within the trigger
*/

/*
Notes on landmarks:

the following 4 types of waypoints must be placed by the module designer
to make use of either the i_gotoarea meme or the i_gotolandmark meme.
waypoint names need only be unique within an area.

"landmark" waypoints (LW_#) are used to represent likely places for an NPC
to want to go.  LW_1 might represent a bedroom, for instance, and would be
placed near the center, where there is a clear path to LT_1_#_01.

"gateway" waypoints (GW_#) are used to get an NPC from one area to another.
Each GW must have a string variable "MT: Destination Area" that tells which
area it leads to, and a string variable "MT: Destination GW" that tells
which GW in the destination area it leads to.  all transitions (not just
area transitions) should be marked with GW_# waypoints.

"local trail" waypoints (LT_#_#_##) are used to move an NPC from a landmark
(1st #) to another landmark (2nd #); if only one is needed, then the ##
is 01; if more are needed (up to 100), they must be contiguously numbered
starting at 01.

"gateway trail" waypoints (GT_#_#_##) are used to move an NPC from a gateway
(1st #) to a landmark (2nd #), similarly to local trails.

nonetheless, the code in h_landmark_init.nss is not complete; code using
i_gotoarea or i_gotolandmark will most likely not accomplish its goals.
*/

/*
BarPatron_ent():
	called when a creature enters a trigger with a tag of "BarPatron"
*/

void
BarPatron_ent()
{
	int bFirstIn = 0;
	struct message mEnter;
	object oTrigger;

    _Start("BarPatron timing='ent' name='" + _GetName(OBJECT_SELF) + "'");

	if (!GetIsObjectValid(OBJECT_SELF))
	{
		// this *shouldn't* be able to happen
		_Assert("BarPatron_ent(): entering object is not valid!");
		return;
	}

	// get the trigger
	oTrigger = GetNearestObject(OBJECT_TYPE_TRIGGER, OBJECT_SELF);

	// add the patron to the end of the list: first come, first served
	bFirstIn = MePushFifoObjectRef(oTrigger, "BarPatron", OBJECT_SELF);

	mEnter.sChannelName = "BarPatron";

	if (bFirstIn)
	{
		// broadcast a message: there is at least 1 patron to be served
		mEnter.sMessageName = "BarPatron/FirstIn";
		mEnter.oData = OBJECT_SELF;
		MeBroadcastMessage(mEnter, mEnter.sChannelName);
	}

	// broadcast a message: a patron has entered the service area
	mEnter.sMessageName = "BarPatron/Enter";
	mEnter.oData = OBJECT_SELF;
	MeBroadcastMessage(mEnter, mEnter.sChannelName);

    _End();
}

/*
BarPatron_ext():
	called when a creature exits a trigger with a tag of "BarPatron"
*/

void
BarPatron_ext()
{
	int bLastOut = 0;
	struct message mExit;
	object oTrigger;

    _Start("BarPatron timing='ext' name='" + _GetName(OBJECT_SELF) + "'");

	if (!GetIsObjectValid(OBJECT_SELF))
	{
		// this *shouldn't* be able to happen
		_Assert("BarPatron_ext(): exiting object is not valid!");
		return;
	}

	// get the trigger
	oTrigger = GetNearestObject(OBJECT_TYPE_TRIGGER, OBJECT_SELF);

	// delete the patron from the list
	bLastOut = MeDeleteFifoObjectRef(oTrigger, "BarPatron", OBJECT_SELF);

	mExit.sChannelName = "BarPatron";

	// broadcast a message: a patron has exited the service area
	mExit.sMessageName = "BarPatron/Exit";
	mExit.oData = OBJECT_SELF;
	MeBroadcastMessage(mExit, mExit.sChannelName);

	if (bLastOut)
	{
		// broadcast a message: there are no more patrons to be served
		mExit.sMessageName = "BarPatron/LastOut";
		mExit.oData = OBJECT_SELF;
		MeBroadcastMessage(mExit, mExit.sChannelName);
	}

	_End();
}

void e_barpatron_ini()
{
	MeSubscribeMessage(MEME_SELF, "BarPatron/FirstIn", "BarPatron");
	MeSubscribeMessage(MEME_SELF, "BarPatron/Enter", "BarPatron");
	MeSubscribeMessage(MEME_SELF, "BarPatron/Exit", "BarPatron");
	MeSubscribeMessage(MEME_SELF, "BarPatron/LastOut", "BarPatron");
}

void e_barpatron_go()
{
	_Start("Event timing = 'go'");

	struct message mSched = MeGetLastMessage();
	string sMsg = mSched.sMessageName;

	_PrintString("e_barpatron_go(): Message = '" + sMsg + "'");

	if (GetLocalInt(NPC_SELF, "Bartender:AtWork"))
	{
		// do something about it
		_PrintString("e_barpatron_go(): at work, acting on message");
	}
	else
	{
		_PrintString("e_barpatron_go(): not at work, ignoring message");
	}
	_End();
}

// helper function to convert a TimeOfDay (iHHMM) to seconds past Midnight

int cvtHHMMToSeconds(int iHHMM)
{
	float fHour = HoursToSeconds(1);
	int iResult = FloatToInt(HoursToSeconds(iHHMM / 100));

	iResult += FloatToInt((IntToFloat(iHHMM % 100) * 60.0) / fHour);
	return(iResult);
}

// helper function to create moments that invoke functions

void MeCreateTODMoment(string sFunc, string sName, int iDefault)
{
	int iTime = GetLocalInt(NPC_SELF, "MT: " + sName);
	int i3hours = cvtHHMMToSeconds(300);
	string sBase = "!BROKEN!";
	int iWhich;

	// if variable is 0 or unspecified, use a class-provided default time
	if (iTime == 0)
		iTime = iDefault;

	// now convert HHMM to HH hours and MM minutes past Midnight in seconds
	iTime = cvtHHMMToSeconds(iTime);
	// stash this time and Moment name on the event
	MeAddIntRef(OBJECT_SELF, iTime, "Times");
	MeAddStringRef(OBJECT_SELF, sName, "Moments");
	_PrintString("Moment '" + sName + "' occurs at " + IntToString(iTime) + " calling '" + sFunc + "'.");

	// determine which predefined Moment to base this Moment on
	iWhich = iTime / i3hours;
	switch (iWhich)
	{
	case 0:	sBase = "Midnight"; break;
	case 1:	sBase = "Moondark";	break;
	case 2:	sBase = "Dawn"; break;
	case 3:	sBase = "Morning"; break;
	case 4:	sBase = "Noon"; break;
	case 5:	sBase = "Afternoon"; break;
	case 6:	sBase = "Sunset"; break;
	case 7:	sBase = "Evening"; break;
	}
	// adjust to the offset from the chosen predefined Moment
	iTime -= iWhich * i3hours;

	// and schedule the moment to repeat daily
	// FIXME: possibly both of these FALSE values must change once
	//	i_sequence is fixed.
	MeScheduleMoment(sName, iTime, sBase, FALSE);
	MeScheduleFunction(OBJECT_SELF, sFunc, OBJECT_INVALID, 0, sName, FALSE);
}

void c_bartender_ini()
{
	_Start("Initialize class = '" + MEME_CALLED + "'", DEBUG_COREAI);

	// setup class-wide response tables

	_End();
}

void c_bartender_go()
{
	int iNow;
	int i1day = cvtHHMMToSeconds(2400);	// 24 hours worth of minutes
	object oEvent;
	string sMoment;

	_Start("Instantiate class = '" + MEME_CALLED + "'", DEBUG_COREAI);

	// setup per-instance response tables

	// setup schedule; this is per-instance because the times are
	//	initialized from variables on the creature.

	MeCreateTODMoment("f_breakfast_start",	"Breakfast STime",	 600);
	MeCreateTODMoment("f_breakfast_end",	"Breakfast ETime",	 659);
	MeCreateTODMoment("f_work_start",		"Work STime",		 700);
	MeCreateTODMoment("f_lunch_start",		"Lunch STime",		1200);
	MeCreateTODMoment("f_lunch_end",		"Lunch ETime",		1259);
	MeCreateTODMoment("f_work_end",			"Work ETime",		1800);
	MeCreateTODMoment("f_dinner_start",		"Dinner STime",		1801);
	MeCreateTODMoment("f_dinner_end",		"Dinner ETime",		1900);
	MeCreateTODMoment("f_sleep_start",		"Sleep STime",		2200);
	MeCreateTODMoment("f_sleep_end",		"Sleep ETime",		 559);

	// with schedule in place, see which state we're supposedly currently in

	// get current time in seconds
	iNow = cvtHHMMToSeconds((GetTimeHour() * 100) + GetTimeMinute());
	_PrintString("iNow: " + IntToString(iNow));

	int iBestDiff = 999999;
	int iBestIndx = -1;
	int i;

	// loop over Times/Moments stored on OBJECT_SELF
	for (i = MeGetStringCount(OBJECT_SELF, "Moments") - 1; i >= 0; --i)
	{
		int iTime = MeGetIntByIndex(OBJECT_SELF, i, "Times");
		int iDiff = iNow - iTime;

		// iDiff must represent how many minutes ago the Moment
		//	under consideration was, so add a day's worth of
		//	seconds if it's negative.
		if (iDiff < 0)
			iDiff += i1day;

		// keep track of the best (nearest) past Moment
		if (iDiff < iBestDiff)
		{
			iBestDiff = iDiff;
			iBestIndx = i;
		}
	}

	// FIXME: perhaps it is better to build the scheduled meme sequences
	//	here than in the individual functions

	// FIXME: we really want to just call the function here
	sMoment = MeGetStringByIndex(OBJECT_SELF, iBestIndx, "Moments");
	_PrintString("Activating Moment '" + sMoment + "'");
	MeActivateMoment(sMoment);

	// for now, subscribe to BarPatron messages
	oEvent = MeCreateEvent("e_barpatron");

	_End();
}

// helper function to add memes to a sequence to move the NPC to a destination.
//	sWhere is the prefix of the name of local strings denoting the target
//	area and waypoint.  " Area" and " Room" are the respective suffixes, so
//	if sWhere is "Lunch", then the area can be obtained by
//	MeGetConfString(OBJECT_SELF, "Lunch Area").

void AddToSeq_goto(object oSeq, string sWhere)
{
	object oMeme;
	string sDBarea = MeGetConfString(OBJECT_SELF, sWhere + " Area");
	string sDBroom = MeGetConfString(OBJECT_SELF, sWhere + " Room");

	_Start("Function f='AddToSeq_goto' sWhere='" + sWhere + "'");

	/*
	ok, this is troublesome.  I would much prefer to use i_gotoarea and
	i_gotolandmark, but they are not yet complete enough to use.  so, the
	code to use them remains here (commented out), ready and waiting.
	meanwhile, we must rely on i_goto.  i_goto also has issues: it
	can get quite confused in the presence of placeables; it works too
	hard to get around them even when there is a helper waypoint handy;
	and it gives up too easily.
	*/

	// DEBUG: blather about what area we're headed for
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "I'm headed for Area '" + sDBarea + "'");

	// waiting for i_gotoarea/i_gotolandmark
	// add the new meme
	//oMeme = MeCreateSequenceMeme(oSeq, "i_gotoarea");
	//SetLocalObject(oMeme, "Area", GetObjectByTag(sDBarea));

	// DEBUG: blather about what area we're headed for
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "I'm headed for Waypoint '" + sDBroom + "'");

	// waiting for i_gotoarea/i_gotolandmark
	// add the new meme
	//oMeme = MeCreateSequenceMeme(oSeq, "i_gotolandmark");
	//SetLocalObject(oMeme, "Destination", GetWaypointByTag(sDBroom));

	oMeme = MeCreateSequenceMeme(oSeq, "i_goto");
	SetLocalObject(oMeme, "Object", GetWaypointByTag(sDBroom));
	SetLocalInt(oMeme, "Run", TRUE);
	SetLocalInt(oMeme, "Chatty", TRUE);
	SetLocalInt(oMeme, "UsePolling", TRUE);
	SetLocalInt(oMeme, "MaxRetries", 20);
	SetLocalFloat(oMeme, "Timeout", 60.0);
	SetLocalFloat(oMeme, "MinDistance", 0.0);
	// max distance in a 32x32 area
	SetLocalFloat(oMeme, "MaxDistance", 640.0);

	_End();
}

// helper function to add memes to a sequence to move the NPC to a destination,
//	then sit in a nearby seat (or complain if none is available).
//	the movement memes are added using AddToSeq_goto(), and we use the
//	suffix " Seat" to obtain the tag of acceptable seats to sit in.

void AddToSeq_goto_sit(object oSeq, string sWhere)
{
	object oMeme;
	string sDBseat;

	_Start("Function f='AddToSeq_goto_sit' sWhere='" + sWhere + "'");

	AddToSeq_goto(oSeq, sWhere);

	sDBseat = MeGetConfString(OBJECT_SELF, sWhere + " Seat");
	_PrintString("sSeat = '" + sDBseat + "'");

	// DEBUG: blather about what seat we want
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "I'm sitting in '" + sDBseat + "'");

	// grab a seat, if we can
	oMeme = MeCreateSequenceMeme(oSeq, "i_sit");
	SetLocalString(oMeme, "Seat", sDBseat);
	SetLocalString(oMeme, "Complain", "I can't find a seat!");

	_End();
}

// here's what we do at breakfast time: say that it is breakfast time,
//	go to our breakfast spot, grab a seat, (eventually) order some food,
//	and (eventually) eat it.

object f_breakfast_start(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_breakfast_start oArg = '" + _GetName(oArg) + "'");

	// build memes to do the breakfast thing; until we're
	//	finished eating, we stay seated (unless interrupted,
	//	by combat, for instance)

	// keep track of local state
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_breakfast_start", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Time for breakfast.  Is it too early for beer?");

	// let's get to the right spot, and sit down
	AddToSeq_goto_sit(oSeq, "MT: Breakfast");

	// for now, let's just say we're eating
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Mmmm!  What a tasty breakfast!");

	// set it off
	MeStartSequence(oSeq);

	_End();

	return OBJECT_SELF;
}

// here's what we do when breakfast is over: say that breakfast is done,
//	(eventually) get out of the seat, and enter idle mode.

object f_breakfast_end(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_breakfast_end oArg = '" + _GetName(oArg) + "'");

	// build memes to get up from the table, then go idle

	// keep track of local state
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_breakfast_end", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Man, that was a great breakfast!");

	// FIXME: need an unsit meme

	MeStartSequence(oSeq);

	_End();

	return OBJECT_SELF;
}

// here's what we do at work time: say it's time to go to work, go to where
//	we work, and say that we're working.

object f_work_start(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_work_start oArg = '" + _GetName(oArg) + "'");

	// build memes to go behind the bar, then do the bartender
	//	service thing

	// keep track of local state
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_work_start", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Rats!  Time to go to work!");

	// let's get to the right place
	AddToSeq_goto(oSeq, "MT: Work");

	// let 'em know the bar is open
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Ok, bar's open!  What'll ya have?");

	// start up the sequence
	MeStartSequence(oSeq);

	// FIXME: we really shouldn't do this until the bartender
	//	actually reaches his work spot
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 1);

	_End();

	return OBJECT_SELF;
}

// here's what we do at lunch time: say that it's lunch time, go to our
//	lunch spot, find a seat, (eventually) order food, and (eventually)
//	start eating.

object f_lunch_start(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_lunch_start oArg = '" + _GetName(oArg) + "'");

	// build memes to do the lunch thing; as for breakfast,
	//	we stay seated

	// pay no attention to patrons
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_lunch_start", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Time for lunch.  I hope it's yummy....");

	// let's get to the right place and sit down
	AddToSeq_goto_sit(oSeq, "MT: Lunch");

	// for now, let's just say we're eating
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Ewww!  Not orc meat again!");

	// set it off
	MeStartSequence(oSeq);

	_End();

	return OBJECT_SELF;
}

// here's what we do when lunch is over: say that it's time to go back to
//	work, (eventually) get up from our seat, move back to our work
//	position, and say we're back to work.

object f_lunch_end(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_lunch_end oArg = '" + _GetName(oArg) + "'");

	// build memes to get up from the table, go behind the bar,
	//	and do the bartender service thing

	// keep track of local state
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_lunch_end", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Man, that was a terrible lunch!");

	// FIXME: need an unsit meme

	// let's get to the right place
	AddToSeq_goto(oSeq, "MT: Work");

	// say we're back at work
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Ok, I'm back at work.  Who needs a brewski?");

	// start it up
	MeStartSequence(oSeq);

	// FIXME: we really shouldn't do this until the bartender
	//	actually reaches his work spot
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 1);

	_End();

	return OBJECT_SELF;
}

// here's what we do when it's quittin' time: collect shift pay, say that
//	it's quittin' time, go to an off work location, and say we're off work.

object f_work_end(object oArg = OBJECT_INVALID)
{
	int iPay = -1;
	object oSeq;
	object oMeme;

	_Start("f_work_end oArg = '" + _GetName(oArg) + "'");

	// build memes to go away from behind the bar, then go idle

	// we don't need no stinkin' patrons!
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	// let's collect our shift pay
	iPay = GetLocalInt(NPC_SELF, "MT: Shift Pay");
	if (iPay == 0)
		iPay = 30;
	GiveGoldToCreature(NPC_SELF, iPay);

	oSeq = MeCreateSequence("f_work_end", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Yippee!  It's quittin' time!");

	// let's get to the right place
	AddToSeq_goto(oSeq, "MT: OffWork");

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Another day, another gold piece: it's good to get paid!");

	// start it up
	MeStartSequence(oSeq);

	_End();

	return OBJECT_SELF;
}

object f_dinner_start(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_dinner_start oArg = '" + _GetName(oArg) + "'");

	// build memes to do the dinner thing; as for breakfast,
	//	we stay seated

	// keep track of local state
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_dinner_start", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Time for dinner.  I'm just famished!");

	// let's get to the right place and find a seat
	AddToSeq_goto_sit(oSeq, "MT: Dinner");

	// for now, let's just say we're eating
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Excellent!  Dragon steak for dinner!");

	// set it off
	MeStartSequence(oSeq);

	_End();

	return OBJECT_SELF;
}

object f_dinner_end(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_dinner_end oArg = '" + _GetName(oArg) + "'");

	// build memes to get up from the table, then go idle

	// keep track of local state
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_dinner_end", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Chef did an awesome job with that dragon steak!");

	// FIXME: need an unsit meme

	// start it up
	MeStartSequence(oSeq);

	_End();

	return OBJECT_SELF;
}

object f_sleep_start(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_sleep_start oArg = '" + _GetName(oArg) + "'");

	// build memes to go to my room, unequip weapons, shield, and clothing,
	//	and get into bed; we remain sleeping until it's time to get up

	// keep track of local state
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_sleep_start", PRIO_HIGH);

	// let's get to the right place
	AddToSeq_goto(oSeq, "MT: Sleep");

	// and get these clothes off
	oMeme = MeCreateSequenceMeme(oSeq, "i_undress");

	// show that I'm sleeping
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "ZZZZzzzz....");

	// and go to sleep already
	oMeme = MeCreateSequenceMeme(oSeq, "i_sleep");
	SetLocalString(oMeme, "Bed", MeGetConfString(NPC_SELF, "MT: Sleep Bed"));
	SetLocalString(oMeme, "Complain", "I can't find my bed!");
	SetLocalFloat(oMeme, "Duration", 8.0 * 60.0);

	// start it up
	MeStartSequence(oSeq);

	_End();

	return OBJECT_SELF;
}

object f_sleep_end(object oArg = OBJECT_INVALID)
{
	object oSeq;
	object oMeme;

	_Start("f_sleep_end oArg = '" + _GetName(oArg) + "'");

	// build memes to get out of bed, equip clothing, then go idle

	// keep track of local state
	SetLocalInt(NPC_SELF, "Bartender:AtWork", 0);

	oSeq = MeCreateSequence("f_sleep_end", PRIO_HIGH);

	// let's say what we're doing
	oMeme = MeCreateSequenceMeme(oSeq, "i_say");
	MeAddStringRef(oMeme, "Tarnation!  Time to get up already?!?");

	// FIXME: need a meme to unsleep

	// equip those things we unequipped at bed time
	oMeme = MeCreateSequenceMeme(oSeq, "i_dress");

	// start it up
	MeStartSequence(oSeq);

	_End();

	return OBJECT_SELF;
}

// Main: Register Functions & Dispatch -----------------------------------------

void main()
{
	_Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

	// Register classes and functions
	if (MEME_DECLARE_LIBRARY)
	{
		// Class Registrations
		MeRegisterClass("bartender");

		// Trigger Event Declarations
		MeLibraryImplements("BarPatron",	"_ent", 0x0000+0x01);
		MeLibraryImplements("BarPatron",	"_ext", 0x0000+0x02);

		// Generator Declarations
		MeLibraryImplements("c_bartender",	"_ini",	0x0100+0x01);
		MeLibraryImplements("c_bartender",	"_go",	0x0100+0x02);

		// Event Declarations
		MeLibraryImplements("e_barpatron",	"_ini",	0x0300+0x01);
		MeLibraryImplements("e_barpatron",	"_go",	0x0300+0x02);

		// Function Declarations
		MeLibraryFunction("f_breakfast_start",		0xff00+0xf6);
		MeLibraryFunction("f_breakfast_end",		0xff00+0xf7);
		MeLibraryFunction("f_work_start",			0xff00+0xf8);
		MeLibraryFunction("f_lunch_start",			0xff00+0xf9);
		MeLibraryFunction("f_lunch_end",			0xff00+0xfa);
		MeLibraryFunction("f_work_end",				0xff00+0xfb);
		MeLibraryFunction("f_dinner_start",			0xff00+0xfc);
		MeLibraryFunction("f_dinner_end",			0xff00+0xfd);
		MeLibraryFunction("f_sleep_start",			0xff00+0xfe);
		MeLibraryFunction("f_sleep_end",			0xff00+0xff);

		_End("Library");
		return;
	}

	// Dispatch to the function
	switch (MEME_ENTRYPOINT & 0xff00)
	{
	case 0x0000:
		switch (MEME_ENTRYPOINT & 0x00ff)
		{
		case 0x01:	BarPatron_ent(); break;
		case 0x02:	BarPatron_ext(); break;
		}
		break;
	case 0x0100:
		switch (MEME_ENTRYPOINT & 0x00ff)
		{
		case 0x01:	c_bartender_ini(); break;
		case 0x02:	c_bartender_go(); break;
		}
		break;
	case 0x0300:
		switch (MEME_ENTRYPOINT & 0x00ff)
		{
		case 0x01:	e_barpatron_ini(); break;
		case 0x02:	e_barpatron_go(); break;
		}
		break;
	case 0xff00:
		switch (MEME_ENTRYPOINT & 0x00ff)
		{
		case 0xf6:	MeSetResult(f_breakfast_start(MeGetArgument())); break;
		case 0xf7:	MeSetResult(f_breakfast_end(MeGetArgument())); break;
		case 0xf8:	MeSetResult(f_work_start(MeGetArgument())); break;
		case 0xf9:	MeSetResult(f_lunch_start(MeGetArgument())); break;
		case 0xfa:	MeSetResult(f_lunch_end(MeGetArgument())); break;
		case 0xfb:	MeSetResult(f_work_end(MeGetArgument())); break;
		case 0xfc:	MeSetResult(f_dinner_start(MeGetArgument())); break;
		case 0xfd:	MeSetResult(f_dinner_end(MeGetArgument())); break;
		case 0xfe:	MeSetResult(f_sleep_start(MeGetArgument())); break;
		case 0xff:	MeSetResult(f_sleep_end(MeGetArgument())); break;
		}
		break;
	}

	_End();
}
