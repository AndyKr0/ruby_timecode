#!/usr/bin/env ruby
require  './ruby_timecode.rb'

def usage_notes()
  puts "\nCommand line tool to adjust plain text timecodes."
  puts "\n\nUsage:"
  puts "ruby_timecode.rb input_filename output_filename offset_timecode [optional]fps"
  puts "\n\tDefaults to 29.97 dropframe timecode if no fps provided."
  puts '\n\tSource timecodes with the format of "hh:mm:ss;ff" will automatically force dropframe timecode.'
  puts "\n\n"
end

if ARGV.empty?
  usage_notes()
  exit
else
  if ARGV.length > 2 && is_valid_timecode(ARGV[2]) == true
    input_filename = ARGV[0]
    output_filename = ARGV[1]
    tc_offset = ARGV[2].to_s
  else
    raise "ERROR: Not enough arguments given."
    usage_notes()
    exit
  end

  if ARGV.at(3) == nil
    puts "Assuming 29.97 frames per second."
    fps = 29.97
  else
    if is_valid_fps(ARGV[3].to_f)
      fps = ARGV[3].to_f
    end
  end


  txt = File.read(input_filename)

  puts "Opening file #{input_filename}: "

  new_text = txt.gsub(/\d\d:\d\d:\d\d[;|:]\d\d/) { |tc| tc_add(tc, tc_offset, fps) }

  target = File.new(output_filename, "w")

  target.write(new_text)

  target.close

  puts "Adjustment complete."
end
