-- drum_grid
-- v0.1.0 @sonocircuit
-- llllllll.co/t/drum-grid
--
-- four track drum sequencer 
-- controlled by grid
--
-- E1: select track
-- E2: select beat
-- E3: change volume
-- K2: stop
-- K3: start/pause

local g = grid.connect()
local grid_dirty = true
local screen_dirty = true
local AUDIO_DIRECTORY = _path.audio
local drum_1 = AUDIO_DIRECTORY .. "common/808/808-BD.wav"
local drum_2 = AUDIO_DIRECTORY .. "common/808/808-SD.wav"
local drum_3 = AUDIO_DIRECTORY .. "common/808/808-CH.wav"
local drum_4 = AUDIO_DIRECTORY .. "common/808/808-OH.wav"

-- Global state
local playing = false
local current_step = 1
local current_track = 1
local selected_beat = 1

-- Load sample into softcut buffer
function load_sample(file_path, buffer, start_pos)
  if util.file_exists(file_path) then
    print("Loading " .. file_path)
    softcut.buffer_read_mono(file_path, 0, start_pos, -1, 1, 1)
  else
    print("File not found: " .. file_path)
  end
end

-- Initialize softcut
function init_softcut()
  -- Clear both buffers
  softcut.buffer_clear()
  
  -- Load all samples into buffer 1 (2 second regions)
  softcut.buffer_clear_region(1, 0, 32)
  
  print("Loading samples...")
  load_sample(drum_1, 1, 0)   -- 0-2s
  load_sample(drum_2, 1, 2)   -- 2-4s
  load_sample(drum_3, 1, 4)   -- 4-6s
  load_sample(drum_4, 1, 6)   -- 6-8s
  print("Samples loaded")
  
  -- Configure voices
  for v = 1,2 do
    softcut.enable(v,1)
    softcut.buffer(v,1)  -- both voices use buffer 1
    softcut.level(v,1.0)
    softcut.position(v,0)
    softcut.play(v,0)
    softcut.rate(v,1.0)
    softcut.loop(v,0)
    softcut.rec(v,0)
    
    -- Cut mode settings
    softcut.pre_level(v,0)
    softcut.pre_filter_dry(v,0)
    softcut.pre_filter_lp(v,1.0)
    softcut.pre_filter_hp(v,1.0)
    softcut.pre_filter_bp(v,1.0)
    softcut.pre_filter_br(v,1.0)
  end
end

function init()
  init_softcut()
  clock.run(grid_redraw_clock)
  
  -- Initialize default song data
  current_song = {
    title = "untitled",
    tempo = 120,
    beats = {
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- track 1
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- track 2
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- track 3
      {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}  -- track 4
    }
  }
  
  -- Start the clock
  clock.run(step)
end

-- Main sequencer loop
function step()
  while true do
    clock.sync(1/4) -- Sync to quarter notes
    
    if playing then
      -- Play current step with voice stealing
      -- Check high priority sounds first (1 & 3)
      for track = 1,4,2 do
        local vol = current_song.beats[track][current_step]
        if vol > 0 then
          local voice = track <= 2 and 1 or 2
          local pos = (track - 1) * 2
          softcut.position(voice, pos)
          softcut.level(voice, vol * 0.5)
          softcut.play(voice, 1)
        else
          -- If high priority sound isn't playing, check low priority sound
          local low_priority_track = track + 1
          local vol = current_song.beats[low_priority_track][current_step]
          if vol > 0 then
            local voice = low_priority_track <= 2 and 1 or 2
            local pos = (low_priority_track - 1) * 2
            softcut.position(voice, pos)
            softcut.level(voice, vol * 0.5)
            softcut.play(voice, 1)
          end
        end
      end
      
      -- Advance step
      current_step = current_step % 16 + 1
      grid_dirty = true
      screen_dirty = true
    end
    
    -- Always redraw grid even when not playing
    if grid_dirty then
      grid_redraw()
    end
  end
end

-- Grid event handler
function g.key(x,y,z)
  if z == 1 then -- Only handle key down
    if y >= 5 and y <= 8 then -- Beat programming area
      local track = y - 4 -- Row 5 = track 1, Row 8 = track 4
      local step = x
      -- Cycle through volumes: 0 -> 1 -> 2 -> 0
      current_song.beats[track][step] = (current_song.beats[track][step] + 1) % 3
      grid_dirty = true
    end
    -- Ignoring rows 5-8 for now
  end
end

-- Grid redraw
function grid_redraw()
  if not grid_dirty then return end
  g:all(0)
  
  -- Draw sequence (top 4 rows)
  for track = 1,4 do
    for step = 1,16 do
      local y = track + 4 -- Row 5 = track 1, Row 8 = track 4
      local brightness = current_song.beats[track][step] * 5 + 
                        (step == current_step and playing and 5 or 0)
      g:led(step,y,brightness)
    end
  end
  
  g:refresh()
  grid_dirty = false
end

-- Screen redraw
function redraw()
  if not screen_dirty then return end
  screen.clear()
  
  -- Draw basic info
  screen.move(0,10)
  screen.text(current_song.title)
  screen.move(0,20)
  screen.text("Track: " .. current_track)
  screen.move(0,30)
  screen.text("Step: " .. current_step)
  screen.move(0,40)
  screen.text("Tempo: " .. current_song.tempo)
  
  screen.update()
  screen_dirty = false
end

-- Encoder handler
function enc(n,d)
  if n == 1 then
    current_track = util.clamp(current_track + d, 1, 4)
  elseif n == 2 then
    selected_beat = util.clamp(selected_beat + d, 1, 16)
  elseif n == 3 then
    current_song.beats[current_track][selected_beat] = 
      util.clamp(current_song.beats[current_track][selected_beat] + d, 0, 2)
  end
  grid_dirty = true
  screen_dirty = true
end

-- Key handler
function key(n,z)
  if n == 2 and z == 1 then
    -- Stop
    playing = false
    current_step = 1
  elseif n == 3 and z == 1 then
    -- Start/pause
    playing = not playing
  end
  grid_dirty = true
  screen_dirty = true
end
-- Separate clock for grid updates
function grid_redraw_clock()
  while true do
    clock.sleep(1/30) -- 30fps grid refresh
    if grid_dirty then
      grid_redraw()
    end
  end
end
