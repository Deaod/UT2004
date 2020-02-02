//-----------------------------------------------------------
//
//-----------------------------------------------------------
class utvInteraction extends Interaction;

//P should always be set.. up is not set for the primary spectator
var PlayerController p;
var utvReplication UtvRep;
//var utvPlayer up;

var bool shownWelcome;
var float WelcomeWidth;
var float WelcomeMargin;
var float WelcomePos;
var int WelcomeStart[2];
var int WelcomeEnd[2];
var string WelcomeMsg[12];

var string WarnMsg;
var int Clients;
var int Delay;
var int RestartIn;

//primary only
var string ServerAddress;
var int ServerPort;
var int ListenPort;
var string JoinPassword;
var string PrimaryPassword;
var string VipPassword;
var string NormalPassword;
//var float Delay;
var int MaxClients;


//Remove ourselves if the level changes
event NotifyLevelChange()
{
	Log ("utv: Removed interaction");
	Master.RemoveInteraction (self);
}

simulated function SetState (bool primary)
{
	if (primary)
		GotoState ('Primary');
	else
		GotoState ('Secondary');
}

simulated function SetWarning (string msg)
{
	WarnMsg = msg;
}

function bool globalKeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local string tmp;

	if ((!shownWelcome) && (Action == IST_Press)) {
		shownWelcome = true;
		return true;
	}

	//Is it the key that would invoke say?
	if (Action == IST_Press) {
		tmp = Viewportowner.Actor.ConsoleCommand ("KEYNAME " $ key);
		if (tmp ~= "F8") {
			ShowMenu ();
			return true;
		}
	}

	return false;
}

//stub, overriden in states
function DrawWelcome (Canvas canvas)
{
}

function DrawTextBox (Canvas canvas, string text, bool sizing, float X, out float Y, float XW)
{
	local float LineSpace;
	local float WordSpace;
	local string cur;
	local float xl, yl;
	local int i;
	local float curx;

	Canvas.TextSize("A", XL, YL);
	LineSpace = (YL * 1.1) / Canvas.ClipY;
	Canvas.TextSize(" ", XL, YL);
	WordSpace = XL * 1.1;

    //Replace color tags with the codes that DrawText recognizes
    text = Repl(text, "<1>", chr(27) $ chr(255) $ chr(255) $ chr(255));
    text = Repl(text, "<2>", chr(27) $ "‡‡`");
    text = Repl(text, "<3>", chr(27) $ "‡@@");

	curx = 0;

	while (len (text) > 0) {
		i = InStr (text, " ");
		if (i == -1) {
			cur = text;
			text = "";
		} else {
			cur = Mid (text, 0, i);
			text = Mid (text, i + 1);
		}

		Canvas.TextSize (cur, xl, yl);
		if (curx + xl > xw * Canvas.ClipX) {
			Y+=LineSpace;
			Curx = 0;
		}

		if (!sizing) {
			Canvas.SetPos ((Canvas.ClipX * x) + curx, Canvas.ClipY * y);
			Canvas.DrawText (cur, false);
		}

		curx += xl + wordspace;
	}
	Y+=LineSpace;
}

function DrawWelcomeText (Canvas canvas, int index)
{
	local float x, y, xw, yw;
	local int i;

	Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX); // Update which font to use.

	yw = 0;
	xw = WelcomeWidth - WelcomeMargin*2;

	//Check sizing
	for (i = WelcomeStart[index]; i <= WelcomeEnd[index]; ++i) {
		DrawTextBox (canvas, WelcomeMsg[i], true, 0, yw, xw);
	}

	//Now draw it
	x = (1 - WelcomeWidth) / 2;
	y = ((1 - yw) / 2) - 0.1;		//kind of looks better with - 0.1

	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(Canvas.ClipX * x, Canvas.ClipY * y);
	//Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', Canvas.ClipX * WelcomeWidth, Canvas.ClipY * (yw + WelcomeMargin * 2));
	Canvas.DrawTileStretched(texture 'InterfaceContent.Menu.EditBoxDown', Canvas.ClipX * WelcomeWidth, Canvas.ClipY * (yw + WelcomeMargin * 2));

    //cPlayerHightlight ScoreBoxB/C      ButtonFocus
	y += WelcomeMargin;
	x += WelcomeMargin;

	for (i = WelcomeStart[index]; i <= WelcomeEnd[index]; ++i) {
		DrawTextBox (canvas, WelcomeMsg[i], false, x, y, xw);
	}
}

