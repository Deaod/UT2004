//=============================================================================
// TeamVoicePack.
//=============================================================================
class TeamVoicePack extends VoicePack
	config
	abstract;

var() Sound NameSound[4]; // leader names

const MAXACK = 16;
var() Sound AckSound[MAXACK]; // acknowledgement sounds
var() localized string AckString[MAXACK];
var() localized string AckAbbrev[MAXACK];
var() name AckAnim[MAXACK];
var() int numAcks;

const MAXFIRE = 16;
var() Sound FFireSound[MAXFIRE];
var() localized string FFireString[MAXFIRE];
var() localized string FFireAbbrev[MAXFIRE];
var() name FFireAnim[MAXFIRE];
var() int numFFires;

const MAXTAUNT = 48;
var() Sound TauntSound[MAXTAUNT];
var() localized string TauntString[MAXTAUNT];
var() localized string TauntAbbrev[MAXTAUNT];
var() name TauntAnim[MAXTAUNT];
var() int numTaunts;
var config bool bShowMessageText;
var() byte MatureTaunt[MAXTAUNT];
var() byte HumanOnlyTaunt[MAXTAUNT]; // Whether this taunt should not be used by bots
var   float Pitch;
var string MessageString;
var name MessageAnim;
var byte DisplayString;
var String LeaderSign[4];

/* Orders (in same order as in Orders Menu
	0 = Defend,
	1 = Hold,
	2 = Attack,
	3 = Follow,
	4 = FreeLance
*/
const MAXORDER = 16;
var() Sound OrderSound[MAXORDER];
var() localized string OrderString[MAXORDER];
var() localized string OrderAbbrev[MAXORDER];
var() name OrderAnim[MAXORDER];

var string CommaText;

/* Other messages - use passed messageIndex
	0 = Base Undefended
	1 = Get Flag
	2 = Got Flag
	3 = Back up
	4 = Im Hit
	5 = Under Attack
	6 = Man Down
*/
const MAXOTHER = 48;
var() Sound OtherSound[MAXOTHER];
var() localized string OtherString[MAXOTHER];
var() localized string OtherAbbrev[MAXOTHER];
var() name OtherAnim[MAXOTHER];
var() byte OtherDelayed[MAXOTHER];
var() byte DisplayOtherMessage[MAXOTHER];
var() name OtherMesgGroup[MAXOTHER]; // Used to only show relevant comments in menu

const MAXPHRASE = 8;
var Sound Phrase[MAXPHRASE];
var string PhraseString[MAXPHRASE];
var int PhraseNum;
var() byte DisplayMessage[MAXPHRASE];
var PlayerReplicationInfo DelayedSender;

var Sound	DeathPhrases[MAXPHRASE];				// only spoken as alternative to death scream, not available from menus
var byte	HumanOnlyDeathPhrase[MAXPHRASE];
var int		NumDeathPhrases;

var array<Sound> HiddenPhrases;
var array<String> HiddenString;

var bool bForceMessageSound;
var bool bDisplayNextMessage;
var bool bDisplayPortrait;
var PlayerReplicationInfo PortraitPRI;

enum EVoiceGender
{
	VG_None,
	VG_Male,
	VG_Female
};

function string GetCallSign( PlayerReplicationInfo P )
{
	if ( P == None )
		return "";
	if ( (Level.NetMode == NM_Standalone) && (P.TeamID == 0) )
		return LeaderSign[P.Team.TeamIndex];
	else
		return P.PlayerName;
}

static function bool PlayDeathPhrase(Pawn P)
{
	local int pdNum, tryCount;
	local bool foundPhrase;

	if ( Default.NumDeathPhrases == 0 )
		return false;

	for(tryCount = 0; !foundPhrase && tryCount < 100; tryCount++)
	{
		pdNum = Rand(Default.NumDeathPhrases);

		if( !P.IsHumanControlled() &&  Default.HumanOnlyDeathPhrase[pdNum] == 1 )
			continue;

		foundPhrase = true;
	}

	if(!foundPhrase)
	{
		Log("PlayDeathPhrase: Could Not Find Suitable Phrase.");
		return false;
	}

	P.PlaySound(Default.DeathPhrases[pdNum], SLOT_Pain,2.5*P.TransientSoundVolume, true,500);
	return true;
}

