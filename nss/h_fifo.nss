/*
h_fifo: routines to manage a first-in, first-out list of objects.  this file
	is not stand-alone; it must be #included.

Author: Marty Shannon (a.k.a. Olias of Sunhillow); 2004/05/29.

these are not optimized, and only deal with fifos of objects; eventually,
	both of these issues will be fixed.
*/

#include "h_debug"

void _Assert(string s)
{
	_PrintString("<Assert>" + s + "</Assert>");
}

int MePushFifoObjectRef(object oTarget, string sProp, object oValue)
{
	int i;
	string sPi;
	object oTemp;

	for (i = 0; ; ++i)
	{
		// generate the property name
		sPi = sProp + IntToString(i);

		// get the object there
		oTemp = GetLocalObject(oTarget, sPi);

		// are we at the end of the list?
		if (!GetIsObjectValid(oTemp))
			break;

		// sanity clause: prevent object from being listed twice
		if (oTemp == oValue)
		{
			// this *shouldn't* be able to happen....
			_Assert("MePushFifoObjectRef(): object '" + _GetName(oValue) + "' is already at '" + sPi + "' on '" + _GetName(oTarget) + "'!");
			// ignore the 2nd entry; wasn't FirstIn, either
			return(0);
		}
	}
	SetLocalObject(oTarget, sPi, oValue);

	// true if this is FirstIn; false otherwise
	return(i == 0);
}

int MeDeleteFifoObjectRef(object oTarget, string sProp, object oValue)
{
	int i;
	string sPi;
	object oi;
	int j;
	string sPj;
	object oj;

	// delete the value from the fifo
	for (i = 0; ; ++i)
	{
		// generate property name
		sPi = sProp + IntToString(i);

		// get the object
		oi = GetLocalObject(oTarget, sPi);

		// sanity clause: object exiting isn't listed
		if (!GetIsObjectValid(oi))
		{
			// this *shouldn't* be able to happen
			_Assert("MeDeleteFifoObjectRef(): object '" + _GetName(oValue) + "' is not in fifo '" + sProp + "' of '" + _GetName(oTarget) + "!");
			// nothing to do; none removed -> not LastOut
			return(0);
		}

		// is this the one to delete?
		if (oi == oValue)
		{
			// yes; "j" variables refer to "next"; "i" variables refer to
			//	current; copy remaining objects 1 element down.

			for (j = i + 1; ; ++j)
			{
				// generate property name of next entry
				sPj = sProp + IntToString(j);

				// get the next object
				oj = GetLocalObject(oTarget, sPj);

				// are we at the end?
				if (oj == OBJECT_INVALID)
				{
					// yes; delete current object
					DeleteLocalObject(oTarget, sPi);	// yes: i, not j
					// and we're done; i == 0 -> LastOut
					return(i == 0);
				}

				// overwrite the current object with the next one
				SetLocalObject(oTarget, sPi, oj);

				// avoid computing property name
				sPi = sPj;
			}
		}
	}
	// NOTREACHED
	return(0);
}

object MePopFifoObjectRef(object oTarget, string sProp)
{
	string sP0 = sProp + "0";
	object o0 = GetLocalObject(oTarget, sP0);

	// are there any objects to pop?
	if (GetIsObjectValid(o0))
		MeDeleteFifoObjectRef(oTarget, sProp, o0);

	// return whatever we found
	return(o0);
}
