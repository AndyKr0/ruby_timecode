ruby_timecode
=============

SMTPE Timecode functions in Ruby

Functional

tc_adjust.rb - Ruby command line application to adjust timecodes on plain text.
  Usage - ``ruby tc_adjust.rb input_filename output_filename "offset timecode" [framerate]``
  
  Be sure to enter a valid SMPTE timecode in HH:MM:SS:FF format for the offset timecode (eg - 01:00:10:15). 
  Framerate is optional, defaults to 29.97fps.  Valid framerates: ``23.98``, ``24``, ``25``, and ``29.97``.

ruby_timecode.rb - Timecode related functions.

timecode_obj.rb - Object oriented approach to timecode. Experimental at this point.
