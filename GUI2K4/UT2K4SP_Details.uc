//==============================================================================
// Tournament details
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class UT2K4SP_Details extends UT2K4MainPage config;

var automated GUIButton	btnClose, btnExport;
var automated moCheckBox cbAlwaysShow;

var localized string PageCaption, ProfileExported;

/** profile exporter to use */
var globalconfig string ProfileExporter;

var UT2K4GameProfile GP;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local UT2K4SPTab_DetailEnemies detab;
	Super.Initcomponent(MyController, MyOwner);
	GP = UT2K4GameProfile(PlayerOwner().Level.Game.CurrentGameProfile);
	t_Header.SetCaption(PageCaption);
	c_Tabs.AddTab(PanelCaption[0], PanelClass[0], , PanelHint[0], true); // last match
	if (GP.PhantomMatches.length > 0) c_Tabs.AddTab(PanelCaption[2], PanelClass[2], , PanelHint[2], false); // phantom
	detab = UT2K4SPTab_DetailEnemies(c_Tabs.AddTab(PanelCaption[1], PanelClass[1], , PanelHint[1], false)); // enemies
	if (detab.TeamStats.length == 0) c_Tabs.RemoveTab(, detab.MyButton);

	cbAlwaysShow.Checked(GP.bShowDetails);
}

function bool InternalOnPreDraw(Canvas Canvas)
{
	local float XL,YL;
	btnExport.Style.TextSize(Canvas, btnExport.MenuState, btnExport.Caption, XL, YL, btnExport.FontScale);

	// Automatically size the buttons based on the size of their captions
	btnClose.WinWidth = XL+32;
	btnClose.WinLeft = Canvas.ClipX-btnClose.WinWidth;
	btnExport.WinWidth = XL+32;
	btnExport.WinLeft = btnClose.WinLeft-btnExport.WinWidth;
	return false;
}

function bool btnCloseOnClick(GUIComponent Sender)
{
	return Controller.CloseMenu(true);
}

/**	Clicked a TabButton */
function InternalOnChange(GUIComponent Sender)
{
	if (GUITabButton(Sender)==none)	return;
	t_Header.SetCaption(PageCaption@"|"@GUITabButton(Sender).Caption);
}

function cbAlwaysShowOnChange(GUIComponent Sender)
{
	GP.bShowDetails = cbAlwaysShow.IsChecked();
	return;
}

function bool btnExportOnClick(GUIComponent Sender)
{
	local GUIQuestionPage QPage;
	local class<SPProfileExporter> expclass;
	local SPProfileExporter exporter;

	expclass = class<SPProfileExporter>(DynamicLoadObject(ProfileExporter, class'Class'));
	if (expclass == none)
	{
		Warn("Invalid profile exporter:"@ProfileExporter);
		return true;
	}

	exporter = new expclass;
	exporter.Create(GP, PlayerOwner().Level);
	exporter.ExportProfile();
	if (Controller.OpenMenu(Controller.QuestionMenuClass))
	{
		QPage=GUIQuestionPage(Controller.TopPage());
		QPage.SetupQuestion(QPage.Replace(ProfileExported, "%filename%", exporter.ResultFile), QBTN_Ok);
	}
	return true;
}

function OnDetailClose(optional bool bCanceled)
{
	local UT2K4SP_Main main;
	main = UT2K4SP_Main(Controller.FindMenuByClass(class'UT2K4SP_Main'));
//	main = UT2K4SP_Main(Controller.MenuStack[Controller.MenuStack.length-2]);
	if (main != none)
	{
		if (main.c_Tabs.PendingTab == none) main.c_Tabs.ActiveTab.MyPanel.ShowPanel(true);
	}
}

defaultproperties
{
     Begin Object Class=GUIButton Name=SPDbtnClose
         Caption="CLOSE"
         StyleName="FooterButton"
         Hint="Return to the ladder"
         WinTop=0.959479
         WinWidth=0.120000
         WinHeight=0.040703
         RenderWeight=1.000000
         TabOrder=0
         bBoundToParent=True
         OnClick=UT2K4SP_Details.btnCloseOnClick
         OnKeyEvent=SPDbtnClose.InternalOnKeyEvent
     End Object
     btnClose=GUIButton'GUI2K4.UT2K4SP_Details.SPDbtnClose'

     Begin Object Class=GUIButton Name=SPDbtnExport
         Caption="EXPORT"
         StyleName="FooterButton"
         Hint="Export the details to a file"
         WinTop=0.959479
         WinLeft=0.880000
         WinWidth=0.120000
         WinHeight=0.040703
         RenderWeight=1.000000
         TabOrder=1
         bBoundToParent=True
         OnClick=UT2K4SP_Details.btnExportOnClick
         OnKeyEvent=SPDbtnExport.InternalOnKeyEvent
     End Object
     btnExport=GUIButton'GUI2K4.UT2K4SP_Details.SPDbtnExport'

     Begin Object Class=moCheckBox Name=SPDcbAlwaysShow
         Caption="Show after a match"
         OnCreateComponent=SPDcbAlwaysShow.InternalOnCreateComponent
         WinTop=0.966146
         WinLeft=0.006250
         WinWidth=0.289063
         RenderWeight=1.000000
         TabOrder=2
         OnChange=UT2K4SP_Details.cbAlwaysShowOnChange
     End Object
     cbAlwaysShow=moCheckBox'GUI2K4.UT2K4SP_Details.SPDcbAlwaysShow'

     PageCaption="Tournament details"
     ProfileExported="Profile details exported to:|%filename%"
     ProfileExporter="GUI2K4.SPProfileExporter"
     Begin Object Class=GUIHeader Name=SPDhdrHeader
         RenderWeight=0.300000
     End Object
     t_Header=GUIHeader'GUI2K4.UT2K4SP_Details.SPDhdrHeader'

     Begin Object Class=ButtonFooter Name=SPDftrFooter
         RenderWeight=0.300000
         OnPreDraw=SPDftrFooter.InternalOnPreDraw
     End Object
     t_Footer=ButtonFooter'GUI2K4.UT2K4SP_Details.SPDftrFooter'

     PanelClass(0)="GUI2K4.UT2K4SPTab_DetailMatch"
     PanelClass(1)="GUI2K4.UT2K4SPTab_DetailEnemies"
     PanelClass(2)="GUI2K4.UT2K4SPTab_DetailPhantom"
     PanelCaption(0)="Last Match Played"
     PanelCaption(1)="Opponent Teams"
     PanelCaption(2)="Other Tournament Matches"
     PanelHint(0)="Overview of the last match played"
     PanelHint(1)="Overview of the teams you've played against"
     PanelHint(2)="Overview of matches played by other teams"
     bPersistent=False
     OnClose=UT2K4SP_Details.OnDetailClose
     bDrawFocusedLast=False
     OnPreDraw=UT2K4SP_Details.InternalOnPreDraw
}
