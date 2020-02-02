//==============================================================================
//	Created on: 08/08/2003
//	Description
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4BotConfigPage extends LockedFloatingWindow;

var localized string NoInformation, NoPref, DefaultString;
var GUIImage BotPortrait;
var GUILabel BotName;

var int ConfigIndex;
var xUtil.PlayerRecord ThisBot;
var bool bIgnoreChange;

var automated GUIImage i_Portrait;
var automated moSlider sl_Agg, sl_Acc, sl_Com, sl_Str, sl_Tac, sl_Rea, sl_Jumpy;
var automated moComboBox co_Weapon, co_Voice, co_Orders;

var	automated GUISectionBackground sb_PicBK;

var class<CustomBotConfig> BotConfigClass;
var array<CacheManager.WeaponRecord> Records;
var localized string ResetString;
var localized string AttributesString;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyController, MyOwner);

	sb_PicBK.ManageComponent(i_Portrait);

	sb_Main.SetPosition(0.350547,0.078391,0.565507,0.600586);

	sb_Main.Caption=AttributesString;

    sb_Main.ManageComponent(sl_Agg);
    sb_Main.ManageComponent(sl_Acc);
    sb_Main.ManageComponent(sl_Com);
    sb_Main.ManageComponent(sl_Str);
    sb_Main.ManageComponent(sl_Tac);
    sb_Main.ManageComponent(sl_Rea);
    sb_Main.ManageComponent(sl_Jumpy);
    sb_Main.ManageComponent(co_Weapon);
    sb_Main.ManageComponent(co_Voice);
    sb_Main.ManageComponent(co_Orders);


	class'CacheManager'.static.GetWeaponList( Records );
    co_Weapon.AddItem(NoPref);
    for (i=0;i<Records.Length;i++)
    	co_Weapon.AddItem(Records[i].FriendlyName,,Records[i].ClassName);

    for ( i = 0; i < ArrayCount(class'GameProfile'.default.PositionName); i++ )
    	co_Orders.AddItem(class'GameProfile'.default.PositionName[i]);

    co_Weapon.Onchange=ComboBoxChange;

	sl_Agg.MySlider.OnDrawCaption=AggDC;
	sl_Acc.MySlider.OnDrawCaption=AccDC;
	sl_Com.MySlider.OnDrawCaption=ComDC;
	sl_Str.MySlider.OnDrawCaption=StrDC;
	sl_Tac.MySlider.OnDrawCaption=TacDC;
	sl_Rea.MySlider.OnDrawCaption=ReaDC;
	sl_Jumpy.MySlider.OnDrawCaption=JumpyDC;

	b_OK.OnClick = OkClick;

	b_Cancel.Caption=ResetString;
	b_Cancel.OnClick=ResetClick;

}

function SetupBotInfo(Material Portrait, string DecoTextName, xUtil.PlayerRecord PRE)
{
	local int i;
	local array<string> VoicePackClasses;
	local class<xVoicePack> Pack;

	bIgnoreChange = true;

    ThisBot = PRE;
    PlayerOwner().GetAllInt("XGame.xVoicePack", VoicePackClasses);

    co_Voice.MyComboBox.List.Clear();
    co_Voice.AddItem(DefaultString);
    for ( i = 0; i < VoicePackClasses.Length; i++ )
    {
    	Pack = class<xVoicePack>(DynamicLoadObject( VoicePackClasses[i], class'Class'));
    	if ( Pack != None )
    	{
    		// Only show voices that correspond to this gender
    		if ( class'TeamVoicePack'.static.VoiceMatchesGender(Pack.default.VoiceGender, ThisBot.Sex) )
	    		co_Voice.AddItem( Pack.default.VoicePackName, Pack, VoicePackClasses[i] );
	    }
    }

	// Setup the Portrait from here
	i_Portrait.Image = PRE.Portrait;
	// Setup the decotext from here
	sb_PicBK.Caption = PRE.DefaultName;

    ConfigIndex = BotConfigClass.static.IndexFor(PRE.DefaultName);

    if (ConfigIndex>=0)
    {
    	sl_Agg.SetValue(BotConfigClass.default.ConfigArray[ConfigIndex].Aggressiveness);
    	sl_Acc.SetValue(BotConfigClass.default.ConfigArray[ConfigIndex].Accuracy);
    	sl_Com.SetValue(BotConfigClass.default.ConfigArray[ConfigIndex].CombatStyle);
    	sl_Str.SetValue(BotConfigClass.default.ConfigArray[ConfigIndex].StrafingAbility);
    	sl_Tac.SetValue(BotConfigClass.default.ConfigArray[ConfigIndex].Tactics);
        sl_Rea.SetValue(BotConfigClass.default.ConfigArray[ConfigIndex].ReactionTime);
        sl_Jumpy.SetValue(BotConfigClass.default.ConfigArray[ConfigIndex].Jumpiness);

        co_Weapon.Find(BotConfigClass.default.ConfigArray[ConfigIndex].FavoriteWeapon,,True);
        co_Voice.Find(BotConfigClass.default.ConfigArray[ConfigIndex].CustomVoice,,True);
        co_Orders.Find(class'GameProfile'.static.TextPositionDescription(BotConfigClass.default.ConfigArray[ConfigIndex].CustomOrders));

    }
    else
	{
    	sl_Agg.SetValue(float(PRE.Aggressiveness));
    	sl_Acc.SetValue(float(PRE.Accuracy));
    	sl_Com.SetValue(float(PRE.CombatStyle));
    	sl_Str.SetValue(float(PRE.StrafingAbility));
    	sl_Tac.SetValue(float(PRE.Tactics));
    	sl_Rea.SetValue(float(PRE.ReactionTime));
        sl_Jumpy.SetValue(float(PRE.Jumpiness));

        co_Weapon.Find(PRE.FavoriteWeapon,,True);
        if ( PRE.VoiceClassName != "" )
	        co_Voice.Find(PRE.VoiceClassName,,True);

	    co_Orders.SetIndex(0);
    }

    bIgnoreChange=false;

}

