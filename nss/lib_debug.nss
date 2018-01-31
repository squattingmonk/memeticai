/* A debug library for generators.
 *
 * Contains a debug NPC class, a debug trigger, and basic callback responses for
 * creatures and triggers.
 *
 * == TODO ==
 * Add basic callback reporting for doors, items, encounters
 * Add a function that will list the current meme store of a given memetic object.
 */

#include "h_library"
#include "h_ai"
#include "h_response"

//object f_report_memes()

object f_debug_mark(object oTarget = OBJECT_SELF)
{
    //VFX_DUR_INFERNO VFX_DUR_LIGHT
    effect e = EffectVisualEffect(VFX_DUR_GLOW_LIGHT_PURPLE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, e, OBJECT_SELF, 2.0);
    return OBJECT_INVALID;
}

object f_walk_test(object oTarget = OBJECT_INVALID)
{
    _Start("Trail", DEBUG_USERAI);

    //SpeakString("Walking Trail.");

    object oTrail = MeCreateMeme("i_walkwp", PRIO_DEFAULT, 0, MEME_REPEAT);
    SetLocalString(oTrail, "Tag", MeGetLocalString(NPC_SELF, "Tag"));
    SetLocalInt(oTrail, "NoPrefix", MeGetLocalInt(NPC_SELF, "NoPrefix"));
    SetLocalInt(oTrail, "Repeat", MeGetLocalInt(NPC_SELF, "Repeat"));
    SetLocalInt(oTrail, "Reverse", MeGetLocalInt(NPC_SELF, "Reverse"));
    SetLocalInt(oTrail, "Loop", MeGetLocalInt(NPC_SELF, "Loop"));
    SetLocalInt(oTrail, "Random", MeGetLocalInt(NPC_SELF, "Random"));
    SetLocalInt(oTrail, "Run", MeGetLocalInt(NPC_SELF, "Run"));

    float fDelay = MeGetLocalFloat(NPC_SELF, "WalkDelay");
    if (fDelay == 0.0f) fDelay = 300.0;

    DelayCommand(fDelay, MeClearMemeFlag(oTrail, MEME_REPEAT));
    //MeStopMeme(oTrail, fDelay);

    _End();
    return NPC_SELF;
}

void c_debug_walk_ini()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_USERAI);

    MeAddResponse(MEME_SELF, "Debug Walk Table", "f_walk_test", 0, RESPONSE_START);
    MeSetActiveResponseTable("Idle", "Debug Walk Table");

    _End();
}

/* Create a trigger in the toolset and set its tag to 'DebugTrigger'. */
void DebugTrigger_ent()
{
    _Start("Trigger timing='Enter'", DEBUG_COREAI);

    if (GetIsObjectValid(OBJECT_SELF))
    {
        _PrintString(_GetName(OBJECT_SELF) + " entered the trigger.", DEBUG_COREAI);
        FloatingTextStringOnCreature("Entered Trigger.", OBJECT_SELF, TRUE);
    }

    _End();
}

void DebugTrigger_ext()
{
    _Start("Trigger timing='Exit'", DEBUG_COREAI);

    if (GetIsObjectValid(OBJECT_SELF))
    {
        _PrintString(_GetName(OBJECT_SELF) + " exited the trigger.", DEBUG_COREAI);
        FloatingTextStringOnCreature("Exited Trigger.", OBJECT_SELF, TRUE);
    }

    _End();
}

void DebugTrigger_clk()
{
    _Start("Trigger timing='Clicked'", DEBUG_COREAI);

    if (GetIsObjectValid(OBJECT_SELF))
    {
        _PrintString(_GetName(OBJECT_SELF) + " clicked within the trigger area.", DEBUG_COREAI);
        FloatingTextStringOnCreature("Clicked On Trigger.", OBJECT_SELF, TRUE);
    }

    _End();
}

void DebugTrigger_hbt()
{
    _Start("Trigger timing='Heartbeat'", DEBUG_COREAI);

    if (GetIsObjectValid(OBJECT_SELF))
    {
        _PrintString(_GetName(OBJECT_SELF) + " is within the trigger area.", DEBUG_COREAI);
        FloatingTextStringOnCreature("Trigger Heartbeat.", OBJECT_SELF, TRUE);
    }

    _End();
}

