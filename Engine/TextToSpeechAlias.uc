class TextToSpeechAlias extends Object
	config(user)
	abstract
	native;

struct native SpeechReplacement
{
	var array<string>     MatchWords;
	var string            ReplaceWord;
};

var	config array<SpeechReplacement>		 Aliases;
var	config string				RemoveCharacters;

defaultproperties
{
     Aliases(0)=(MatchWords=("gg"),ReplaceWord="good game")
     Aliases(1)=(MatchWords=("rofl","rotfl","rotflmao"),ReplaceWord="rolls on floor laughing!")
     Aliases(2)=(MatchWords=("lol"),ReplaceWord="laughing out loud!")
     Aliases(3)=(MatchWords=("thx"),ReplaceWord="thanks")
     Aliases(4)=(MatchWords=("np"),ReplaceWord="no problem")
     Aliases(5)=(MatchWords=(":)",":-)",":P"),ReplaceWord="smile")
     Aliases(6)=(MatchWords=(";)",";-)",";P"),ReplaceWord="wink")
     Aliases(7)=(MatchWords=("omg","omfg"),ReplaceWord="oh my god!")
     Aliases(8)=(MatchWords=("ns"),ReplaceWord="nice shot")
     Aliases(9)=(MatchWords=("hf"),ReplaceWord="have fun")
     Aliases(10)=(MatchWords=("fc"),ReplaceWord="flag carrier")
     Aliases(11)=(MatchWords=("ih"),ReplaceWord="incoming high")
     Aliases(12)=(MatchWords=("iw"),ReplaceWord="incoming low")
     Aliases(13)=(MatchWords=("ir"),ReplaceWord="incoming right")
     Aliases(14)=(MatchWords=("il"),ReplaceWord="incoming left")
     Aliases(15)=(MatchWords=("thx"),ReplaceWord="thanks")
     Aliases(16)=(MatchWords=("gl"),ReplaceWord="good luck")
     Aliases(17)=(MatchWords=("cya"),ReplaceWord="seeya")
     Aliases(18)=(MatchWords=("gj"),ReplaceWord="good job")
     Aliases(19)=(MatchWords=("ty"),ReplaceWord="thank you")
     Aliases(20)=(MatchWords=("bbl"),ReplaceWord="be back later")
     Aliases(21)=(MatchWords=("brb"),ReplaceWord="be right back")
     Aliases(22)=(MatchWords=("bbiab"),ReplaceWord="be back in a bit")
     Aliases(23)=(MatchWords=("woot","w00t"),ReplaceWord="woute")
     Aliases(24)=(MatchWords=("woot!","w00t!"),ReplaceWord="woute!")
     Aliases(25)=(MatchWords=("woohoo"),ReplaceWord="woo who")
     RemoveCharacters="|:][}{^/\~()*"
}
