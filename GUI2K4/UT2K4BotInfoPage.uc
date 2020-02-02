//==============================================================================
//	UT2K4 version of UT2BotInfoPage
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4BotInfoPage extends LockedFloatingWindow;
var localized string NoInformation, AggressionCaption, AccuracyCaption, AgilityCaption, TacticsCaption;

var automated GUIImage 			i_Portrait;
var automated GUIProgressBar 	pb_Accuracy, pb_Agility, pb_Tactics, pb_Aggression;
var automated GUIScrollTextBox	lb_Deco;

var	automated GUISectionBackground sb_PicBK;
var automated altSectionBackground sb_HistBK;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	sb_Main.SetPosition(0.363243,0.057558,0.539140,0.336132);

	sb_PicBK.ManageComponent(i_Portrait);

	sb_HistBK.Managecomponent(lb_Deco);

	sb_Main.Managecomponent(pb_Accuracy);
	sb_Main.Managecomponent(pb_Agility);
	sb_Main.Managecomponent(pb_Tactics);
	sb_Main.Managecomponent(pb_Aggression);

	pb_Accuracy.Caption = AccuracyCaption;
	pb_Agility.Caption = AgilityCaption;
	pb_Tactics.Caption = TacticsCaption;
	pb_Aggression.Caption = AggressionCaption;

	b_Cancel.SetVisibility(false);
}

function SetupBotInfo(Material Portrait, string DecoTextName, xUtil.PlayerRecord PRE)
{
	local DecoText BotDeco;
	local int i;
	local string FavWeap, Package, TextName;

	// Setup the Portrait from here
	i_Portrait.Image = PRE.Portrait;
	if (DecoTextName == "")
		DecoTextName = PRE.TextName;

	if (InStr(DecoTextName, ".") != -1)
		Divide(DecoTextName, ".", Package, TextName);
	else TextName = DecoTextName;

	if (DecoTextName != "")
		BotDeco = class'xUtil'.static.LoadDecoText(Package, TextName);

	sb_PicBK.Caption = PRE.DefaultName;

	i = class'CustomBotConfig'.static.IndexFor(PRE.DefaultName);
	if (i != -1)
	{
		FavWeap = class'CustomBotConfig'.static.GetFavoriteWeaponFor(class'CustomBotConfig'.default.ConfigArray[i]);
		pb_Aggression.Value=class'CustomBotConfig'.static.AggressivenessRating(class'CustomBotConfig'.default.ConfigArray[i]);
		pb_Agility.Value=class'CustomBotConfig'.static.AgilityRating(class'CustomBotConfig'.default.ConfigArray[i]);
		pb_Tactics.Value=class'CustomBotConfig'.static.TacticsRating(class'CustomBotConfig'.default.ConfigArray[i]);
		pb_Accuracy.Value=class'CustomBotConfig'.static.AccuracyRating(class'CustomBotConfig'.default.ConfigArray[i]);
	}
	else
	{
		FavWeap = class'xUtil'.static.GetFavoriteWeaponFor(PRE);
		pb_Aggression.Value=class'XUtil'.static.AggressivenessRating(PRE);
		pb_Agility.Value=class'XUtil'.static.AgilityRating(PRE);
		pb_Tactics.Value=class'XUtil'.static.TacticsRating(PRE);
		pb_Accuracy.Value=class'XUtil'.static.AccuracyRating(PRE);
	}

	sb_Main.Caption = FavWeap;
	if (BotDeco != None)
		lb_Deco.SetContent( JoinArray(BotDeco.Rows, "|"), "|" );

	sb_HistBK.Caption = PRE.Species.default.SpeciesName;
}

defaultproperties
{
     NoInformation="No Information Available!"
     AggressionCaption="Aggressiveness"
     AccuracyCaption="Accuracy"
     AgilityCaption="Agility"
     TacticsCaption="Tactics"
     Begin Object Class=GUIImage Name=imgBotPic
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.097923
         WinLeft=0.079861
         WinWidth=0.246875
         WinHeight=0.866809
         RenderWeight=1.010000
     End Object
     i_Portrait=GUIImage'GUI2K4.UT2K4BotInfoPage.imgBotPic'

     Begin Object Class=GUIProgressBar Name=myPB
         BarBack=Texture'2K4Menus.NewControls.NewStatusBar'
         BarTop=Texture'2K4Menus.NewControls.NewStatusFill'
         BarColor=(B=255,G=155)
         Value=50.000000
         FontName="UT2SmallFont"
         bShowValue=False
         StyleName="TextLabel"
         WinHeight=0.040000
         RenderWeight=1.200000
     End Object
     pb_Accuracy=GUIProgressBar'GUI2K4.UT2K4BotInfoPage.myPB'

     pb_Agility=GUIProgressBar'GUI2K4.UT2K4BotInfoPage.myPB'

     pb_Tactics=GUIProgressBar'GUI2K4.UT2K4BotInfoPage.myPB'

     pb_Aggression=GUIProgressBar'GUI2K4.UT2K4BotInfoPage.myPB'

     Begin Object Class=GUIScrollTextBox Name=DecoDescription
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=DecoDescription.InternalOnCreateComponent
         WinTop=0.613447
         WinLeft=0.353008
         WinWidth=0.570936
         WinHeight=0.269553
         bNeverFocus=True
     End Object
     lb_Deco=GUIScrollTextBox'GUI2K4.UT2K4BotInfoPage.DecoDescription'

     Begin Object Class=GUISectionBackground Name=PicBK
         WinTop=0.057558
         WinLeft=0.026150
         WinWidth=0.290820
         WinHeight=0.661731
         OnPreDraw=PicBK.InternalPreDraw
     End Object
     sb_PicBK=GUISectionBackground'GUI2K4.UT2K4BotInfoPage.PicBK'

     Begin Object Class=AltSectionBackground Name=HistBk
         LeftPadding=0.010000
         RightPadding=0.010000
         WinTop=0.515790
         WinLeft=0.357891
         WinWidth=0.546522
         WinHeight=0.269553
         OnPreDraw=HistBk.InternalPreDraw
     End Object
     sb_HistBK=AltSectionBackground'GUI2K4.UT2K4BotInfoPage.HistBk'

     WinTop=0.100228
     WinLeft=0.045898
     WinWidth=0.902344
     WinHeight=0.759115
}