/*
void c_debug_npc_ini()
{
    _Start("Initialize class='"+MEME_CALLED+"'", DEBUG_USERAI);

    MeAddResponse(MEME_SELF, "Debug Idle Table", "f_walk_test", 50, RESPONSE_LOW);
    MeAddResponse(MEME_SELF, "Debug Idle Table", "f_sit",       50, RESPONSE_HIGH);

    MeSetActiveResponseTable("Idle", "Debug Idle Table");

    _End();
}
*/

void c_debug_npc_go()
{
    _Start("Instantiate class='"+MEME_CALLED+"'", DEBUG_USERAI);

    object oDebug = MeCreateGenerator("g_debug", PRIO_VERYHIGH, 100);
    MeStartGenerator(oDebug);

    _End();
}

void g_debug_ini()
{
    _Start("Generator name='Debug' timing='Initialize'", DEBUG_USERAI);

    SpeakString("Initializing the generator!");
    _End();
}

void g_debug_hea()
{
    _Start("Generator name='Debug' timing='Hear'", DEBUG_USERAI);
    object oSeen;
    oSeen = GetLastPerceived();
    SpeakString("I can hear you, " + _GetName(oSeen) + "!");
    _End();
}

void g_debug_see()
{
    _Start("Generator name='Debug' timing='See'", DEBUG_USERAI);
    object oSeen;
    oSeen = GetLastPerceived();
    SpeakString("I can see you, " + _GetName(oSeen) + "!");
    _End();
}

void g_debug_inv()
{
    _Start("Generator name='Debug' timing='Inventory'", DEBUG_USERAI);

    object oSeen = GetLastPerceived();
    SpeakString(_GetName(oSeen) + " has disturbed my inventory!");

    object oHostile = GetLastHostileActor(OBJECT_SELF);
    SpeakString(_GetName(oHostile) + " is my last hostile actor.");

    object oItem = GetLastDisturbed();
    SpeakString(_GetName(oItem) + " is the item last disturbed, and it is " +
        (GetStolenFlag(oItem) ? "" : "not ") + "stolen property.");

    _End();
}

void g_debug_atk()
{
    _Start("Generator name='Debug' timing='Attacked'", DEBUG_USERAI);

    object oAttacker = GetLastAttacker();
    object oActor = GetLastHostileActor();
    object oWeapon = GetLastWeaponUsed(OBJECT_SELF);
    int iDamage = GetTotalDamageDealt();
    SpeakString("I was attacked by " + _GetName(oAttacker) + " (" +
        _GetName(oActor) + ") by a " + _GetName(oWeapon) + " for " +
        IntToString(iDamage) + " points of damage!");
    _End();
}

void g_debug_blk()
{
    _Start("Generator name='Debug' timing='Blocked'", DEBUG_USERAI);

    SpeakString("I am blocked!");
    _End();
}

void g_debug_end()
{
    _Start("Generator name='Debug' timing='End'", DEBUG_USERAI);

    SpeakString("I am ending!");
    _End();
}

void g_debug_tlk()
{
    _Start("Generator name='Debug' timing='Talk'", DEBUG_USERAI);

    SpeakString("I am talking!");
    _End();
}

void g_debug_dmg()
{
    _Start("Generator name='Debug' timing='Damaged'", DEBUG_USERAI);

    SpeakString("I took damage!");
    _End();
}

void g_debug_dth()
{
    _Start("Generator name='Debug' timing='Death'", DEBUG_USERAI);

    SpeakString("I died!");
    _End();
}

void g_debug_hbt()
{
    _Start("Generator name='Debug' timing='Heartbeat'", DEBUG_USERAI);

    SpeakString("I have a heartbeat!");
    _End();
}

void g_debug_van()
{
    _Start("Generator name='Debug' timing='Vanished'", DEBUG_USERAI);

    SpeakString("I have lost sight of you!");
    _End();
}

void g_debug_ina()
{
    _Start("Generator name='Debug' timing='Inaudible'", DEBUG_USERAI);

    SpeakString("I cannot hear you.!");
    _End();
}

