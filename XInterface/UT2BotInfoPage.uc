class UT2BotInfoPage extends UT2K3GUIPage;

var localized string NoInformation;
var GUIImage BotPortrait;
var GUILabel BotName, BotRace;
var array<GUIProgressBar> Bars;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	BotPortrait=GUIImage(Controls[1]);
	BotName=GUILabel(Controls[3]);
	BotRace=GUILabel(Controls[4]);
	Bars[0]=GUIProgressBar(Controls[5]);
	Bars[1]=GUIProgressBar(Controls[6]);
	Bars[2]=GUIProgressBar(Controls[7]);
	Bars[3]=GUIProgressBar(Controls[8]);
	Bars[4]=GUIProgressBar(Controls[9]);
}

function SetupBotInfo(Material Portrait, string DecoTextName, xUtil.PlayerRecord PRE)
{
	// Setup the Portrait from here
	BotPortrait.Image = PRE.Portrait;
	// Setup the decotext from here
	BotName.Caption = PRE.DefaultName;
	BotRace.Caption = PRE.Species.default.SpeciesName$" - "$class'XUtil'.static.GetFavoriteWeaponFor(PRE);

	Bars[0].Value=class'XUtil'.static.AccuracyRating(PRE);
	Bars[1].Value=class'XUtil'.static.AgilityRating(PRE);
	Bars[2].Value=class'XUtil'.static.TacticsRating(PRE);
	Bars[3].Value=class'XUtil'.static.AccuracyRating(PRE);
}


function bool OkClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
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
     Controls(0)=GUIImage'XInterface.UT2BotInfoPage.PageBack'

     Begin Object Class=GUIImage Name=imgBotPic
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Normal
         WinTop=0.170834
         WinLeft=0.078125
         WinWidth=0.246875
         WinHeight=0.658008
     End Object
     Controls(1)=GUIImage'XInterface.UT2BotInfoPage.imgBotPic'

     Begin Object Class=GUIImage Name=BotPortraitBorder
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.168751
         WinLeft=0.076563
         WinWidth=0.253125
         WinHeight=0.664258
     End Object
     Controls(2)=GUIImage'XInterface.UT2BotInfoPage.BotPortraitBorder'

     Begin Object Class=GUILabel Name=lblName
         Caption="Unknown"
         TextAlign=TXTA_Center
         TextColor=(B=253,G=216,R=153)
         WinTop=0.175781
         WinLeft=0.333008
         WinWidth=0.598437
         WinHeight=0.052539
     End Object
     Controls(3)=GUILabel'XInterface.UT2BotInfoPage.lblName'

     Begin Object Class=GUILabel Name=lblRace
         Caption="Unknown"
         TextAlign=TXTA_Center
         TextColor=(B=253,G=216,R=153)
         TextFont="UT2SmallFont"
         WinTop=0.231771
         WinLeft=0.332031
         WinWidth=0.609180
         WinHeight=0.047656
     End Object
     Controls(4)=GUILabel'XInterface.UT2BotInfoPage.lblRace'

     Begin Object Class=GUIProgressBar Name=myPB
         BarColor=(G=160,R=0)
         Value=45.000000
         Caption="Accuracy"
         FontName="UT2SmallFont"
         WinTop=0.329167
         WinLeft=0.335938
         WinWidth=0.600000
         WinHeight=0.062500
     End Object
     Controls(5)=GUIProgressBar'XInterface.UT2BotInfoPage.myPB'

     Begin Object Class=GUIProgressBar Name=myPB2
         BarColor=(G=160,R=0)
         Value=20.000000
         Caption="Agility"
         FontName="UT2SmallFont"
         WinTop=0.410417
         WinLeft=0.335938
         WinWidth=0.600000
         WinHeight=0.062500
     End Object
     Controls(6)=GUIProgressBar'XInterface.UT2BotInfoPage.myPB2'

     Begin Object Class=GUIProgressBar Name=myPB3
         BarColor=(G=160,R=0)
         Value=50.000000
         Caption="Tactics"
         FontName="UT2SmallFont"
         WinTop=0.491667
         WinLeft=0.335938
         WinWidth=0.600000
         WinHeight=0.062500
     End Object
     Controls(7)=GUIProgressBar'XInterface.UT2BotInfoPage.myPB3'

     Begin Object Class=GUIProgressBar Name=myPB4
         BarColor=(G=160,R=0)
         Value=75.000000
         Caption="Aggressiveness"
         FontName="UT2SmallFont"
         WinTop=0.572917
         WinLeft=0.335938
         WinWidth=0.600000
         WinHeight=0.062500
     End Object
     Controls(8)=GUIProgressBar'XInterface.UT2BotInfoPage.myPB4'

     Begin Object Class=GUIProgressBar Name=myPB5
         BarColor=(G=160,R=0)
         Value=70.000000
         Caption="..."
         FontName="UT2SmallFont"
         WinTop=0.654167
         WinLeft=0.335938
         WinWidth=0.600000
         WinHeight=0.062500
         bVisible=False
     End Object
     Controls(9)=GUIProgressBar'XInterface.UT2BotInfoPage.myPB5'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.762501
         WinLeft=0.703125
         WinWidth=0.237500
         WinHeight=0.060938
         OnClick=UT2BotInfoPage.OkClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(10)=GUIButton'XInterface.UT2BotInfoPage.OkButton'

     WinTop=0.150000
     WinHeight=0.700000
}
