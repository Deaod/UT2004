// ====================================================================
//  Class:  XInterface.Tab_MultiplayerHostServerSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_MultiplayerHostServerSettings extends UT2K3TabPanel;

var Config 	bool 	bDedicated;
var	Config	bool	bLanPlay;
var Config  int		BotSkill;
var Config  bool    bPlayersMustBeReady;
var Config	bool	bUseDefaults;
var Config	bool	bUseCustomBots;
var	Config	int		MinPlayers;
var Config 	int		MaxPlayers;
var Config	int		MaxSpecs;
var Config 	bool	bAllowBehindView;
var Config	string	AdminName;
var Config	string	AdminPass;
var Config	string	GamePass;
var Config  bool 	bBalanceTeams;
var Config  bool	bCollectStats;

var moCheckBox 		MyDedicated;
var moCheckBox 		MyLanGame;
var moCheckBox		MyAdvertise;
var moCheckBox 		MyCollectStats;
var moCheckBox 		MyBalanceTeams;
var moCheckBox		MyPlayersMustBeReady;
var moCheckBox		MyAllowBehindView;
var moComboBox		MyBotSkill;
var moCheckBox		MyUseDefaultBots;
var moCheckBox		MyUseCustomBots;
var moNumericEdit	MyMinPlayers;
var moNumericEdit	MyMaxPlayers;
var moNumericEdit	MyMaxSpecs;

var moEditBox		MyServerName;
var moEditBox		MyServerPasswrd;
var	moEditBox		MyAdminName;
var	moEditBox		MyAdminEmail;
var	moEditBox		MyAdminPasswrd;
var	moEditBox		MyMOTD1;
var	moEditBox		MyMOTD2;
var	moEditBox		MyMOTD3;
var	moEditBox		MyMOTD4;
var moCheckBox 		MyUseWebAdmin;
var moNumericEdit	MyWebPort;

var bool bInitialized;

delegate OnChangeCustomBots(bool Enable);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int	index;
	Super.InitComponent(MyController, MyOwner);

	MyDedicated 	= moCheckBox(Controls[2]);		MyDedicated.Checked(bDedicated);
	MyLanGame		= moCheckBox(Controls[3]);		MyLanGame.Checked(bLanPlay);
	MyAdvertise		= moCheckBox(Controls[4]);		MyAdvertise.Checked(class'MasterServerUplink'.default.DoUplink);
	MyCollectStats	= moCheckBox(Controls[5]);		MyCollectStats.Checked(bCollectStats);
	MyBalanceTeams	= moCheckBox(Controls[6]);		MyBalanceTeams.Checked(bBalanceTeams);

    MyPlayersMustBeReady = moCheckBox(Controls[7]); MyPlayersMustBeReady.Checked(bPlayersMustBeReady);

	MyBotSkill = moComboBox(Controls[8]);
	for(index = 0;index < 8;index++)
		MyBotSkill.AddItem(class'Tab_InstantActionMain'.default.DifficultyLevels[index]);
	MyBotSkill.ReadOnly(True);
	MyBotSkill.SetIndex(BotSkill);

	MyUseDefaultBots= moCheckbox(Controls[9]);		MyUseDefaultBots.Checked(bUseDefaults);
	MyUseCustomBots = moCheckbox(Controls[10]);		MyUseCustomBots.Checked(bUseCustomBots);

	MyMinPlayers	= moNumericEdit(Controls[11]);	MyMinPlayers.SetValue(MinPlayers);
	MyMaxPlayers	= moNumericEdit(Controls[12]);	MyMaxPlayers.SetValue(MaxPlayers);
	MyMaxSpecs		= moNumericEdit(Controls[13]);	MyMaxSpecs.SetValue(MaxSpecs);


	MyServerName	= moEditBox(Controls[14]);		MyServerName.SetText(class'GameReplicationInfo'.default.ServerName);
	MyServerPasswrd = moEditBox(Controls[15]);		MyServerPasswrd.SetText(GamePass);
	MyAdminName		= moEditBox(Controls[16]);		MyAdminName.SetText(AdminName);
	MyAdminEmail	= moEditBox(Controls[17]);		MyAdminEmail.SetText(class'GameReplicationInfo'.default.AdminEmail);
	MyAdminPasswrd	= moEditBox(Controls[18]);		MyAdminPasswrd.SetText(AdminPass);
