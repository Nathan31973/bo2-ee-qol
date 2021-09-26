#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;

init()
{
	level thread tranzit_solo();
}

tranzit_solo()
{ 
	level endon("end_game");
	self endon("disconnect");
	for(;;)
	{
		if ( (getPlayers().size <= 1) && (level.sq_progress[ "rich" ][ "C_screecher_light" ] >= 1) )
		{
			level.sq_progress[ "rich" ][ "C_screecher_light" ] += 4;
		}
		wait 1;
	}
}