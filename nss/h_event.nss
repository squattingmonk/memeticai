#include "h_debug"
#include "h_class"
#include "h_util"
#include "h_constants"
#include "h_time"

// --- Event Functions ---------------------------------------------------------
//
// These functions allow you to create Memetic Event objects, a set of scripts
// (or functions in a library) that are executed when a message is sent to an
// NPC or a channel that the event object is subscribed to. This allows for
//

// MeCreateEvent
// File: h_event
//
// This will create an event object, used to responds to a message.
// Messages have data that can be sent to one or many objects via a channel.
// You can define e_myEvent_ini, e_myEvent_go scripts or define them
// in a library. By calling MeSubscribeMessage(), you can cause this code
// to execute when a particular message is sent to this object, or on a channel.
// Some events automatically subscribe to a channel in the _ini script.
// Many memetic objects, scripts, and things like Point of Interest emitters
// send event messages on standard channels. Refer to the documentation for
// each event and library to learn more.
object MeCreateEvent(string sEventName, object oTarget = OBJECT_SELF);

// MeDestroyEvent
// File: h_event
//
// This destroys and event object, causing it to be unsubscribed from any
// channels and clean up any allocated memory.
void MeDestroyEvent(object oEvent, object oTarget = OBJECT_SELF);

// MeActivateEvent
// File: h_event
//
// This will cause the event object to execute, running <event name>_go
void MeActivateEvent(object oEvent);

// MeGetEvent
// File: h_event
//
// This gets an event with the given name or by count. You can provide as many
// or as few of these parameters as you like to query the internal memetic
// store. If no name is provided every event is found.
object MeGetEvent(string sName = "", int iIndex = 0, object oTarget = OBJECT_SELF);

// MeSubscribeMessage
// File: h_event
//
// This subcribes the event to a channel or particular message. When the channel
// name is empty, the event will be senstive to messages on the private channel.
// If the message name is empty, the event will be activated whenever any message
// is sent to the object that holds this event. If a message name and channel name
// are provided then the even will be activated when the particular message on the
// given channel is received. It is safe to call this function more than once on
// the event object.
void MeSubscribeMessage(object oEvent, string sMessageName = "", string sChannelName  = "");

// MeUnsubscribeMessage
// File: h_event
//
// This stops an event from activating when a message on a channel is received.
// This must correspond to a message/channel combination that the even subscribed to.
// For example, if the event subscribed to all messages on a channel, you cannot
// unsubscribe to one particular message, only the whole channel. But if you
// subscribted to message "RedTeamStart" and "BlueTeamStart" then you can unsubscribe
// to "RedTeamStart" and still respond to the "BlueTeamStart" message.
void MeUnsubscribeMessage(object oEvent, string sMessageName = "", string sChannelName = "");

// --- Message Functions -------------------------------------------------------

///////////////////////////////////////
// REFER TO H_CLASS FOR MESSAGE APIs. //
///////////////////////////////////////

//
// Messages are basic datastructures used to send information to one or many
// objects. They are received by Memetic Event objects and can be given to a
// scheduler for persistant delayed or recurring transmission.
//

// MeSendMessage
// File: h_event
//
// This allows you to send a message to an NPC. It assumes the NPC has
// an event object created by MeCreateEvent(), which may be subscribed
// to the message by MeSubscribeMessage(). When the message is sent, the
// event object's code is executed. (i.e. e_myeventname_go script.)
//
// sMessage: This is a struct that contains the message information.
//           When the message is sent, the information will be added to the struct
//           so that the receiver will know who sent the message.
// sChannel: This simulates receiving the message on a channel. This will NOT
//           send the message to everyone else on the channel -- use MeBroadcastMessage().
// oTarget:  This is the object that should receive the event. If this object
//           is invalid, the message will be sent to yourself.
//           When the message is received, each event object that has subscribed
//           to the message (or to all messages) will be activated.
// oSender:  This is sets who sent the message.
void MeSendMessage(struct message sMessage, string sChannel = "", object oTarget = OBJECT_SELF, object oSender = OBJECT_SELF, int iOverride = FALSE);


// MeBroadcastMessage
// File: h_event
//
// This automatically call MeSendMessage() for each NPC that has an event
// that has subscribed to the given channel. This allows you to efficiently
// notify a group of NPCs about something. More importantly, it allows you to
// send messages out, without knowing about specifically knowing about the NPCs.
//
// For example, you could send "CityMood" message to the "Town of Morville" channel.
// All NPCs could subscribe to this channel when they enter the town, and
// adjust their behavior according to the "CityMood". When they leave and go to
// the next town they can
//
// sMessage: This is a struct that contains the message information.
//           When the message is sent, the information will be added to the struct
//           so that the receiver will know who sent the message.
//           The channel is set in the message struct to allow the event to know
//           it came from a broadcast channel.
// sChannel: This is the name of your broadcast channel. It will correspond to
//           the name of the channel passed as a parameter to MeSubscribeMessage().
//           If you pass "", then you will send the message to yourself.
void MeBroadcastMessage(struct message sMessage, string sChannel, int iOverride = FALSE);

