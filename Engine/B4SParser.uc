//==============================================================================
//  Created on: 10/27/2003
//  Specialized parser for WinAmp B4U playlists
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class B4SParser extends PlaylistParserBase;

function ParseLines()
{
	local int i, pos;
	local string Str;

	Super.ParseLines();
	if ( Lines.Length == 0 )
		return;

	for ( i = 0; i < Lines.Length; i++ )
	{
		if ( InStr(Lines[i], "</playlist>") != -1 || Lines[i] == "" )
			break;

		if ( PlaylistName == "" )
		{
			pos = InStr(Lines[i], "num_entries");
			if ( pos == -1 )
				continue;

			pos = InStr(Lines[i], "label");
			if ( pos == -1 )
			{
				PlaylistName = DefaultPlaylistName;
				continue;
			}

			PlaylistName = GetValue(Mid(Lines[i], pos));
			continue;
		}

		if ( InStr(Lines[i], "<entry ") != -1 )
		{
			Str = GetValue(Lines[i]);
			if ( Str == "" || Left(Str,5) != "file:" )
				continue;

			Paths[Paths.Length] = HtmlDecode(Mid(Str, 5));
			continue;
		}
	}
}

defaultproperties
{
}
