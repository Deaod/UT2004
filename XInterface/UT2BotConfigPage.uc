class UT2BotConfigPage extends UT2K3GUIPage;

var localized string NoInformation;
var GUIImage BotPortrait;
var GUILabel BotName;

var int ConfigIndex;
var xUtil.PlayerRecord ThisBot;
var bool bIgnoreChange;
var moComboBox Wep;

var array<CacheManager.WeaponRecord> Records;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	Super.Initcomponent(MyController, MyOwner);
	BotPortrait=GUIImage(Controls[1]);
	BotName=GUILabel(Controls[3]);

	class'CacheManager'.static.GetWeaponList( Records );
    Wep = moComboBox(Controls[13]);
    Wep.AddItem("None");
    for (i=0;i<Records.Length;i++)
    	Wep.AddItem(Records[i].FriendlyName,,Records[i].ClassName);

    Wep.Onchange=ComboBoxChange;

	moSlider(Controls[6]).MySlider.OnDrawCaption=AggDC;
	moSlider(Controls[7]).MySlider.OnDrawCaption=AccDC;
	moSlider(Controls[8]).MySlider.OnDrawCaption=ComDC;
	moSlider(Controls[9]).MySlider.OnDrawCaption=StrDC;
	moSlider(Controls[10]).MySlider.OnDrawCaption=TacDC;
	moSlider(Controls[11]).MySlider.OnDrawCaption=ReaDC;
}

function SetupBotInfo(Material Portrait, string DecoTextName, xUtil.PlayerRecord PRE)
{

    ThisBot = PRE;

	// Setup the Portrait from here
	BotPortrait.Image = PRE.Portrait;
	// Setup the decotext from here
	BotName.Caption = PRE.DefaultName;

    ConfigIndex = class'CustomBotConfig'.static.IndexFor(PRE.DefaultName);

	bIgnoreChange = true;
    if (ConfigIndex>=0)
    {
    	moSlider(Controls[6]).SetValue(class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Aggressiveness);
    	moSlider(Controls[7]).SetValue(class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Accuracy);
    	moSlider(Controls[8]).SetValue(class'CustomBotConfig'.default.ConfigArray[ConfigIndex].CombatStyle);
    	moSlider(Controls[9]).SetValue(class'CustomBotConfig'.default.ConfigArray[ConfigIndex].StrafingAbility);
    	moSlider(Controls[10]).SetValue(class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Tactics);
        moSlider(Controls[11]).SetValue(class'CustomBotConfig'.default.ConfigArray[ConfigIndex].ReactionTime);
        mocheckBox(Controls[12]).Checked(class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Jumpiness > 0.5);

        Wep.Find(class'CustomBotConfig'.default.ConfigArray[ConfigIndex].FavoriteWeapon,,True);

    }
    else
	{
    	moSlider(Controls[6]).SetValue(float(PRE.Aggressiveness));
    	moSlider(Controls[7]).SetValue(float(PRE.Accuracy));
    	moSlider(Controls[8]).SetValue(float(PRE.CombatStyle));
    	moSlider(Controls[9]).SetValue(float(PRE.StrafingAbility));
    	moSlider(Controls[10]).SetValue(float(PRE.Tactics));
    	moSlider(Controls[11]).SetValue(float(PRE.ReactionTime));
        mocheckBox(Controls[12]).Checked(float(PRE.Jumpiness) > 0.5);

        Wep.Find(PRE.FavoriteWeapon,,True);

    }

    bIgnoreChange=false;

}

function bool OkClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	class'CustomBotConfig'.static.StaticSaveConfig();
	return true;
}

function bool ResetClick(GUIComponent Sender)
{
	bIgnoreChange = true;

	SetDefaults();

   	moSlider(Controls[6]).SetValue(float(ThisBot.Aggressiveness));
   	moSlider(Controls[7]).SetValue(float(ThisBot.Accuracy));
   	moSlider(Controls[8]).SetValue(float(ThisBot.CombatStyle));
   	moSlider(Controls[9]).SetValue(float(ThisBot.StrafingAbility));
   	moSlider(Controls[10]).SetValue(float(ThisBot.Tactics));
   	moSlider(Controls[11]).SetValue(float(ThisBot.ReactionTime));
   	moCheckBox(Controls[12]).Checked(float(ThisBot.Jumpiness) > 0.5);
	Wep.Find(ThisBot.FavoriteWeapon,false,True);
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
	return DoPerc(moSlider(Controls[6]).MySlider) $ "%";
}

function string AccDC()
{
	return DoPerc(moSlider(Controls[7]).MySlider) $"%";
}

function string ComDC()
{
	return DoPerc(moSlider(Controls[8]).MySlider) $"%";
}