// MeGetLastMessage()
// File: h_event
//
// This is used by an event script to get the message structure
struct message MeGetLastMessage();

// MeCreateMessage()
// File: h_event
//
// This is a convient way to make the message struct. It is for people who are
// unfamiliar with using structs and defining them. Keep in mind it is more efficient
// to use the NWScript notation for making a struct. This will automatically fill
// the location field with the location of OBJECT_SELF.
struct message MeCreateMessage(string sName, string sData="", int iData=0, float fData=0.0, object oData=OBJECT_INVALID);

// --- Scheduler Functions -----------------------------------------------------
//
// MeScheduleMoment
// File: h_event
//
// This defines an abstract moment in time. When it occurs, anything scheduled to
// occur based on that moment is scheduled. This means that you can adjust this
// moment at any time up until it happens.
//
// The scheduler is an efficent system for running scripts, or sending messages
// at certain time or at regular intervals. The time can be based on scaled game-time,
// real-time, or an offset of an abstract moment in time, like "Dawn" or "Noon".
// These moments can be defined as an offset from an earlier moments, or the
// current time. This unit of time is in seconds -- not floats.
//
// A moment with a 0 time is automatically activated and cannot be marked as repeat
// if there is no earlier moment.
//
// sMomentName:    This is an arbitrary name of a moment in time, like "dawn" or
//                 "lunchtime" or "end of chapter 2".
// iTime:          This is the amount of time before the moment occurs. Use the function
//                 MeTime() to define this value.
// sEarlierMoment: This is the name of another moment that will trigger this
//                 moment. For example, "dawn" may be 6 hours after "midnight".
// bRepeat:        This flag means that the moment should be rescheduled to occur
//                 with the same time delay, triggered off the optional earlier moment.
//                 Thus, you can easily set up daily events triggers X hours after "dawn".
int MeScheduleMoment(string sMomentName, int iTime=0, string sEarlierMoment="", int bRepeat=FALSE);

// MeActivateMoment
// File: h_event
//
// This causes a moment to immediately occur, which may cause other scheduled things to happen.
// sMomentName:    This is an arbitrary string like "dawn" or "team 1 wins". Nothing will happen
//                 unless something is scheduled using this name.
void MeActivateMoment(string sMomentName);

// MeAdjustSchedule
// File: h_event
//
// This allows you to change when a previously scheduled moment, message, or
// function will occur. If you adjust a moment that has already occurred,
// all the items based on that moment will not be rescheduled. If this moment
// has not occurred all future events based on this moment will be adjusted
// accordingly. If you set the delay to 0, it will be suspended and will wait
// to be adjusted, later.
//
// For example, let's say that message "flee" is sent when moment "invaders arrive" happens.
// Furthermore, "invaders arrive" happens 10 minutes after "dawn". When the moment, "dawn" occurs,
// the moment "invaders arrive" is scheduled to occur. You can change the "invaders arrive"
// moment earlier to 3 minutes from dawn. But if 5 minutes have passed, the "invaders arrive" moment
// will be missed and the "flee" message will not be sent.
void MeAdjustSchedule(int iScheduledThing, int iTime, int bRepeat=TRUE);

// MeScheduleMessage
// File: h_event
//
// This schedules a message to be sent at a particular time.
// You can specifiy an offset from an abstract moment in time
// or an offset from the current time. By default this uses non-linear time
// computations to figure out how long you really want to wait. You can have the
// message repeat if you want it to be resent on a regular basis.
int MeScheduleMessage(struct message sData, object oTarget, string sChannel = "", int iTime=0, string sMoment="", int bRepeat=FALSE);

// MeScheduleFunction
// File: h_event
//
// This schedules a script function defined in a library to be executed at a
// particular time. Functions may be executed by an object and can be passed an
// argument. At this time the return result from the function is ignored.
// You can specifiy an offset from an abstract moment in time
// or an offset from the current time. By default this uses non-linear time
// computations to figure out how long you really want to wait. You can have the
// message repeat if you want it to be resent on a regular basis.
int MeScheduleFunction(object oTarget, string sFunction, object oArgument=OBJECT_INVALID, int iTime=0, string sMoment="", int bRepeat=FALSE);