function bool OkClick(GUIComponent Sender)
{
	BotConfigClass.static.StaticSaveConfig();
	Controller.CloseMenu(false);
	return true;
}

function bool ResetClick(GUIComponent Sender)
{
	bIgnoreChange = true;

	if ( ConfigIndex >= 0 )
	{
		class'CustomBotConfig'.default.ConfigArray.Remove(ConfigIndex,1);
		class'CustomBotConfig'.static.StaticSaveConfig();
	}

	ConfigIndex = -1;
   	sl_Agg.SetValue(float(ThisBot.Aggressiveness));
   	sl_Acc.SetValue(float(ThisBot.Accuracy));
   	sl_Com.SetValue(float(ThisBot.CombatStyle));
   	sl_Str.SetValue(float(ThisBot.StrafingAbility));
   	sl_Tac.SetValue(float(ThisBot.Tactics));
   	sl_Rea.SetValue(float(ThisBot.ReactionTime));
   	sl_Jumpy.SetValue(float(ThisBot.Jumpiness));
	co_Weapon.Find(ThisBot.FavoriteWeapon,false,True);

	if ( ThisBot.VoiceClassName != "" )
		co_Voice.Find(ThisBot.VoiceClassName,false,True);

	else co_Voice.SetIndex(0);

	co_Orders.SetIndex(0);
    bIgnorechange = false;

	return true;
}


function string DoPerc(GUISlider Control)
{
	local float r,v,vmin;

    vmin = Control.MinValue;
    r = Control.MaxValue - vmin;
    v = Control.Value - vmin;

    return string(int(v/r*100));
}



function string AggDC()
{
	return DoPerc(sl_Agg.MySlider) $ "%";
}

function string AccDC()
{
	return sl_Acc.GetComponentValue();
}

function string ComDC()
{
	return DoPerc(sl_Com.MySlider) $"%";
}

function string StrDC()
{
	return sl_Str.GetComponentValue();
}

function string TacDC()
{
	return sl_Tac.GetComponentValue();
}

function string ReaDC()
{
	return sl_Rea.GetComponentValue();
}

function string JumpyDC()
{
	return DoPerc(sl_Jumpy.MySlider) $ "%";
}

