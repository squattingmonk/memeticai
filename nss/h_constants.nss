/*  Constants for the Memetic Toolkit
 *  William Bull
 *  September, 2002
 */

// ----- Datatypes -------------------------------------------------------------

struct message
{
    // Define the name of the message. Anonymous messages are ok, but are
    // only received by events that have subscribed to all messages.
    // Events subscribe to all messages by subscribing to the null string, "".
    string sMessageName;

    // Message Data
    string   sData;
    int      iData;
    float    fData;
    location lData;
    object   oData;

    // These are normally filled in for you. The assumption is that
    // messages will be resent by various senders to various receivers.
    // As a result, these are defined when the message is sent on a particular
    // channel, by a particular object to a particular object.
    object oSender;
    object oTarget;
    string sChannelName;
};

// ----- POI Sizes -------------------------------------------------------------

const float POI_LARGE = 10.0;
const float POI_SMALL = 5.0;

const int   AOE_LARGE_POI = AOE_PER_INVIS_SPHERE;
const int   AOE_SMALL_POI = 37;

// ----- Observer Meme ---------------------------------------------------------

const int SIGNAL_OBSERVER   = 0x02021; // Some arbitrary signal trigger.

const int NOTIFY_ARM        = 0x000001;
const int NOTIFY_DISARM     = 0x000002;
const int NOTIFY_APPEAR     = 0x000004;
const int NOTIFY_VANISH     = 0x000008;
const int NOTIFY_ATTACK     = 0x000010;
const int NOTIFY_DEFEND     = 0x000020;
const int NOTIFY_CAST_AT    = 0x000040; // Requires changes to all spell scipts.
const int NOTIFY_CAST_ON    = 0x000080; // Requires changes to all spell scipts.

const int NOTIFY_ENEMY      = 0x000100;
const int NOTIFY_FRIEND     = 0x000200;
const int NOTIFY_PC         = 0x000400;
const int NOTIFY_NPC        = 0x000800;
const int NOTIFY_DM         = 0x001000;

const int NOTIFY_DEAD       = 0x002000;
const int NOTIFY_ALIVE      = 0x004000;
const int NOTIFY_HEALTHY    = 0x008000;
const int NOTIFY_BRUISED    = 0x010000;
const int NOTIFY_WOUNDED    = 0x020000;
const int NOTIFY_HURT       = 0x040000;
const int NOTIFY_BADLYHURT  = 0x080000;
const int NOTIFY_NEARDEATH  = 0x100000;
const int NOTIFY_HEALTH_INC = 0x200000;
const int NOTIFY_HEALTH_DEC = 0x400000;

// ----- Core Meme Constants ---------------------------------------------------

// Response Tables
const string RESPONSE_START = "MEME_RTS_";
const string RESPONSE_END   = "MEME_RTE_";
const string RESPONSE_HIGH   = "MEME_RTH_";
const string RESPONSE_MEDIUM = "MEME_RTM_";
const string RESPONSE_LOW    = "MEME_RTL_";

// Event Constants
const int MEME_EVENT         = 0x001;
const int GENERATOR_EVENT    = 0x002;
const int ALL_TRIGGERS       = 9999999;

// General Sequence Constants
const int SEQ_REPEAT         = 0x001;
const int SEQ_RESUME_FIRST   = 0x002;
const int SEQ_RESUME_LAST    = 0x004;
const int SEQ_INSTANT        = 0x040;
const int SEQ_IMMEDIATE      = 0x080;
const int SEQ_CHILDREN       = 0x800;

// General Meme Constants
const int MEME_ONCE          = 0x0000; // Run this once, do nothing tricky.
const int MEME_REPEAT        = 0x0008; // Restart this meme after all its actions complete.
const int MEME_RESUME        = 0x0010; // Restart this meme if it's interrupted.
const int MEME_CHECKPOINT    = 0x0020; // This is where a sequence should resume if interrupted.
const int MEME_INSTANT       = 0x0040; // Only make this meme if it's the higest priority?
const int MEME_IMMEDIATE     = 0x0080; // Should the meme run regardless of the current meme, w/o _brk?

const int MEME_CHILDREN      = 0x0800;
const int MEME_NOBIAS        = 0x1000; // Should the modifier not be modified because of the class?

// PoI Emitter Constants
//const int EMIT_MANY          = 0x00; (Not implemented)
//const int EMIT_ONCE_TO_ONE   = 0x01; (Not implemented)
//const int EMIT_ONCE_TO_MANY  = 0x02; (Not implemented)
//const int EMIT_ONCE          = 0x04; (Not implemented)
const int EMIT_TO_PC         = 0x08;
const int EMIT_TO_DM         = 0x10; // This may not work; depending on if Bioware lets DM's trigger AoEs.
const int EMIT_TO_NPC        = 0x20;
      int EMIT_TO_ALL        = EMIT_TO_PC | EMIT_TO_DM | EMIT_TO_NPC;

// Meme Priority Constants
const int PRIO_DEFAULT       = 0;
const int PRIO_NONE          = 1;
const int PRIO_LOW           = 2;
const int PRIO_MEDIUM        = 3;
const int PRIO_HIGH          = 4;
const int PRIO_VERYHIGH      = 5;

// Generator Constants
const int GEN_SINGLEUSE      = 1;
//const int GEN_PROPOGATE_PRIO = 0x100; (Not implemented)

const int TIME_ONE_MINUTE = 60;
const int TIME_ONE_HOUR   = 3600;
const int TIME_ONE_DAY    = 86400;

// Variable Declaration Constants

const int VAR_INHERIT        = 0x01;
//const int VAR_INHERIT_COPY   = 0x02; (Not implemented)
//const int VER_INHERIT_FORCE  = 0x04; (Not implemented)
//const int VAR_PERSISTANT     = 0x08; (Not implemented)
//const int VAR_EXPIRE         = 0x10; (Not implemented)

// ----- Private ---------------------------------------------------------------

object MEME_SELF          = GetLocalObject (OBJECT_SELF, "MEME_ObjectSelf");
object NPC_SELF           = GetLocalObject (OBJECT_SELF, "MEME_NPCSelf");
const int    TYPE_MEME          = 0x00001;
const int    TYPE_SEQ_REF       = 0x00002;
const int    TYPE_GENERATOR     = 0x00004;
const int    TYPE_EVENT         = 0x00008;
const int    TYPE_SEQUENCE      = 0x00010;
const int    TYPE_MEME_BAG      = 0x00020;
const int    TYPE_GENERATOR_BAG = 0x00040;
const int    TYPE_EVENT_BAG     = 0x00080;
const int    TYPE_SEQUENCE_BAG  = 0x00100;
const int    TYPE_PRIO_BAG      = 0x00200;
const int    TYPE_PRIO_BAG1     = 0x00400;
const int    TYPE_PRIO_BAG2     = 0x00800;
const int    TYPE_PRIO_BAG3     = 0x01000;
const int    TYPE_PRIO_BAG4     = 0x02000;
const int    TYPE_PRIO_BAG5     = 0x04000;
const int    TYPE_PRIO_SUSPEND  = 0x08000;
const int    TYPE_CLASS         = 0x10000;
const int    TYPE_NPC_SELF      = 0x20000;

/*  Constants for the lib_combat
 *  Joel Martin
 *  May, 2003
 */

// ----- SIGNALS ---------------------------------------------------------------

const int CH_DEAD = 691;
const int CH_COMBAT = 699;
const int CH_ALL = 700;

// ----- EFFECTS ---------------------------------------------------------------

const int BLINDNESS = 32;
