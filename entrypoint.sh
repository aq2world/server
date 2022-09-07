#!/bin/bash

echo SERVER STARTING!

# DL MAPS

if [ $FULLMAPS == "TRUE" ]; then
cp /aq2server/action/fullmaplist.ini /aq2server/action/maplist.ini
else
  IFS=',' read -r -a rotation <<< "$ROTATION"
  for map in "${rotation[@]}"
  do
    echo $map >> /aq2server/action/maplist.ini
  done
fi

baseUrl="http://gameassets.aqtiongame.com/action/maps/"

cat /aq2server/action/maplist.ini | while read map
do
    if [ -f "/aq2server/action/maps/${map}.bsp" ]; then
        echo "Map $map exists."
    else 
       wget "${baseUrl}${map}.bsp" -O "/aq2server/action/maps/${map}.bsp"
    fi
done

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
# locked parameters
echo "game action" > /aq2server/action/config.cfg
echo "gamedir action" >> /aq2server/action/config.cfg

# Server settings
echo "set hostname \"${HOSTNAME}\"" >> /aq2server/action/config.cfg
echo "set net_port $PORT" >> /aq2server/action/config.cfg
echo "set dedicated $DEDICATED" >> /aq2server/action/config.cfg
echo "set public $PUBLIC" >> /aq2server/action/config.cfg
echo "set maxclients $MAXCLIENTS" >> /aq2server/action/config.cfg
echo "set sv_reserved_slots $SV_RESERVED_SLOTS" >> /aq2server/action/config.cfg
echo "set sv_fps $SV_FPS" >> /aq2server/action/config.cfg
echo "set warmup $WARMUP" >> /aq2server/action/config.cfg
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

# Passwords
echo "set rcon_password $RCON_PASSWORD" >> /aq2server/action/config.cfg
echo "set sv_password $SV_PASSWORD" >> /aq2server/action/config.cfg
echo "set sv_mvd_password $SV_MVD_PASSWORD" >> /aq2server/action/config.cfg
echo "set sv_reserved_password $SV_RESERVED_PASSWORD" >> /aq2server/action/config.cfg

# Map rotation
echo "set actionmaps $ACTIONMAPS" >> /aq2server/action/config.cfg
echo "set rrot $RROT" >> /aq2server/action/config.cfg
echo "set vrot $VROT" >> /aq2server/action/config.cfg

# Lag settings
echo "set llsound $LLSOUND" >> /aq2server/action/config.cfg
echo "set bholelimit $BHOLELIMIT" >> /aq2server/action/config.cfg
echo "set splatlimit $SPLATLIMIT" >> /aq2server/action/config.cfg
echo "set shelloff $SHELLOFF" >> /aq2server/action/config.cfg
echo "set sv_gib $SV_GIB" >> /aq2server/action/config.cfg
echo "set breakableglass $BREAKABLEGLASS" >> /aq2server/action/config.cfg
echo "set glassfragmentlimit $GLASSFRAGMENTLIMIT" >> /aq2server/action/config.cfg
echo "set sv_min_rate $SV_MIN_RATE" >> /aq2server/action/config.cfg
echo "set sv_max_rate $SV_MAX_RATE" >> /aq2server/action/config.cfg

#  Voting
echo "set use_cvote $USE_CVOTE" >> /aq2server/action/config.cfg
echo "set cvote_min $CVOTE_MIN" >> /aq2server/action/config.cfg
echo "set cvote_need $CVOTE_NEED" >> /aq2server/action/config.cfg
echo "set cvote_pass $CVOTE_PASS" >> /aq2server/action/config.cfg
#echo "set configlistname $CONFIGLISTNAME" >> /aq2server/action/config.cfg
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

# Teamkill parameters
echo "set maxteamkills $MAXTEAMKILLS" >> /aq2server/action/config.cfg
echo "set tkbanrounds $TKBANROUNDS" >> /aq2server/action/config.cfg
echo "set twbanrounds $twbanrounds" >> /aq2server/action/config.cfg
echo "set ff_afterround $FF_AFTERROUND" >> /aq2server/action/config.cfg

