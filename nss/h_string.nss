/*
 *       File: h_string
 * Created By: Lomin Isilmelind
 *       Date: 11/11/2003
 *Last Update: 06/06/2004 by Lomin Isilmelind
 *
 *    Purpose: String functions
 */
// -- Required includes: -------------------------------------------------------

// -- Implementation -----------------------------------------------------------

// -- Constants ----------------------------------------------------------------

const string DEFAULT_SEPARATOR = "|";

// -- Prototypes ---------------------------------------------------------------

// Adds a string ahead a segment
string StringAddAheadSegment(string sString, string sAdd, int iSegment, string sSeparator = DEFAULT_SEPARATOR);
// Adds a string behind a segment
string StringAddBehindSegment(string sString, string sAdd, int iSegment, string sSeparator = DEFAULT_SEPARATOR);
// Deletes a char within a string
string StringDeleteChar(string sString, int iChar);
//Deletes the first char of a string
string StringDeleteFirstChar(string sString);
// Deletes a string segment
string StringDeleteSegment(string sString, int iSegment, string sSeparator = DEFAULT_SEPARATOR);
// Gets the first char of a string
string StringGetFirstChar(string sString);
// Get the requested string segment
string StringGetSegment(string sString, int iSegment = 1, string sSeparator = DEFAULT_SEPARATOR);
// Sets a string segment to sSegment
string StringSetSegment(string sString, string sSegment, int iSegment, string sSeparator = DEFAULT_SEPARATOR);

// -- Source -------------------------------------------------------------------

string StringAddAheadSegment(string sString, string sAdd, int iSegment, string sSeparator = DEFAULT_SEPARATOR)
{
    if (FindSubString(sString, sSeparator) == -1)
        return sString;
    sAdd = sAdd + DEFAULT_SEPARATOR;
    string sSave = sString;
    int i, iPosition = 0;
    for (i = 0; i < iSegment; i++)
    {
        iPosition = FindSubString(sString, sSeparator);
        sString = StringDeleteChar(sString, iPosition);
    }
    return InsertString(sSave, sAdd, iPosition + i);
}

string StringAddBehindSegment(string sString, string sAdd, int iSegment, string sSeparator = DEFAULT_SEPARATOR)
{
    if (FindSubString(sString, sSeparator) == -1)
        return sString;
    sAdd = DEFAULT_SEPARATOR + sAdd;
    string sSave = sString;
    int i, iPosition = 0;
    for (i = 0; i < iSegment + 1; i++)
    {
        iPosition = FindSubString(sString, sSeparator);
        sString = StringDeleteChar(sString, iPosition);
    }
    return InsertString(sSave, sAdd, iPosition + i - 1);
}

string StringDeleteChar(string sString, int iChar)
{
  return GetStringLeft(sString, iChar)
           +
           GetStringRight(sString, GetStringLength(sString) - iChar - 1);
}

string StringDeleteFirstChar(string sString)
{
  return GetStringRight(sString, GetStringLength(sString) - 1);
}

string StringDeleteSegment(string sString, int iSegment, string sSeparator = DEFAULT_SEPARATOR)
{
    string sSave = sString;
    int i, iPosition = 0;
    for (i = 0; i < iSegment; i++)
    {
        iPosition = FindSubString(sString, sSeparator);
        sString = StringDeleteChar(sString, iPosition);
    }
    return GetStringLeft(sSave, iPosition + i)
            + GetStringRight(sString, GetStringLength(sString) - FindSubString(sString, sSeparator) - 1);
}

string StringGetFirstChar(string sString)
{
    return GetStringLeft(sString, 1);
}

string StringGetSegment(string sString, int iSegment, string sSeparator = DEFAULT_SEPARATOR)
{
    if (FindSubString(sString, sSeparator) == -1)
        return sString;
    int i, iPosition = 0;
    for (i = 0; i < iSegment; i++)
    {
        iPosition = FindSubString(sString, sSeparator);
        sString = GetStringRight(sString, GetStringLength(sString) - FindSubString(sString, sSeparator) - 1);
    }
    return GetStringLeft(sString, FindSubString(sString, sSeparator));
}

string StringSetSegment(string sString, string sSegment, int iSegment, string sSeparator = DEFAULT_SEPARATOR)
{
    if (FindSubString(sString, sSeparator) == -1)
        return sString;
    string sSave = sString;
    int i, iPosition = 0;
    for (i = 0; i < iSegment; i++)
    {
        iPosition = FindSubString(sString, sSeparator);
        sString = StringDeleteChar(sString, iPosition);
    }
    return GetStringLeft(sSave, iPosition + i)
            + sSegment
            + GetStringRight(sString, GetStringLength(sString) - FindSubString(sString, sSeparator));
}
