#include "h_ai"
#include "h_poi"

void main()
{
    //MeStartDebugging(DEBUG_UTILITY, 1);
    _Start("LeverActivated");

    object   oPoI      = GetWaypointByTag("POI_ONE");
    location lLocation = GetLocation(oPoI);
    object   oLever    = OBJECT_SELF;
    object   oEmitter  = GetLocalObject(oLever, "Emitter");
    string   sName     = GetName(oLever);
    int      isOn      = GetLocalInt(oLever, "IsOn");

    object   oCow      = GetObjectByTag("NW_COW");

    // Basic lever code. I would have thought Bioware would have provided
    // some function like IsObjectActivated() and ActivateObject(). Guess not.
    if (!isOn)
    {

        PlayAnimation( ANIMATION_PLACEABLE_DEACTIVATE );
        isOn = 1;
        SetLocalInt(oLever, "IsOn", isOn);
    }
    else
    {
        PlayAnimation( ANIMATION_PLACEABLE_ACTIVATE );
        isOn = 0;
        SetLocalInt(oLever, "IsOn", isOn);
    }



    if (sName == "SwitchOne")
    {
        _PrintString("Activating Lever One isOn = " + IntToString(isOn));
        // Turn it on - this is how you make an emitter.
        // Everything else is just junk to handle a switch.
        if (isOn)
        {
            ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_FNF_SUNBEAM), lLocation);

            // Step 1: Just emit an enter and exit notification.
            // MeDefineEmitter(sName, sTestFunction, sActivationFunction, sExitFunction, sResRef, sEnterText = "", string sExitText = "", int iFlags = 0x08 /* EMIT_TO_PC */, float fDistance = 10.0, int fCacheTest = 0, int fCacheNotify = 0, int iSignal = 0, string sChannel = "")
            MeDefineEmitter("Chill", "", "", "", "c_poi_1", "You feel a chill - all the hairs raise up on your neck.", "You feel less disturbed.", EMIT_TO_PC | EMIT_TO_DM, 2.0);

            // Step 2: Add the emitter at the location
            oEmitter = MeAddEmitterToLocation(lLocation, "Chill");

            // Just store the emitter so we can remove it later.
            SetLocalObject(oLever, "Emitter", oEmitter);
        }
        // Turn it off.
        else
        {
            _PrintString("Removing emitter", DEBUG_UTILITY);
            _PrintString("Emitter tag is +"+GetTag(oEmitter), DEBUG_UTILITY);
            MeRemoveEmitter(oEmitter, "Chill");
        }
    }

    if (sName == "SwitchTwo")
    {
        _PrintString("Activating Lever Two isOn = " + IntToString(isOn));
        // Turn it on - this is how you make an emitter.
        // Everything else is just junk to handle a switch.
        if (isOn)
        {
            ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_FNF_SUNBEAM), lLocation);

            // Step 1: Just emit an enter and exit notification.
            // MeDefineEmitter(sName, sTestFunction, sActivationFunction, sExitFunction, sResRef, sEnterText = "", string sExitText = "", int iFlags = 0x08 /* EMIT_TO_PC */, float fDistance = 10.0, int fCacheTest = 0, int fCacheNotify = 0, int iSignal = 0, string sChannel = "")
            MeDefineEmitter("Draft", "", "", "", "", "A cold draft makes you shiver.", "It feels warmer over here.", EMIT_TO_PC | EMIT_TO_DM, POI_LARGE);

            // Step 2: Add the emitter at the location
            oEmitter = MeAddEmitterToLocation(lLocation, "Draft");

            // Just store the emitter so we can remove it later.
            // If there was one already, it will be the same emitter -- they're at the same location.
            SetLocalObject(oLever, "Emitter", oEmitter);
        }
        // Turn it off.
        else
        {
            _PrintString("Removing emitter", DEBUG_UTILITY);
            _PrintString("Emitter tag is +"+GetTag(oEmitter), DEBUG_UTILITY);
            MeRemoveEmitter(oEmitter, "Draft");
        }
    }

    if (sName == "SwitchThree")
    {
        _PrintString("Activating Lever Three isOn = " + IntToString(isOn));
        // Turn it on - this is how you make an emitter.
        // Everything else is just junk to handle a switch.
        if (isOn)
        {
            // Step 1: Just emit an enter and exit notification.
            // MeDefineEmitter(sName, sTestFunction, sActivationFunction, sExitFunction, sResRef, sEnterText = "", string sExitText = "", int iFlags = 0x08 /* EMIT_TO_PC */, float fDistance = 10.0, int fCacheTest = 0, int fCacheNotify = 0, int iSignal = 0, string sChannel = "")
            MeDefineEmitter("CowPatty", "", "", "", "", "*Squish*", "", 0x08, 10.0, 0, 5);

            // Step 2: Add the emitter at the location
            MeAddEmitterToCreature(oCow, "CowPatty");
        }
        // Turn it off.
        else
        {
            _PrintString("Removing emitter", DEBUG_UTILITY);
            _PrintString("Emitter tag is +"+GetTag(oCow), DEBUG_UTILITY);
            MeRemoveEmitter(oCow, "CowPatty");
        }
    }
    _End("LeverActivated");
}
