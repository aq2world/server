--
-- Q2Admin example configuration
--
-- rename to "config.lua" and place this to quake 2 root
--

plugins = {
  lrcon = {
    quit_on_empty = false,
      cvars = {
      -- server
      'password', 'maxclients', 'timelimit', 'dmflags', 'sv_gravity', 'sv_iplimit', 'fraglimit',
      'sv_anticheat_required','sv_fps','esp_enhancedslippers','sv_antilag','use_xerp',

      -- mod
      'teamplay', 'ctf', 'matchmode', 'roundtimelimit', 'tgren', 'limchasecam', 'forcedteamtalk',
      'mm_forceteamtalk', 'ir', 'wp_flags', 'itm_flags', 'hc_single', 'use_punch',  'darkmatch',
      'allitem', 'allweapon', 'use_3teams','medkit_drop','medkit_instant',
      },
      modes = {
        '2v2-ldr-cl','2v2-ldr-eu','2v2-ldr-na','2v2-ldr-oc',
        'mm-cl','mm-eu','mm-na','mm-oc',
        'enhanced-dualmk23', 'enhanced-slippers-1', 'enhanced-slippers-2',
        'espionage', 'g-spawn-items', 'item-kit-mode',
      }
    },
  mvd = {
    mvd_webby = 'https://demos.aq2world.com',
    exec_script_on_system_after_recording = '/aq2server/plugins/mvd_transfer.sh',
    exec_script_cvars_as_parameters = {"q2a_mvd_file", "s3cmd"},
    needs_cvar_q2a_mvd_autorecord = false
  },
  version = {}, -- version feedback script
  coinflip = {}, -- toss a coin INGAME ;)
}