// MeScheduleScript
// File: h_event
//
// This schedules a script to be executed at a particular time by an object.
// You can specifiy an offset from an abstract moment in time
// or an offset from the current time. By default this uses non-linear time
// computations to figure out how long you really want to wait. You can have the
// message repeat if you want it to be resent on a regular basis.
int MeScheduleScript(object oTarget, string sScript, int iTime=0, string sMoment="", int bRepeat=FALSE);

// MeUnSchedule
// File: h_event
//
// This stops the event from being scheduled, all the data associated to it is
// cleared. If this thing is a moment, any currently scheduled (in-the-future)
// moments will not activate.
void MeUnschedule(int iScheduledThing);

// MeClearScheduledMoments
// File: h_event
//
// This stops any currently scheduled moments with this ID. For example if you
// schedule a moment, "BlueMonsterSpawn" in 10 minutes and call this function,
// the "BlueMonsterSpawn" moment and all of its related activities will fail
// to occur. Bear in mind that if you have ten "RandomForestSpawn" moments
// scheduled, NONE of these other moments will be invalidate. Only the one
// corresponding to this ID will be invalid.
void MeClearScheduledMoments(int iMomentID);


//----- Implementation ---------------------------------------------------------

object MeCreateEvent(string sEventName, object oTarget = OBJECT_SELF)
{
    _Start("MeCreateEvent", DEBUG_TOOLKIT);

    object oResult, oEventBag, oSelf;

    // We create several invisible objects to hold local data for the event.
    // This allows us to efficiently clear up memory when the event is terminated.
    oSelf = GetLocalObject(oTarget, "MEME_NPCSelf");
    if (oSelf == OBJECT_INVALID) oSelf = MeInit(oTarget);

    // The event bag holds these event objects.
    oEventBag = GetLocalObject(oSelf, "MEME_EventBag");
    if (!GetIsObjectValid(oEventBag)) PrintString("<Assert>Failed to create event bag. This is a critical bug in MeInit().</Assert>");

    // Add the object to the bag
    oResult = _MeMakeObject(oEventBag, sEventName, TYPE_EVENT);

    // Inherit the class of the context that's creating this generator.
    SetLocalString(oResult, "MEME_ActiveClass", GetLocalString(MEME_SELF, "MEME_ActiveClass"));

    MeExecuteScript(sEventName,"_ini", OBJECT_SELF, oResult);

    _End("MeCreateEvent");
    return oResult;
}

// The Event object has the string list, "MEME_Subscribe" which contains the
// names of all the channel and message lists on NPC_SELF that have a reference
// to this event. When the event is destroyed, the event is removed from each
// of these lists.
void MeDestroyEvent(object oEvent, object oTarget = OBJECT_SELF)
{
    _Start("MeDestroyEvent", DEBUG_TOOLKIT);

    string sSubscribeName;
    string sEventName = GetLocalString(oEvent, "Name");
    int i;
    for (i = MeGetObjectCount(oEvent, "MEME_Subscribe")-1; i >= 0; i--)
    {
        sSubscribeName = MeGetStringByIndex(oEvent, i, "MEME_Subscribe");
        MeRemoveObjectRef(NPC_SELF, oEvent, sSubscribeName);
    }

    MeExecuteScript(sEventName,"_end", OBJECT_SELF, oEvent);
    DestroyObject(oEvent);

    _End("MeDestroyEvent");
}

void MeActivateEvent(object oEvent)
{
    _Start("MeActivateEvent oEvent='"+_GetName(oEvent)+"'", DEBUG_UTILITY);

    if (GetIsObjectValid(oEvent))
    {
        MeExecuteScript(GetLocalString(oEvent, "Name"), "_go", OBJECT_SELF, oEvent);
    }

    _End();
}

// You can pass NPC_SELF of OBJECT_SELF as oTarget -- either should work.
object MeGetEvent(string sName = "", int iIndex = 0, object oTarget = OBJECT_SELF)
{
    _Start("MeGetEvent", DEBUG_UTILITY);

    object oResult;
    object oEventBag = GetLocalObject(oTarget, "MEME_EventBag");

    if (!GetIsObjectValid(oEventBag))
    {
        // All memetic objects are hung off of a "self" object.
        // If there isn't one, this isn't a memetic object.
        oTarget = GetLocalObject(oTarget, "MEME_NPCSelf");
        if (oTarget == OBJECT_INVALID)
        {
            _End("MeGetEvent");
            return OBJECT_INVALID;
        }
        oEventBag = GetLocalObject(oTarget, "MEME_EventBag");
    }

    oResult = MeGetObjectByName(oEventBag, sName, "", iIndex);

    _End("MeGetEvent", DEBUG_UTILITY);
    return oResult;
}