void g_debug_per()
{
    _Start("Generator name='Debug' timing='Perceive'", DEBUG_USERAI);

    SpeakString("I perceive someone!");
    _End("Generator", DEBUG_COREAI);
}

void g_debug_rst()
{
    _Start("Generator name='Debug' timing='Rest'", DEBUG_USERAI);

    SpeakString("I am resting!");
    _End();
}

void g_debug_mgk()
{
    _Start("Generator name='Debug' timing='Magic'", DEBUG_USERAI);

    SpeakString("I am affected by magic!");
    _End();
}

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("g_debug",      "_ini",     0x0100+0xff);
        MeLibraryImplements("g_debug",      "_hea",     0x0100+0x01);
        MeLibraryImplements("g_debug",      "_see",     0x0100+0x02);
        MeLibraryImplements("g_debug",      "_van",     0x0100+0x03);
        MeLibraryImplements("g_debug",      "_ina",     0x0100+0x04);
        MeLibraryImplements("g_debug",      "_per",     0x0100+0x05);
        MeLibraryImplements("g_debug",      "_atk",     0x0100+0x06);
        MeLibraryImplements("g_debug",      "_dmg",     0x0100+0x07);
        MeLibraryImplements("g_debug",      "_mgk",     0x0100+0x08);
        MeLibraryImplements("g_debug",      "_dth",     0x0100+0x09);
        MeLibraryImplements("g_debug",      "_inv",     0x0100+0x0a);
        MeLibraryImplements("g_debug",      "_blk",     0x0100+0x0b);
        MeLibraryImplements("g_debug",      "_tlk",     0x0100+0x0c);
        MeLibraryImplements("g_debug",      "_rst",     0x0100+0x0d);
        MeLibraryImplements("g_debug",      "_end",     0x0100+0x0e);
        MeLibraryImplements("g_debug",      "_hbt",     0x0100+0x0f);

        MeRegisterClass("debug_npc");
        MeLibraryImplements("c_debug_npc",  "_go",      0x0200+0x01);

        MeLibraryFunction("f_walk_test",                 0x0300);

        MeLibraryImplements("DebugTrigger",  "_ent",    0x0400+0x01);
        MeLibraryImplements("DebugTrigger",  "_ext",    0x0400+0x02);
        MeLibraryImplements("DebugTrigger",  "_clk",    0x0400+0x03);
        MeLibraryImplements("DebugTrigger",  "_hbt",    0x0400+0x04);

        MeLibraryFunction("f_debug_mark",               0x0500);

        MeRegisterClass("debug_walk");
        MeLibraryImplements("c_debug_walk",  "_ini",    0x0600+0xff);

        _End();
        return;
    }

    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: g_debug_ini(); break;
            case 0x01: g_debug_hea(); break;
            case 0x02: g_debug_see(); break;
            case 0x03: g_debug_van(); break;
            case 0x04: g_debug_ina(); break;
            case 0x05: g_debug_per(); break;
            case 0x06: g_debug_atk(); break;
            case 0x07: g_debug_dmg(); break;
            case 0x08: g_debug_mgk(); break;
            case 0x09: g_debug_dth(); break;
            case 0x0a: g_debug_inv(); break;
            case 0x0b: g_debug_blk(); break;
            case 0x0c: g_debug_tlk(); break;
            case 0x0d: g_debug_rst(); break;
            case 0x0e: g_debug_end(); break;
            case 0x0f: g_debug_hbt(); break;
        } break;

        case 0x0200: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: c_debug_npc_go(); break;
        }   break;

        case 0x0300: MeSetResult(f_walk_test(MEME_ARGUMENT)); break;

        case 0x0400: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: DebugTrigger_ent(); break;
            case 0x02: DebugTrigger_ext(); break;
            case 0x03: DebugTrigger_clk(); break;
            case 0x04: DebugTrigger_hbt(); break;
        } break;

        case 0x0500: MeSetResult(f_debug_mark(MEME_ARGUMENT)); break;

        case 0x0600: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: c_debug_walk_ini(); break;
        }   break;
   }

    _End("Library", DEBUG_TOOLKIT);
}

