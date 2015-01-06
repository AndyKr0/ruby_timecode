class Timecode
  attr_accessor :fps, :is_drop, :framecount, :smpte_tc, :hh, :mm, :ss, :ff

  def initialize(smpte_tc, fps)
    if smpte_tc != nil && is_valid_timecode(smpte_tc) # Check for valid TC at start
      timecode_parse(smpte_tc)
    end

    @fps = fps.to_f
  end

  def timecode_parse(timecode)
    @hh = timecode[0, 2].to_i
    @mm = timecode[3, 2].to_i
    @ss = timecode[6, 2].to_i
    @ff = timecode[9, 2].to_i
    if timecode[8] == ';'
      @is_drop = true
    else
      @is_drop = false
    end
  end

  def is_valid_timecode(timecode)
    if timecode.size != 11
      # raise ArgumentError.new('Error: Invalid timecode. Incorrect length.')
      raise "\nERROR: Invalid timecode length found in [" + timecode + "]."

    elsif timecode[8, 1] != ';' and timecode[8, 1] != ':'
      #raise ArgumentError.new('Error: Invalid timecode. Timecodes must be formatted as hh:mm:ss:ff or hh:mm:ss;ff (for NTSC dropframe)')
      raise "\nERROR: Invalid delimiter found in [" + timecode + "]."
    else
      true
    end
  end

  def timecode_framecount
    frames_dropped = 0 # init - I don't need this, do I!
    nominal_fps = fps_normalize(fps)

    total_minutes = 60 * hh + mm
    if is_drop == true
      frames_dropped = 2 * (total_minutes - (total_minutes / 10))
      puts "frames droppped " + frames_dropped.to_s
    end
    frames_in_seconds = nominal_fps * ss
    frames_in_minutes = nominal_fps * mm * 60
    frames_in_hours   = nominal_fps * hh * 60 * 60

    framecount = ff + frames_in_seconds + frames_in_minutes + frames_in_hours - frames_dropped

    #puts frame_count
    return framecount
  end


  def timecode_format
    if is_drop == true
      frames_seperator = ';'
    else
      frames_seperator = ':'
    end

    "%02d" % hh.to_s + ':' + "%02d" % mm.to_s + ':' + "%02d" % ss.to_s + frames_seperator + "%02d" % ff.to_s
  end
end

# Converts the framecount to valid SMPTE timecode.
def timecode_frames_to_smpte(frame_count, fps, is_drop)

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
    puts "whole tens " + whole_ten_minutes.to_s
    puts "partial tens " + partial_ten_minutes.to_s
    if partial_ten_minutes < 2
      partial_ten_minutes = 2
    end
    frame_count += (whole_ten_minutes * 18) + (2 * ((partial_ten_minutes - 2) / 1798))
    puts "whole tens * 19 " + (whole_ten_minutes * 19).to_s
    puts 2 * ((partial_ten_minutes - 2) / 1798)
  end
  puts frame_count
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

# Simple Tests
# --------------------------------------
# t = Timecode.new("00:05:59;28", 29.97)
# puts t.timecode_format
# puts t.is_drop
# puts t.timecode_framecount
# puts t.fps
# puts t.is_drop
# x = Timecode.new(timecode_frames_to_smpte(t.timecode_framecount, t.fps, t.is_drop), 29.97)
# puts x.timecode_format