/*
    This assumes the caller of the function owns the event object.
    This function may adds a reference to this object on the module if it
    specifies a channel name. Then a messagename+channelname is stored in
    the subscription list. Then a messagename+channelname int is set to 1.
    When a message arrives if the messagename+channelname is set the event
    is activated. When a module receives a channel broadcast, it processess
    two lists: the channel list (objects sensitive to all messages) and the
    channel+message list (objects senstive to this message on this channel.)
    Each NPC event on those lists will get the message delivered to it.
*/
void MeSubscribeMessage(object oEvent, string sMessageName = "", string sChannelName  = "")
{
    _Start("MeSubscribeMessage sMessageName='"+sMessageName+"' sChannelName='"+sChannelName+"'", DEBUG_TOOLKIT);

    string sID = "MEME_Events_M:"+sMessageName+"_C:"+sChannelName;
    // The NPC_SELF global represents the memetic NPC.
    MeAddObjectRef(NPC_SELF, oEvent, sID, TRUE);

    // We store every subscription pair on the event -- when the event is destroyed
    // we will use this list to remove the references from the NPC_SELF, when the
    // list count falls to 0 then we can unsubscribe from a module channel, if necessary.
    MeAddStringRef(oEvent, sID, "MEME_Subscribe");

    // If a channel name is provided, this event must be added to a subscription
    // list on the module. This way the module can find us.
    if (sChannelName != "")
    {
        // First time subscription sign up for the channel.
        if (MeGetObjectCount(NPC_SELF, sID) == 1)
        {
            MeAddObjectRef(GetModule(), NPC_SELF, sID);
        }
    }

    _End();
}

/*
    This assumes the caller of the function owns the event object.
    This does the inverse of MeSubscribeMessage(). It removes the message and
    channel int on the event object and from its list and removes any
    entries from the module's subscription lists.
*/
void MeUnsubscribeMessage(object oEvent, string sMessageName = "", string sChannelName = "")
{
    _Start("MeUnsubscribeMessage", DEBUG_TOOLKIT);

    string sID = "MEME_Events_M:"+sMessageName+"_C:"+sChannelName;
    MeRemoveObjectRef(NPC_SELF, oEvent, sID);

    // If there are no more events sensitive to this channel...remove myself from the channel
    if (sChannelName != "")
    {
        if (MeGetObjectCount(NPC_SELF, sID) == 0) MeRemoveObjectRef(GetModule(), NPC_SELF, sID);
    }

    _End();
}

// --- Message Implementation --------------------------------------------------

/*
    This actively sends a message to a particular object (NPC) that has an
    event handler. If the event is not sensitive to the message or channel
    specified in the message, then it is ignored. Otherwise, the message
    is set locally on the NPC and the event's _go script is executed.
*/
void MeSendMessage(struct message sMessage, string sChannel="", object oTarget = OBJECT_SELF, object oSender = OBJECT_SELF, int iOverride = FALSE)
{
    if (oTarget != OBJECT_SELF)
    {
        _Start("MeSendMessage to='"+_GetName(oTarget)+"' MessageName='"+sMessage.sMessageName+"'", DEBUG_TOOLKIT);
        AssignCommand(oTarget, MeSendMessage(sMessage, sChannel, oTarget, oSender));
        _End();
        return;
    }

    _Start("ReceivedMessage MessageName='"+sMessage.sMessageName+"'", DEBUG_TOOLKIT);

    object oSelf;

    // When we're at this point, there needs to be a valid NPC_SELF.
    // NPC_SELF is where event subscription information is stored. If there isn't
    // an NPC_SELF then this is oTarget is not a memetic thing and cannot recieve events.

    if (GetLocalInt(OBJECT_SELF, "MEME_Type") == TYPE_NPC_SELF)
    {
        NPC_SELF = OBJECT_SELF;
        oSelf    = MeGetNPCSelfOwner(NPC_SELF);
    }
    else
    {
        // Note: If you ever do an AssignCommand of a Memetic Function, NPC_SELF will likely be invalid.
        //       This means that you need to change that memetic function to reset its NPC_SELF, like this:
        oSelf    = OBJECT_SELF;
        NPC_SELF = GetLocalObject(oSelf, "MEME_NPCSelf");
    }
    
    if (NPC_SELF == OBJECT_INVALID)
    {
        _PrintString("NPC_SELF == OBJECT_INVALID");
        _End();
        return;
    }

    // When the system is paused, messages are ignored
    // unless passed the override flag.
    if (GetLocalInt(NPC_SELF, "MEME_Paused"))
    {
        _PrintString("MEME_Paused", DEBUG_COREAI);
        
        _PrintString("Message: " + sMessage.sMessageName, DEBUG_COREAI);
        
        if (iOverride == FALSE) 
       	{	
       		_End();
        	return;
       	}
       	else        
			_PrintString("Overriding, allowing message.", DEBUG_COREAI);	
    }

    string sID = "MEME_Events_M:"+sMessage.sMessageName+"_C:"+sChannel;
    int i;
    object oEvent;
    string sName;

    sMessage.oSender = oSender;
    sMessage.oTarget = oTarget;
    sMessage.sChannelName = sChannel;

    MeSetLocalMessage(oSelf, "LastSent", sMessage);

    // Beware that if you have too many events on one NPC subscribed to the same
    // event, this may TMI. As a result, you may need to DelayCommand(0.0) on this.
    // I have avoided this because you *MAY* lose your message if another message
    // is backed up against this message. I won't know without further testing.
    // Hopefully we can live with this for a while.
    _PrintString("Event count: "+IntToString(MeGetObjectCount(NPC_SELF, sID)), DEBUG_TOOLKIT);
    for (i = MeGetObjectCount(NPC_SELF, sID)-1; i >= 0; i--)
    {
        oEvent = MeGetObjectByIndex(NPC_SELF, i, sID);
        sName = GetLocalString(oEvent, "Name");

        _PrintString("Calling: "+sName+"_go");
        MeExecuteScript(sName, "_go", oSelf, oEvent);
    }

    _End();
}

