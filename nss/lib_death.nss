#include "h_library"

// Basic GC --------------------------------------------------------------------
void g_cleanup_dth()
{
    _Start("Generator name='NPC_SELF Cleanup' timing='Death'");

    object oSelf = MeGetNPCSelf();
    DestroyObject(oSelf);

    _End("Generator");
}


// Main: Register Functions & Dispatch -----------------------------------------

void main()
{
    _Start("Library name='"+MEME_LIBRARY+"'", DEBUG_TOOLKIT);

    // Register classes and functions
    if (MEME_DECLARE_LIBRARY)
    {
        MeLibraryImplements("g_cleanup", "_dth", 0x0100+0xff);

        _End();
        return;
    }

    // Dispatch to the function
    switch (MEME_ENTRYPOINT & 0xff00)
    {
        case 0x0100: switch (MEME_ENTRYPOINT & 0x00ff)
        {
            case 0xff: g_cleanup_dth(); break;
        } break;
    }
    _End();
}
