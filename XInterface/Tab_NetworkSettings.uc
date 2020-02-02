// ====================================================================
//  Class:  XInterface.Tab_OnlineSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_NetworkSettings extends UT2K3TabPanel;


var localized string	NetSpeedText[4];

var localized string	StatsURL;
var localized string    EpicIDMsg;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	local int i;
	Super.Initcomponent(MyController, MyOwner);

	for (i=0;i<Controls.Length;i++)
		Controls[i].OnChange=InternalOnChange;

	for(i = 0;i < ArrayCount(NetSpeedText);i++)
		moComboBox(Controls[1]).AddItem(NetSpeedText[i]);

	moEditBox(Controls[2]).MyEditBox.bConvertSpaces = true;
	moEditBox(Controls[2]).MyEditBox.MaxWidth=14;

	moEditBox(Controls[3]).MyEditBox.MaxWidth=14;

	moEditBox(Controls[3]).MaskText(true);
	moEditBox(Controls[2]).MenuStateChange(MSAT_Disabled);
	moEditBox(Controls[3]).MenuStateChange(MSAT_Disabled);

	GUILabel(Controls[8]).Caption = EpicIDMsg@FormatID(PlayerOwner().GetPlayerIDHash());

    moCheckBox(Controls[9]).Checked(PlayerOwner().bDynamicNetSpeed);

}

function string FormatID(string id)
{
    id=Caps(id);
	return mid(id,0,8)$"-"$mid(id,8,8)$"-"$mid(id,16,8)$"-"$mid(id,24,8);
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local int i;

	if (Sender==Controls[1])
	{
		i = class'Player'.default.ConfiguredInternetSpeed;
		if (i<=2600)
			moComboBox(Sender).SetText(NetSpeedText[0]);
		else if (i<=5000)
			moComboBox(Sender).SetText(NetSpeedText[1]);
		else if (i<=10000)
			moComboBox(Sender).SetText(NetSpeedText[2]);
		else
			moComboBox(Sender).SetText(NetSpeedText[3]);
	}
	else if (Sender==Controls[2])
	{
		if(PlayerOwner().StatsUserName!="" && PlayerOwner().StatsPassword!="")
		{
			moEditBox(Sender).SetText(PlayerOwner().StatsUserName);
			moEditBox(Sender).MenuStateChange(MSAT_Blurry);
		}
		else
		{
			moEditBox(Sender).SetText("");
			moEditBox(Sender).MenuStateChange(MSAT_Disabled);
		}
	}
	else if (Sender==Controls[3])
	{
		if(PlayerOwner().StatsUserName!="" && PlayerOwner().StatsPassword!="")
		{
			moEditBox(Sender).SetText(PlayerOwner().StatsPassword);
			moEditBox(Sender).MenuStateChange(MSAT_Blurry);
		}
		else
		{
			moEditBox(Sender).SetText("");
			moEditBox(Sender).MenuStateChange(MSAT_Disabled);
		}
	}
	else if (Sender==Controls[5])
	{
		GUICheckBoxButton(GUIMenuOption(Sender).MyComponent).SetChecked( PlayerOwner().StatsUserName!="" && PlayerOwner().StatsPassword!="" );
	}

	Controls[7].bVisible = !ValidStatConfig();
}

function bool ValidStatConfig()
{
	if(moCheckBox(Controls[5]).IsChecked())
	{
		if(Len(moEditBox(Controls[2]).GetText()) < 4)
			return false;

		if(Len(moEditBox(Controls[3]).GetText()) < 6)
			return false;
	}

	return true;
}

function ApplyStatConfig()
{
	if(moCheckBox(Controls[5]).IsChecked())
	{
		PlayerOwner().StatsUserName = moEditBox(Controls[2]).GetText();
		PlayerOwner().StatsPassword = moEditBox(Controls[3]).GetText();
	}
	else
	{
		PlayerOwner().StatsUserName = moEditBox(Controls[2]).GetText();
		PlayerOwner().StatsPassword = moEditBox(Controls[3]).GetText();
	}
	PlayerOwner().SaveConfig();
}

function InternalOnChange(GUIComponent Sender)
{
	local GUIMenuOption O;

	if (!Controller.bCurMenuInitialized)
		return;

	if (Sender==Controls[1])
	{
		if (moComboBox(Sender).GetText()==NetSpeedText[0])
			PlayerOwner().ConsoleCommand("netspeed 2600");
		else if (moComboBox(Sender).GetText()==NetSpeedText[1])
			PlayerOwner().ConsoleCommand("netspeed 5000");
		else if (moComboBox(Sender).GetText()==NetSpeedText[2])
			PlayerOwner().ConsoleCommand("netspeed 10000");
		else if (moComboBox(Sender).GetText()==NetSpeedText[3])
			PlayerOwner().ConsoleCommand("netspeed 20000");
	}
	else
	if (Sender==Controls[5])
	{
		O = GUIMenuOption(Sender);
		if ( !GUICheckBoxButton(O.MyComponent).bChecked )
		{
			moEditBox(Controls[2]).SetText("");
			moEditBox(Controls[3]).SetText("");
			moEditBox(Controls[2]).MenuStateChange(MSAT_Disabled);
			moEditBox(Controls[3]).MenuStateChange(MSAT_Disabled);
		}
		else
		{
			moEditBox(Controls[2]).MenuStateChange(MSAT_Blurry);
			moEditBox(Controls[3]).MenuStateChange(MSAT_Blurry);
		}
	}

    else if (Sender==Controls[9])
    {
    	PlayerOwner().bDynamicNetSpeed = moCheckBox(Controls[9]).IsChecked();
        PlayerOwner().Saveconfig();
    }

	Controls[7].bVisible = !ValidStatConfig();
}