/*
    This actively sends a message to a particular object (NPC) that has an
    event handler. If the event is not sensitive to the message or channel
    specified in the message, then it is ignored. Otherwise, the message
    is set locally on the NPC and the event's _go script is executed.
*/
void MeBroadcastMessage(struct message sMessage, string sChannel, int iOverride = FALSE)
{
    _Start("MeBroadcastMessage MessageName='"+sMessage.sMessageName+"'", DEBUG_TOOLKIT);

    if (sChannel == "")
    {
        MeSendMessage(sMessage);
    }
    else
    {
        string sID = "MEME_Events_M:"+sMessage.sMessageName+"_C:"+sChannel;
        int i;
        object oTarget;
        object oModule = GetModule();

        _PrintString("Broadcasting to "+IntToString(MeGetObjectCount(oModule, sID))+" targets", DEBUG_TOOLKIT);
        for (i = MeGetObjectCount(oModule, sID)-1; i >= 0; i--)
        {
            oTarget = MeGetObjectByIndex(oModule, i, sID);
            if (!GetIsObjectValid(oTarget))
            {
                MeRemoveObjectByIndex(oModule, i, sID);
            }
            else
            {
                _PrintString("Broadcasting to '"+_GetName(oTarget)+"'", DEBUG_TOOLKIT);
                object oObject = OBJECT_SELF;
                AssignCommand(oTarget, MeSendMessage(sMessage, sChannel, oTarget, oObject, iOverride));
            }
        }
    }

    _End();
}

struct message MeGetLastMessage()
{
    return MeGetLocalMessage(OBJECT_SELF, "LastSent");
}


struct message MeCreateMessage(string sName, string sData="", int iData=0, float fData=0.0, object oData=OBJECT_INVALID)
{
    location lData=GetLocation(OBJECT_SELF);
    struct message sMessage;
    sMessage.sData = sData;
    sMessage.iData = iData;
    sMessage.fData = fData;
    sMessage.lData = lData;
    sMessage.oData = oData;
    sMessage.sChannelName = "";
    sMessage.sMessageName = sName;
    sMessage.oSender = OBJECT_INVALID;
    sMessage.oTarget = OBJECT_INVALID;
    return sMessage;
}

// --- Scheduler Implementation Functions --------------------------------------

// Initial draft of how this works. Some implementation differences my exist.
// Note: this is not a bulletproof scheduler, but it's enough to be useful for
//       a persistant world.
//
// Every schedulable thing gets a number. A count, MESch_C, is incremented with
// each call the schedule functions. Things can either be scheduled in absolute
// terms or terms of a relative moment. Either way, an entry is made, registering
// an int for the schedulable thing. This thing is either scheduled to activate
// by calling DelayCommand or is added to a list of things to be scheduled, based
// on another moment. Finally, if the thing being defined is a moment, the number
// of the moment is registered with its name MESch_MO_<Name>.
//
// When a schedulable thing is registered, a variety of variables may be stored
// on the module based on its type, keyed off of its id.
//
// MESch_<N>_Repeat: A flag meaning that once this executes, reschedule it. This
//                   is ignored if Delay is 0.0.
// MESch_<N>_Type:   An int representing moment, message,
// MESch_<N>_Name:   This is either the name of the moment, the name of the script
//                   the name of the library function, or message to be called
// MESch_<N>_RelMo:  The relative moment.
// MESch_<N>_Delay:  Number of (float) seconds before this should be activated.
// MESch_<N>_Target: The OBJECT_SELF for functions, scripts, the sender of a message,
// MESch_<N>_Arg:    The argument to a library function.
// MeSch_<N>[]:      This is an object list of schedulable things that are relative to this moment.


