// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2K4UserMods extends ModsAndDemosTabs;

var automated GUISectionBackground sb_1, sb_2, sb_3;
var automated GUIListBox lb_ModList;
var automated GUIScrollTextBox lb_ModInfo;
var automated GUIImage i_ModLogo;

var localized string NoModsListText;
var localized string NoModsInfoText;

var array<class> ModClasses;

var bool bInitialized;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    lb_ModList.List.Clear();
    LoadUserMods();
    bInitialized = true;
	ModListChange(none);

	sb_1.ManageComponent(lb_ModList);
	sb_2.Managecomponent(lb_ModInfo);
	sb_3.Managecomponent(i_ModLogo);

	MyPage.MyFooter.b_Activate.OnClick=LaunchClick;
	MyPage.MyFooter.b_Web.OnClick=WebClick;

	lb_ModInfo.MyScrollText.bClickText=true;
	lb_ModInfo.MyScrollText.OnDblClick=LaunchURL;
}

function bool LaunchURL(GUIComponent Sender)
{
    local string ClickString;

    ClickString = StripColorCodes(lb_ModInfo.MyScrollText.ClickedString);
   	Controller.LaunchURL(ClickString);
    return true;
}


function LoadUserMods()
{
	local array<string> ModDirs, ModTitles;
	local int i;

	GetModList(ModDirs, ModTitles);
	for (i=0;i<ModDirs.Length;i++)
	  	lb_ModList.List.Add(ModTitles[i],,ModDirs[i]);
}

function ModListChange(GUIComponent Sender)
{
	local Material M;
	lb_ModInfo.SetContent( GetModValue( lb_ModList.List.GetExtra(),"ModDesc" ));
	M = GetModLogo( lb_ModList.List.GetExtra() );

    if (!bInitialized)
    	return;

    if (m!=none)
    {
		i_ModLogo.Image = M;
        i_ModLogo.SetVisibility(true);

		sb_2.WinTop    = 0.300253;
		sb_2.WinHeight = 0.676279;
		sb_3.bVisible=true;

		lb_ModInfo.WinHeight=0.476758;
		lb_ModInfo.WinTop=0.376652;
    }
    else
	{
		sb_2.WinTop    = 0.012761;
		sb_2.WinHeight = 0.965263;
		sb_3.bVisible=false;

        i_ModLogo.SetVisibility(false);
		lb_ModInfo.WinHeight=0.750196;
		lb_ModInfo.WinTop=0.103215;
    }


}

function bool LaunchClick(GUIComponent Sender)
{
	local string CmdLine;

	if (lb_ModList.List.Index<0)
		return true;

	CmdLine = GetModValue( lb_ModList.List.GetExtra(), "ModCmdLine" );
    if (CmdLine!="")
		Console(Controller.Master.Console).DelayedConsoleCommand("relaunch"@CmdLine@"-mod="$lb_ModList.List.GetExtra()@"-newwindow");
	else
		Console(Controller.Master.Console).DelayedConsoleCommand("relaunch -mod="$lb_ModList.List.GetExtra()@"-newwindow");

    return true;
}

function bool WebClick(GUIComponent Sender)
{
	local string url;

	if (lb_ModList.List.Index<0)
		return true;

	url = GetModValue( lb_ModList.List.GetExtra(),"ModURL" );
	Console(Controller.Master.Console).DelayedConsoleCommand("open"@url);
    return true;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=sb1
         bFillClient=True
         Caption="Mods"
         BottomPadding=0.200000
         WinTop=0.012761
         WinLeft=0.012527
         WinWidth=0.408084
         WinHeight=0.960281
         RenderWeight=0.010000
         OnPreDraw=sb1.InternalPreDraw
     End Object
     sb_1=GUISectionBackground'GUI2K4.UT2K4UserMods.sb1'

     Begin Object Class=AltSectionBackground Name=sb2
         bFillClient=True
         Caption="Description"
         WinTop=0.012761
         WinLeft=0.431054
         WinWidth=0.562541
         WinHeight=0.965263
         RenderWeight=0.010000
         OnPreDraw=sb2.InternalPreDraw
     End Object
     sb_2=AltSectionBackground'GUI2K4.UT2K4UserMods.sb2'

     Begin Object Class=AltSectionBackground Name=sb3
         bFillClient=True
         WinTop=0.012761
         WinLeft=0.431054
         WinWidth=0.562541
         WinHeight=0.277682
         RenderWeight=0.010000
         OnPreDraw=sb3.InternalPreDraw
     End Object
     sb_3=AltSectionBackground'GUI2K4.UT2K4UserMods.sb3'

     Begin Object Class=GUIListBox Name=lbModList
         bVisibleWhenEmpty=True
         OnCreateComponent=lbModList.InternalOnCreateComponent
         WinTop=0.102865
         WinLeft=0.030468
         WinWidth=0.333985
         WinHeight=0.749024
         TabOrder=0
         OnChange=UT2K4UserMods.ModListChange
     End Object
     lb_ModList=GUIListBox'GUI2K4.UT2K4UserMods.lbModList'

     Begin Object Class=GUIScrollTextBox Name=lbModInfo
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=lbModInfo.InternalOnCreateComponent
         WinTop=0.103215
         WinLeft=0.378906
         WinWidth=0.582032
         WinHeight=0.750196
         TabOrder=1
     End Object
     lb_ModInfo=GUIScrollTextBox'GUI2K4.UT2K4UserMods.lbModInfo'

     Begin Object Class=GUIImage Name=iLogo
         Image=Texture'2K4Menus.Content.modmenulogo'
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.102865
         WinLeft=0.377930
         WinWidth=0.583008
         WinHeight=0.255859
         RenderWeight=0.400000
         bVisible=False
     End Object
     i_ModLogo=GUIImage'GUI2K4.UT2K4UserMods.iLogo'

     NoModsListText="No Mods Installed"
     NoModsInfoText="There are currently no mods or TC installed in this copy of UT2004.  Add message pimping cool places to get them here"
     PropagateVisibility=False
     Tag=1
}