static function int PickCustomTauntFor(controller C, bool bNoMature, bool bNoHumanOnly, int Start)
{
	local int result, tryCount;

	bNoMature = bNoMature || class'PlayerController'.Default.bNoMatureLanguage;
	if ( Start >= Default.NumTaunts - 1 )
		Start = 0;
		
	for(tryCount = 0; tryCount<8; tryCount++)
	{
		result = Start + rand(Default.NumTaunts- Start);

		if(C.DontReuseTaunt(result))
			continue;

		if(bNoMature && Default.MatureTaunt[result] == 1)
			continue;

		if(bNoHumanOnly && Default.HumanOnlyTaunt[result] == 1)
			continue;

		// Pick mature taunts less often...
		if(Default.MatureTaunt[result] == 1 && FRand() < 0.5)
			continue;

		return result;
	}
	if(bNoMature && Default.MatureTaunt[result] == 1)
		return Rand(3);

	return result;
}

static function int PickRandomTauntFor(controller C, bool bNoMature, bool bNoHumanOnly)
{
	return PickCustomTauntFor(C, bNoMature, bNoHumanOnly, 0);
}


function BotInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	local Sound MessageSound;

	DelayedSender = Sender;
	DisplayString = 0;
	if ( messagetype == 'ACK' )
	{
		SetAckMessage(Rand(NumAcks), Recipient, MessageSound);
		if ( messageIndex == 255 )
			SetTimer(0.3, false);
	}
	else
	{
		SetTimer(0.1, false);
		if ( messagetype == 'FRIENDLYFIRE' )
			SetFFireMessage(Rand(NumFFires), Recipient, MessageSound);
		else if ( (messagetype == 'AUTOTAUNT') || (messagetype == 'TAUNT') )
			SetTauntMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'ORDER' )
			SetOrderMessage(messageIndex, Recipient, MessageSound);
		else // messagetype == Other
			SetOtherMessage(messageIndex, Recipient, MessageSound);

		Phrase[0] = MessageSound;
		PhraseString[0] = MessageString;
		DisplayMessage[0] = DisplayString;
	}
}

static function int OrderToIndex(int Order, class<GameInfo> GameClass)
{
	return GameClass.Static.OrderToIndex(Order);
}

function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	local Sound MessageSound;

	DelayedSender = Sender;
	DisplayString = 0;
	bDisplayPortrait = false;
	bDisplayNextMessage = bShowMessageText && (MessageType != 'TAUNT') && (MessageType != 'AUTOTAUNT');
	if ( (PlayerController(Owner).PlayerReplicationInfo == Recipient) || (messagetype == 'OTHER') )
	{
		PortraitPRI = Sender;
		bDisplayPortrait = true;
	}
	else if ( (Recipient == None) && (messagetype == 'ORDER') )
	{
		PortraitPRI = Sender;
		bDisplayPortrait = true;
	}
	else if ( (PlayerController(Owner).PlayerReplicationInfo != Sender) && ((messagetype == 'ORDER') || (messagetype == 'ACK'))
			&& (Recipient != None) )
	{
		Destroy();
		return;
	}

	if(PlayerController(Owner).bNoVoiceMessages
		|| (PlayerController(Owner).bNoVoiceTaunts && (MessageType == 'TAUNT' || MessageType == 'AUTOTAUNT'))
		|| (PlayerController(Owner).bNoAutoTaunts && MessageType == 'AUTOTAUNT')
		)
	{
		Destroy();
		return;
	}

	if ( Sender.bBot )
	{
		BotInitialize(Sender, Recipient, messagetype, messageIndex);
		return;
	}

	SetTimer(0.6, false);

	if ( messagetype == 'ACK' )
		SetClientAckMessage(messageIndex, Recipient, MessageSound);
	else
	{
		if ( messagetype == 'FRIENDLYFIRE' )
			SetClientFFireMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'TAUNT' )
			SetClientTauntMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'AUTOTAUNT' )
		{
			SetClientTauntMessage(messageIndex, Recipient, MessageSound);
			SetTimer(1, false);
		}
		else if ( messagetype == 'ORDER' )
			SetClientOrderMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'HIDDEN' )
			SetClientHiddenMessage(messageIndex, Recipient, MessageSound);
		else // messagetype == Other
			SetClientOtherMessage(messageIndex, Recipient, MessageSound);
	}
	Phrase[0] = MessageSound;
	PhraseString[0] = MessageString;
	DisplayMessage[0] = DisplayString;
	if ( PlayerController(Owner).PlayerReplicationInfo == Sender )
		bForceMessageSound = true;
	else if ( (PlayerController(Owner).PlayerReplicationInfo == Recipient)
			&& (MessageType != 'TAUNT') && (MessageType != 'AUTOTAUNT') )
		bForceMessageSound = true;
}

function SetClientAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numAcks-1);
	MessageSound = AckSound[messageIndex];
	MessageString = AckString[messageIndex];
	if ( (Recipient != None) && (Level.NetMode == NM_Standalone)
		&& (recipient.TeamID == 0) && PlayerController(Owner).GameReplicationInfo.bTeamGame )
	{
		Phrase[1] = NameSound[Recipient.Team.TeamIndex];
	}
    MessageAnim = AckAnim[messageIndex];
}

function SetAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	SetTimer(3 + FRand(), false); // wait for initial order to be spoken
	Phrase[0] = AckSound[messageIndex];
	PhraseString[0] = AckString[messageIndex];
	if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) && PlayerController(Owner).GameReplicationInfo.bTeamGame )
	{
		Phrase[1] = NameSound[recipient.Team.TeamIndex];
		PhraseString[0] = PhraseString[0]@LeaderSign[recipient.Team.TeamIndex];
	}
    MessageAnim = AckAnim[messageIndex];
}

function SetClientFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numFFires-1);
	MessageSound = FFireSound[messageIndex];
	MessageString = FFireString[messageIndex];
    MessageAnim = FFireAnim[messageIndex];
}

function SetFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = FFireSound[messageIndex];
	MessageString = FFireString[messageIndex];
    MessageAnim = FFireAnim[messageIndex];
}

// Taunts from Players
function SetClientTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numTaunts-1);

	// If we are trying to set a mature message but its turned off - pick a new random one.
	if(MatureTaunt[messageIndex] == 1 && PlayerController(Owner).bNoMatureLanguage)
		messageIndex = PickRandomTauntFor(PlayerController(Owner), true, false);

	MessageSound = TauntSound[messageIndex];
	MessageString = TauntString[messageIndex];
    MessageAnim = TauntAnim[messageIndex];
}

// Taunts from Bots
function SetTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numTaunts-1);

	if(MatureTaunt[messageIndex] == 1 && PlayerController(Owner).bNoMatureLanguage)
		messageIndex = PickRandomTauntFor(PlayerController(Owner), true, true);

	MessageSound = TauntSound[messageIndex];
	MessageString = TauntString[messageIndex];
    MessageAnim = TauntAnim[messageIndex];
	SetTimer(1.0, false);
}

function SetClientOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = OrderSound[messageIndex];
	MessageString = OrderString[messageIndex];
    MessageAnim = OrderAnim[messageIndex];
}

// 'Hidden' Messages - only from players
function SetClientHiddenMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, HiddenPhrases.Length-1);
	MessageSound = HiddenPhrases[messageIndex];
	MessageString = HiddenString[messageIndex];
    MessageAnim = '';
}
//

function SetOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = OrderToIndex(messageIndex, Level.Game.Class);

	MessageSound = OrderSound[messageIndex];
	MessageString = OrderString[messageIndex];
    MessageAnim = OrderAnim[messageIndex];
}

// for Voice message popup menu - since order names may be replaced for some game types
static function string GetOrderString(int i, class<GameInfo> GameClass)
{
	if ( i > 9 )
		return ""; //high index order strings are alternates to the base orders

	i = OrderToIndex(i, GameClass);

	if ( Default.OrderAbbrev[i] != "" )
		return Default.OrderAbbrev[i];

	return Default.OrderString[i];
}

function SetClientOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = OtherSound[messageIndex];
	MessageString = OtherString[messageIndex];
	DisplayString = DisplayOtherMessage[messageIndex];
    MessageAnim = OtherAnim[messageIndex];
}

function SetOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	if ( OtherDelayed[messageIndex] != 0 )
		SetTimer(2.5 + 0.5*FRand(), false); // wait for initial request to be spoken
	MessageSound = OtherSound[messageIndex];
	MessageString = OtherString[messageIndex];
	DisplayString = DisplayOtherMessage[messageIndex];
    MessageAnim = OtherAnim[messageIndex];
}