function SetDefaults()
{
	BotConfigClass.default.ConfigArray[ConfigIndex].CharacterName = ThisBot.DefaultName;
	BotConfigClass.default.ConfigArray[ConfigIndex].PlayerName = ThisBot.DefaultName;
    BotConfigClass.default.ConfigArray[ConfigIndex].FavoriteWeapon = ThisBot.FavoriteWeapon;
    BotConfigClass.default.ConfigArray[ConfigIndex].Aggressiveness = float(ThisBot.Aggressiveness);
    BotConfigClass.default.ConfigArray[ConfigIndex].Accuracy = float(ThisBot.Accuracy);
    BotConfigClass.default.ConfigArray[ConfigIndex].CombatStyle = float(ThisBot.CombatStyle);
    BotConfigClass.default.ConfigArray[ConfigIndex].StrafingAbility = float(ThisBot.StrafingAbility);
    BotConfigClass.default.ConfigArray[ConfigIndex].Tactics = float(ThisBot.Tactics);
    BotConfigClass.default.ConfigArray[ConfigIndex].ReactionTime = float(ThisBot.ReactionTime);
    BotConfigClass.default.ConfigArray[ConfigIndex].Jumpiness = float(ThisBot.Jumpiness);
    BotConfigClass.default.ConfigArray[ConfigIndex].CustomVoice = ThisBot.VoiceClassName;
    BotConfigClass.default.ConfigArray[ConfigIndex].CustomOrders = POS_Auto;
}

function SliderChange(GUIComponent Sender)
{
	local moSlider S;

	if ( moSlider(Sender) != None )
		S = moSlider(Sender);

    if ( bIgnoreChange || S == None )
    	return;

	ValidateIndex();
	if (S == sl_Agg)
      BotConfigClass.default.ConfigArray[ConfigIndex].Aggressiveness = S.GetValue();

	else if (S == sl_Acc)
      BotConfigClass.default.ConfigArray[ConfigIndex].Accuracy = S.GetValue();

	else if (S == sl_Com)
      BotConfigClass.default.ConfigArray[ConfigIndex].CombatStyle = S.GetValue();

	else if (S == sl_Str)
      BotConfigClass.default.ConfigArray[ConfigIndex].StrafingAbility = S.GetValue();

	else if (S == sl_Tac)
      BotConfigClass.default.ConfigArray[ConfigIndex].Tactics = S.GetValue();

	else if (S == sl_Rea)
      BotConfigClass.default.ConfigArray[ConfigIndex].ReactionTime = S.GetValue();

    else if ( S == sl_Jumpy )
      BotConfigClass.default.ConfigArray[ConfigIndex].Jumpiness = S.GetValue();
}

function ComboBoxChange(GUIComponent Sender)
{
	if (bIgnorechange || moComboBox(Sender) == None)
    	return;

	ValidateIndex();
	if ( Sender == co_Weapon )
	    BotConfigClass.default.ConfigArray[ConfigIndex].FavoriteWeapon = co_Weapon.GetExtra();

	else if ( Sender == co_Voice )
		BotConfigClass.default.ConfigArray[ConfigIndex].CustomVoice = co_Voice.GetExtra();

	else if ( Sender == co_Orders )
		BotConfigClass.default.ConfigArray[ConfigIndex].CustomOrders = class'GameProfile'.static.EnumPositionDescription(co_Orders.GetText());
}

function ValidateIndex()
{
	// Look to see if this is a new entry
    if (ConfigIndex==-1)
    {
    	ConfigIndex = BotConfigClass.Default.ConfigArray.Length;
		BotConfigClass.Default.ConfigArray.Length = ConfigIndex+1;
        SetDefaults();
    }
}