//	MyMOTD1			= moEditBox(Controls[19]);		MyMOTD1.SetText(class'GameReplicationInfo'.default.MOTDLine1);
//	MyMOTD2			= moEditBox(Controls[20]);		MyMOTD2.SetText(class'GameReplicationInfo'.default.MOTDLine2);
//	MyMOTD3			= moEditBox(Controls[21]);		MyMOTD3.SetText(class'GameReplicationInfo'.default.MOTDLine3);
//	MyMOTD4			= moEditBox(Controls[22]);		MyMOTD4.SetText(class'GameReplicationInfo'.default.MOTDLine4);
	MyUseWebAdmin	= moCheckBox(Controls[23]);		MyUseWebAdmin.Checked(class'WebServer'.default.benabled);
	MyWebPort		= moNumericEdit(Controls[24]);	MyWebPort.SetValue(class'WebServer'.default.ListenPort);

    MyAllowBehindview = moCheckBox(Controls[25]); MyAllowBehindView.Checked(bAllowBehindView);

	bInitialized = true;

    MyAdminName.MyEditBox.bConvertSpaces = true;
    MyAdminPasswrd.MyEditBox.bConvertSpaces = true;
    MyServerPasswrd.MyEditBox.bConvertSpaces = true;

}

function string Play()
{
	local string url;
	local string gc;
	local Tab_MultiplayerHostMain pMain;

	bDedicated 		= MyDedicated.IsChecked();
	bCollectStats	= MyCollectStats.IsChecked();
	bBalanceTeams	= MyBalanceTeams.IsChecked();

	bPlayersMustBeReady = MyPlayersMustBeReady.IsChecked();

	bLanPlay   		= MyLanGame.IsChecked();
	BotSkill		= MyBotSkill.GetIndex();
	MinPlayers 		= MyMinPlayers.GetValue();
	MaxPlayers 		= MyMaxPlayers.GetValue();
	MaxSpecs  	 	= MyMaxSpecs.GetValue();
	bUseDefaults	= MyUseDefaultBots.IsChecked();
	bUseCustomBots	= MyUseCustomBots.IsChecked();
	GamePass		= MyServerPasswrd.GetText();
	AdminName		= MyAdminName.GetText();
	AdminPass		= MyAdminPasswrd.GetText();

	bAllowBehindView = MyAllowBehindview.IsChecked();

	SaveConfig();

	class'MasterServerUplink'.default.DoUplink = MyAdvertise.IsChecked();
	class'MasterServerUplink'.Static.StaticSaveConfig();

	class'GameReplicationInfo'.default.ServerName 	= MyServerName.GetText();
	class'GameReplicationInfo'.default.AdminName  	= AdminName;

	class'GameReplicationInfo'.default.AdminEmail 	= MyAdminEmail.GetText();
//	class'GameReplicationInfo'.default.MOTDLine1	= MyMOTD1.GetText();
//	class'GameReplicationInfo'.default.MOTDLine2	= MyMOTD2.GetText();
//	class'GameReplicationInfo'.default.MOTDLine3	= MyMOTD3.GetText();
//	class'GameReplicationInfo'.default.MOTDLine4	= MyMOTD4.GetText();
//	class'GameReplicationInfo'.static.StaticSaveConfig();

	class'WebServer'.Default.bEnabled = MyUseWebAdmin.IsChecked();
	class'WebServer'.Default.ListenPort = MyWebPort.GetValue();
	class'WebServer'.static.StaticSaveConfig();

	pMain = UT2MultiplayerHostPage(Controller.ActivePage).pMain;
	gc = pMain.GetGameClass();

	url = url$"?GameStats="$bCollectStats;
	if ( pMain.GetIsTeamGame() )
		url = url$"?BalanceTeams="$bBalanceTeams;

	if (bLanPlay)
		Url=URL$"?LAN";

	if (!bUseDefaults)
	{
		if(!bUseCustomBots)
			Url=URL$"?MinPlayers="$MinPlayers;
		Url=Url$"?MaxPlayers="$MaxPlayers$"?MaxSpectators="$MaxSpecs;
	}
	else
		Url=Url$"?bAutoNumBots=True";

	if ( (AdminName!="") && (AdminPass!="") )
		URL=URL$"?AdminName="$AdminName$"?AdminPassword="$AdminPass;

	if (GamePass!="")
		URL=URL$"?GamePassword="$GamePass;

    if (bPlayersMustBeReady)
    	URL=URL$"?PlayersMustBeReady="$bPlayersMustBeReady;

	if (bAllowBehindView)
    	URL=URL$"?AllowBehindview="$bAllowBehindView;

	URL = URL$"?difficulty="$BotSkill;

	return url;

}