void _MeCallFunction(string a, object b, object c)
{
    MeCallFunction(a, b, c);
}

void _MeActivateMoment(string sMomentName, int mID, string sID, int iGood)
{
    _Start("_MeActivateMoment sMomentName='"+sMomentName+"' mID='"+IntToString(mID)+"' sID='"+sID+"' iGood='"+IntToString(iGood)+"'", DEBUG_TOOLKIT);

    if (iGood == GetLocalInt(GetModule(), sID+"_Good"))
    {
        MeActivateMoment(sMomentName);
    }

    _End();
}

int MeScheduleMoment(string sMomentName, int iTime=0, string sEarlierMoment="", int bRepeat=FALSE)
{
    _Start("MeScheduleMoment sMomentName='"+sMomentName+"'", DEBUG_TOOLKIT);

    if (iTime == 0 && sEarlierMoment == "" && bRepeat == TRUE) bRepeat == FALSE;

    if (bRepeat == TRUE && sEarlierMoment == "") sEarlierMoment = sMomentName;

    object oModule = GetModule();
    // float fDelay = MeGameDuration(iTime);
    float fDelay = IntToFloat(iTime);
    _PrintString("fDelay: "+FloatToString(fDelay), DEBUG_TOOLKIT);

    int mID = GetLocalInt(oModule, "MESch_MO"+sMomentName);
    if (!mID)
    {
        mID = GetLocalInt(oModule, "MeSch_C")+1;
        SetLocalInt(oModule, "MeSch_C", mID);
        SetLocalInt(oModule, "MESch_MO"+sMomentName, mID);
    }
    string sID = "MeSch_"+IntToString(mID);
    _PrintString("sId: "+sID, DEBUG_TOOLKIT);

    SetLocalInt(oModule,    sID+"_Type", 1); // Type 1 is moment
    SetLocalInt(oModule,    sID+"_Good", 1);
    SetLocalInt(oModule,    sID+"_Repeat", bRepeat);
    SetLocalString(oModule, sID+"_Name", sMomentName);
    SetLocalFloat(oModule,  sID+"_Delay", fDelay);
    SetLocalString(oModule, sID+"_Rel", sEarlierMoment);

    // Add this moment to the list of triggered relative things.
    int pID = GetLocalInt(oModule, "MESch_MO"+sEarlierMoment);
    if (pID) MeAddIntRef(oModule, mID, "MeSch_"+IntToString(pID));

    if ((sEarlierMoment == "") || (sEarlierMoment == sMomentName)) {
        _PrintString("DelayCommand("+FloatToString(fDelay)+", _MeActivateMoment("+sMomentName+", "+IntToString(mID)+", "+sID+", "+IntToString(GetLocalInt(oModule, sID+"_Good"))+")", DEBUG_TOOLKIT);
        DelayCommand(fDelay, _MeActivateMoment(sMomentName, mID, sID, GetLocalInt(oModule, sID+"_Good")));
    }

    _End();
    return mID;
}

