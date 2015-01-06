# Takes a properly formatted SMPTE timecode as a string and splits into hh, mm, ss, ff
# ie - 00:00:00;00
def timecode_split(timecode)

  is_valid_timecode(timecode) # Check for valid TC at start
  hh = timecode[0, 2].to_i
  mm = timecode[3, 2].to_i
  ss = timecode[6, 2].to_i
  ff = timecode[9, 2].to_i
  if timecode[8] == ';'
    is_drop = true
  else
    is_drop = false
  end
  timecode_array = { hh: hh, mm: mm, ss: ss, ff: ff, is_drop: is_drop }
  #puts timecode_array
  return timecode_array
end

#Validates valid timecode input
def is_valid_fps(fps)
  valid_fps_array = [30, 29.97, 25, 24, 23.98]
  if valid_fps_array.include?(fps)
    true
  else
    raise "\nERROR: Invalid framerate.\nPlease use a valid SMPTE framerate."
    exit
  end
end

# Simple check to determine if using dropframe timecode
def is_drop?(fps, timecode)
  if fps == 29.97 && timecode[8] == ';'
    return true
  else
    return false
  end
end

# Validates that a timecode string is a valid SMPTE timecode
def is_valid_timecode(timecode)

    if timecode.size != 11
      #raise ArgumentError.new('Error: Invalid timecode. Incorrect length.')
      raise "\nERROR: Invalid timecode length found in [" + timecode + "]."


    elsif timecode[8, 1] != ';' and timecode[8, 1] != ':'
      #raise ArgumentError.new('Error: Invalid timecode. Timecodes must be formatted as hh:mm:ss:ff or hh:mm:ss;ff (for NTSC dropframe)')
      raise "\nERROR: Invalid delimiter found in [" + timecode + "]."

    else
      true
    end


end

# Fractional framecounts are moved to their nominal equivalents for some calculations
def fps_normalize(fps)
  if fps == 29.97
    nominal_fps = 30

  elsif fps == 23.98
    nominal_fps = 24

  else
    nominal_fps = fps
  end

  return nominal_fps
end

# Converts SMPTE timecodes to an accurate frame count at a given FPS.
def timecode_framecount(timecode, fps)
  frames_dropped = 0 # init - I don't need this, do I!
  fps = fps_normalize(fps)
  timecode_array = timecode_split(timecode)

  total_minutes = 60 * timecode_array[:hh] + timecode_array[:mm]
  if timecode_array[:is_drop] == true
    frames_dropped = 2 * (total_minutes - (total_minutes / 10))
  end
  frames_in_seconds = fps * timecode_array[:ss]
  frames_in_minutes = fps * timecode_array[:mm] * 60
  frames_in_hours   = fps * timecode_array[:hh] * 60 * 60
  frame_count = timecode_array[:ff] + frames_in_seconds + frames_in_minutes + frames_in_hours - frames_dropped

  #puts frame_count
  return frame_count
end


# Converts the framecount to valid SMPTE timecode.
def timecode_frames_to_smpte(frame_count, fps, is_drop=false)

  if is_drop == true
    frames_seperator = ';'
    frames_dropped = 2
  else
    frames_seperator = ':'
    frames_dropped = 0
  end

  fps = fps_normalize(fps)

  # with knowledge from http://www.cinematography.com/index.php?showtopic=44367
  # and http://www.andrewduncan.ws/Timecodes/Timecodes.html
  # 17982 is the number of frames in 10 drop-frame minutes
  # 18000 is the number of frames in 10 non-df minutes

  # Dropframe case
  if is_drop == true
    whole_ten_minutes = frame_count / 17982
    partial_ten_minutes = frame_count % 17982
    if partial_ten_minutes < 2
      partial_ten_minutes = 2
    end
    frame_count += (whole_ten_minutes * 18) + 2 * ((partial_ten_minutes - 2) / 1798)
  end

  frames = frame_count % fps
  seconds = (frame_count / fps) % 60
  minutes = ((frame_count / fps) / 60) % 60
  hours = (((frame_count / fps) / 60) / 60) % 24

  # Ensure 2 digit fields
  frames = "%02d" % frames
  seconds = "%02d" % seconds
  minutes = "%02d" % minutes
  hours = "%02d" % hours

  timecode = hours.to_s + ':' + minutes.to_s + ':' + seconds.to_s + frames_seperator + frames.to_s

  return timecode
end

def tc_add(tc_in, tc_offset, fps, is_drop=false)
  is_drop = is_drop?(fps, tc_in)
  #puts timecode_framecount(tc_in, fps)
  #puts timecode_framecount(tc_offset, fps)
  new_tc = timecode_framecount(tc_in, fps) + timecode_framecount(tc_offset, fps)
  return timecode_frames_to_smpte(new_tc, fps, is_drop)
end
