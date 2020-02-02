//==============================================================================
//	Loading screen that appears while you are waiting join a server
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4ServerLoading extends UT2K4LoadingPageBase
	config(User);

var() config array<string> Backgrounds;

simulated event Init()
{
    Super.Init();

	SetImage();
	SetText();
}

simulated function SetImage()
{
	local int i, cnt;
	local string str;
	local material mat;

	mat = Material'MenuBlack';
	DrawOpImage(Operations[0]).Image = mat;

	if ( Backgrounds.Length == 0 )
	{
		Warn("No background images configured for"@Name);
		return;
	}

	do
	{
		i = Rand(Backgrounds.Length);
		str = Backgrounds[i];
		if ( str == "" )
			Warn("Invalid value for "$Name$".Backgrounds["$i$"]");

		else mat = DLOTexture(str);
	}

	until (mat != None || ++cnt >= 10);

	if ( mat == None )
		Warn("Unable to find any valid images for vignette class"@name$"!");

	DrawOpImage(Operations[0]).Image = mat;
}

simulated function string StripMap(string s)
{
	local int p;

	p = len(s);
	while (p>0)
	{
		if ( mid(s,p,1) == "." )
		{
			s = left(s,p);
			break;
		}
		else
		 p--;
	}

	p = len(s);
	while (p>0)
	{
		if ( mid(s,p,1) == "\\" || mid(s,p,1) == "/" || mid(s,p,1) == ":" )
			return Right(s,len(s)-p-1);
		else
		 p--;
	}

	return s;
}

simulated function SetText()
{
	local DrawOpText HintOp;
	local string Hint;

	DrawOpText(Operations[2]).Text = StripMap(MapName);

	if (Level.IsSoftwareRendering())
		return;

	HintOp = DrawOpText(Operations[3]);
	if ( HintOp == None )
		return;

	if ( GameClass == None )
	{
		Warn("Invalid game class, so cannot draw loading hint!");
		return;
	}

	Hint = GameClass.static.GetLoadingHint(Level.GetLocalPlayerController(), MapName, HintOp.DrawColor);
	if ( Hint == "" )
	{
		log("No loading hint configured for "@GameClass.Name);
		return;
	}

	HintOp.Text = Hint;
}

defaultproperties
{
     Backgrounds(0)="2k4Menus.Loading.loadingscreen1"
     Backgrounds(1)="2k4Menus.Loading.loadingscreen2"
     Backgrounds(2)="2k4Menus.Loading.loadingscreen2"
     Backgrounds(3)="2k4Menus.Loading.loadingscreen4"
     Operations(0)=DrawOpImage'GUI2K4.UT2K4ServerLoading.OpBackground'
     Operations(1)=DrawOpText'GUI2K4.UT2K4ServerLoading.OpLoading'
     Operations(2)=DrawOpText'GUI2K4.UT2K4ServerLoading.OpMapname'
     Operations(3)=DrawOpText'GUI2K4.UT2K4ServerLoading.OpHint'
}
