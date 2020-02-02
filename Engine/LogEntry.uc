//=============================================================================
// LogEntry.
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================
class LogEntry extends Object native;

var() config string DateTime;
var() config string Entry;

// hot hot list
var() LogEntry      Next;

simulated function Insert( LogEntry newLE )
{
    local LogEntry cur;

    if ( Next == None )
        Next = newLE;
    else
    {
        cur = Next;
        while( cur.Next != None )
        {
            cur = cur.Next;
        }
        cur.Next = newLE;
    }
}

simulated function LogEntry Delete( LogEntry delLE )
{
    local LogEntry head;
    local LogEntry prev;
    local LogEntry cur;

    head = self;

    if ( self == delLe )
    {
        head = Next;
    }
    else
    {
        prev = self;
        cur = Next;

        while( cur != delLE )
        {
            prev = cur;
            cur = cur.Next;
        }
        prev.Next = cur.Next;
    }

    //delete delLE;

    return head;
}

simulated function int Count()
{
    local int num;
    local LogEntry le;

    le = self;
    num = 0;

    while ( le != None )
    {
        num++;
        le = le.Next;
    }
    return num;
}

defaultproperties
{
     DateTime="No Date/Time specified."
     Entry="No Data."
}
