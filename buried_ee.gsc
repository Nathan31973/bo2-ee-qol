#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zm_buried_sq_tpo;

main()
{
	replaceFunc( ::_are_all_players_in_time_bomb_volume, ::_are_all_players_in_time_bomb_volume_qol );
}

_are_all_players_in_time_bomb_volume_qol( e_volume )
{
	n_required_players = 4;
	a_players = get_players();
	if (getPlayers().size <= 3)
	{
		n_required_players = a_players.size;
	}
	n_players_in_position = 0;
	_a239 = a_players;
	_k239 = getFirstArrayKey( _a239 );
	while ( isDefined( _k239 ) )
	{
		player = _a239[ _k239 ];
		if ( player istouching( e_volume ) )
		{
			n_players_in_position++;
		}
		_k239 = getNextArrayKey( _a239, _k239 );
	}
	b_all_in_valid_position = n_players_in_position == n_required_players;
	return b_all_in_valid_position;
}

init()
{
	level thread buried_targets();
}

buried_targets()
{
	level endon("end_game");
	self endon("disconnect");
	for(;;)
	{
		flag_wait("sq_ows_start");
		if (getPlayers().size <= 3)
		{
			flag_set("sq_ows_success");
			break;
		}
	}
}