function bool OnViewStats(GUIComponent Sender)
{
	PlayerOwner().ConsoleCommand("start"@StatsURL);
	return true;
}

defaultproperties
{
     NetSpeedText(0)="Modem"
     NetSpeedText(1)="ISDN"
     NetSpeedText(2)="Cable/ADSL"
     NetSpeedText(3)="LAN/T1"
     StatsURL="http://ut2003stats.epicgames.com/"
     EpicIDMsg="Your Unique id is:"
     Begin Object Class=GUIImage Name=OnlineBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.355208
         WinLeft=0.216797
         WinWidth=0.576640
         WinHeight=0.489999
     End Object
     Controls(0)=GUIImage'XInterface.Tab_NetworkSettings.OnlineBK1'

     Begin Object Class=moComboBox Name=OnlineNetSpeed
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.400000
         Caption="Connection"
         OnCreateComponent=OnlineNetSpeed.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Cable Modem/DSL"
         Hint="How fast is your connection?"
         WinTop=0.085678
         WinLeft=0.250000
         WinHeight=0.060000
         OnLoadINI=Tab_NetworkSettings.InternalOnLoadINI
     End Object
     Controls(1)=moComboBox'XInterface.Tab_NetworkSettings.OnlineNetSpeed'

     Begin Object Class=moEditBox Name=OnlineStatsName
         CaptionWidth=0.400000
         Caption="Stats UserName"
         OnCreateComponent=OnlineStatsName.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Please select a name to use for UT Stats!"
         WinTop=0.494271
         WinLeft=0.250000
         WinHeight=0.060000
         OnLoadINI=Tab_NetworkSettings.InternalOnLoadINI
     End Object
     Controls(2)=moEditBox'XInterface.Tab_NetworkSettings.OnlineStatsName'

     Begin Object Class=moEditBox Name=OnlineStatsPW
         CaptionWidth=0.400000
         Caption="Stats Password"
         OnCreateComponent=OnlineStatsPW.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Please select a password that will secure your UT Stats!"
         WinTop=0.583594
         WinLeft=0.250000
         WinHeight=0.060000
         OnLoadINI=Tab_NetworkSettings.InternalOnLoadINI
     End Object
     Controls(3)=moEditBox'XInterface.Tab_NetworkSettings.OnlineStatsPW'

     Begin Object Class=GUILabel Name=OnlineStatDesc
         Caption="UT2003 Global Stats"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         TextFont="UT2HeaderFont"
         WinTop=0.391145
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=32.000000
     End Object
     Controls(4)=GUILabel'XInterface.Tab_NetworkSettings.OnlineStatDesc'

     Begin Object Class=moCheckBox Name=OnlineTrackStats
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Track Stats"
         OnCreateComponent=OnlineTrackStats.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="True"
         Hint="Enable this option to join the online ranking system."
         WinTop=0.742708
         WinLeft=0.251565
         WinWidth=0.210000
         WinHeight=0.040000
         OnLoadINI=Tab_NetworkSettings.InternalOnLoadINI
     End Object
     Controls(5)=moCheckBox'XInterface.Tab_NetworkSettings.OnlineTrackStats'

     Begin Object Class=GUIButton Name=ViewOnlineStats
         Caption="View Stats"
         Hint="Click to launch the UT stats website."
         WinTop=0.742708
         WinLeft=0.536721
         WinWidth=0.210000
         OnClick=Tab_NetworkSettings.OnViewStats
         OnKeyEvent=ViewOnlineStats.InternalOnKeyEvent
     End Object
     Controls(6)=GUIButton'XInterface.Tab_NetworkSettings.ViewOnlineStats'

     Begin Object Class=GUILabel Name=InvalidWarning
         Caption="Your stats username or password is invalid.  Your username must be at least 4 characters long, and your password must be at least 6 characters long."
         TextAlign=TXTA_Center
         TextColor=(B=0,R=255)
         bMultiLine=True
         WinTop=0.870832
         WinLeft=0.215625
         WinWidth=0.576561
         WinHeight=0.125001
     End Object
     Controls(7)=GUILabel'XInterface.Tab_NetworkSettings.InvalidWarning'

     Begin Object Class=GUILabel Name=EpicID
         Caption="Your Unique id is:"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=255)
         TextFont="UT2SmallFont"
         bMultiLine=True
         WinTop=0.313279
         WinHeight=0.066407
     End Object
     Controls(8)=GUILabel'XInterface.Tab_NetworkSettings.EpicID'

     Begin Object Class=moCheckBox Name=NetworkDynamicNetspeed
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Dynamic Netspeed"
         OnCreateComponent=NetworkDynamicNetspeed.InternalOnCreateComponent
         Hint="Dynamic adjust your netspeed on slower connections."
         WinTop=0.179011
         WinLeft=0.250000
         WinHeight=0.040000
     End Object
     Controls(9)=moCheckBox'XInterface.Tab_NetworkSettings.NetworkDynamicNetspeed'

     WinTop=0.150000
     WinHeight=0.740000
}
