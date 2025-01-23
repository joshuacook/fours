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
local AUDIO_DIRECTORY = norns.state.path .. "audio/"
local drum_1 = AUDIO_DIRECTORY .. "common/808/808-BD.wav"
local drum_2 = AUDIO_DIRECTORY .. "common/808/808-SD.wav"
local drum_3 = AUDIO_DIRECTORY .. "common/808/808-CH.wav"
local drum_4 = AUDIO_DIRECTORY .. "common/808/808-OH.wav"

-- Global state
local playing = false
local current_step = 1
local current_track = 1
local selected_beat = 1

-- Initialize softcut
function init_softcut()
  -- Voice 1 for drums 1-2
  softcut.buffer_clear()
  softcut.enable(1,1)
  softcut.buffer(1,1)
  softcut.level(1,1.0)
  softcut.position(1,0)
  softcut.play(1,0)
  softcut.rate(1,1.0)
  softcut.loop(1,0)
  softcut.loop_start(1,0)
  softcut.loop_end(1,1)
  
  -- Voice 2 for drums 3-4  
  softcut.enable(2,1)
  softcut.buffer(2,1)
  softcut.level(2,1.0)
  softcut.position(2,0)
  softcut.play(2,0)
  softcut.rate(2,1.0)
  softcut.loop(2,0)
  softcut.loop_start(2,0)
  softcut.loop_end(2,1)
end

function init()
  init_softcut()
  
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
      -- Play current step
      for track = 1,4 do
        local vol = current_song.beats[track][current_step]
        if vol > 0 then
          -- TODO: Trigger appropriate softcut voice with volume
        end
      end
      
      -- Advance step
      current_step = current_step % 16 + 1
      grid_dirty = true
      screen_dirty = true
    end
  end
end

-- Grid event handler
function g.key(x,y,z)
  if z == 1 then -- Only handle key down
    if y <= 4 then -- Beat programming area
      local track = 5-y -- Convert from bottom-up
      local step = x
      -- Cycle through volumes: 0 -> 1 -> 2 -> 0
      current_song.beats[track][step] = (current_song.beats[track][step] + 1) % 3
      grid_dirty = true
    end
  end
end

-- Grid redraw
function grid_redraw()
  if not grid_dirty then return end
  g:all(0)
  
  -- Draw sequence
  for track = 1,4 do
    for step = 1,16 do
      local y = 5-track
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