# Download settings
echo "set allow_download $ALLOW_DOWNLOAD" >> /aq2server/action/config.cfg
echo "set allow_download_skins $ALLOW_DOWNLOAD_SKINS" >> /aq2server/action/config.cfg
echo "set allow_download_players $ALLOW_DOWNLOAD_PLAYERS" >> /aq2server/action/config.cfg
echo "set allow_download_pics $ALLOW_DOWNLOAD_PICS" >> /aq2server/action/config.cfg
echo "set allow_download_sounds $ALLOW_DOWNLOAD_SOUNDS" >> /aq2server/action/config.cfg
echo "set sv_downloadserver \"$SV_DOWNLOADSERVER\"" >> /aq2server/action/config.cfg
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
echo "set auto_menu $AUTO_MENU" >> /aq2server/action/config.cfg
echo "set sv_allow_map $SV_ALLOW_MAP" >> /aq2server/action/config.cfg
echo "set deadtalk $DEADTALK" >> /aq2server/action/config.cfg
echo "set force_skin $FORCE_SKIN" >> /aq2server/action/config.cfg
echo "set ppl_idletime $PPL_IDLETIME" >> /aq2server/action/config.cfg
echo "set sv_idleremove $SV_IDLEREMOVE" >> /aq2server/action/config.cfg
echo "set sv_idlekick $SV_IDLEKICK" >> /aq2server/action/config.cfg
echo "set g_spawn_items $G_SPAWN_ITEMS" >> /aq2server/action/config.cfg

# Game mode settings
echo "set deathmatch $DEATHMATCH" >> /aq2server/action/config.cfg
echo "set teamplay $TEAMPLAY" >> /aq2server/action/config.cfg
echo "set teamdm $TEAMDM" >> /aq2server/action/config.cfg
echo "set ctf $CTF" >> /aq2server/action/config.cfg
echo "set ctf_mode $CTF_MODE" >> /aq2server/action/config.cfg
echo "set use_3teams $USE_3TEAMS" >> /aq2server/action/config.cfg
echo "set use_tourney $USE_TOURNEY" >> /aq2server/action/config.cfg
echo "set matchmode $MATCHMODE" >> /aq2server/action/config.cfg
echo "set darkmatch $DARKMATCH" >> /aq2server/action/config.cfg
echo "set ltk_loadbots $LTK_LOADBOTS" >> /aq2server/action/config.cfg
echo "set ltk_skill $LTK_SKILL" >> /aq2server/action/config.cfg
echo "set ltk_chat $LTK_CHAT" >> /aq2server/action/config.cfg
echo "set auto_join $AUTO_JOIN" >> /aq2server/action/config.cfg
echo "set auto_equip $AUTO_EQUIP" >> /aq2server/action/config.cfg


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
echo "set new_irvision $NEW_IRVISION" >> /aq2server/action/config.cfg
echo "set tgren $TGREN" >> /aq2server/action/config.cfg
echo "set dmweapon $DMWEAPON" >> /aq2server/action/config.cfg
echo "set hc_single $HC_SINGLE" >> /aq2server/action/config.cfg
echo "set use_classic $USE_CLASSIC" >> /aq2server/action/config.cfg
echo "set dm_choose $DM_CHOOSE" >> /aq2server/action/config.cfg
echo "set dm_shield $DM_SHIELD" >> /aq2server/action/config.cfg
echo "set items $ITEMS" >> /aq2server/action/config.cfg
echo "set allow_hoarding $ALLOW_HOARDING" >> /aq2server/action/config.cfg
echo "set medkit_drop $MEDKIT_DROP" >> /aq2server/action/config.cfg
echo "set medkit_time $MEDKIT_TIME" >> /aq2server/action/config.cfg
echo "set use_randoms $USE_RANDOMS" >> /aq2server/action/config.cfg

