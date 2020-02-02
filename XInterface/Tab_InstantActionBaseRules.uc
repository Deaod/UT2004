// ====================================================================
//  Class:  XInterface.Tab_InstantActionBaseRules
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_InstantActionBaseRules extends UT2K3TabPanel;

var config  float	LastFriendlyFire;
var config 	bool	LastWeaponStay;
var config 	bool	LastTranslocator;

var config 	float	LastGameSpeed;
var config  int		LastGoalScore;
var config	int		LastTimeLimit;
var config	int		LastMaxLives;

var Config  bool  	bLastWeaponThrowing;

var	GUISlider		MyGameSpeed;

var moCheckBox		MyWeaponStay;
var moCheckBox		MyTranslocator;
var GUISlider 		MyFriendlyFire;

var moNumericEdit	MyGoalScore;
var	moNumericEdit	MyTimeLimit;
var	moNumericEdit	MyMaxLives;

var moCheckBox		MyWeaponThrowing;
var moCheckBox		MyBrightSkins;


var localized string	PercentText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int NewGameSpeed;

	Super.Initcomponent(MyController, MyOwner);

	MyGameSpeed=GUISlider(Controls[4]);
	MyWeaponStay=moCheckBox(Controls[5]);
	MyTranslocator=moCheckBox(Controls[6]);
	MyFriendlyFire=GUISlider(Controls[8]);

	MyGoalScore=moNumericEdit(Controls[9]);
	MyTimeLimit=moNumericEdit(Controls[10]);
	MyMAxLives=moNumericEdit(Controls[11]);

	NewGameSpeed = int(LastGameSpeed * 100);
	MyGameSpeed.Value = Clamp(NewGameSpeed,50,200);

	MyWeaponStay.Checked(LastWeaponStay);
	MyFriendlyFire.Value = LastFriendlyFire * 100;

	MyTranslocator.Checked(LastTranslocator);
	MyGoalScore.SetValue(LastGoalScore);
	MyTimeLimit.SetValue(LastTimeLimit);
	MyMaxLives.SetValue(LastMaxLives);

	MyGameSpeed.OnDrawCaption = InternalGameSpeedDraw;
	MyFriendlyFire.OnDrawCaption = InternalFriendlyFireDraw;

	Controls[4].FriendlyLabel = GUILabel(Controls[3]);
	Controls[8].FriendlyLabel = GUILabel(Controls[7]);

    MyWeaponThrowing = moCheckBox(Controls[12]); MyWeaponThrowing.Checked(bLastWeaponThrowing);
    MyBrightSkins	= moCheckBox(Controls[13]); MyBrightSkins.Checked(class'dmmutator'.default.bBrightSkins);


}

function string Play()
{
	local string url;

	LastGameSpeed = MyGameSpeed.Value / 100;
	LastWeaponStay = MyWeaponStay.IsChecked();
	LastTranslocator = MyTranslocator.IsChecked();
	LastFriendlyFire = MyFriendlyFire.Value/100;

	LastGoalScore = MyGoalScore.GetValue();
	LastTimeLimit = MyTimeLimit.GetValue();
	LastMaxLives  = MyMaxLives.GetValue();

    bLastWeaponThrowing = MyWeaponThrowing.IsChecked();


	SaveConfig();

	url = "?GameSpeed="$LastGameSpeed$"?WeaponStay="$LastWeaponStay$"?Translocator="$LastTranslocator$"?FriendlyFireScale="$LastFriendlyFire;
	url = url$"?GoalScore="$LastGoalScore$"?TimeLimit="$LastTimeLimit$"?MaxLives="$LastMAxLives;

    if (bLastWeaponThrowing)
    	URL=URL$"?AllowThrowing="$bLastWeaponThrowing;


	return url;
}

function string InternalGameSpeedDraw()
{
	return "("$int(MyGameSpeed.Value)@PercentText$")";
}

function string InternalFriendlyFireDraw()
{
	return "("$int(MyFriendlyFire.Value)@PercentText$")";
}

function BrightOnchange(GUIComponent Sender)
{

	class'dmmutator'.default.bBrightSkins = MyBrightSkins.IsChecked();
    class'dmmutator'.static.StaticSaveConfig();

}