void MeActivateMoment(string sMomentName)
{
    _Start("MeActivateMoment sMomentName='"+sMomentName+"'", DEBUG_UTILITY);

    object oModule = GetModule();

    // If this moment is valid it'll have a registered id.
    int mID = GetLocalInt(oModule, "MESch_MO"+sMomentName);
    // So its private prefix looks like:
    string sID = "MeSch_" + IntToString(mID);
    _PrintString("sID: "+sID, DEBUG_TOOLKIT);

    int i;
    for (i = MeGetIntCount(oModule, sID)-1; i >= 0; i--)
    {
        _PrintString("i: "+IntToString(i), DEBUG_TOOLKIT);

        int mChild = MeGetIntByIndex(oModule, i, sID);
        string sChild = "MeSch_"+IntToString(mChild);
        _PrintString("sChild: "+sChild, DEBUG_TOOLKIT);
        if (GetLocalInt(oModule, sChild+"_Good") == 0) continue;

        float fDelay = GetLocalFloat(oModule, sChild+"_Delay");
        int iRepeat  = GetLocalInt(oModule, sChild+"_Repeat");
        int iType = GetLocalInt(oModule, sChild+"_Type");

        string sName;
        struct message sMsg;
        string sChannel;
        object oTarget;
        object oSender;
        object oArg;
        int iGood;

        // do what this is
        switch (iType)
        {
            case 0:
                _PrintString("Case: Bad Type", DEBUG_TOOLKIT);
                break;
            case 1:
                // Moment
                _PrintString("Case: Moment", DEBUG_TOOLKIT);
                sName = GetLocalString(oModule, sChild+"_Name");
                iGood = GetLocalInt(oModule, sID+"_Good");
                DelayCommand(fDelay, _MeActivateMoment(sName, mChild, sChild, iGood));
                break;
            case 2:
                // Message
                _PrintString("Case: Message", DEBUG_TOOLKIT);
                sMsg = MeGetLocalMessage(oModule,  sChild+"_Msg");
                sChannel = GetLocalString(oModule, sChild+"_Channel");
                oTarget = GetLocalObject(oModule,  sChild+"_Target");
                oSender = GetLocalObject(oModule,  sChild+"_Sender");
                if (GetIsObjectValid(oTarget))
                {
                    DelayCommand(fDelay, MeSendMessage(sMsg, sChannel, oTarget, oSender));
                }
                else
                {
                    DelayCommand(fDelay, MeBroadcastMessage(sMsg, sChannel));
                }
                break;
            case 3:
                // Function
                _PrintString("Case: Function", DEBUG_TOOLKIT);
                oTarget = GetLocalObject(oModule, sChild+"_Target");
                oArg = GetLocalObject(oModule,    sChild+"_Arg");
                sName = GetLocalString(oModule,   sChild+"_Name");
                DelayCommand(fDelay, _MeCallFunction(sName, oArg, oTarget));
                break;
            case 4:
                // Script
                _PrintString("Case: Script", DEBUG_TOOLKIT);
                sName = GetLocalString(oModule,   sID+"_Name");
                oTarget = GetLocalObject(oModule, sChild+"_Target");
                DelayCommand(fDelay, ExecuteScript(sName,oTarget));
                break;
        }

        // if this is not a repeating event then make it invalid.
        if (!iRepeat)
        {
            MeRemoveIntRef(oModule, i);
            // Scheduled things that are not moments and have just been activated
            // but are not marked as repeat are now destroyed. These are considered
            // transient (roughly atomic) operations.
            if (iType > 1)
            {
                MeUnschedule(mChild);
                DeleteLocalInt(oModule, sChild+"_Good");
            }
        }
    }

    _End();
}

void MeAdjustSchedule(int iScheduledThing, int iTime, int bRepeat=TRUE)
{
    object oModule = GetModule();
    string sId = IntToString(iScheduledThing);
    // float fDelay = MeGameDuration(iTime);
    float fDelay = IntToFloat(iTime);
    if (GetLocalInt(oModule, "MeSch_"+sId+"_Good"))
    {
        SetLocalFloat(oModule, "MeSch_"+sId+"_Delay", fDelay);
        SetLocalInt(oModule, "MeSch_"+sId+"_Repeat", bRepeat);
    }
}

int MeScheduleMessage(struct message sData, object oTarget, string sChannel = "", int iTime=0, string sMoment="", int bRepeat=FALSE)
{
    _Start("MeScheduleMessage sMomentName='"+sData.sMessageName+"'", DEBUG_TOOLKIT);

    if (iTime == 0 && sMoment == "" && bRepeat == TRUE) bRepeat == FALSE;

    object oModule = GetModule();
    // float fDelay = MeGameDuration(iTime);
    float fDelay = IntToFloat(iTime);

    // Get the id if the scheduled thing
    int pID;
    int mID = GetLocalInt(oModule, "MeSch_C")+1;
    SetLocalInt(oModule, "MeSch_C", mID);
    string sID = "MeSch_"+IntToString(mID);

    SetLocalInt(oModule,       sID+"_Type", 2); // Type 2 is MeSendMessage
    SetLocalInt(oModule,       sID+"_Good", 1);
    SetLocalInt(oModule,       sID+"_Repeat", bRepeat);
    SetLocalObject(oModule,    sID+"_Target", oTarget);
    SetLocalFloat(oModule,     sID+"_Delay", fDelay);
    SetLocalString(oModule,    sID+"_Channel", sChannel);
    MeSetLocalMessage(oModule, sID+"_Msg", sData);

    if (sMoment == "")
    {
        if (GetIsObjectValid(oTarget))
        {
            _PrintString("MeSendMessage", DEBUG_TOOLKIT);
            DelayCommand(fDelay, MeSendMessage(sData, sChannel, oTarget, OBJECT_SELF));
        }
        else
        {
            _PrintString("MeBroadcastMessage", DEBUG_TOOLKIT);
            DelayCommand(fDelay, MeBroadcastMessage(sData, sChannel));
        }
    }
    // Otherwise attach this message request to the moment
    else
    {
        pID = GetLocalInt(oModule, "MESch_MO"+sMoment);
        if (pID) MeAddIntRef(oModule, mID, "MeSch_"+IntToString(pID));
    }

    _End();
    return mID;
}

