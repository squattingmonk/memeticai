/*
    date & time access, construction & transformation +
    clock and calendar advancement

    Author: Lucullo
    Date:   January, 2003
*/

//
// Prototypes
//

// Date

// Get current date in Date format
int     MeGetCurrentDate();
// Build a Date
int     MeDateYMD(int nYear, int nMonth, int nDay);
// Build a Date
int     MeDateMDY(int nMonth, int nDay, int nYear);
// Build a Date
int     MeDateDMY(int nDay, int nMonth, int nYear);
// extract the Year from a Date
int     MeGetYear(int nDate);
// extract the Month from a Date
int     MeGetMonth(int nDate);
// extract the Day from a Date
int     MeGetDay(int nDate);
// build DateInterval from Days
int     MeDays(int nValue);
// build DateInterval from Months
int     MeMonths(int nValue);
// build DateInterval from Years
int     MeYears(int nValue);

// True Time

// Get current TOD in TrueTime format
int     MeGetCurrentTime();
// Build a TrueTime TOD
int     MeTime(int nHour, int nMinute, int nSecond);
// extract the Hour from a TrueTime TOD
int     MeGetHour(int nTime);
// extract the Minute from a TrueTime TOD
int     MeGetMinute(int nTime);
// extract the Second from a TrueTime TOD
int     MeGetSecond(int nTime);
// build TrueTime Interval from Seconds
int     MeSeconds(int nValue);
// build TrueTime Interval from Minutes
int     MeMinutes(int nValue);
// build TrueTime Interval from Hours
int     MeHours(int nValue);
// compute a TrueTime Interval as difference between 2 TODs (and optionally Dates)
// - if one or both Dates are 0 then nTimeEnd is always considered after nTimeStart
//   adding a 24h interval if needed (roll around-the-clock)
// Note: by specifying the dates it is possible to get a negative interval
int     MeInterval(int nTimeStart, int nTimeEnd, int nDateStart=0, int nDateEnd=0);

// Game Time

// Get current TOD in GameTime format
float   MeGetCurrentGameTime();
// Build a GameTime TOD
float   MeGameTime(int nHour, int nMinute, int nSecond, int nMillisecond=0);
// extract the Hour from a GameTime TOD
int     MeGetGameHour(float fGameTime);
// extract the Minute from a GameTime TOD
int     MeGetGameMinute(float fGameTime);
// extract the Second from a GameTime TOD
int     MeGetGameSecond(float fGameTime);
// extract the Millisecond from a GameTime TOD
int     MeGetGameMillisecond(float fGameTime);
// build GameTime Interval from Milliseconds
float   MeGameMilliseconds(int nValue);
// build GameTime Interval from Seconds
float   MeGameSeconds(int nValue);
// build GameTime Interval from Minutes
float   MeGameMinutes(int nValue);
// build GameTime Interval from Hours
float   MeGameHours(int nValue);
// compute a GameTime Interval as difference between 2 TODs (and optionally Dates)
// - if one or both Dates are 0 then fGameTimeEnd is always considered after fGameTimeStart
//   adding a 24h interval if needed (roll around-the-clock)
// Note: by specifying the dates it is possible to get a negative interval
float   MeGameInterval(float fGameTimeStart, float fGameTimeEnd, int nDateStart=0, int nDateEnd=0);

// Mapping

// Transform a TrueTime into a GameTime (linear)
float   MeTimeToGameTime(int nTime);
// Transform a GameTime into a TrueTime (linear)
int     MeGameTimeToTime(float fGameTime);
// Non-linear transformation of a TrueTime duration into a GameTime duration
float   MeGameDuration(int nDuration);
// Non-linear transformation of a GameTime duration into a TrueTime duration
int     MeTimeElapsed(float fGameTimeElapsed);

// Clock and Calendar Advancement

