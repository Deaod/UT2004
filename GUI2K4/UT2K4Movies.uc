//-----------------------------------------------------------
//
//-----------------------------------------------------------
class UT2K4Movies extends ModsAndDemosTabs;

var automated GUISectionBackground sb_Maps, sb_Preview;
var automated AltSectionBackground sb_Scroll;

var automated GUIScrollTextBox  lb_MapDesc;
var automated GUIListBox   		lb_Maps;
var automated GUIImage          i_MapPreview;
var automated GUILabel          l_MapAuthor,  l_NoPreview;

var array<CacheManager.MapRecord> Maps;

struct DefItem
{
	var localized string MapName;
	var localized string Title;
    var localized string Author;
};

var array<DefItem> DefaultItems;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	Super.InitComponent(MyController,MyOwner);

	for (i=0;i<DefaultItems.Length;i++)
		lb_Maps.List.Add(DefaultItems[i].title,,""$((i+1)*-1));

	class'CacheManager'.static.GetMapList(Maps,"MOV");
	for (i=0;i<Maps.Length;i++)
	{
		if ( !DefaultMovie(Maps[i].MapName) )
		{
			lb_Maps.List.Add(Maps[i].FriendlyName,,""$i);
		}
	}

	sb_Maps.ManageComponent(lb_Maps);
	sb_Scroll.ManageComponent(lb_MapDesc);


	lb_Maps.OnChange=MapListChange;
	MapListChange(lb_Maps);

	MyPage.MyFooter.b_Movie.OnClick = MovieClick;

}


function bool DefaultMovie(string Mov)
{
	local int i;
	for (i=0;i<DefaultItems.Length;i++)
		if (DefaultItems[i].MapName ~= mov)
			return true;

	return false;
}

function string GetMovieInfo(string Index,string prop)
{
	local int i;
	i = int(Index);

	if (i>=0)
	{
		if (prop=="author")
			return Maps[i].Author;
		if (prop=="desc")
			return Maps[i].Description;
		if (prop=="map")
			return Maps[i].MapName;
		if (prop=="screen")
			return Maps[i].ScreenshotRef;
	}
	else
	{
		i = abs(i);
		if (prop=="author")
			return DefaultItems[i-1].Author;
		if (prop=="desc")
			return DefaultItems[i-1].Title$".";
		if (prop=="map")
			return DefaultItems[i-1].MapName;
	}
	return "";
}

function MapListChange(GUIComponent Sender)
{
	l_MapAuthor.Caption = GetMovieInfo(lb_Maps.List.GetExtra(),"author");
	lb_MapDesc.SetContent(GetMovieInfo(lb_Maps.List.GetExtra(),"desc"));
	UpdateScreenshot( GetMovieInfo(lb_Maps.List.GetExtra(),"screen") );
}

function UpdateScreenshot(string ScreenShotRef)
{
	local Material Screenie;

    Screenie = Material(DynamicLoadObject(ScreenshotRef, class'Material'));
    i_MapPreview.Image = Screenie;
    l_NoPreview.SetVisibility( Screenie == none );
    i_MapPreview.SetVisibility( Screenie != None );
}


function bool MovieClick(GUIComponent Sender)
{
	Console(Controller.Master.Console).DelayedConsoleCommand("open"@GetMovieInfo(lb_Maps.List.GetExtra(),"map")$"?game=");
    return true;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=sbMaps
         bFillClient=True
         Caption="Movie Selection"
         WinTop=0.018125
         WinLeft=0.016993
         WinWidth=0.482149
         WinHeight=0.523611
         OnPreDraw=sbMaps.InternalPreDraw
     End Object
     sb_Maps=GUISectionBackground'GUI2K4.UT2K4Movies.sbMaps'

     Begin Object Class=GUISectionBackground Name=sbPreview
         bFillClient=True
         Caption="Preview"
         WinTop=0.018125
         WinLeft=0.515743
         WinWidth=0.470899
         WinHeight=0.527876
         OnPreDraw=sbPreview.InternalPreDraw
     End Object
     sb_Preview=GUISectionBackground'GUI2K4.UT2K4Movies.sbPreview'

     Begin Object Class=AltSectionBackground Name=sbScroll
         bFillClient=True
         Caption="Movie Description"
         WinTop=0.561207
         WinLeft=0.019970
         WinWidth=0.967924
         WinHeight=0.421870
         OnPreDraw=sbScroll.InternalPreDraw
     End Object
     sb_Scroll=AltSectionBackground'GUI2K4.UT2K4Movies.sbScroll'

     Begin Object Class=GUIScrollTextBox Name=lbMapDesc
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=lbMapDesc.InternalOnCreateComponent
         WinTop=0.628421
         WinLeft=0.561065
         WinWidth=0.379993
         WinHeight=0.268410
         bTabStop=False
         bNeverFocus=True
     End Object
     lb_MapDesc=GUIScrollTextBox'GUI2K4.UT2K4Movies.lbMapDesc'

     Begin Object Class=GUIListBox Name=lbMaps
         bVisibleWhenEmpty=True
         OnCreateComponent=lbMaps.InternalOnCreateComponent
         Hint="Click a movie to see a preview and description.  Double-click to view it."
         WinTop=0.169272
         WinLeft=0.045671
         WinWidth=0.422481
         WinHeight=0.449870
         TabOrder=0
     End Object
     lb_Maps=GUIListBox'GUI2K4.UT2K4Movies.lbMaps'

     Begin Object Class=GUIImage Name=iMapPreview
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.107691
         WinLeft=0.562668
         WinWidth=0.372002
         WinHeight=0.357480
         RenderWeight=0.200000
     End Object
     i_MapPreview=GUIImage'GUI2K4.UT2K4Movies.iMapPreview'

     Begin Object Class=GUILabel Name=MapAuthorLabel
         TextAlign=TXTA_Center
         StyleName="TextLabel"
         WinTop=0.467658
         WinLeft=0.538209
         WinWidth=0.426180
         WinHeight=0.032552
         RenderWeight=0.300000
     End Object
     l_MapAuthor=GUILabel'GUI2K4.UT2K4Movies.MapAuthorLabel'

     Begin Object Class=GUILabel Name=lNoPreview
         Caption="No Preview Available"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=247)
         TextFont="UT2HeaderFont"
         bTransparent=False
         bMultiLine=True
         VertAlign=TXTA_Center
         WinTop=0.107691
         WinLeft=0.562668
         WinWidth=0.372002
         WinHeight=0.357480
     End Object
     l_NoPreview=GUILabel'GUI2K4.UT2K4Movies.lNoPreview'

     DefaultItems(0)=(MapName="MOV-UT2004-Intro",Title="UT2004 Single Player Introduction Movie",Author="Epic Games")
     DefaultItems(1)=(MapName="MOV-UT2-Intro",Title="UT2003 Single Player Introduction Movie",Author="Epic Games")
     DefaultItems(2)=(MapName="TUT-BR",Title="Bombing Run Tutorial",Author="Epic Games")
     DefaultItems(3)=(MapName="TUT-CTF",Title="Capture the Flag Tutorial",Author="Epic Games")
     DefaultItems(4)=(MapName="TUT-DM",Title="Deathmatch Tutorial",Author="Epic Games")
     DefaultItems(5)=(MapName="TUT-DOM",Title="Double Domination Tutorial",Author="Epic Games")
     DefaultItems(6)=(MapName="TUT-ONS",Title="Onslaught Tutorial",Author="Epic Games")
     Tag=4
}
