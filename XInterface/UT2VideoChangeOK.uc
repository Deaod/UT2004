// ====================================================================
//  Class:  XInterface.UT2VideoChangeOK
//  Parent: XInterface.GUIPage
//
//  <Enter a description here>
// ====================================================================

class UT2VideoChangeOK extends UT2K3GUIPage;

var		Int 		Count;
var		string		OrigRes;

var localized string	RestoreTextPre,
						RestoreTextPost,
						RestoreTextSingular;

event Timer()
{
	Count--;
	if (Count>1)
		GUILabel(Controls[4]).Caption = RestoreTextPre$Count$RestoreTextPost;
	else
		GUILabel(Controls[4]).Caption = RestoreTextSingular;

	if (Count<=0)
	{
		SetTimer(0);

		// Reset resolution here

		PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice Use16bit"@(InStr(OrigRes,"x16")!=-1));
		PlayerOwner().ConsoleCommand("setres"@OrigRes);

		Controller.CloseMenu(True);
	}
}

function Execute(string DesiredRes)
{
	local string res,bit,x,y;
	local int i;

	if (DesiredRes=="")
		return;

	res	= Controller.GetCurrentRes();
	bit = PlayerOwner().ConsoleCommand("get ini:Engine.Engine.RenderDevice Use16bit");

	if (bit=="true")
		OrigRes=res$"x16";
	else
		OrigRes=res$"x32";

	if(bool(PlayerOwner().ConsoleCommand("ISFULLSCREEN")))
		OrigRes=OrigRes$"f";
	else
		OrigRes=OrigRes$"w";

	PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice Use16bit"@(InStr(DesiredRes,"x16") != -1));
	PlayerOwner().ConsoleCommand("setres"@DesiredRes);

	i = Instr(DesiredRes,"x");
	x = left(DesiredRes,i);
	y = mid(DesiredRes,i+1);

	if( (int(x)<640) || (int(y)<480) )
	{
		PlayerOwner().ConsoleCommand("tempsetres 640x480");
		SetTimer(0,false);
		Controller.ReplaceMenu("xinterface.UT2DeferChangeRes");
		Controller.GameResolution = Left(DesiredRes,Len(DesiredRes) - 4);
	}
	else
		Controller.GameResolution = "";
}


function StartTimer()
{
	Count=15;
	SetTimer(1.0,true);
}

function bool InternalOnClick(GUIComponent Sender)
{
	SetTimer(0);
	if (Sender==Controls[2])
	{
		PlayerOwner().ConsoleCommand("set ini:Engine.Engine.RenderDevice Use16bit"@(InStr(OrigRes,"x16")!=-1));
		PlayerOwner().ConsoleCommand("setres"@OrigRes);
	}

	GUILabel(Controls[3]).Caption="Accept these settings?";
	Controller.CloseMenu(Sender == Controls[2]);

	return true;
}

defaultproperties
{
     RestoreTextPre="(Original settings will be restored in "
     RestoreTextPost=" seconds)"
     RestoreTextSingular="(Original settings will be restored in 1 second)"
     InactiveFadeColor=(B=128,G=128,R=128)
     Begin Object Class=GUIButton Name=VidOKBackground
         StyleName="SquareBar"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=VidOKBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2VideoChangeOK.VidOKBackground'

     Begin Object Class=GUIButton Name=AcceptButton
         Caption="Keep Settings"
         WinTop=0.750000
         WinLeft=0.125000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2VideoChangeOK.InternalOnClick
         OnKeyEvent=AcceptButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.UT2VideoChangeOK.AcceptButton'

     Begin Object Class=GUIButton Name=BackButton
         Caption="Restore Settings"
         WinTop=0.750000
         WinLeft=0.650000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2VideoChangeOK.InternalOnClick
         OnKeyEvent=BackButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.UT2VideoChangeOK.BackButton'

     Begin Object Class=GUILabel Name=VideoOKDesc
         Caption="Accept these settings?"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.UT2VideoChangeOK.VideoOKDesc'

     Begin Object Class=GUILabel Name=VideoOkTimerDesc
         Caption="(Original settings will be restored in 15 seconds)"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         WinTop=0.460000
         WinHeight=32.000000
     End Object
     Controls(4)=GUILabel'XInterface.UT2VideoChangeOK.VideoOkTimerDesc'

     WinTop=0.375000
     WinHeight=0.250000
     OnActivate=UT2VideoChangeOK.StartTimer
}
