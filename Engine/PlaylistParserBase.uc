//==============================================================================
//  Created on: 10/27/2003
//  Base class for external playlist parsers
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class PlaylistParserBase extends StreamInterface
	within StreamPlaylistManager;

var private EStreamPlaylistType Type;
var string PlaylistName;
var array<string> Paths;
var array<string> Lines;

// Characters which aren't rendered correctly in HTML
struct HtmlChar
{
	var string Plain;
	var string Coded;
};
var array<HtmlChar> SpecialChars;

function EStreamPlaylistType GetType()
{
	return Type;
}

function SetType( EStreamPlaylistType InType )
{
	if ( Type != SPT_None )
		return;

	Type = InType;
}

function bool Import( int PlaylistIndex, int InsertPosition, string Path )
{
	if ( FileManager.LoadPlaylist( Path, Lines ) )
	{
		ImportedPlaylist( PlaylistIndex, InsertPosition );
		return true;
	}

	return false;
}

function ImportedPlaylist( int PlaylistIndex, int InsertPosition )
{
	local StreamPlaylist Playlist;
	local int i;

	ParseLines();
	if ( !ValidIndex(PlaylistIndex) )
		PlaylistIndex = AddPlaylist(PlaylistName);

	Playlist = Playlists[PlaylistIndex];
	if ( !Playlist.ValidStreamIndex(InsertPosition) )
		InsertPosition = Playlist.GetPlaylistLength();

	for ( i = Paths.Length - 1; i >= 0; i-- )
		InsertInPlaylist(PlaylistIndex, InsertPosition, Paths[i], i > 0);

	Save();
}

function ParseLines()
{
	Paths.Remove(0, Paths.Length);
}

static function string GetValue( string KeyValuePair, optional bool bAllowSpaces )
{
	local int i;
	local string str;

	i = InStr(KeyValuePair, "=");
	if ( i != -1 )
	{
		str = Mid(KeyValuePair, i+1);
		if ( Left(str,1) == "\"" )
		{
			str = Mid(str,1);
			i = RevInStr(str,"\"");
			if ( i != -1 )
				str = Left(str,i);

			return str;
		}

		i = InStr(str," ");
		if ( i != -1 && !bAllowSpaces )
			str = Left(str,i);

		return str;
	}

	return "";
}

static function string GetTagged( out string Text )
{
	local string Tag;
	local int opos, cpos;

	opos = InStr(Text, "<");
	if ( opos != -1 )
	{
		Text = Mid(Text,opos+1);
		cpos = InStr(Text, ">");
		if ( cpos == -1 )
			return"";

		Tag = Left(Text, cpos);
		Text = Mid(Text, cpos+1);
		opos = InStr( Locs(Text), "</" $ Locs(Tag) $ ">" );
		if ( opos == -1 )
			return Tag;

		Text = Left(Text, opos);
		return Tag;
	}

	return "";
}

// Replaces any occurences of HTML coded characters with their text representations
static function string HtmlDecode(string src)
{
	local int i;

	for (i = 0; i < default.SpecialChars.Length; i++)
		src = Repl(src, default.SpecialChars[i].Coded, default.SpecialChars[i].Plain);

	return src;
}

defaultproperties
{
     SpecialChars(0)=(Plain="&",Coded="&amp;")
     SpecialChars(1)=(Plain=""",Coded="&quot;")
     SpecialChars(2)=(Plain=" ",Coded="&nbsp;")
     SpecialChars(3)=(Plain="<",Coded="&lt;")
     SpecialChars(4)=(Plain=">",Coded="&gt;")
     SpecialChars(5)=(Plain="©",Coded="&copy;")
     SpecialChars(6)=(Plain="™",Coded="&#8482;")
     SpecialChars(7)=(Plain="®",Coded="&reg;")
     SpecialChars(8)=(Plain="'",Coded="&apos;")
}
