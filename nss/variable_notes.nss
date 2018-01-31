// NPC Variables
//
// [String] MT: Talk Animated
// If this is true then the NPC will perform ambient animations as they talk
// to a player.
//
// [String] MT: Talk Timeout
// This string is what the NPC says when if the dialog goes on for too long.
//
// [String] MT: Talk Interruption
// This string is that an NPC says when they're being interrupted mid-conversation
// by another player.
//
// [Float]  MT: Dialog Timeout
// This is the number of seconds that the NPC will stay engaged in a
// conversation. If this is empty, the conversation will go on indefinately.

#include "h_library"

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    if (MEME_DECLARE_LIBRARY)
    {
        //MeRegisterClass("<name>");
        //MeLibraryImplements("<name>",        "_atk",    0x??00+0x01);
        //MeLibraryImplements("<name>",        "_blk",    0x??00+0x02);
        //MeLibraryImplements("<name>",        "_end",    0x??00+0x03);
        //MeLibraryImplements("<name>",        "_tlk",    0x??00+0x04);
        //MeLibraryImplements("<name>",        "_dmg",    0x??00+0x05);
        //MeLibraryImplements("<name>",        "_dth",    0x??00+0x06);
        //MeLibraryImplements("<name>",        "_inv",    0x??00+0x07);
        //MeLibraryImplements("<name>",        "_hbt",    0x??00+0x08);
        //MeLibraryImplements("<name>",        "_see",    0x??00+0x09);
        //MeLibraryImplements("<name>",        "_van",    0x??00+0x0a);
        //MeLibraryImplements("<name>",        "_hea",    0x??00+0x0b);
        //MeLibraryImplements("<name>",        "_ina",    0x??00+0x0c);
        //MeLibraryImplements("<name>",        "_per",    0x??00+0x0d);
        //MeLibraryImplements("<name>",        "_rst",    0x??00+0x0e);
        //MeLibraryImplements("<name>",        "_mgk",    0x??00+0x0f);
        //MeLibraryImplements("<name>",        "_ini",    0x??00+0xff);
        //MeLibraryFunction("<name>",       0x??00);
        _End();
        return;
    }

    _PrintString("MEME_ENTRYPOINT == "+IntToHexString(MEME_ENTRYPOINT), DEBUG_TOOLKIT);
    switch (MEME_ENTRYPOINT & 0xff00)
    {
        /*
        case 0x??00: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0x01: <name>_atk();     break; // Attacked
            case 0x02: <name>_blk();     break; // Blocked by a door
            case 0x03: <name>_end();     break; // Combat round ended
            case 0x04: <name>_tlk();     break; // Conversation starts or speech is heard
            case 0x05: <name>_dmg();     break; // Damaged
            case 0x06: <name>_dth();     break; // Death
            case 0x07: <name>_inv();     break; // Inventory disturbed
            case 0x08: <name>_hbt();     break; // Heartbeat
            case 0x09: <name>_see();     break; // Perception (Sight)
            case 0x0a: <name>_van();     break; // Perception (Disappeared - Vanished)
            case 0x0b: <name>_hea();     break; // Perception (Heard)
            case 0x0c: <name>_ina();     break; // Perception (Disappeared - Inaudible)
            case 0x0d: <name>_per();     break; // Bulk Perception (Coming Soon - DR4)
            case 0x0e: <name>_rst();     break; // Rest
            case 0x0f: <name>_mgk();     break; // Spell target
            case 0xff: <name>_ini();     break; // Initializer
        } break;

        case 0x??00: MeSetResult(<name>(MEME_ARGUMENT)); break;
        */
    }

    _End();
}
