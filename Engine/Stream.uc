//==============================================================================
//	Created on: 10/12/2003
//	A single music file
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class Stream extends StreamBase
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() editconst protected                  int             Handle;
var() editconst private   const            string          DefaultExtension; // What to use if no extension specified
var() editconst protected const editinline StreamTag       IDTag;
var() editconst private   const editinline FilePath        PathName;
var() editconst private   const            EFileType       Type;           // Type of file (mp3, wav, ogg)
var() editconst           const bool                       bReadOnly;      // Whether this stream is read-only (cannot be deleted)

native final function bool   SaveID3Tag(); // not yet implemented
native final function bool   LoadID3Tag();

function bool            IsReadOnly()  { return bReadOnly; }
function int             GetHandle()   { return Handle;    }
function StreamTag       GetTag()      { return IDTag;     }
function EFileType GetType()           { return Type;      }

function string          GetDirectory()  { return PathName.Directory;                   }
function string          GetFileName()   { return PathName.FileName;                    }
function string          GetExtension()  { return PathName.Extension;                   }
function string          GetPath()       { return PathName.FullPath;                    }
function string          GetFullName()   { return GetFileName() $ "." $ GetExtension(); }


function string GetSongTitle()
{
	if ( IDTag == None || IDTag.Title.FieldValue == "" )
		return GetFileName();

	return IDTag.Title.FieldValue;
}

event bool SetHandle( int NewHandle )
{
	Handle = NewHandle;
	return true;
}

function DumpScriptTag()
{
	IDTag.DumpScriptTag();
}

function DumpTags()
{
	IDTag.DumpTag();
}

defaultproperties
{
     Handle=-1
     DefaultExtension="mp3"
}
