//==============================================================================
//	Created on: 10/16/2003
//	Description
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamCommandlet extends Commandlet;

event int Main( string Parms )
{
	local string src, match;

	if ( !divide(parms, ";", src, match) )
		return 0;

	log("Source '"$src$"'   Match '"$match$"'");
	log("Result of reverse search is"@ RevInStr(src,match));

	log("");
	chart(src);
	return 0;

}

function chart(string src)
{
	local int i, j, k;
	local string s, t;

	for ( i = 0; i < Len(src); i++ )
	{
		j = i % 10;
		if ( j == 0 )
		{
			k = i / 10;
			t $= k;
		}
		else t $= " ";

		s $= j;
	}

	log(src);
	log(s);
	log(t);
}

function int RevInStr( string src, string match )
{
	local int pos, i;
	local string s;

	if ( src == "" || match == "" )
		return -1;

	s = src;
	i = InStr(s, match);

	do
	{
		pos += i;
		s = Mid(src, pos+1);
		i = InStr(s, match) + 1;
	} until ( i == 0 );

	return pos;
}

defaultproperties
{
}