// We can't use the normal ParseMessageString, because thats only really valid on the server.
// So we use a special one just for the %l (location) token.
static function string ClientParseChatPercVar(PlayerReplicationInfo PRI, String Cmd)
{
	if (cmd~="%L")
		return "("$PRI.GetLocationName()$")";
}

static function string ClientParseMessageString(PlayerReplicationInfo PRI, String Message)
{
	local string OutMsg;
	local string cmd;
	local int pos,i;

	OutMsg = "";
	pos = InStr(Message,"%");
	while (pos>-1)
	{
		if (pos>0)
		{
		  OutMsg = OutMsg$Left(Message,pos);
		  Message = Mid(Message,pos);
		  pos = 0;
	    }

		i = len(Message);
		cmd = mid(Message,pos,2);
		if (i-2 > 0)
			Message = right(Message,i-2);
		else
			Message = "";

		OutMsg = OutMsg$ClientParseChatPercVar(PRI, Cmd);
		pos = InStr(Message,"%");
	}

	if (Message!="")
		OutMsg=OutMsg$Message;

	return OutMsg;
}

function Timer()
{
	local PlayerController PlayerOwner;
	local string Mesg;

	PlayerOwner = PlayerController(Owner);
	if ( bDisplayPortrait && (PhraseNum == 0) && (PortraitPRI != None))
		PlayerController(Owner).myHUD.DisplayPortrait(PortraitPRI);
	if ( (Phrase[PhraseNum] != None) && (bDisplayNextMessage || (DisplayMessage[PhraseNum] != 0)) )
	{
		Mesg = ClientParseMessageString(DelayedSender, PhraseString[PhraseNum]);
		if ( Mesg != "" )
			PlayerOwner.TeamMessage(DelayedSender,Mesg,'TEAMSAYQUIET');
	}

	if ( (Phrase[PhraseNum] != None) && ((Level.TimeSeconds - PlayerOwner.LastPlaySpeech > 2) || (PhraseNum > 0) || bForceMessageSound)  )
	{
		PlayerOwner.LastPlaySpeech = Level.TimeSeconds;
		if ( (PlayerOwner.ViewTarget != None) )
		{
			PlayerOwner.ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Interface,1.5*TransientSoundVolume,,,Pitch,false);
		}
		else
		{
			PlayerOwner.PlaySound(Phrase[PhraseNum], SLOT_Interface,1.5*TransientSoundVolume,,,Pitch,false);
		}

        if (MessageAnim != '')
        {
            UnrealPlayer(PlayerOwner).Taunt(MessageAnim);
        }

		if ( Phrase[PhraseNum+1] == None )
			Destroy();
		else
		{
			SetTimer(GetSoundDuration(Phrase[PhraseNum]), false);
			PhraseNum++;
		}
	}
	else
		Destroy();
}


static function PlayerSpeech( name Type, int Index, string Callsign, Actor PackOwner )
{
	local name SendMode;
	local PlayerReplicationInfo Recipient;
	local int i;
	local GameReplicationInfo GRI;

	switch (Type)
	{
		case 'ACK':					// Acknowledgements
		case 'FRIENDLYFIRE':		// Friendly Fire
		case 'OTHER':				// Other
			SendMode = 'TEAM';		// Only send to team.
			Recipient = None;		// Send to everyone.
			break;
		case 'ORDER':				// Orders
			SendMode = 'TEAM';		// Only send to team.

			Index = OrderToIndex(Index, PackOwner.Level.Game.Class);

			GRI = PlayerController(PackOwner).GameReplicationInfo;
			if ( GRI.bTeamGame )
			{
				if ( Callsign == "" )
					Recipient = None;
				else
				{
					for ( i=0; i<GRI.PRIArray.Length; i++ )
						if ( (GRI.PRIArray[i] != None) && (GRI.PRIArray[i].PlayerName == Callsign)
							&& (GRI.PRIArray[i].Team == PlayerController(PackOwner).PlayerReplicationInfo.Team) )
						{
							Recipient = GRI.PRIArray[i];
							break;
						}
				}
			}
			break;
		case 'TAUNT':				// Taunts
		case 'HIDDEN':				// Hidden Taunts
			SendMode = 'GLOBAL';	// Send to all teams.
			Recipient = None;		// Send to everyone.
			break;
		default:
			SendMode = 'GLOBAL';
			Recipient = None;
	}
	if (!PlayerController(PackOwner).GameReplicationInfo.bTeamGame)
		SendMode = 'GLOBAL';  // Not a team game? Send to everyone.

	//Log("PlayerSpeech: "$Type$" Ix:"$Index$" Callsign:"$Callsign$" Recip:"$Recipient);
	Controller(PackOwner).SendVoiceMessage( Controller(PackOwner).PlayerReplicationInfo, Recipient, Type, Index, SendMode );
}