defaultproperties
{
     bLastWeaponThrowing=True
     PercentText="percent"
     Begin Object Class=GUIImage Name=IARulesBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.024687
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.156016
     End Object
     Controls(0)=GUIImage'XInterface.Tab_InstantActionBaseRules.IARulesBK1'

     Begin Object Class=GUIImage Name=IARulesBK2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.239531
         WinLeft=0.509922
         WinWidth=0.469219
         WinHeight=0.487071
     End Object
     Controls(1)=GUIImage'XInterface.Tab_InstantActionBaseRules.IARulesBK2'

     Begin Object Class=GUIImage Name=IARulesBK3
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.239531
         WinLeft=0.019531
         WinWidth=0.469219
         WinHeight=0.487071
     End Object
     Controls(2)=GUIImage'XInterface.Tab_InstantActionBaseRules.IARulesBK3'

     Begin Object Class=GUILabel Name=IARulesGameSpeedLabel
         Caption="Game Speed"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.041406
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.Tab_InstantActionBaseRules.IARulesGameSpeedLabel'

     Begin Object Class=GUISlider Name=IARulesGameSpeedSlider
         MinValue=50.000000
         MaxValue=200.000000
         Hint="This option controls how fast the game will be played."
         WinTop=0.097552
         WinLeft=0.375000
         WinWidth=0.250000
         OnClick=IARulesGameSpeedSlider.InternalOnClick
         OnMousePressed=IARulesGameSpeedSlider.InternalOnMousePressed
         OnMouseRelease=IARulesGameSpeedSlider.InternalOnMouseRelease
         OnKeyEvent=IARulesGameSpeedSlider.InternalOnKeyEvent
         OnCapturedMouseMove=IARulesGameSpeedSlider.InternalCapturedMouseMove
     End Object
     Controls(4)=GUISlider'XInterface.Tab_InstantActionBaseRules.IARulesGameSpeedSlider'

     Begin Object Class=moCheckBox Name=IARulesWeaponStay
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Weapon Stay"
         OnCreateComponent=IARulesWeaponStay.InternalOnCreateComponent
         Hint="When enabled, weapons will always be available for pickup."
         WinTop=0.315104
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
     End Object
     Controls(5)=moCheckBox'XInterface.Tab_InstantActionBaseRules.IARulesWeaponStay'

     Begin Object Class=moCheckBox Name=IARulesTranslocator
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Include Translocator"
         OnCreateComponent=IARulesTranslocator.InternalOnCreateComponent
         Hint="Enable this option to allow Translocators."
         WinTop=0.428125
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
     End Object
     Controls(6)=moCheckBox'XInterface.Tab_InstantActionBaseRules.IARulesTranslocator'

     Begin Object Class=GUILabel Name=IARulesFriendlyFireLabel
         Caption="FriendlyFire"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.540833
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
     End Object
     Controls(7)=GUILabel'XInterface.Tab_InstantActionBaseRules.IARulesFriendlyFireLabel'

     Begin Object Class=GUISlider Name=IARulesFriendlyFireSlider
         MaxValue=200.000000
         Hint="This option controls how much damage you do to teammates."
         WinTop=0.600000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
         OnClick=IARulesFriendlyFireSlider.InternalOnClick
         OnMousePressed=IARulesFriendlyFireSlider.InternalOnMousePressed
         OnMouseRelease=IARulesFriendlyFireSlider.InternalOnMouseRelease
         OnKeyEvent=IARulesFriendlyFireSlider.InternalOnKeyEvent
         OnCapturedMouseMove=IARulesFriendlyFireSlider.InternalCapturedMouseMove
     End Object
     Controls(8)=GUISlider'XInterface.Tab_InstantActionBaseRules.IARulesFriendlyFireSlider'

     Begin Object Class=moNumericEdit Name=IARulesGoalScore
         MinValue=0
         MaxValue=99
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Goal Score"
         OnCreateComponent=IARulesGoalScore.InternalOnCreateComponent
         Hint="The game will end when this threshold is met."
         WinTop=0.315104
         WinLeft=0.553906
         WinWidth=0.400000
         WinHeight=0.040000
     End Object
     Controls(9)=moNumericEdit'XInterface.Tab_InstantActionBaseRules.IARulesGoalScore'

     Begin Object Class=moNumericEdit Name=IARulesTimeLimit
         MinValue=0
         MaxValue=3600
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Time Limit"
         OnCreateComponent=IARulesTimeLimit.InternalOnCreateComponent
         Hint="The game will end after this many minutes of play."
         WinTop=0.428125
         WinLeft=0.553906
         WinWidth=0.400000
         WinHeight=0.040000
     End Object
     Controls(10)=moNumericEdit'XInterface.Tab_InstantActionBaseRules.IARulesTimeLimit'

     Begin Object Class=moNumericEdit Name=IARulesMaxLives
         MinValue=0
         MaxValue=255
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Max Lives"
         OnCreateComponent=IARulesMaxLives.InternalOnCreateComponent
         Hint="If this value is not 0, you will only respawn this many times."
         WinTop=0.547656
         WinLeft=0.553906
         WinWidth=0.400000
         WinHeight=0.040000
     End Object
     Controls(11)=moNumericEdit'XInterface.Tab_InstantActionBaseRules.IARulesMaxLives'

     Begin Object Class=moCheckBox Name=IARulesAllowWeaponThrow
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Allow Weapon Throwing"
         OnCreateComponent=IARulesAllowWeaponThrow.InternalOnCreateComponent
         Hint="When selected, a player will have the ability to throw out his current weapon."
         WinTop=0.370833
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.040000
     End Object
     Controls(12)=moCheckBox'XInterface.Tab_InstantActionBaseRules.IARulesAllowWeaponThrow'

     Begin Object Class=moCheckBox Name=IARulesBrightSkins
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Bright Skins"
         OnCreateComponent=IARulesBrightSkins.InternalOnCreateComponent
         Hint="When selected, the server will cause the skins to be brighter than usual."
         WinTop=0.479585
         WinLeft=0.048242
         WinWidth=0.390626
         WinHeight=0.040000
         OnChange=Tab_InstantActionBaseRules.BrightOnchange
     End Object
     Controls(13)=moCheckBox'XInterface.Tab_InstantActionBaseRules.IARulesBrightSkins'

     WinTop=0.150000
     WinHeight=0.770000
}
