--
-- Q2Admin example configuration
-- 
-- rename to "config.lua" and place this to quake 2 root
--

plugins = {
  mvd = {
          mvd_webby = 'https://demos.aq2world.com',
          exec_script_on_system_after_recording = '/aq2server/plugins/mvd_transfer.sh',
          exec_script_cvars_as_parameters = {"q2a_mvd_file", "s3cmd"},
          needs_cvar_q2a_mvd_autorecord = false
  },
  coinflip = {}, -- Heads & Tails script
  broadcast = {}, -- Broadcast script
  version = {}, -- version feedback script
  scoreboardStore = {}, -- store scoreboard at match end into MVD2
  cvarbans = {
    root_dir = '/aq2server/',  -- rootdir of this server
    url = 'https://raw.githubusercontent.com/actionquake/q2admin/aqtion/action/force_xerp.cfg', -- url to download force_xerp.cfg
    check_interval = 5,
},
}