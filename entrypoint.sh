#!/bin/bash

echo SERVER STARTING!


## Downloading assets for the server
baseUrl="http://gameassets.aqtiongame.com/action"
# DL MAPS and map overrides

if [ $FULLMAPS == "TRUE" ]; then
# Old methods
#cp /aq2server/action/fullmaplist.ini /aq2server/action/maplist.ini
# Old method downloaded from https://github.com/actionquake/distrib/blob/main/server/fullmaplist.ini
wget "${baseUrl}/server/fullmaplist.ini" -O "/aq2server/action/maplist.ini"
wget "${baseUrl}/server/mapoverridelist.ini" -O "/aq2server/action/mapoverridelist.ini"
wget "${baseUrl}/server/entoverridelist.ini" -O "/aq2server/action/entoverridelist.ini"
else
  IFS=',' read -r -a rotation <<< "$ROTATION"
  for map in "${rotation[@]}"
  do
    echo $map >> /aq2server/action/maplist.ini
  done
fi
cat /aq2server/action/maplist.ini | while read map
do
    if [ ! -f "/aq2server/action/maps/${map}.bsp" ]; then
       wget "${baseUrl}/maps/${map}.bsp" -O "/aq2server/action/maps/${map}.bsp"
    fi
done
# Map overrides
mkdir -p /aq2server/action/map_overrides
cat /aq2server/action/mapoverridelist.ini | while read mapo
do
    if [ -f "/aq2server/action/map_overrides/${mapo}.bsp.override" ]; then
        echo "Map $mapo override exists."
    else
       wget -q "${baseUrl}/map_overrides/${mapo}.bsp.override" -O "/aq2server/action/map_overrides/${mapo}.bsp.override"
    fi
done
# End map overrides

# Ent overrides
cat /aq2server/action/entoverridelist.ini | while read mape
do
    if [ -f "/aq2server/action/map_overrides/${mape}.ent" ]; then
        echo "Ent $mape override exists."
    else
       wget -q "${baseUrl}/ents/${mape}.ent" -O "/aq2server/action/map_overrides/${mape}.ent"
    fi
done
# End ent downloads

# ## Download the latest Espionage scenes
# wget --timestamping "${baseUrl}/server/fullscenelist.ini" -O "/aq2server/action/scenelist.ini"

# ## `aqtion` branch has the latest scenes.  Not using Amazon S3 because it caches files and doesn't always get the latest.
# scenebaseUrl="https://raw.githubusercontent.com/actionquake/aq2-tng/aqtion/action"

# cat /aq2server/action/scenelist.ini | while read scene
# do
#   wget -q --timestamping "${scenebaseUrl}/tng/${scene}.esp" -O "/aq2server/action/tng/${scene}.esp"
# done

## Download the latest Espionage, Domination and CTF files
wget "${baseUrl}/tng/tng.zip" -O "/aq2server/tng.zip"
unzip -oq /aq2server/tng.zip -d /aq2server/action/

## Download and extract the bot navmesh zip file from S3
wget "${baseUrl}/bots/navmesh.zip" -O "/aq2server/navmesh.zip"
unzip -oq /aq2server/navmesh.zip -d /aq2server/action/

## Adapt this for other models skins once true_hitbox supports them
# Don't download skins for now, this was just a test

# mkdir -p /aq2server/action/players/{male,female,actionmale,aqmarine,messiah,sas,sydney,terror}
# cat /aq2server/action/skinlist.ini | while read skin
# do
#     if [ -f "/aq2server/action/players/male/${skin}" ]; then
#         echo "Skin $skin exists."
#     else 
#        wget "${baseUrl}/players/male/${skin}" -O "/aq2server/action/players/male/${skin}"
#     fi
# done

# Get IP address and convert it into a decimal + port (server_id uniqueness)
# Function to get the server IP in decimal format
ip2dec () {
    local a b c d
    IFS=. read -r a b c d <<< "$1"
    printf '%d\n' "$((a * 256 ** 3 + b * 256 ** 2 + c * 256 + d))"
}

# Function to get the server IP in dotted-decimal notation
get_server_ip () {
    echo "$1"
}

