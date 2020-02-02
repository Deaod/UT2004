// front-end for the drafting page, to explain what the heck is going on
class UT2SP_DraftEventPage extends UT2SP_LadderEventPage;

var localized string MessageDraft, MessageDraftTitle;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super.Initcomponent(pMyController, MyOwner);
	lblCaption.Caption = MessageDraft;
	lblTitle.Caption = MessageDraftTitle;
}

function bool InternalOnClick(GUIComponent Sender) 
{
	if (Sender==btnOK) 
	{
		return Controller.ReplaceMenu("xInterface.UT2DraftTeam");
	} 
	else 
		return super.InternalOnClick(Sender);
}

function SetTutorialName(string tutname) 
{
}

defaultproperties
{
     MessageDraft="You have proven your valor in the qualification round,|and won the right to form your own team for the tournament.|Draft your team from the available free agents,|then enter the ladders of the team tournament--|but only after you have proven that you are fit to lead."
     MessageDraftTitle="Welcome to the Tournament"
}