// Set Calendar to a Date (note: if Date is less then Today nothing happens)
void MeSetCalendar(int nDate);
// Advance Calendar a given number of days
void MeAdvanceCalendar(int nDays);
// Set Clock to a new TrueTime Time-of-Day
// note: if Time is less then Now the Calendar is advanced to next day
void MeSetClock(int nTime);
// Advance Clock a given TrueTime Interval (in seconds)
void MeAdvanceClock(int nInterval);
// Set Clock to a new GameTime Time-of-Day
// note: if GameTime is less then Now the Calendar is advanced to next day
void MeSetClockToGameTime(float fGameTime);
// Advance Clock a given GameTime Interval (in seconds)
void MeAdvanceClockByGameInterval(float nGameInterval);


//---- Implementation ----------------------------------------------------------

// Date

int MeGetCurrentDate()
{
 return MeDateYMD(GetCalendarYear(), GetCalendarMonth(), GetCalendarDay());
}

int MeDateYMD(int nYear, int nMonth, int nDay)
{
 nMonth = (nMonth < 1) ? 1 : ((nMonth >    12)  ?    12 : nMonth);
 nDay   = (nDay   < 1) ? 1 : ((nDay   >    28)  ?    28 : nDay);
 nYear  = (nYear  < 0) ? 0 : nYear;
 int    nValue  =  nYear                * 12;   // months
        nValue  = (nValue + nMonth - 1) * 28;   // days
 return nValue  = (nValue + nDay - 1);
}

int MeDateMDY(int nMonth, int nDay, int nYear)
{return MeDateYMD(nYear, nMonth, nDay);}

int MeDateDMY(int nDay, int nMonth, int nYear)
{return MeDateYMD(nYear, nMonth, nDay);}

int MeGetYear(int nDate)    {return nDate / 336;}
int MeGetMonth(int nDate)   {return ((nDate / 28) % 12) + 1;}
int MeGetDay(int nDate)     {return (nDate % 28) + 1;}

int MeDays(int nValue)      {return nValue;}
int MeMonths(int nValue)    {return nValue *  28;}
int MeYears(int nValue)     {return nValue * 336;}  // 28 * 12

// True Time

int MeGetCurrentTime()
{
   return MeGameTimeToTime(MeGetCurrentGameTime());
}

int MeTime(int nHour, int nMinute, int nSecond)
{
 nHour      = (nHour < 0)   ? 0 : nHour;
 nMinute    = (nMinute < 0) ? 0 : nMinute;
 nSecond    = (nSecond < 0) ? 0 : nSecond;
 return ((nHour * 3600) + (nMinute * 60) + nSecond) % 86400;  // 3600 * 24
}

int MeGetHour(int nTime)    {return nTime / 3600;}
int MeGetMinute(int nTime)  {return (nTime / 60) % 60;}
int MeGetSecond(int nTime)  {return nTime  % 60;}

int MeSeconds(int nValue)   {return nValue        ;}
int MeMinutes(int nValue)   {return nValue  *   60;}
int MeHours(int nValue)     {return nValue  * 3600;}

int MeInterval(int nTimeStart, int nTimeEnd, int nDateStart=0, int nDateEnd=0)
{
    int nResult = nTimeEnd - nTimeStart;
    if (nDateStart && nDateEnd)             // both dates given
    {
        nResult += (nDateEnd - nDateStart) * 86400;  // add n days
    }
    else if (nResult < 1)
        nResult += 86400;                   // add one day
    return nResult;
}

// Game Time

float MeGetCurrentGameTime()
{
 return ((GetTimeHour()   * HoursToSeconds(1)) +
         (GetTimeMinute() * 60) +
          GetTimeSecond() +
         (IntToFloat(GetTimeMillisecond()) / 1000));
}

float MeGameTime(int nHour, int nMinute, int nSecond, int nMillisecond=0)
{
 nHour      = (nHour < 0)   ? 0 : nHour;
 nMinute    = (nMinute < 0) ? 0 : nMinute;
 nSecond    = (nSecond < 0) ? 0 : nSecond;
 return ((nHour   * HoursToSeconds(1)) +
         (nMinute * 60) +
          nSecond +
         (IntToFloat(nMillisecond) / 1000));
}