function UseMapOnChange(GUIComponent Sender)
{
	if (!bInitialized)
    	return;

	if(!MyUseDefaultBots.IsChecked())
	{
		MyUseCustomBots.MenuStateChange(MSAT_Blurry);
		MyMaxPlayers.MenuStateChange(MSAT_Blurry);
		MyMaxSpecs.MenuStateChange(MSAT_Blurry);

		if(MyUseCustomBots.IsChecked())
			MyMinPlayers.MenuStateChange(MSAT_Disabled);
		else
			MyMinPlayers.MenuStateChange(MSAT_Blurry);

		OnChangeCustomBots(MyUseCustomBots.IsChecked());
	}
	else
	{
		MyUseCustomBots.MenuStateChange(MSAT_Disabled);
		MyMinPlayers.MenuStateChange(MSAT_Disabled);
		MyMaxPlayers.MenuStateChange(MSAT_Disabled);
		MyMaxSpecs.MenuStateChange(MSAT_Disabled);

		OnChangeCustomBots(False);
	}
}

function UseCustomOnChange(GUIComponent Sender)
{
	if (!bInitialized)
    	return;


	if(MyUseCustomBots.IsChecked())
		MyMinPlayers.MenuStateChange(MSAT_Disabled);
	else
		MyMinPlayers.MenuStateChange(MSAT_Blurry);

	OnChangeCustomBots(MyUseCustomBots.IsChecked());
}

function bool UseCustomBots()
{
	return !MyUseDefaultBots.IsChecked() && MyUseCustomBots.IsChecked();
}