static function string GetAckString(int i)
{
	if ( Default.AckAbbrev[i] != "" )
		return Default.AckAbbrev[i];

	return default.AckString[i];
}

static function string GetFFireString(int i)
{
	if ( default.FFireAbbrev[i] != "" )
		return default.FFireAbbrev[i];

	return default.FFireString[i];
}

static function string GetTauntString(int i)
{
	if ( default.TauntAbbrev[i] != "" )
		return default.TauntAbbrev[i];

	return default.TauntString[i];
}

static function string GetOtherString(int i)
{
	if ( Default.OtherAbbrev[i] != "" )
		return default.OtherAbbrev[i];

	return default.OtherString[i];
}

static function GetAllAcks( out array<string> AckArray )
{
	local int i;

	AckArray.Length = 0;
	for ( i = 0; i < MAXACK; i++ )
	{
		if ( default.AckAbbrev[i] != "" )
			AckArray[AckArray.Length] = default.AckAbbrev[i];

		else if ( default.AckString[i] != "" )
			AckArray[AckArray.Length] = default.AckString[i];

		else break;
	}
}

static function GetAllFFire( out array<string> FFireArray )
{
	local int i;

	FFireArray.Length = 0;
	for ( i = 0; i < MAXFIRE; i++ )
	{
		if ( default.FFireAbbrev[i] != "" )
			FFireArray[FFireArray.Length] = default.FFireAbbrev[i];

		else if ( default.FFireString[i] != "" )
			FFireArray[FFireArray.Length] = default.FFireString[i];

		else break;
	}
}

static function GetAllOrder( out array<string> OrderArray )
{
	local int i;

	OrderArray.Length = 0;

	for ( i = 0; i < MAXORDER; i++ )
	{
		if ( default.OrderAbbrev[i] != "" )
			OrderArray[OrderArray.Length] = default.OrderAbbrev[i];

		else if ( default.OrderString[i] != "" )
			OrderArray[OrderArray.Length] = default.OrderString[i];

		else break;
	}
}

static function GetAllTaunt( out array<string> TauntArray, optional bool bNoMature )
{
	local int i;

	TauntArray.Length = 0;
	for ( i = 0; i < MAXTAUNT; i++ )
	{
		if ( bNoMature && default.MatureTaunt[i] > 0 )
			continue;
			
		if ( default.TauntAbbrev[i] != "" )
			TauntArray[TauntArray.Length] = default.TauntAbbrev[i];

		else if ( default.TauntString[i] != "" )
			TauntArray[TauntArray.Length] = default.TauntString[i];

		else break;
	}
}

static function GetAllOther( out array<string> OtherArray )
{
	local int i;

	OtherArray.Length = 0;
	for ( i = 0; i < MAXOTHER; i++ )
	{
		if ( default.OtherAbbrev[i] != "" )
			OtherArray[OtherArray.Length] = default.OtherAbbrev[i];

		else if ( default.OtherString[i] != "" )
			OtherArray[OtherArray.Length] = default.OtherString[i];

		else break;
	}
}

final simulated static function bool VoiceMatchesGender( EVoiceGender GenderType, string PlayerGender )
{
	if ( GenderType == VG_None )
		return true;

	if ( GenderType == VG_Male && PlayerGender ~= "Male" )
		return true;

	if ( GenderType == VG_Female && PlayerGender ~= "Female" )
		return true;

	return false;
}

defaultproperties
{
     bShowMessageText=True
     Pitch=1.000000
     LeaderSign(0)="Red Leader"
     LeaderSign(1)="Blue Leader"
     LeaderSign(2)="Green Leader"
     LeaderSign(3)="Gold Leader"
     CommaText=", "
}