function DrawWarnMsg (Canvas canvas, string m)
{
	local float xl, yl;

    //Canvas.Font = class'HUD'.static.GetMediumFontFor (Canvas); //hm funka inte.. noo
    Canvas.Font = class'UT2MidGameFont'.static.GetMidGameFont(Canvas.ClipX);

	Canvas.StrLen(m,XL,YL);
	Canvas.DrawColor = class'HUD'.default.GoldColor;

	Canvas.SetPos(0.5*(Canvas.ClipX-XL), Canvas.ClipY * 0.15);
	Canvas.DrawText(m, true);
}

function DrawStats (Canvas canvas)
{
/*
	local float xl, yl;

    Canvas.Font = class'HUD'.static.GetConsoleFont (Canvas);
	Canvas.DrawColor = class'HUD'.default.WhiteColor;
	Canvas.StrLen("o_O", xl, yl);
	Canvas.SetPos(0.01 * (Canvas.ClipX), Canvas.ClipY * 0.25);
	Canvas.DrawText("UTV Clients: " $ Clients, true);
	Canvas.SetPos(0.01 * (Canvas.ClipX), Canvas.ClipY * 0.25 + yl * 1.1);
	Canvas.DrawText("UTV Delay: " $ Delay $ " seconds", true);
*/
}

function PostRender( canvas Canvas )
{
	if (p == none) {
		Log ("utv: Interaction setting playercontroller to " $ viewportowner.actor);
		p = ViewPortOwner.Actor;
	}

	Canvas.Style = p.ERenderStyle.STY_Alpha;

	if (!shownWelcome) {
		DrawWelcome (canvas);
	}

	//Anything important to tell the client?
	if (RestartIn > 0) {
		DrawWarnMsg (Canvas, "The UTV Proxy will restart in about " $ RestartIn $ " seconds");
	}
	else {
		if (WarnMsg != "") {
			DrawWarnMsg (Canvas, WarnMsg);
		}
	}

	DrawStats (Canvas);
}

function ShowChat (string msg)
{
	Viewportowner.Actor.ClientMessage (msg);
}

function ShowMenu ()
{
}

simulated function GotStatus (string s)
{
 	local string tmps;
 	local int i;

 	//Parse out the values
 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	clients = int (tmps);
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	delay = int (tmps);
 	s = Mid (s, i + 1);

 	restartin = int (s);

 	Log ("utv: Got status - " $ clients $ " - " $ delay $ " - " $ restartin);
}

simulated function GotBigStatus (string s)
{
 	local string tmps;
 	local int i;

 	//Parse out the values
 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	ServerAddress = tmps;
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	ServerPort = int (tmps);
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	ListenPort = int (tmps);
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	JoinPassword = tmps;
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	PrimaryPassword = tmps;
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	VipPassword = tmps;
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	NormalPassword = tmps;
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	Delay = float (tmps);
 	s = Mid (s, i + 1);

 	i = InStr (s, " ");
 	tmps = Mid (s, 0, i);
 	MaxClients = int (tmps);
 	s = Mid (s, i + 1);
}

state Primary
{
 	function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
		local string tmp;

		if (GlobalKeyEvent (Key, Action, Delta))
			return true;

		//Check stuff
		if (Action == IST_Press) {
			//teamsay key?
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYNAME " $ key);
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYBINDING " $ tmp);

			if (tmp ~= "TeamTalk") {
				p.ClientOpenMenu (class'utvReplication'.default.UtvPackage $ ".utvInputPage");
			    return true;
			}
		}
	}

   	function ShowMenu ()
	{
		if(ListenPort!=0){
			//StopForceFeedback();
			p.ClientMessage ("Opening menu");
			p.ClientOpenMenu(class'utvReplication'.default.UtvPackage $ ".utvPrimaryMenu");
		} else {
			p.ClientMessage ("Waiting for info from proxy");
		}
	}

	function DrawWelcome (canvas canvas)
	{
		DrawWelcomeText (canvas, 0);
	}

}