defaultproperties
{
     NoInformation="No Information Available!"
     NoPref="No Preference"
     DefaultString="Default"
     Begin Object Class=GUIImage Name=imgBotPic
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.116031
         WinLeft=0.079861
         WinWidth=0.246875
         WinHeight=0.822510
         RenderWeight=0.110000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_Portrait=GUIImage'GUI2K4.UT2K4BotConfigPage.imgBotPic'

     Begin Object Class=moSlider Name=BotAggrSlider
         MaxValue=1.000000
         SliderCaptionStyleName="TextLabel"
         Caption="Aggressiveness"
         OnCreateComponent=BotAggrSlider.InternalOnCreateComponent
         Hint="Configures the aggressiveness rating of this bot."
         WinTop=0.107618
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.037500
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.SliderChange
     End Object
     sl_Agg=moSlider'GUI2K4.UT2K4BotConfigPage.BotAggrSlider'

     Begin Object Class=moSlider Name=BotAccuracySlider
         MaxValue=2.000000
         MinValue=-2.000000
         SliderCaptionStyleName="TextLabel"
         Caption="Accuracy"
         OnCreateComponent=BotAccuracySlider.InternalOnCreateComponent
         Hint="Configures the accuracy rating of this bot."
         WinTop=0.177603
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.037500
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.SliderChange
     End Object
     sl_Acc=moSlider'GUI2K4.UT2K4BotConfigPage.BotAccuracySlider'

     Begin Object Class=moSlider Name=BotCStyleSlider
         MaxValue=1.000000
         SliderCaptionStyleName="TextLabel"
         Caption="Combat Style"
         OnCreateComponent=BotCStyleSlider.InternalOnCreateComponent
         Hint="Adjusts the combat style of this bot."
         WinTop=0.247588
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.037500
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.SliderChange
     End Object
     sl_Com=moSlider'GUI2K4.UT2K4BotConfigPage.BotCStyleSlider'

     Begin Object Class=moSlider Name=BotStrafeSlider
         MaxValue=2.000000
         MinValue=-2.000000
         SliderCaptionStyleName="TextLabel"
         Caption="Strafing Ability"
         OnCreateComponent=BotStrafeSlider.InternalOnCreateComponent
         Hint="Adjusts the strafing ability of this bot."
         WinTop=0.317573
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.037500
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.SliderChange
     End Object
     sl_Str=moSlider'GUI2K4.UT2K4BotConfigPage.BotStrafeSlider'

     Begin Object Class=moSlider Name=BotTacticsSlider
         MaxValue=2.000000
         MinValue=-2.000000
         SliderCaptionStyleName="TextLabel"
         Caption="Tactics"
         OnCreateComponent=BotTacticsSlider.InternalOnCreateComponent
         Hint="Adjusts the team-play awareness ability of this bot."
         WinTop=0.387558
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.037500
         TabOrder=4
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.SliderChange
     End Object
     sl_Tac=moSlider'GUI2K4.UT2K4BotConfigPage.BotTacticsSlider'

     Begin Object Class=moSlider Name=BotReactionSlider
         MaxValue=2.000000
         MinValue=-2.000000
         SliderCaptionStyleName="TextLabel"
         Caption="Reaction Time"
         OnCreateComponent=BotReactionSlider.InternalOnCreateComponent
         Hint="Adjusts the reaction speed of this bot."
         WinTop=0.457542
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.037500
         TabOrder=5
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.SliderChange
     End Object
     sl_Rea=moSlider'GUI2K4.UT2K4BotConfigPage.BotReactionSlider'

     Begin Object Class=moSlider Name=BotJumpy
         MaxValue=1.000000
         SliderCaptionStyleName="TextLabel"
         Caption="Jumpiness"
         OnCreateComponent=BotJumpy.InternalOnCreateComponent
         Hint="Controls whether this bot jumps a lot during the game."
         WinTop=0.527528
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.037500
         TabOrder=6
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.SliderChange
     End Object
     sl_Jumpy=moSlider'GUI2K4.UT2K4BotConfigPage.BotJumpy'

     Begin Object Class=moComboBox Name=BotWeapon
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Preferred Weapon"
         OnCreateComponent=BotWeapon.InternalOnCreateComponent
         Hint="Select which weapon this bot should prefer."
         WinTop=0.647967
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.055469
         TabOrder=7
         bBoundToParent=True
         bScaleToParent=True
     End Object
     co_Weapon=moComboBox'GUI2K4.UT2K4BotConfigPage.BotWeapon'

     Begin Object Class=moComboBox Name=BotVoice
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Voice"
         OnCreateComponent=BotVoice.InternalOnCreateComponent
         Hint="Choose which voice this bot uses."
         WinTop=0.718011
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.055469
         TabOrder=8
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.ComboBoxChange
     End Object
     co_Voice=moComboBox'GUI2K4.UT2K4BotConfigPage.BotVoice'

     Begin Object Class=moComboBox Name=BotOrders
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Orders"
         OnCreateComponent=BotOrders.InternalOnCreateComponent
         Hint="Choose which role this bot will play in the game."
         WinTop=0.791159
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.055469
         TabOrder=9
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2K4BotConfigPage.ComboBoxChange
     End Object
     co_Orders=moComboBox'GUI2K4.UT2K4BotConfigPage.BotOrders'

     Begin Object Class=GUISectionBackground Name=PicBK
         WinTop=0.078391
         WinLeft=0.026150
         WinWidth=0.290820
         WinHeight=0.638294
         OnPreDraw=PicBK.InternalPreDraw
     End Object
     sb_PicBK=GUISectionBackground'GUI2K4.UT2K4BotConfigPage.PicBK'

     BotConfigClass=Class'UnrealGame.CustomBotConfig'
     ResetString="Reset"
     AttributesString="Attributes"
     WinTop=0.123958
     WinLeft=0.043945
     WinWidth=0.921875
     WinHeight=0.759115
}
