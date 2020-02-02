class Browser_IRC extends Browser_Page;

var IRC_System			SystemPage;
var GUITabControl		ChannelTabs;
var localized string	SystemLabel;
var bool				bIrcIsInitialised;

var GUIButton			LeaveButton;
var GUIButton			BackButton;
var GUIButton			ChangeNickButton;
var localized string	LeaveChannelCaption;
var localized string	LeavePrivateCaptionHead;
var localized string	LeavePrivateCaptionTail;
var localized string	ChooseNewNickText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	// If not already initialised, create system page and add to tabs.
	if(!bIrcIsInitialised)
	{
		ChannelTabs = GUITabControl(Controls[1]);

		SystemPage = IRC_System( ChannelTabs.AddTab(SystemLabel, "xinterface.IRC_System", , , true) );
		SystemPage.IRCPage = self;

		ChannelTabs.OnChange = TabChange;

		SystemPage.SetCurrentChannel(-1); // Initially, System page is shown

		// Set up buttons
		BackButton = GUIButton(GUIPanel(Controls[0]).Controls[0]);
		BackButton.OnClick = BackClick;

		LeaveButton = GUIButton(GUIPanel(Controls[0]).Controls[1]);
		LeaveButton.bVisible = false;
		LeaveButton.OnClick = LeaveChannelClick;

		ChangeNickButton = GUIButton(GUIPanel(Controls[0]).Controls[2]);
		ChangeNickButton.OnClick = ChangeNickClick;

		bIrcIsInitialised=true;
	}
}

// delegates
function bool BackClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;		
} 

function bool ChangeNickClick(GUIComponent Sender)
{
	local IRC_NewNick NewNickDialog;

	if( SystemPage.Controller.OpenMenu("xinterface.IRC_NewNick") )
	{
		NewNickDialog = IRC_NewNick(SystemPage.Controller.TopPage());
		NewNickDialog.NewNickPrompt.Caption = ChooseNewNickText;
		NewNickDialog.SystemPage = SystemPage;
	}

	return true;
}

function TabChange(GUIComponent Sender)
{
	local GUITabButton TabButton;

	TabButton = GUITabButton(Sender);
		
	if ( TabButton == none )
		return;

	// If changed to system page - set channel to -1 (ie system)
	if( SystemPage == TabButton.MyPanel )
	{
		SystemPage.SetCurrentChannel(-1);
		LeaveButton.bVisible = false;
	}
	else
	{
		SystemPage.SetCurrentChannelPage( IRC_Channel( TabButton.MyPanel ) );

		// Set caption
		if( IRC_Private( TabButton.MyPanel ) != None)
			LeaveButton.Caption = LeavePrivateCaptionHead$Caps(TabButton.Caption)$LeavePrivateCaptionTail;
		else
			LeaveButton.Caption = LeaveChannelCaption;

		LeaveButton.bVisible = true;
	}

	TabButton.bForceFlash=false; // Stop any 'forced' flashing when we switch to a tab
}

function bool LeaveChannelClick(GUIComponent Sender)
{
	SystemPage.PartCurrentChannel();
	return true;		
}

defaultproperties
{
     SystemLabel="System"
     LeaveChannelCaption="LEAVE CHANNEL"
     LeavePrivateCaptionHead="CLOSE "
     ChooseNewNickText="Choose A New Chat Nickname"
     Begin Object Class=GUIPanel Name=FooterPanel
         Begin Object Class=GUIButton Name=MyBackButton
             Caption="BACK"
             StyleName="SquareMenuButton"
             WinWidth=0.200000
             WinHeight=1.000000
             OnKeyEvent=MyBackButton.InternalOnKeyEvent
         End Object
         Controls(0)=GUIButton'XInterface.Browser_IRC.MyBackButton'

         Begin Object Class=GUIButton Name=MyLeaveButton
             StyleName="SquareMenuButton"
             WinLeft=0.400000
             WinWidth=0.200000
             WinHeight=1.000000
             OnKeyEvent=MyLeaveButton.InternalOnKeyEvent
         End Object
         Controls(1)=GUIButton'XInterface.Browser_IRC.MyLeaveButton'

         Begin Object Class=GUIButton Name=MyChangeNickButton
             Caption="CHANGE NICK"
             StyleName="SquareMenuButton"
             WinLeft=0.200000
             WinWidth=0.200000
             WinHeight=1.000000
             OnKeyEvent=MyChangeNickButton.InternalOnKeyEvent
         End Object
         Controls(2)=GUIButton'XInterface.Browser_IRC.MyChangeNickButton'

         WinTop=0.950000
         WinHeight=0.050000
     End Object
     Controls(0)=GUIPanel'XInterface.Browser_IRC.FooterPanel'

     Begin Object Class=GUITabControl Name=ChannelTabControl
         bDockPanels=True
         TabHeight=0.040000
         WinHeight=48.000000
         bAcceptsInput=True
         OnActivate=ChannelTabControl.InternalOnActivate
     End Object
     Controls(1)=GUITabControl'XInterface.Browser_IRC.ChannelTabControl'

}
