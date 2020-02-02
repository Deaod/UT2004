//==============================================================================
//	Created on: 10/12/2003
//	Standard ID3 Tag
//  Contains Artist, Title, Album, Lyrics, etc.
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class StreamTag extends StreamBase within Stream
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


// shortcuts
var() const editconst ID3Field TagID;
var() const editconst ID3Field TrackNumber;
var() const editconst ID3Field Title;
var() const editconst ID3Field Artist;
var() const editconst ID3Field Album;
var() const editconst ID3Field Year;
var() const editconst ID3Field Genre;
var()       editconst ID3Field Duration;	// in milliseconds

var() const editconst editconstarray array<ID3Field> Fields;
var private pointer NativeID3Tag[2];

delegate OnRefresh();

function DumpScriptTag()
{
	local int i;

	log("================");
	log("      TagID:"$TagID.FieldName@"#"@TagID.FieldValue);
	log("TrackNumber:"$TrackNumber.FieldName@"#"@TrackNumber.FieldValue);
	log("      Title:"$Title.FieldName@"#"@Title.FieldValue);
	log("     Artist:"$Artist.FieldName@"#"@Artist.FieldValue);
	log("      Album:"$Album.FieldName@"#"@Album.FieldValue);
	log("       Year:"$Year.FieldName@"#"@Year.FieldValue);
	log("      Genre:"$Genre.FieldName@"#"@Genre.FieldValue);
	log("   Duration:"$Duration.FieldName@"#"@Duration.FieldValue);
	log("  == All Fields == ");
	for ( i = 0; i < Fields.Length; i++ )
	{
		log("    "$i$") ID:"$Fields[i].FieldID@"Name:"$Fields[i].FieldName@"Value:"$Fields[i].FieldValue);
	}

	log("");
}

native final function DumpTag();

defaultproperties
{
}