# Q2proded
echo "set sv_recycle $SV_RECYCLE" >> /aq2server/action/config.cfg
echo "set loud_guns $LOUD_GUNS" >> /aq2server/action/config.cfg
echo "set sync_guns $SYNC_GUNS" >> /aq2server/action/config.cfg
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
echo "addstuffcmd begin \"say vers: $version gdrv: $gl_driver \""

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

# Set ini files
echo "set ininame teamplay.ini" >> /aq2server/action/config.cfg
echo "set maplistname maplist.ini" >> /aq2server/action/config.cfg

# Display serverinfo in console when server starts up
echo "hostname" >> /aq2server/action/config.cfg
echo "serverinfo" >> /aq2server/action/config.cfg

# Espionage (non-TNG)
echo "set scripts $ETE_SCRIPTS" >> /aq2server/action/config.cfg
echo "set ogl $ETE_OGL" >> /aq2server/action/config.cfg
echo "set matchplay $ETE_MATCHPLAY" >> /aq2server/action/config.cfg
echo "set e_maxVolunteers $ETE_MAXVOLUNTEERS" >> /aq2server/action/config.cfg
echo "set e_mustVolunteer $ETE_MUSTVOLUNTEER" >> /aq2server/action/config.cfg
echo "set escore $ETE_ESCORE" >> /aq2server/action/config.cfg
echo "set allowMPELPSuicide $ETE_ALLOWMPELP" >> /aq2server/action/config.cfg
echo "set e_allRadio $ETE_ALLRADIO" >> /aq2server/action/config.cfg
echo "set e_useDefaultScenario $ETE_USEDEFSCENARIO" >> /aq2server/action/config.cfg
echo "set e_defaultScenarioName $ETE_DEFSCENARIONAME" >> /aq2server/action/config.cfg
echo "set e_carrierReturn $ETE_CARRIERRETURN" >> /aq2server/action/config.cfg
echo "set e_enhancedSlippers $ETE_ENHANCEDSLIPPERS" >> /aq2server/action/config.cfg
echo "set allowVotemap $ETE_ALLOWVOTEMAP" >> /aq2server/action/config.cfg
echo "set votemapPercentage $ETE_VOTEMAPPERCENT" >> /aq2server/action/config.cfg
echo "set allow_vote $ETE_ALLOWVOTE" >> /aq2server/action/config.cfg
echo "set e_voteWait $ETE_VOTEWAIT" >> /aq2server/action/config.cfg
echo "set sv_author $ETE_SVAUTHOR" >> /aq2server/action/config.cfg

## Set logfile_prefix if stat_logs is enabled (official servers only)
if [ ${STAT_LOGS} == "1" ]; then
  echo 'set logfile_prefix "[%Y-%m-%d %H:%M] "' >> /aq2server/action/config.cfg
fi
# stat_log apikey
echo "set stat_apikey $STAT_APIKEY" >> /aq2server/action/config.cfg

# Load map
echo "map $default_map" >> /aq2server/action/config.cfg

# Setup S3 vars to allow for demo uploading
sed -i "s-AWS_ACCESS_KEY-$AWS_ACCESS_KEY-g" /home/admin/.s3cfg
sed -i "s-AWS_SECRET_KEY-$AWS_SECRET_KEY-g" /home/admin/.s3cfg
sed -i "s-SERVERTARGETDIR-$SERVERTARGETDIR-g" /aq2server/plugins/mvd_transfer.sh

# Start the server!
## Sets the server_id
if [ ! -z $AWS_ACCESS_KEY ]; then
  SERVERID=${AWS_ACCESS_KEY}${PORT}
else
  SERVERID=NOID${PORT}
fi

/aq2server/q2proded +set game action +set net_port $PORT +exec config.cfg +set q2a_config $Q2A_CONFIG +seta server_id $SERVERID
