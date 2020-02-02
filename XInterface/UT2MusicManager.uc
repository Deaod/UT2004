// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2MusicManager extends GUIPage;

struct PlayListStruct
{
	var	config bool			bRepeat;
    var	config bool			bShuffle;
    var config String		Current;
    var config array<string>	Songs;
};

var config PlayListStruct PlayList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	ExtendedConsole(Controller.Master.Console).MusicManager = Self;
}

function SetMusic(string NewSong)
{
	PlayList.Current = NewSong;
}

function String SetInitialMusic(string NewSong)
{
	local int i;
	if (PlayList.Songs.Length==0)
		return NewSong;

    for (i=0;i<PlayList.Songs.Length;i++)
    	if (PlayList.Songs[i]~=NewSong)
        	return NewSong;

    if (PlayList.Current=="")
    	return PlayList.Songs[0];

   	return PlayList.Current;
}


function MusicChanged()
{
	local int i,index;

	if (PlayList.Songs.Length==0)	// Nothing in play list, loop current
    	return;

	if (PlayList.bShuffle)
    {
    	i = rand(PlayList.Songs.Length);
        PlayerOwner().ClientSetMusic(PlayList.Songs[i],MTRAN_Fade);
	}
    else
    {
		Index=-1;
		for (i=0;i<PlayList.Songs.Length;i++)
        {
        	if (PlayList.Songs[i] ~= PlayList.Current)
				Index = i;
        }

       	Index++;
        if (Index==PlayList.Songs.Length && PlayList.bRepeat)
	       	Index = 0;

		PlayerOwner().ClientSetMusic(PlayList.Songs[index],MTRAN_Fade);
    }
}

function bool NotifyLevelChange()
{
	return false;
}

defaultproperties
{
     bPersistent=True
}
