//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K4ModFooter extends ButtonFooter;

var automated GUIButton b_Activate, b_Web, b_Download, b_Dump, b_Watch, b_Back, b_Movie;
var UT2K4ModsAndDemos MyPage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController,MyOwner);
    MyPage = UT2K4ModsAndDemos(MyOwner);
}

function bool BackClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

function TabChange(int NewTag)
{
	local int i;
	local GUIButton B;
	for (i=0;i<Components.Length;i++)
	{
		B = GUIButton(Components[i]);
		if ( b!=None && b.Tag>0 )
		{
			if (b.Tag==NewTag)
				b.SetVisibility(true);
			else
				b.SetVisibility(false);
		}
	}

	SetupButtons("true");
}

defaultproperties
{
     Begin Object Class=GUIButton Name=BB1
         Caption="Activate"
         StyleName="FooterButton"
         Hint="Activates the selected mod"
         WinTop=0.085678
         WinLeft=0.885352
         WinWidth=0.120000
         WinHeight=0.036482
         RenderWeight=2.000000
         TabOrder=0
         Tag=1
         bBoundToParent=True
         bVisible=False
         OnKeyEvent=BB1.InternalOnKeyEvent
     End Object
     b_Activate=GUIButton'GUI2K4.UT2K4ModFooter.BB1'

     Begin Object Class=GUIButton Name=BB2
         Caption="Visit Web Site"
         StyleName="FooterButton"
         Hint="Visit the web site of the selected mod"
         WinTop=0.085678
         WinLeft=0.885352
         WinWidth=0.120000
         WinHeight=0.036482
         RenderWeight=2.000100
         TabOrder=1
         Tag=1
         bBoundToParent=True
         bVisible=False
         OnKeyEvent=BB2.InternalOnKeyEvent
     End Object
     b_Web=GUIButton'GUI2K4.UT2K4ModFooter.BB2'

     Begin Object Class=GUIButton Name=BB3
         Caption="Download"
         StyleName="FooterButton"
         Hint="Download the selected Ownage map"
         WinTop=0.085678
         WinLeft=0.885352
         WinWidth=0.120000
         WinHeight=0.036482
         RenderWeight=2.000100
         TabOrder=2
         Tag=2
         bBoundToParent=True
         bVisible=False
         OnKeyEvent=BB3.InternalOnKeyEvent
     End Object
     b_Download=GUIButton'GUI2K4.UT2K4ModFooter.BB3'

     Begin Object Class=GUIButton Name=BB5
         Caption="Create AVI"
         StyleName="FooterButton"
         Hint="Convert the selected demo to a DIVX AVI"
         WinTop=0.085678
         WinWidth=0.120000
         WinHeight=0.036482
         RenderWeight=2.000100
         TabOrder=3
         Tag=3
         bBoundToParent=True
         bVisible=False
         OnKeyEvent=BB5.InternalOnKeyEvent
     End Object
     b_Dump=GUIButton'GUI2K4.UT2K4ModFooter.BB5'

     Begin Object Class=GUIButton Name=BB4
         Caption="Watch Demo"
         StyleName="FooterButton"
         Hint="Watch the selected demo"
         WinTop=0.085678
         WinWidth=0.120000
         WinHeight=0.036482
         RenderWeight=2.000100
         TabOrder=4
         Tag=3
         bBoundToParent=True
         bVisible=False
         OnKeyEvent=BB4.InternalOnKeyEvent
     End Object
     b_Watch=GUIButton'GUI2K4.UT2K4ModFooter.BB4'

     Begin Object Class=GUIButton Name=BackB
         Caption="BACK"
         StyleName="FooterButton"
         Hint="Return to the previous menu"
         WinTop=0.085678
         WinWidth=0.120000
         WinHeight=0.036482
         RenderWeight=2.000200
         TabOrder=3
         Tag=0
         bBoundToParent=True
         OnClick=UT2K4ModFooter.BackClick
         OnKeyEvent=BackB.InternalOnKeyEvent
     End Object
     b_Back=GUIButton'GUI2K4.UT2K4ModFooter.BackB'

     Begin Object Class=GUIButton Name=BB66
         Caption="Play Movie"
         StyleName="FooterButton"
         Hint="Watch the selected movie"
         WinTop=0.085678
         WinWidth=0.120000
         WinHeight=0.036482
         RenderWeight=2.000100
         TabOrder=4
         Tag=4
         bBoundToParent=True
         bVisible=False
         OnKeyEvent=BB66.InternalOnKeyEvent
     End Object
     b_Movie=GUIButton'GUI2K4.UT2K4ModFooter.BB66'

     Padding=0.300000
     Margin=0.010000
     Spacer=0.010000
}
