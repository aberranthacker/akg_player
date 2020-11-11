filename = 'song.akg.s'

src = File.read(filename)
pitch_flag = false

File.open(filename, 'w') do |dst|
  src.lines do |line|
    next if /\.even/.match?(line)

    line = if pitch_flag
             pitch_flag = false
             line.sub('.byte', '.word')
           else
             line
           end


    # .word Justaddcream_Pitch1 + 4 * 0 + 1
    line.sub!(/(\.word \w+_Pitch\d+ \+ \d+ \* \d+ \+ )\d+/, '\12')

    dst << line
    dst << "        .even\n" if /DisarkPointerRegionStart/.match?(line)
    dst << "        .even\n" if /DisarkWordForceReference/.match?(line)

    pitch_flag = true if /^\w+_Pitch\d+:/.match?(line)
  end
end