int MeGetGameHour(float fGameTime)
    {return FloatToInt(fGameTime / HoursToSeconds(1));}
int MeGetGameMinute(float fGameTime)
    {return (FloatToInt(fGameTime) / 60) % (FloatToInt(HoursToSeconds(1)) / 60);}
int MeGetGameSecond(float fGameTime)
    {return FloatToInt(fGameTime)  % 60;}
int MeGetGameMillisecond(float fGameTime)
    {return FloatToInt(fGameTime * 1000)  % 1000;}

float MeGameMilliseconds(int nValue)
    {return IntToFloat(nValue) / 1000;}
float MeGameSeconds(int nValue)
    {return IntToFloat(nValue);}
float MeGameMinutes(int nValue)
    {return IntToFloat(nValue) * 60.0f;}
float MeGameHours(int nValue)
    {return HoursToSeconds(nValue);}

float   MeGameInterval(float fGameTimeStart, float fGameTimeEnd, int nDateStart=0, int nDateEnd=0)
{
    float fResult = fGameTimeEnd - fGameTimeStart;
    if (nDateStart && nDateEnd)             // both dates given
    {
        fResult += MeGameHours((nDateEnd - nDateStart) * 24);  // add n days
    }
    else if (fResult <= 0.0f )
        fResult += MeGameHours(24);                // add one day
    return fResult;
}


// Mapping

float MeTimeToGameTime(int nTime)
    {return (nTime * HoursToSeconds(1)) / 3600;}
//    {return IntToFloat(FloatToInt(nTime * HoursToSeconds(1)) / 3600);}

int MeGameTimeToTime(float fGameTime)
    {return FloatToInt(fGameTime * 3600 / HoursToSeconds(1));}

float MeGameDuration(int nDuration)
{
 if (nDuration >= 3600)
    return MeTimeToGameTime(nDuration);
 float fFactor = GetLocalFloat(GetModule(), "MEME_TimeAdjustFactor");
 if (fFactor == 0.0f)
    {                   // compute adjust factor
     fFactor = log(HoursToSeconds(1)) / log(3600.0f);
     SetLocalFloat(GetModule(), "MEME_TimeAdjustFactor", fFactor);
    }
 return pow(IntToFloat(nDuration), fFactor);
}

int MeTimeElapsed(float fGameTimeElapsed)
{
 if (fGameTimeElapsed >= HoursToSeconds(1))
    return MeGameTimeToTime(fGameTimeElapsed);
 float fFactor = GetLocalFloat(GetModule(), "MEME_TimeReverseFactor");
 if (fFactor == 0.0f)
    {                   // compute reverse factor
     fFactor = log(3600.0f) / log(HoursToSeconds(1));
     SetLocalFloat(GetModule(), "MEME_TimeReverseFactor", fFactor);
    }
 return FloatToInt(pow(fGameTimeElapsed, fFactor));
}

// Clock and Calendar Advancement

void MeSetCalendar(int nDate)
    {SetCalendar(MeGetYear(nDate), MeGetMonth(nDate), MeGetDay(nDate));}

void MeAdvanceCalendar(int nDays)
    {MeSetCalendar(MeGetCurrentDate() + nDays);}

void MeSetClock(int nTime)
    {MeSetClockToGameTime(MeTimeToGameTime(nTime));}

void MeAdvanceClock(int nInterval)
    {MeAdvanceClockByGameInterval(MeTimeToGameTime(nInterval));}

void MeSetClockToGameTime(float fGameTime)
{
    SetTime(MeGetGameHour(fGameTime),
            MeGetGameMinute(fGameTime),
            MeGetGameSecond(fGameTime),
            MeGetGameMillisecond(fGameTime));
}

void MeAdvanceClockByGameInterval(float nGameInterval)
    {MeSetClockToGameTime(MeGetCurrentGameTime() + nGameInterval);}

