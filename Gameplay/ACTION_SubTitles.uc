class ACTION_SubTitles extends ScriptedAction;

var()	SceneSubtitles.ESST_Mode SubTitleMode;

function bool InitActionFor(ScriptedController C)
{
	C.Level.GetLocalPlayerController().myHUD.SubTitles.ProcessEvent( SubTitleMode );
	return false;	
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
     ActionString="SubTitles"
}
