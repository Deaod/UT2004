//==============================================================================
//	Created on: 09/17/2003
//	Base class for menus which handle custom playinfo properties
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class GUICustomPropertyPage extends LockedFloatingWindow;

// GUIComponent associated with this custom property page
// this will normally be the component that wanted this page opened
// In the case of the playinfo lists, this would be the moButton responsible for tracking this property's value
var() noexport GUIComponent Owner;
var() noexport PlayInfo.PlayInfoData           Item;     // Playinfo property this item is associated with

function SetOwner( GUIComponent NewOwner )
{
	Owner = NewOwner;
}

function GUIComponent GetOwner()
{
	return Owner;
}

function SetReadOnly( bool bValue );
function bool GetReadOnly() { return false; }

function Strip(out string Source, string Char)
{
	if (Source != "" && Char != "")
	{
		if (Left(Source,Len(Char)) == Char)
			Source = Mid(Source, Len(Char));

		if (Right(Source, Len(Char)) == Char)
			Source = Left(Source, Len(Source) - Len(Char));
	}
}


// copied from GameInfo and modified
static function bool GrabOption( string Delim, out string Options, out string Result )
{
	local string s;

	s = Options;
    if( Left(Options,1)==Delim )
        Result = Mid(Options,1);

	if ( !Divide(s, Delim, Result, Options) )
		Result = s;

	return Result != "";
}

//
// Break up a key=value pair into its key and value.
//
static function GetKeyValue( string Pair, out string Key, out string Value )
{
	if ( !Divide(Pair, "=", Key, Value) )
		Key = Pair;
}

/* ParseOption()
 Find an option in the options string and return it.
*/
static function string ParseOption( string Options, string Delim, string InKey )
{
    local string Pair, Key, Value;

    while( GrabOption( Delim, Options, Pair ) )
    {
        GetKeyValue( Pair, Key, Value );
        if( Key ~= InKey )
            return Value;
    }
    return "";
}

defaultproperties
{
}