int MeScheduleFunction(object oTarget, string sFunction, object oArgument=OBJECT_INVALID, int iTime=0, string sMoment="", int bRepeat=FALSE)
{
    if (iTime == 0 && sMoment == "" && bRepeat == TRUE) bRepeat == FALSE;

    object oModule = GetModule();
    //float fDelay = MeGameDuration(iTime);
    float fDelay = IntToFloat(iTime);

    // Get the id if the scheduled thing
    int pID;
    int mID = GetLocalInt(oModule, "MeSch_C")+1;
    SetLocalInt(oModule, "MeSch_C", mID);
    string sID = "MeSch_"+IntToString(mID);

    SetLocalInt(oModule,       sID+"_Type",   3); // Type 3 is MeCallFunction
    SetLocalInt(oModule,       sID+"_Good", 1);
    SetLocalInt(oModule,       sID+"_Repeat", bRepeat);
    SetLocalObject(oModule,    sID+"_Target", oTarget);
    SetLocalObject(oModule,    sID+"_Arg",    oArgument);
    SetLocalString(oModule,    sID+"_Name",   sFunction);
    SetLocalFloat(oModule,     sID+"_Delay",  fDelay);

    if (sMoment == "") DelayCommand(fDelay, _MeCallFunction(sFunction, oArgument, oTarget));
    // Otherwise attach this message request to the moment
    else
    {
        pID = GetLocalInt(oModule, "MESch_MO"+sMoment);
        if (pID) MeAddIntRef(oModule, mID, "MeSch_"+IntToString(pID));
    }
    return mID;
}

int MeScheduleScript(object oTarget, string sScript, int iTime=0, string sMoment="", int bRepeat=FALSE)
{
    if (iTime == 0 && sMoment == "" && bRepeat == TRUE) bRepeat == FALSE;

    object oModule = GetModule();
    // float fDelay = MeGameDuration(iTime);
    float fDelay = IntToFloat(iTime);

    // Get the id if the scheduled thing.
    int mID = GetLocalInt(oModule, "MeSch_C")+1;
    SetLocalInt(oModule, "MeSch_C", mID);
    string sID = "MeSch_"+IntToString(mID);

    SetLocalInt(oModule,    sID+"_Type", 4); // Type 4 is ExecuteScript
    SetLocalInt(oModule,    sID+"_Good", 1);
    SetLocalInt(oModule,    sID+"_Repeat", bRepeat);
    SetLocalObject(oModule, sID+"_Target", oTarget);
    SetLocalString(oModule, sID+"_Name", sScript);
    SetLocalFloat(oModule,  sID+"_Delay", fDelay);
    SetLocalString(oModule, sID+"_Rel", sMoment);

    // Add this moment to the list of triggered relative things.
    string sEarlierMoment = GetLocalString(oModule, sID+"_Rel");
    int pID = GetLocalInt(oModule, "MESch_MO"+sEarlierMoment);
    if (pID) MeAddIntRef(oModule, mID, "MeSch_"+IntToString(pID));

    if (sEarlierMoment == "") DelayCommand(fDelay, ExecuteScript(sScript,oTarget));
    return mID;
}

void MeUnschedule(int iScheduledThing)
{
    object oModule = GetModule();
    string sID = "MeSch_"+IntToString(iScheduledThing);

    // Increment the good count to prevent the execution of previously scheduled
    // moments, which are going to happen because of a call to DelayCommand().
    // Since we cannot cancel calls to DelayCommand() we create an incrementing
    // serial lock. This limits us to, like, four billion cancelled calls to a
    // given moment.
    SetLocalInt(oModule, sID+"_Good", GetLocalInt(oModule, sID+"_Good")+1);

    DeleteLocalInt(oModule,    sID+"_Type");
    DeleteLocalInt(oModule,    sID+"_Repeat");
    DeleteLocalObject(oModule, sID+"_Target");
    DeleteLocalObject(oModule, sID+"_Arg");
    DeleteLocalString(oModule, sID+"_Name");
    DeleteLocalFloat(oModule,  sID+"_Delay");
    DeleteLocalString(oModule, sID+"_Rel");
    MeDeleteLocalMessage(oModule, sID+"_Msg");
}

void MeClearScheduledMoments(int iMomentID)
{
    object oModule = GetModule();
    string sID = "MeSch_"+IntToString(iMomentID);
    SetLocalInt(oModule, sID+"_Good", GetLocalInt(oModule, sID+"_Good")+1);
}