function string StrDC()
{
	return DoPerc(moSlider(Controls[9]).MySlider) $"%";
}

function string TacDC()
{
	return DoPerc(moSlider(Controls[10]).MySlider) $"%";
}

function string ReaDC()
{
	return DoPerc(moSlider(Controls[11]).MySlider) $"%";
}

function SetDefaults()
{
	class'CustomBotConfig'.default.ConfigArray[ConfigIndex].CharacterName = ThisBot.DefaultName;
	class'CustomBotConfig'.default.ConfigArray[ConfigIndex].PlayerName = ThisBot.DefaultName;
    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].FavoriteWeapon = ThisBot.FavoriteWeapon;
    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Aggressiveness = float(ThisBot.Aggressiveness);
    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Accuracy = float(ThisBot.Accuracy);
    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].CombatStyle = float(ThisBot.CombatStyle);
    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].StrafingAbility = float(ThisBot.StrafingAbility);
    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Tactics = float(ThisBot.Tactics);
    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].ReactionTime = float(ThisBot.ReactionTime);
    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Jumpiness = float(ThisBot.Jumpiness);
}

function SliderChange(GUIComponent Sender)
{
	local GUISlider S;

	if ( moSlider(Sender) != None )
		S = moSlider(Sender).MySlider;

    if ( bIgnoreChange || S == None )
    	return;

	// Look to see if this is a new entry

    if (ConfigIndex==-1)
    {
    	ConfigIndex = class'CustomBotConfig'.Default.ConfigArray.Length;
		class'CustomBotConfig'.Default.ConfigArray.Length = ConfigIndex+1;
        SetDefaults();
    }


	if (S == Controls[6])
      class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Aggressiveness = S.Value;

	else if (S == Controls[7])
      class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Accuracy = S.Value;

	else if (S == Controls[8])
      class'CustomBotConfig'.default.ConfigArray[ConfigIndex].CombatStyle = S.Value;

	else if (S == Controls[9])
      class'CustomBotConfig'.default.ConfigArray[ConfigIndex].StrafingAbility = S.Value;

	else if (S == Controls[10])
      class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Tactics = S.Value;

	else if (S == Controls[11])
      class'CustomBotConfig'.default.ConfigArray[ConfigIndex].ReactionTime = S.Value;
}

function CheckBoxChange(GUIComponent Sender)
{
	if (bIgnorechange || Sender!=Controls[18])
    	return;

	// Look to see if this is a new entry

    if (ConfigIndex==-1)
    {
    	ConfigIndex = class'CustomBotConfig'.Default.ConfigArray.Length;
		class'CustomBotConfig'.Default.ConfigArray.Length = ConfigIndex+1;
        SetDefaults();
    }
    if ( moCheckBox(Controls[18]).IsChecked() )
		class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Jumpiness = 1;
	else 
		class'CustomBotConfig'.default.ConfigArray[ConfigIndex].Jumpiness = 0;
}

function ComboBoxChange(GUIComponent Sender)
{
	if (bIgnorechange || Sender!=Controls[13])
    	return;

	// Look to see if this is a new entry
    if (ConfigIndex==-1)
    {
    	ConfigIndex = class'CustomBotConfig'.Default.ConfigArray.Length;
		class'CustomBotConfig'.Default.ConfigArray.Length = ConfigIndex+1;
        SetDefaults();
    }

    class'CustomBotConfig'.default.ConfigArray[ConfigIndex].FavoriteWeapon = moComboBox(Sender).GetExtra();
}