# Retrieve the IP address once
server_ip=$(curl -q -s http://checkip.amazonaws.com/)

# Get the decimal representation of the IP address
decimal_ip=$(ip2dec "$server_ip")

# Sets the server_id
if [ "$decimal_ip" -gt 0 ]; then
  server_id="S${decimal_ip}${PORT}"
else
  echo "I could not find your public IP!"
  removewhitespace=$(echo ${HOSTNAME} | tr -d '[:space:]')
  server_id="S${removewhitespace}${PORT}"
fi
echo "My server_id is ${server_id}"
echo "My server_ip is ${server_ip}"

# motd.txt
echo $MOTD > /aq2server/action/motd.txt

# teamplay.ini
echo "[team1]" > /aq2server/action/teamplay.ini
echo $TEAM_1_NAME >> /aq2server/action/teamplay.ini
echo $TEAM_1_SKIN >> /aq2server/action/teamplay.ini
echo "###" >> /aq2server/action/teamplay.ini
echo "[team2]" >> /aq2server/action/teamplay.ini
echo $TEAM_2_NAME >> /aq2server/action/teamplay.ini
echo $TEAM_2_SKIN >> /aq2server/action/teamplay.ini
echo "###" >> /aq2server/action/teamplay.ini
echo "[team3]" >> /aq2server/action/teamplay.ini
echo $TEAM_3_NAME >> /aq2server/action/teamplay.ini
echo $TEAM_3_SKIN >> /aq2server/action/teamplay.ini
echo "###" >> /aq2server/action/teamplay.ini
# add map rotation to teamplay.ini
echo "[maplist]" >> /aq2server/action/teamplay.ini
IFS=',' read -r -a rotation <<< "$ROTATION"
for map in "${rotation[@]}"
do
  echo $map >> /aq2server/action/teamplay.ini
  default_map=$map
done
echo "###" >> /aq2server/action/teamplay.ini

# config.cfg
# Server settings
echo "set hostname \"${HOSTNAME}\"" > /aq2server/action/config.cfg
echo "set net_port $PORT" >> /aq2server/action/config.cfg
echo "set dedicated $DEDICATED" >> /aq2server/action/config.cfg
echo "set public $PUBLIC" >> /aq2server/action/config.cfg
echo "set maxclients $MAXCLIENTS" >> /aq2server/action/config.cfg
echo "set sv_reserved_slots $SV_RESERVED_SLOTS" >> /aq2server/action/config.cfg
echo "set sv_fps $SV_FPS" >> /aq2server/action/config.cfg
echo "set warmup $WARMUP" >> /aq2server/action/config.cfg
echo "set warmup_bots $WARMUP_BOTS" >> /aq2server/action/config.cfg
echo "set use_newscore $USE_NEWSCORE" >> /aq2server/action/config.cfg
echo "set skipmotd $SKIPMOTD" >> /aq2server/action/config.cfg
echo "set motd_time $MOTD_TIME" >> /aq2server/action/config.cfg
echo "set radiolog $RADIOLOG" >> /aq2server/action/config.cfg
echo "set use_voice $USE_VOICE" >> /aq2server/action/config.cfg
echo "set use_ghosts $USE_GHOSTS" >> /aq2server/action/config.cfg
echo "setmaster $MASTER" >> /aq2server/action/config.cfg
echo "sets _admin $_ADMIN" >> /aq2server/action/config.cfg
echo "set q2a_config $Q2A_CONFIG" >> /aq2server/action/config.cfg
echo "set scoreboard $SCOREBOARD" >> /aq2server/action/config.cfg
echo "set map_override_path $MAP_OVERRIDE" >> /aq2server/action/config.cfg
echo "set sv_changemapcmd $SV_CHANGEMAPCMD" >> /aq2server/action/config.cfg
echo "set round_begin $ROUND_BEGIN" >> /aq2server/action/config.cfg

# Passwords
echo "set rcon_password $RCON_PASSWORD" >> /aq2server/action/config.cfg
echo "set sv_password $SV_PASSWORD" >> /aq2server/action/config.cfg
echo "set sv_mvd_password $SV_MVD_PASSWORD" >> /aq2server/action/config.cfg
echo "set sv_reserved_password $SV_RESERVED_PASSWORD" >> /aq2server/action/config.cfg
echo "set needpass $NEEDPASS" >> /aq2server/action/config.cfg

# Map rotation
echo "set actionmaps $ACTIONMAPS" >> /aq2server/action/config.cfg
echo "set rrot $RROT" >> /aq2server/action/config.cfg
echo "set vrot $VROT" >> /aq2server/action/config.cfg
echo "set empty_rotate $EMPTY_ROTATE" >> /aq2server/action/config.cfg
echo "set empty_exec $EMPTY_EXEC" >> /aq2server/action/config.cfg

# Lag settings
echo "set llsound $LLSOUND" >> /aq2server/action/config.cfg
echo "set bholelimit $BHOLELIMIT" >> /aq2server/action/config.cfg
echo "set bholelife $BHOLELIFE" >> /aq2server/action/config.cfg
echo "set splatlimit $SPLATLIMIT" >> /aq2server/action/config.cfg
echo "set splatlife $SPLATLIFE" >> /aq2server/action/config.cfg
echo "set shelloff $SHELLOFF" >> /aq2server/action/config.cfg
echo "set shelllimit $SHELLLIMIT" >> /aq2server/action/config.cfg
echo "set shelllife $SHELLLIFE" >> /aq2server/action/config.cfg
echo "set sv_gib $SV_GIB" >> /aq2server/action/config.cfg
echo "set sv_killgib $SV_KILLGIB" >> /aq2server/action/config.cfg
echo "set breakableglass $BREAKABLEGLASS" >> /aq2server/action/config.cfg
echo "set glassfragmentlimit $GLASSFRAGMENTLIMIT" >> /aq2server/action/config.cfg
echo "set sv_min_rate $SV_MIN_RATE" >> /aq2server/action/config.cfg
echo "set sv_max_rate $SV_MAX_RATE" >> /aq2server/action/config.cfg

#  Voting
echo "set use_cvote $USE_CVOTE" >> /aq2server/action/config.cfg
echo "set cvote_min $CVOTE_MIN" >> /aq2server/action/config.cfg
echo "set cvote_need $CVOTE_NEED" >> /aq2server/action/config.cfg
echo "set cvote_pass $CVOTE_PASS" >> /aq2server/action/config.cfg
echo "set configlistname $CONFIGLISTNAME" >> /aq2server/action/config.cfg
echo "set use_mapvote $USE_MAPVOTE" >> /aq2server/action/config.cfg
echo "set mapvote_min $MAPVOTE_MIN" >> /aq2server/action/config.cfg
echo "set mapvote_need $MAPVOTE_NEED" >> /aq2server/action/config.cfg
echo "set mapvote_pass $MAPVOTE_PASS" >> /aq2server/action/config.cfg
echo "set mapvote_waittime $MAPVOTE_WAITTIME" >> /aq2server/action/config.cfg
echo "set mv_public $MV_PUBLIC" >> /aq2server/action/config.cfg
echo "set use_kickvote $USE_KICKVOTE" >> /aq2server/action/config.cfg
echo "set kickvote_min $KICKVOTE_MIN" >> /aq2server/action/config.cfg
echo "set kickvote_need $KICKVOTE_NEED" >> /aq2server/action/config.cfg
echo "set kickvote_pass $KICKVOTE_PASS" >> /aq2server/action/config.cfg
echo "set kickvote_tempban $KICKVOTE_TEMPBAN" >> /aq2server/action/config.cfg
echo "set vk_public $VK_PUBLIC" >> /aq2server/action/config.cfg
echo "set kv_public $KV_PUBLIC" >> /aq2server/action/config.cfg
echo "set mapvote_next $MAPVOTE_NEXT" >> /aq2server/action/config.cfg
echo "set mapvote_next_time $MAPVOTE_NEXT_TIME" >> /aq2server/action/config.cfg
echo "set use_scramblevote $USE_SCRAMBLEVOTE" >> /aq2server/action/config.cfg
echo "set scramblevote_pass $SCRAMBLEVOTE_PASS" >> /aq2server/action/config.cfg
echo "set scramblevote_min $SCRAMBLEVOTE_MIN" >> /aq2server/action/config.cfg
echo "set scramblevote_need $SCRAMBLEVOTE_NEED" >> /aq2server/action/config.cfg

# Flood protection
echo "set flood_msgs $FLOOD_MSGS" >> /aq2server/action/config.cfg
echo "set flood_persecond $FLOOD_PERSECOND" >> /aq2server/action/config.cfg
echo "set flood_waitdelay $FLOOD_WAITDELAY" >> /aq2server/action/config.cfg
echo "set radio_repeat $RADIO_REPEAT" >> /aq2server/action/config.cfg
echo "set radio_ban $RADIO_BAN" >> /aq2server/action/config.cfg
echo "set radio_time $RADIO_TIME" >> /aq2server/action/config.cfg
echo "set radio_max $RADIO_MAX" >> /aq2server/action/config.cfg
echo "set sv_crlf $SV_CRLF" >> /aq2server/action/config.cfg
echo "set silenceban $SILENCEBAN" >> /aq2server/action/config.cfg

# Teamkill parameters
echo "set maxteamkills $MAXTEAMKILLS" >> /aq2server/action/config.cfg
echo "set tkbanrounds $TKBANROUNDS" >> /aq2server/action/config.cfg
echo "set twbanrounds $TWBANROUNDS" >> /aq2server/action/config.cfg
echo "set ff_afterround $FF_AFTERROUND" >> /aq2server/action/config.cfg

# Download settings
echo "set sv_downloadserver \"$SV_DOWNLOADSERVER\"" >> /aq2server/action/config.cfg
echo "set allow_download $ALLOW_DOWNLOAD" >> /aq2server/action/config.cfg
echo "set allow_download_skins $ALLOW_DOWNLOAD_SKINS" >> /aq2server/action/config.cfg
echo "set allow_download_players $ALLOW_DOWNLOAD_PLAYERS" >> /aq2server/action/config.cfg
echo "set allow_download_pics $ALLOW_DOWNLOAD_PICS" >> /aq2server/action/config.cfg
echo "set allow_download_sounds $ALLOW_DOWNLOAD_SOUNDS" >> /aq2server/action/config.cfg
echo "set allow_download_others ${ALLOW_DOWNLOAD_OTHERS}" >> /aq2server/action/config.cfg
echo "set allow_download_maps ${ALLOW_DOWNLOAD_MAPS}" >> /aq2server/action/config.cfg
echo "set allow_download_demos ${ALLOW_DOWNLOAD_DEMOS}" >> /aq2server/action/config.cfg

# Video checking
echo "set video_check $VIDEO_CHECK" >> /aq2server/action/config.cfg
echo "set video_force_restart $VIDEO_FORCE_RESTART" >> /aq2server/action/config.cfg
echo "set video_check_lockpvs $VIDEO_CHECK_LOCKPVS" >> /aq2server/action/config.cfg
echo "set video_check_glclear $VIDEO_CHECK_GLCLEAR" >> /aq2server/action/config.cfg
echo "set video_check_gldynamic $VIDEO_CHECK_GLDYNAMIC" >> /aq2server/action/config.cfg
echo "set video_checktime $VIDEO_CHECKTIME" >> /aq2server/action/config.cfg
echo "set video_max_3dfx \"$VIDEO_MAX_3DFX\"" >> /aq2server/action/config.cfg
echo "set video_max_3dfxam \"$VIDEO_MAX_3DFXAM\"" >> /aq2server/action/config.cfg
echo "set video_max_opengl \"$VIDEO_MAX_OPENGL\"" >> /aq2server/action/config.cfg

# General settings
echo "set dmflags $DMFLAGS" >> /aq2server/action/config.cfg
echo "set punishkills $PUNISHKILLS" >> /aq2server/action/config.cfg
echo "set noscore $NOSCORE" >> /aq2server/action/config.cfg
echo "set use_warnings $USE_WARNINGS" >> /aq2server/action/config.cfg
echo "set use_rewards $USE_REWARDS" >> /aq2server/action/config.cfg
echo "set use_balancer $USE_BALANCER" >> /aq2server/action/config.cfg
echo "set use_oldspawns $USE_OLDSPAWNS" >> /aq2server/action/config.cfg
echo "set sv_allow_map $SV_ALLOW_MAP" >> /aq2server/action/config.cfg
echo "set deadtalk $DEADTALK" >> /aq2server/action/config.cfg
echo "set force_skin $FORCE_SKIN" >> /aq2server/action/config.cfg
echo "set ppl_idletime $PPL_IDLETIME" >> /aq2server/action/config.cfg
echo "set sv_idleremove $SV_IDLEREMOVE" >> /aq2server/action/config.cfg
echo "set sv_idlekick $SV_IDLEKICK" >> /aq2server/action/config.cfg
echo "set g_spawn_items $G_SPAWN_ITEMS" >> /aq2server/action/config.cfg
echo "set mm_forceteamtalk $MM_FORCETEAMTALK" >> /aq2server/action/config.cfg
echo "set mm_adminpwd $MM_ADMINPWD" >> /aq2server/action/config.cfg
echo "set mm_allowlock $MM_ALLOWLOCK" >> /aq2server/action/config.cfg
echo "set mm_allowcount $MM_ALLOWCOUNT" >> /aq2server/action/config.cfg
echo "set mm_pausetime $MM_PAUSETIME" >> /aq2server/action/config.cfg
echo "set true_hitbox $TRUE_HITBOX" >> /aq2server/action/config.cfg
echo "set use_killcounts $USE_KILLCOUNTS" >> /aq2server/action/config.cfg
echo "set hearall $HEARALL" >> /aq2server/action/config.cfg
echo "set silentwalk $SILENTWALK" >> /aq2server/action/config.cfg
echo "set printrules $PRINTRULES" >> /aq2server/action/config.cfg
echo "set timedmsgs $TIMEDMSGS" >> /aq2server/action/config.cfg
echo "set g_highscores_dir $G_HIGHSCORES_DIR" >> /aq2server/action/config.cfg
echo "set g_highscores_countbots $G_HIGHSCORES_COUNTBOTS" >> /aq2server/action/config.cfg

# Misc
echo "set use_buggy_bandolier $USE_BUGGY_BANDOLIER" >> /aq2server/action/config.cfg
echo "set use_oldspawns $USE_OLDSPAWNS" >> /aq2server/action/config.cfg
echo "set medkit_drop $MEDKIT_DROP" >> /aq2server/action/config.cfg
echo "set medkit_time $MEDKIT_TIME" >> /aq2server/action/config.cfg
echo "set medkit_instant $MEDKIT_INSTANT" >> /aq2server/action/config.cfg
echo "set respawn_effect $RESPAWN_EFFECT" >> /aq2server/action/config.cfg
echo "set item_respawnmode $ITEM_RESPAWNMODE" >> /aq2server/action/config.cfg
echo "set item_respawn $ITEM_RESPAWN" >> /aq2server/action/config.cfg
echo "set ammo_respawn $AMMO_RESPAWN" >> /aq2server/action/config.cfg
echo "set weapon_respawn $WEAPON_RESPAWN" >> /aq2server/action/config.cfg
echo "set wave_time $WAVE_TIME" >> /aq2server/action/config.cfg
echo "set spectator_hud $SPECTATOR_HUD" >> /aq2server/action/config.cfg
echo "set zoom_comp $ZOOM_COMP" >> /aq2server/action/config.cfg
echo "set item_kit_mode $ITEM_KIT_MODE" >> /aq2server/action/config.cfg
echo "set sv_redirect_address $SV_REDIRECT_ADDRESS" >> /aq2server/action/config.cfg
echo "set sv_load_ent $SV_LOAD_ENT" >> /aq2server/action/config.cfg
echo "set sv_status_ext $SV_STATUS_EXT" >> /aq2server/action/config.cfg

# Game mode settings
echo "set deathmatch $DEATHMATCH" >> /aq2server/action/config.cfg
echo "set teamplay $TEAMPLAY" >> /aq2server/action/config.cfg
echo "set teamdm $TEAMDM" >> /aq2server/action/config.cfg
echo "set teamdm_respawn $TEAMDM_RESPAWN" >> /aq2server/action/config.cfg
echo "set ctf $CTF" >> /aq2server/action/config.cfg
echo "set ctf_mode $CTF_MODE" >> /aq2server/action/config.cfg
echo "set ctf_rewards $CTF_REWARDS" >> /aq2server/action/config.cfg
echo "set ctf_forcejoin $CTF_FORCEJOIN" >> /aq2server/action/config.cfg
echo "set ctf_dropflag $CTF_DROPFLAG" >> /aq2server/action/config.cfg
echo "set ctf_respawn $CTF_RESPAWN" >> /aq2server/action/config.cfg
echo "set ctf_model $CTF_MODEL" >> /aq2server/action/config.cfg
echo "set capturelimit $CAPTURELIMIT" >> /aq2server/action/config.cfg
echo "set ctf_dyn_respawn $CTF_DYN_RESPAWN" >> /aq2server/action/config.cfg

echo "set use_3teams $USE_3TEAMS" >> /aq2server/action/config.cfg
echo "set use_tourney $USE_TOURNEY" >> /aq2server/action/config.cfg
echo "set tourney_lca $TOURNEY_LCA" >> /aq2server/action/config.cfg
echo "set matchmode $MATCHMODE" >> /aq2server/action/config.cfg
echo "set darkmatch $DARKMATCH" >> /aq2server/action/config.cfg
echo "set day_cycle $DAY_CYCLE" >> /aq2server/action/config.cfg
echo "set auto_menu $AUTO_MENU" >> /aq2server/action/config.cfg
echo "set auto_join $AUTO_JOIN" >> /aq2server/action/config.cfg
echo "set auto_equip $AUTO_EQUIP" >> /aq2server/action/config.cfg
echo "set mm_captain_teamname $MM_CAPTAIN_TEAMNAME" >> /aq2server/action/config.cfg

echo "set highlander $HIGHLANDER" >> /aq2server/action/config.cfg

echo "set jump $JUMP" >> /aq2server/action/config.cfg

# LTK (bot) settings
echo "set ltk_loadbots $LTK_LOADBOTS" >> /aq2server/action/config.cfg
echo "set ltk_botfile $LTK_BOTFILE" >> /aq2server/action/config.cfg
echo "set ltk_skill $LTK_SKILL" >> /aq2server/action/config.cfg
echo "set ltk_chat $LTK_CHAT" >> /aq2server/action/config.cfg
echo "set ltk_jumpy $LTK_JUMPY" >> /aq2server/action/config.cfg
echo "set ltk_routing $LTK_ROUTING" >> /aq2server/action/config.cfg
echo "set ltk_classic $LTK_CLASSIC" >> /aq2server/action/config.cfg
echo "set am $AM" >> /aq2server/action/config.cfg
echo "set am_botcount $AM_BOTCOUNT" >> /aq2server/action/config.cfg
echo "set am_team $AM_TEAM" >> /aq2server/action/config.cfg
echo "set am_newnames $AM_NEWNAMES" >> /aq2server/action/config.cfg

# Rektek bot settings
echo "set bot_enable $BOT_ENABLE" >> /aq2server/action/config.cfg
echo "set bot_playercount $BOT_PLAYERCOUNT" >> /aq2server/action/config.cfg
echo "set bot_skill $BOT_SKILL" >> /aq2server/action/config.cfg
echo "set bot_skill_threshold $BOT_SKILL_THRESHOLD" >> /aq2server/action/config.cfg
echo "set bot_remember $BOT_REMEMBER" >> /aq2server/action/config.cfg
echo "set bot_reaction $BOT_REACTION" >> /aq2server/action/config.cfg
echo "set bot_maxteam $BOT_MAXTEAM" >> /aq2server/action/config.cfg
echo "set bot_rush $BOT_RUSH" >> /aq2server/action/config.cfg
echo "set bot_randvoice $BOT_RANDVOICE" >> /aq2server/action/config.cfg
echo "set bot_randskill $BOT_RANDSKILL" >> /aq2server/action/config.cfg
echo "set bot_randname $BOT_RANDNAME" >> /aq2server/action/config.cfg
echo "set bot_chat $BOT_CHAT" >> /aq2server/action/config.cfg
echo "set bot_personality $BOT_PERSONALITY" >> /aq2server/action/config.cfg
echo "set bot_ragequit $BOT_RAGEQUIT" >> /aq2server/action/config.cfg
echo "set bot_countashuman $BOT_COUNTASHUMAN" >> /aq2server/action/config.cfg
echo "set bot_navautogen $BOT_NAVAUTOGEN" >> /aq2server/action/config.cfg
echo "set bot_debug $BOT_DEBUG" >> /aq2server/action/config.cfg
echo "set bot_reportasclient $BOT_REPORTASCLIENT" >> /aq2server/action/config.cfg

# Limits
echo "set fraglimit $FRAGLIMIT" >> /aq2server/action/config.cfg
echo "set timelimit $TIMELIMIT" >> /aq2server/action/config.cfg
echo "set roundlimit $ROUNDLIMIT" >> /aq2server/action/config.cfg
echo "set roundtimelimit $ROUNDTIMELIMIT" >> /aq2server/action/config.cfg
echo "set limchasecam $LIMCHASECAM" >> /aq2server/action/config.cfg
echo "set knifelimit $KNIFELIMIT" >> /aq2server/action/config.cfg
echo "set sv_iplimit $IPLIMIT" >> /aq2server/action/config.cfg

# Weapons and items
echo "set allweapon $ALLWEAPON" >> /aq2server/action/config.cfg
echo "set weapons $WEAPONS" >> /aq2server/action/config.cfg
echo "set wp_flags $WP_FLAGS" >> /aq2server/action/config.cfg
echo "set allitem $ALLITEM" >> /aq2server/action/config.cfg
echo "set items $ITEMS" >> /aq2server/action/config.cfg
echo "set itm_flags $ITM_FLAGS" >> /aq2server/action/config.cfg
echo "set ir $IR" >> /aq2server/action/config.cfg
echo "set tgren $TGREN" >> /aq2server/action/config.cfg
echo "set dmweapon $DMWEAPON" >> /aq2server/action/config.cfg
echo "set hc_single $HC_SINGLE" >> /aq2server/action/config.cfg
echo "set use_classic $USE_CLASSIC" >> /aq2server/action/config.cfg
echo "set dm_choose $DM_CHOOSE" >> /aq2server/action/config.cfg
echo "set dm_shield $DM_SHIELD" >> /aq2server/action/config.cfg
echo "set uvtime $UVTIME" >> /aq2server/action/config.cfg
echo "set items $ITEMS" >> /aq2server/action/config.cfg
echo "set allow_hoarding $ALLOW_HOARDING" >> /aq2server/action/config.cfg
echo "set medkit_drop $MEDKIT_DROP" >> /aq2server/action/config.cfg
echo "set medkit_time $MEDKIT_TIME" >> /aq2server/action/config.cfg
echo "set use_randoms $USE_RANDOMS" >> /aq2server/action/config.cfg
echo "set unique_weapons $UNIQUE_WEAPONS" >> /aq2server/action/config.cfg
echo "set unique_items $UNIQUE_ITEMS" >> /aq2server/action/config.cfg
echo "set gun_dualmk23_enhance $GUN_DUALMK23_ENHANCE" >> /aq2server/action/config.cfg
echo "set loud_guns $LOUD_GUNS" >> /aq2server/action/config.cfg
echo "set sync_guns $SYNC_GUNS" >> /aq2server/action/config.cfg
echo "set use_gren_bonk $USE_GREN_BONK" >> /aq2server/action/config.cfg
echo "set lca_grenade $LCA_GRENADE" >> /aq2server/action/config.cfg

# Q2proded
echo "set g_protocol_extensions $G_PROTOCOL_EXTENSIONS" >> /aq2server/action/config.cfg
echo "set sv_uptime $SV_UPTIME" >> /aq2server/action/config.cfg
echo "set sv_calcpings_method $SV_CALCPINGS_METHOD" >> /aq2server/action/config.cfg
echo "set sv_waterjump_hack $SV_WATERJUMP_HACK" >> /aq2server/action/config.cfg
echo "set sv_packetdup_hack $SV_PACKETDUP_HACK" >> /aq2server/action/config.cfg
echo "set net_maxmsglen $NET_MAXMSGLEN" >> /aq2server/action/config.cfg
echo "set logfile_flush $LOGFILE_FLUSH" >> /aq2server/action/config.cfg
echo "set logfile $LOGFILE" >> /aq2server/action/config.cfg
echo "set logfile_name $LOGFILE_NAME" >> /aq2server/action/config.cfg
echo "set logfile_prefix $LOGFILE_PREFIX" >> /aq2server/action/config.cfg
echo "set stat_logs $STAT_LOGS" >> /aq2server/action/config.cfg
echo "addstuffcmd begin \"$ADDSTUFFCMD_BEGIN\"" >> /aq2server/action/config.cfg

# MVD
echo "set sv_mvd_enable $SV_MVD_ENABLE" >> /aq2server/action/config.cfg
echo "set sv_mvd_maxclients $SV_MVD_MAXCLIENTS" >> /aq2server/action/config.cfg
echo "set sv_mvd_begincmd \"putaway; h_cycle\"" >> /aq2server/action/config.cfg
echo "set sv_mvd_scorecmd \"h_cycle\"" >> /aq2server/action/config.cfg
echo "alias h_cycle \"h_cycle_sb; h_cycle_sb; h_cycle_sb; h_cycle_sb; h_cycle_sb\"" >> /aq2server/action/config.cfg
echo "alias h_cycle_sb \"wait; help; wait 40; help; wait 40; putaway;\"" >> /aq2server/action/config.cfg
echo "set mvd_default_map $MVD_DEFAULT_MAP" >> /aq2server/action/config.cfg
echo "set sv_mvd_maxtime $SV_MVD_MAXTIME" >> /aq2server/action/config.cfg
echo "set mvd_snaps $MVD_SNAPS" >> /aq2server/action/config.cfg
echo "set sv_mvd_nomsgs $SV_MVD_NOMSGS" >> /aq2server/action/config.cfg
echo "set sv_mvd_nogun $SV_MVD_NOGUN" >> /aq2server/action/config.cfg
echo "alias mvdrec \"say MVD recording started: ${com_date}_${com_time}_${mapname}.mvd2; mvdrecord -z ${com_date}_${com_time}_${mapname}\""

# Antilag
echo "set sv_antilag $SV_ANTILAG" >> /aq2server/action/config.cfg
echo "set sv_antilag_interp $SV_ANTILAG_INTERP" >> /aq2server/action/config.cfg
echo "set sv_limp_highping $SV_LIMP_HIGHPING" >> /aq2server/action/config.cfg

# Protocol 38
echo "set use_indicators $USE_INDICATORS" >> /aq2server/action/config.cfg
echo "set use_xerp $USE_XERP" >> /aq2server/action/config.cfg
echo "set spectator_hud $SPECTATOR_HUD" >> /aq2server/action/config.cfg
echo "set new_irvision $NEW_IRVISION" >> /aq2server/action/config.cfg

# Set ini files
echo "set ininame teamplay.ini" >> /aq2server/action/config.cfg
echo "set maplistname maplist.ini" >> /aq2server/action/config.cfg

# Display serverinfo in console when server starts up
echo "hostname" >> /aq2server/action/config.cfg
echo "serverinfo" >> /aq2server/action/config.cfg

# Espionage settings
echo "set esp $ESP" >> /aq2server/action/config.cfg
echo "set esp_enhancedslippers $ESP_ENHANCEDSLIPPERS" >> /aq2server/action/config.cfg
echo "set esp_punish $ESP_PUNISH" >> /aq2server/action/config.cfg
echo "set esp_leaderequip $ESP_LEADEREQUIP" >> /aq2server/action/config.cfg
echo "set esp_leaderenhance $ESP_LEADERENHANCE" >> /aq2server/action/config.cfg
echo "set esp_matchmode $ESP_MATCHMODE" >> /aq2server/action/config.cfg
echo "set esp_respawn_uvtime $ESP_RESPAWN_UVTIME" >> /aq2server/action/config.cfg
echo "set esp_atl $ESP_ATL" >> /aq2server/action/config.cfg
echo "set esp_etv_halftime $ESP_ETV_HALFTIME" >> /aq2server/action/config.cfg
echo "set esp_debug $ESP_DEBUG" >> /aq2server/action/config.cfg
echo "set medkit_max $MEDKIT_MAX" >> /aq2server/action/config.cfg
echo "set medkit_value $MEDKIT_VALUE" >> /aq2server/action/config.cfg


## Set logfile_prefix if stat_logs is enabled (official servers only)
if [ ${STAT_LOGS} == "1" ]; then
  echo 'set logfile_prefix "[%Y-%m-%d %H:%M] "' >> /aq2server/action/config.cfg
fi
# stat_log apikey
echo "set stat_apikey $STAT_APIKEY" >> /aq2server/action/config.cfg

## Server/Discord announcement info
echo "set sv_curl_enable $SV_CURL_ENABLE" >> /aq2server/action/config.cfg
echo "set sv_curl_stat_enable $SV_CURL_STAT_ENABLE" >> /aq2server/action/config.cfg
echo "set sv_discord_announce_enable $SV_DISCORD_ANNOUNCE_ENABLE" >> /aq2server/action/config.cfg
echo "set sv_aws_access_key $SV_AWS_ACCESS_KEY" >> /aq2server/action/config.cfg
echo "set sv_aws_secret_key $SV_AWS_SECRET_KEY" >> /aq2server/action/config.cfg
echo "set sv_curl_discord_info_url $SV_CURL_DISCORD_INFO_URL" >> /aq2server/action/config.cfg
echo "set sv_curl_discord_pickup_url $SV_CURL_DISCORD_PICKUP_URL" >> /aq2server/action/config.cfg
echo "set sv_curl_stat_api_url $SV_CURL_STAT_API_URL" >> /aq2server/action/config.cfg
echo "set msgflags $MSGFLAGS" >> /aq2server/action/config.cfg
echo "set use_pickup $USE_PICKUP" >> /aq2server/action/config.cfg

# Load map
echo "map $default_map" >> /aq2server/action/config.cfg

# Setup S3 vars to allow for demo uploading
sed -i "s-AWS_ACCESS_KEY-$AWS_ACCESS_KEY-g" /home/admin/.s3cfg
sed -i "s-AWS_SECRET_KEY-$AWS_SECRET_KEY-g" /home/admin/.s3cfg
sed -i "s%SERVERTARGETDIR%$SERVERTARGETDIR%g" /aq2server/plugins/mvd_transfer.sh

# TNG IRC Bot
echo "set ircserver $IRC_SERVER" >> /aq2server/action/config.cfg
echo "set ircchannel $IRC_CHANNEL" >> /aq2server/action/config.cfg
echo "set ircuser $server_id" >> /aq2server/action/config.cfg
echo "set ircbot $IRC_BOT" >> /aq2server/action/config.cfg

# Start the server!
/aq2server/q2proded +set game action +set net_port $PORT +exec config.cfg +set q2a_config $Q2A_CONFIG +seta server_id $server_id +seta server_ip $server_ip
