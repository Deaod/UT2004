class VignetteTest extends TestPageBase;

// Very simple testing
var UT2SP_LadderLoading	Vig;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	Vig=PlayerOwner().Spawn(class'UT2SP_LadderLoading');
	if (Vig != None)
	{
		Log("Vignette Created");
		Vig.Init();
		OnDraw = MyOnDraw;
		SetTimer(60, false);
		return;
	}
	// Failed
	Controller.CloseMenu();
}

event Timer()
{
	Controller.CloseMenu();
}

function MyOnClose(optional bool bCancelled)
{
	if (Vig != None)
	{
		Log("Destroying the Vignette");
		Vig.Destroy();
	}
}

function bool MyOnDraw(Canvas Canvas)
{
//	Log("In My Own Draw");
	Vig.DrawVignette(Canvas, 1.0f);
	return true;
}

defaultproperties
{
     StyleName="Page"
     WinHeight=1.000000
}