defaultproperties
{
     NoInformation="No Information Available!"
     Begin Object Class=GUIImage Name=PageBack
         Image=Texture'InterfaceContent.Menu.EditBoxDown'
         ImageStyle=ISTY_Stretched
         WinLeft=0.062500
         WinWidth=0.890625
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(0)=GUIImage'XInterface.UT2BotConfigPage.PageBack'

     Begin Object Class=GUIImage Name=imgBotPic
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Normal
         WinTop=0.193982
         WinLeft=0.078125
         WinWidth=0.246875
         WinHeight=0.658008
         RenderWeight=0.100100
     End Object
     Controls(1)=GUIImage'XInterface.UT2BotConfigPage.imgBotPic'

     Begin Object Class=GUIImage Name=BotPortraitBorder
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowX=8
         DropShadowY=8
         WinTop=0.188427
         WinLeft=0.076563
         WinWidth=0.253125
         WinHeight=0.664258
     End Object
     Controls(2)=GUIImage'XInterface.UT2BotConfigPage.BotPortraitBorder'

     Begin Object Class=GUILabel Name=BotCfgName
         Caption="Unknown"
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.119068
         WinLeft=0.084744
         WinWidth=0.598437
         WinHeight=0.052539
     End Object
     Controls(3)=GUILabel'XInterface.UT2BotConfigPage.BotCfgName'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Reset"
         WinTop=0.825001
         WinLeft=0.585938
         WinWidth=0.167187
         WinHeight=0.045313
         OnClick=UT2BotConfigPage.ResetClick
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.UT2BotConfigPage.ResetButton'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.825001
         WinLeft=0.765625
         WinWidth=0.167187
         WinHeight=0.045313
         OnClick=UT2BotConfigPage.OkClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(5)=GUIButton'XInterface.UT2BotConfigPage.OkButton'

     Begin Object Class=moSlider Name=BotAggrSlider
         MaxValue=1.000000
         Caption="Aggressiveness"
         OnCreateComponent=BotAggrSlider.InternalOnCreateComponent
         Hint="Configures the aggressiveness rating of this bot."
         WinTop=0.208229
         WinLeft=0.345313
         WinWidth=0.598438
         TabOrder=0
         OnChange=UT2BotConfigPage.SliderChange
     End Object
     Controls(6)=moSlider'XInterface.UT2BotConfigPage.BotAggrSlider'

     Begin Object Class=moSlider Name=BotAccuracySlider
         MaxValue=1.000000
         MinValue=-1.000000
         Caption="Accuracy"
         OnCreateComponent=BotAccuracySlider.InternalOnCreateComponent
         Hint="Configures the accuracy rating of this bot."
         WinTop=0.281145
         WinLeft=0.345313
         WinWidth=0.598438
         OnChange=UT2BotConfigPage.SliderChange
     End Object
     Controls(7)=moSlider'XInterface.UT2BotConfigPage.BotAccuracySlider'

     Begin Object Class=moSlider Name=BotCStyleSlider
         MaxValue=1.000000
         Caption="Combat Style"
         OnCreateComponent=BotCStyleSlider.InternalOnCreateComponent
         Hint="Adjusts the combat style of this bot."
         WinTop=0.354062
         WinLeft=0.345313
         WinWidth=0.598438
         OnChange=UT2BotConfigPage.SliderChange
     End Object
     Controls(8)=moSlider'XInterface.UT2BotConfigPage.BotCStyleSlider'

     Begin Object Class=moSlider Name=BotStrafeSlider
         MaxValue=1.000000
         Caption="Strafing Ability"
         OnCreateComponent=BotStrafeSlider.InternalOnCreateComponent
         Hint="Adjusts the strafing ability of this bot."
         WinTop=0.426979
         WinLeft=0.345313
         WinWidth=0.598438
         OnChange=UT2BotConfigPage.SliderChange
     End Object
     Controls(9)=moSlider'XInterface.UT2BotConfigPage.BotStrafeSlider'

     Begin Object Class=moSlider Name=BotTacticsSlider
         MaxValue=1.000000
         MinValue=-1.000000
         Caption="Tactics"
         OnCreateComponent=BotTacticsSlider.InternalOnCreateComponent
         Hint="Adjusts the team-play awareness ability of this bot."
         WinTop=0.499895
         WinLeft=0.345313
         WinWidth=0.598438
         OnChange=UT2BotConfigPage.SliderChange
     End Object
     Controls(10)=moSlider'XInterface.UT2BotConfigPage.BotTacticsSlider'

     Begin Object Class=moSlider Name=BotReactionSlider
         MaxValue=4.000000
         MinValue=-4.000000
         Caption="Reaction Time"
         OnCreateComponent=BotReactionSlider.InternalOnCreateComponent
         Hint="Adjusts the reaction speed of this bot."
         WinTop=0.593645
         WinLeft=0.345313
         WinWidth=0.598438
         OnChange=UT2BotConfigPage.SliderChange
     End Object
     Controls(11)=moSlider'XInterface.UT2BotConfigPage.BotReactionSlider'

     Begin Object Class=moCheckBox Name=BotJumpy
         CaptionWidth=0.900000
         Caption="Jump Happy"
         OnCreateComponent=BotJumpy.InternalOnCreateComponent
         Hint="Controls whether this bot jumps a lot during the game."
         WinTop=0.666562
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.040000
         OnChange=UT2BotConfigPage.CheckBoxChange
     End Object
     Controls(12)=moCheckBox'XInterface.UT2BotConfigPage.BotJumpy'

     Begin Object Class=moComboBox Name=BotWeapon
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.450000
         Caption="Preferred Weapon"
         OnCreateComponent=BotWeapon.InternalOnCreateComponent
         Hint="Select which weapon this bot should prefer."
         WinTop=0.729062
         WinLeft=0.345313
         WinWidth=0.598438
         WinHeight=0.044375
     End Object
     Controls(13)=moComboBox'XInterface.UT2BotConfigPage.BotWeapon'

     WinTop=0.100000
     WinHeight=0.800000
}