defaultproperties
{
     Begin Object Class=GUIImage Name=MPServerBk1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.024687
         WinLeft=0.016758
         WinWidth=0.426248
         WinHeight=0.978440
     End Object
     Controls(0)=GUIImage'XInterface.Tab_MultiplayerHostServerSettings.MPServerBk1'

     Begin Object Class=GUIImage Name=MPServerBk2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.696041
         WinLeft=0.016172
         WinWidth=0.427032
         WinHeight=0.307188
     End Object
     Controls(1)=GUIImage'XInterface.Tab_MultiplayerHostServerSettings.MPServerBk2'

     Begin Object Class=moCheckBox Name=MPServerDedicated
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Dedicated Server"
         OnCreateComponent=MPServerDedicated.InternalOnCreateComponent
         Hint="When this option is enabled, you will run a dedicated server."
         WinTop=0.060001
         WinLeft=0.035742
         WinWidth=0.385938
         WinHeight=0.040000
     End Object
     Controls(2)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerDedicated'

     Begin Object Class=moCheckBox Name=MPServerLanGame
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Lan Game"
         OnCreateComponent=MPServerLanGame.InternalOnCreateComponent
         Hint="Optimizes network usage for players on a local area network."
         WinTop=0.118334
         WinLeft=0.035742
         WinWidth=0.385938
         WinHeight=0.040000
     End Object
     Controls(3)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerLanGame'

     Begin Object Class=moCheckBox Name=MPServerAdvertise
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Advertise Server"
         OnCreateComponent=MPServerAdvertise.InternalOnCreateComponent
         Hint="Publishes your server to the internet server browser."
         WinTop=0.185002
         WinLeft=0.035742
         WinWidth=0.385938
         WinHeight=0.040000
     End Object
     Controls(4)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerAdvertise'

     Begin Object Class=moCheckBox Name=MPServerCollectStats
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Collect Player Stats"
         OnCreateComponent=MPServerCollectStats.InternalOnCreateComponent
         Hint="Publishes player stats from your server on the UT2004 stats website."
         WinTop=0.247502
         WinLeft=0.035742
         WinWidth=0.385938
         WinHeight=0.040000
     End Object
     Controls(5)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerCollectStats'

     Begin Object Class=moCheckBox Name=MPServerBalanceTeams
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Balance Teams"
         OnCreateComponent=MPServerBalanceTeams.InternalOnCreateComponent
         Hint="Assigns teams automatically for players joining the server."
         WinTop=0.305835
         WinLeft=0.035742
         WinWidth=0.385938
         WinHeight=0.040000
     End Object
     Controls(6)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerBalanceTeams'

     Begin Object Class=moCheckBox Name=MPServerPlayersMustBeReady
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Players Must Be Ready"
         OnCreateComponent=MPServerPlayersMustBeReady.InternalOnCreateComponent
         Hint="When selected, all players will be required to press FIRE before the match begins."
         WinTop=0.362085
         WinLeft=0.035742
         WinWidth=0.385938
         WinHeight=0.040000
     End Object
     Controls(7)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerPlayersMustBeReady'

     Begin Object Class=moComboBox Name=MPServer_BotSkill
         Caption="Bot Skill"
         OnCreateComponent=MPServer_BotSkill.InternalOnCreateComponent
         Hint="Choose the skill of the bots you wish to play with."
         WinTop=0.547865
         WinLeft=0.036132
         WinWidth=0.385938
         WinHeight=0.060000
     End Object
     Controls(8)=moComboBox'XInterface.Tab_MultiplayerHostServerSettings.MPServer_BotSkill'

     Begin Object Class=moCheckBox Name=MPServerUseDefaults
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Use Map Defaults"
         OnCreateComponent=MPServerUseDefaults.InternalOnCreateComponent
         Hint="Uses the map's default minimum/maximum players settings."
         WinTop=0.622502
         WinLeft=0.036132
         WinWidth=0.385938
         WinHeight=0.040000
         OnChange=Tab_MultiplayerHostServerSettings.UseMapOnChange
     End Object
     Controls(9)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerUseDefaults'

     Begin Object Class=moCheckBox Name=MPServerUseCustomBots
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Use Custom Bots"
         OnCreateComponent=MPServerUseCustomBots.InternalOnCreateComponent
         Hint="When enabled, you may use the Bot tab to choose bots to play with."
         WinTop=0.716252
         WinLeft=0.036132
         WinWidth=0.385938
         WinHeight=0.040000
         OnChange=Tab_MultiplayerHostServerSettings.UseCustomOnChange
     End Object
     Controls(10)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerUseCustomBots'

     Begin Object Class=moNumericEdit Name=MPServerMinPlayers
         MinValue=0
         MaxValue=64
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Min player count"
         OnCreateComponent=MPServerMinPlayers.InternalOnCreateComponent
         Hint="Bots will join the game if there are fewer players than the minimum."
         WinTop=0.769792
         WinLeft=0.035156
         WinWidth=0.381250
         WinHeight=0.060000
     End Object
     Controls(11)=moNumericEdit'XInterface.Tab_MultiplayerHostServerSettings.MPServerMinPlayers'

     Begin Object Class=moNumericEdit Name=MPServerMaxPlayers
         MinValue=1
         MaxValue=64
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Max player count"
         OnCreateComponent=MPServerMaxPlayers.InternalOnCreateComponent
         Hint="Limits the number of players allowed to join the server at once."
         WinTop=0.842708
         WinLeft=0.035156
         WinWidth=0.381250
         WinHeight=0.060000
     End Object
     Controls(12)=moNumericEdit'XInterface.Tab_MultiplayerHostServerSettings.MPServerMaxPlayers'

     Begin Object Class=moNumericEdit Name=MPServerMaxSpecs
         MinValue=0
         MaxValue=64
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Max spectator count"
         OnCreateComponent=MPServerMaxSpecs.InternalOnCreateComponent
         Hint="Limits the number of spectators allowed to join the server at once."
         WinTop=0.915624
         WinLeft=0.035156
         WinWidth=0.381250
         WinHeight=0.060000
     End Object
     Controls(13)=moNumericEdit'XInterface.Tab_MultiplayerHostServerSettings.MPServerMaxSpecs'

     Begin Object Class=moEditBox Name=MPServerName
         CaptionWidth=0.400000
         Caption="Server Name"
         OnCreateComponent=MPServerName.InternalOnCreateComponent
         Hint="The server name will be displayed in the server browser."
         WinTop=0.060938
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(14)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerName'

     Begin Object Class=moEditBox Name=MPServerPW
         CaptionWidth=0.400000
         Caption="Game Password"
         OnCreateComponent=MPServerPW.InternalOnCreateComponent
         Hint="Players must enter the game password to join your server."
         WinTop=0.122605
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(15)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerPW'

     Begin Object Class=moEditBox Name=MPServerAdminName
         CaptionWidth=0.400000
         Caption="Admin Name"
         OnCreateComponent=MPServerAdminName.InternalOnCreateComponent
         Hint="The admin name will be displayed in the server browser."
         WinTop=0.217605
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(16)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerAdminName'

     Begin Object Class=moEditBox Name=MPServerAdminEmail
         CaptionWidth=0.400000
         Caption="Admin Email"
         OnCreateComponent=MPServerAdminEmail.InternalOnCreateComponent
         Hint="The admin email address will be displayed in the server browser."
         WinTop=0.282605
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(17)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerAdminEmail'

     Begin Object Class=moEditBox Name=MPServerAdminPW
         CaptionWidth=0.400000
         Caption="Admin Password"
         OnCreateComponent=MPServerAdminPW.InternalOnCreateComponent
         Hint="The admin password is used to connect to the server as an admin."
         WinTop=0.350938
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(18)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerAdminPW'

     Begin Object Class=moEditBox Name=MPServerMOTD1
         CaptionWidth=0.400000
         Caption="MOTD 1"
         OnCreateComponent=MPServerMOTD1.InternalOnCreateComponent
         Hint="Players see the message of the day when they join the server."
         WinTop=0.499271
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(19)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerMOTD1'

     Begin Object Class=moEditBox Name=MPServerMOTD2
         CaptionWidth=0.400000
         Caption="MOTD 2"
         OnCreateComponent=MPServerMOTD2.InternalOnCreateComponent
         Hint="Players see the message of the day when they join the server."
         WinTop=0.574271
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(20)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerMOTD2'

     Begin Object Class=moEditBox Name=MPServerMOTD3
         CaptionWidth=0.400000
         Caption="MOTD 3"
         OnCreateComponent=MPServerMOTD3.InternalOnCreateComponent
         Hint="Players see the message of the day when they join the server."
         WinTop=0.649271
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(21)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerMOTD3'

     Begin Object Class=moEditBox Name=MPServerMOTD4
         CaptionWidth=0.400000
         Caption="MOTD 4"
         OnCreateComponent=MPServerMOTD4.InternalOnCreateComponent
         Hint="Players see the message of the day when they join the server."
         WinTop=0.727604
         WinLeft=0.468750
         WinHeight=0.060000
     End Object
     Controls(22)=moEditBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerMOTD4'

     Begin Object Class=moCheckBox Name=MPServerUseWebAdmin
         ComponentJustification=TXTA_Left
         Caption="Web Admin"
         OnCreateComponent=MPServerUseWebAdmin.InternalOnCreateComponent
         Hint="Enables remote administration via the web."
         WinTop=0.869999
         WinLeft=0.468750
         WinWidth=0.206250
         WinHeight=0.040000
     End Object
     Controls(23)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerUseWebAdmin'

     Begin Object Class=moNumericEdit Name=MPServerWebPort
         MinValue=0
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Web Admin Port"
         OnCreateComponent=MPServerWebPort.InternalOnCreateComponent
         Hint="The port used to connect to the web admin site."
         WinTop=0.859791
         WinLeft=0.675156
         WinWidth=0.297625
         WinHeight=0.060000
     End Object
     Controls(24)=moNumericEdit'XInterface.Tab_MultiplayerHostServerSettings.MPServerWebPort'

     Begin Object Class=moCheckBox Name=MPServerAllowBehindView
         ComponentJustification=TXTA_Left
         CaptionWidth=0.925000
         Caption="Allow Behind view"
         OnCreateComponent=MPServerAllowBehindView.InternalOnCreateComponent
         Hint="When selected, the server will allow use of the 'behindview 1' console command."
         WinTop=0.476668
         WinLeft=0.035742
         WinWidth=0.385938
         WinHeight=0.040000
     End Object
     Controls(25)=moCheckBox'XInterface.Tab_MultiplayerHostServerSettings.MPServerAllowBehindView'

     WinTop=0.150000
     WinHeight=0.770000
}