state Secondary
{
	function ShowMenu ()
	{
		//StopForceFeedback();
		p.ClientMessage ("Opening menu");
		p.ClientOpenMenu(class'utvReplication'.default.UtvPackage $ ".utvWatcherMenu");
	}

	function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
	{
		local string tmp;

		if (GlobalKeyEvent (Key, Action, Delta))
			return true;

		//Check stuff
		if (Action == IST_Press) {

			//Right mouse pressed?
			if (Key == IK_RightMouse) {
				if(utvRep.FollowPrimary){
					if(utvRep.SeeAll){
						utvRep.FollowPrimary=false;
						utvRep.FreeFlight=true;
						p.ClientMessage ("Free flight mode");
					} else {
						if (class'utvReplication'.default.wantBehindview)
							class'utvReplication'.default.wantBehindview = false;
						else
							class'utvReplication'.default.wantBehindview = true;
					}
				} else {
					if(utvRep.FreeFlight || class'utvReplication'.default.wantBehindview){
						utvRep.FreeFlight=false;
						if(utvRep.LastTargetName=="")
							utvRep.GetNextPlayer();
						if(class'utvReplication'.default.wantBehindview){
							p.ClientMessage ("Following player in 1st person view");
							class'utvReplication'.default.wantBehindview = false;
						} else {
							p.ClientMessage ("Following player with behindview");
							class'utvReplication'.default.wantBehindview = true;
						}
					} else {
						if(utvRep.NoPrimary){
							utvRep.FollowPrimary=false;
							utvRep.FreeFlight=true;
							p.ClientMessage ("Free flight mode");
						} else {
							class'utvReplication'.default.wantBehindview = false;
							utvRep.FollowPrimary=true;
							p.ClientMessage ("Following primary");
						}
					}
				}
				return true;
			}
			if (Key == IK_LeftMouse) {
				if(!utvRep.FollowPrimary){
					utvRep.GetNextPlayer();
					utvRep.FreeFlight=false;
					return true;
				}
			}

			//Or the say key?
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYNAME " $ key);
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYBINDING " $ tmp);

			if (tmp ~= "Talk") {
				p.ClientOpenMenu (class'utvReplication'.default.UtvPackage $ ".utvInputPage");
			    return true;
			}
			if (tmp ~= "MoveForward") {
				utvRep.MoveForward=true;
			}
			if (tmp ~= "MoveBackward") {
				utvRep.MoveBackward=true;
			}
			if (tmp ~= "StrafeLeft") {
				utvRep.MoveLeft=true;
			}
			if (tmp ~= "StrafeRight") {
				utvRep.MoveRight=true;
			}
			if (tmp ~= "Jump") {
				utvRep.MoveUp=true;
			}
			if (tmp ~= "Duck") {
				utvRep.MoveDown=true;
			}
		}
		if (Action == IST_Release) {
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYNAME " $ key);
			tmp = Viewportowner.Actor.ConsoleCommand ("KEYBINDING " $ tmp);

			if (tmp ~= "MoveForward") {
				utvRep.MoveForward=false;
			}
			if (tmp ~= "MoveBackward") {
				utvRep.MoveBackward=false;
			}
			if (tmp ~= "StrafeLeft") {
				utvRep.MoveLeft=false;
			}
			if (tmp ~= "StrafeRight") {
				utvRep.MoveRight=false;
			}
			if (tmp ~= "Jump") {
				utvRep.MoveUp=false;
			}
			if (tmp ~= "Duck") {
				utvRep.MoveDown=false;
			}
		}

		return false;
	}

	function DrawWelcome (canvas canvas)
	{
		DrawWelcomeText (canvas, 1);
	}

}

defaultproperties
{
     WelcomeWidth=0.400000
     WelcomeMargin=0.020000
     WelcomePos=0.200000
     WelcomeStart(1)=5
     WelcomeEnd(0)=4
     WelcomeEnd(1)=11
     WelcomeMsg(0)="Welcome to <2>UTV2004<1> Primary Client!"
     WelcomeMsg(2)="You are now broadcasting a game to people over the net! To configure settings and control the UTV server, press <2>F8<1> to bring up the configuration menu."
     WelcomeMsg(4)="Press any key to close this window.."
     WelcomeMsg(5)="Welcome to <2>UTV2004<1> Watcher Client!"
     WelcomeMsg(7)="You are watching a live broadcast of a game! To configure watcher settings press <2>F8<1> to bring up the configuration menu."
     WelcomeMsg(9)="To toggle between first and third person view, press the <2>right<1> mouse button."
     WelcomeMsg(11)="Press any key to close this window.."
     bVisible=True
}
