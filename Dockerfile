FROM ubuntu:18.04 AS buildstage

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget build-essential libsdl2-dev libopenal-dev libpng-dev libjpeg-dev zlib1g-dev mesa-common-dev libcurl4-gnutls-dev git lua5.1 libsdl1.2-dev libsdl1.2debian liblua5.1-0-dev git gcc-7 nano

# Cache hax
#ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

# Copy stuff
RUN mkdir /aq2server
COPY aq2-tng /aq2-tng
COPY q2admin /q2admin
COPY q2pro /q2pro
COPY q2admin.lua /aq2server/

# Compile stuff
RUN cd /aq2-tng/source && make
RUN cd /q2admin && make
RUN cd /q2pro && CONFIG_FILE=.ci/config_linux make q2proded

# Copy aq2-tng contents to aq2server
RUN cp -r /aq2-tng/action /aq2server/action
RUN cp /aq2-tng/source/gamex86_64.so /aq2server/action/gamex86_64.real.so

# Copy configs to aq2server
RUN cp -r /aq2-tng/action /aq2server/

# Copy q2admin to aq2server
RUN cp /q2admin/gamex86_64.so /aq2server/action/gamex86_64.so
RUN mkdir /aq2server/action/plugins
RUN cp /q2admin/plugins/* /aq2server/action/plugins/

# Copy q2pro to aq2server
RUN cp /q2pro/q2proded /aq2server/q2proded

# Cache hax
#ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install wget lua5.1 liblua5.1-0-dev -y

COPY --from=buildstage /aq2server /aq2server
# Copy and set entrypoint
COPY entrypoint.sh /aq2server
ENTRYPOINT /aq2server/entrypoint.sh

# Maps
COPY fullmaplist.ini /aq2server/action/
RUN mkdir /aq2server/action/maps

# Sounds
COPY sndlist.ini tourney.ini /aq2server/action/

# Create user and add rights to aq2server
RUN useradd -rm -d /home/admin -s /bin/bash -g root -G sudo -u 1001 admin
RUN chown -R admin /aq2server
USER admin
WORKDIR /aq2server


# motd.txt
ENV MOTD '==================================\n AQ2 server\n=================================='

# teamplay.ini
ENV TEAM_1_NAME 'Team 1'
ENV TEAM_1_SKIN 'male/ctf_r'
ENV TEAM_2_NAME 'Team 2'
ENV TEAM_2_SKIN 'male/ctf_b'
ENV TEAM_3_NAME 'Team 3'
ENV TEAM_3_SKIN 'male/ctf_g'

# config.cfg
# Server settings
ENV HOSTNAME AQtion Teamplay
ENV PORT 27910
ENV DEDICATED 1
ENV PUBLIC 1
ENV MAXCLIENTS 18
ENV SV_RESERVED_SLOTS 2
ENV SV_FPS 10
ENV WARMUP 20
ENV USE_NEWSCORE 3
ENV SKIPMOTD 0
ENV MOTD_TIME 5
ENV PPL_IDLETIME 10
ENV CHECK_TIME 5
ENV RADIOLOG 0
ENV USE_VOICE 1
ENV USE_GHOSTS 1
ENV MASTER 'master.quadaver.org master.q2servers.com'
ENV _ADMIN AQ2WORLD

# Passwords
ENV RCON_PASSWORD aq2world
ENV SV_PASSWORD ''
ENV SV_MVD_PASSWORD aq2world
ENV SV_RESERVED_PASSWORD ''

# Map rotation
ENV ACTIONMAPS 1
ENV RROT 0
ENV VROT 0
ENV ROTATION urban2,terminal,tjt,rok,city

# Lag settings
ENV LLSOUND 0
ENV BHOLELIMIT 0
ENV SPLATLIMIT 0
ENV SHELLOFF 1
ENV SV_GIB 1
ENV BREAKABLEGLASS 0
ENV GLASSFRAGMENTLIMIT 0

# Voting
ENV USE_CVOTE 1
ENV CVOTE_MIN 3
ENV CVOTE_NEED 49
ENV CVOTE_PASS 65
#ENV CONFIGLISTNAME configlist.ini
ENV USE_MAPVOTE 1
ENV MAPVOTE_MIN 2
ENV MAPVOTE_NEED 66
ENV MAPVOTE_PASS 50
ENV MAPVOTE_WAITTIME 8
ENV MV_PUBLIC 1
ENV USE_KICKVOTE 1
ENV KICKVOTE_MIN 2
ENV KICKVOTE_NEED 32
ENV KICKVOTE_PASS 29
ENV KICKVOTE_TEMPBAN 1
ENV VK_PUBLIC 1
ENV KV_PUBLIC 1

# Flood protection
ENV FLOOD_MSGS 0
ENV FLOOD_PERSECOND 4
ENV FLOOD_WAITDELAY 10
ENV RADIO_REPEAT 3
ENV RADIO_BAN 15
ENV RADIO_TIME 2
ENV RADIO_MAX 4
ENV SV_CRLF 1

# Teamkill parameters
ENV MAXTEAMKILLS 3
ENV TKBANROUNDS 0
ENV TWBANROUNDS 0
ENV FF_AFTERROUND 1

# Download settings
ENV ALLOW_DOWNLOAD 1
ENV ALLOW_DOWNLOAD_SKINS 1
ENV ALLOW_DOWNLOAD_PLAYERS 1
ENV ALLOW_DOWNLOAD_PICS 1
ENV ALLOW_DOWNLOAD_SOUNDS 1
ENV SV_DOWNLOADSERVER http://gameassets.aqtiongame.com/
ENV ALLOW_DOWNLOAD_OTHERS 1
ENV ALLOW_DOWNLOAD_MAPS 1
ENV ALLOW_DOWNLOAD_DEMOS 1

# Video checking
ENV VIDEO_CHECK 1
ENV VIDEO_FORCE_RESTART 0
ENV VIDEO_CHECK_LOCKPVS 1
ENV VIDEO_CHECK_GLCLEAR 1
ENV VIDEO_CHECK_GLDYNAMIC 0
ENV VIDEO_CHECKTIME 35
ENV VIDEO_MAX_3DFX 3.5
ENV VIDEO_MAX_3DFXAM 3.5
ENV VIDEO_MAX_OPENFL 7.0

# General settings
ENV DMFLAGS 768
ENV PUNISHKILLS 1
ENV NOSCORE 0
ENV NOHUD 0
ENV USE_WARNINGS 1
ENV USE_REWARDS 1
ENV USE_BALANCER 1
ENV USE_OLDSPAWNS 0
ENV AUTO_MENU 1
ENV SV_ALLOW_MAP 0

# Game mode settings
ENV DEATHMATCH 1
ENV TEAMPLAY 1
ENV TEAMDM 0
ENV CTF 0
ENV CTF_MODE 2
ENV USE_3teams 0
ENV USE_TOURNEY 0
ENV MATCHMODE 0
ENV DARKMATCH 0
ENV LTK_LOADBOTS 0
ENV LTK_SKILL 5
ENV LTK_CHAT 0

# Limits
ENV FRAGLIMIT 0
ENV TIMELIMIT 20
ENV ROUNDLIMIT 0
ENV ROUNDTIMELIMIT 3
ENV LIMCHASECAM 0
ENV KNIFELIMIT 40

# Weapons and items
ENV ALLWEAPON 0
ENV WEAPONS 1
ENV WP_FLAGS 511
ENV ALLITEM 0
ENV ITM_FLAGS 63
ENV IR 1
ENV NEW_IRVISION 0
ENV TGREN 1
ENV DMWEAPON 'MK23 Pistol'
ENV HC_SINGLE 1
ENV USE_CLASSIC 0
ENV DM_CHOOSE 1
ENV DM_SHIELD 30

# Q2proded
ENV SV_RECYCLE 1
ENV LOUD_GUNS 0
ENV SV_UPTIME 1
ENV SV_CALCPINGS_METHOD 2
ENV SV_WATERJUMP_HACK 1
ENV SV_PACKETDUP_HACK 1
ENV NET_MAXMSGLEN 0
ENV LOGFILE_FLUSH 0

# MVD
ENV SV_MVD_ENABLE 2
ENV SV_MVD_MAXCLIENTS 2
ENV MVD_DEFAULT_MAP wfall
ENV SV_MVD_MAXTIME 30
ENV MVD_SNAPS 2
ENV MVD_WAIT_DELAY 12
ENV SV_MVD_NOMSGS 0
ENV SV_MVD_NOGUN 0

# Antilag
ENV SV_ANTILAG 1
ENV SV_ANTILAG_INTERP 0