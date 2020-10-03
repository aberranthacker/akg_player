BASE_FREQ = 1789772.5

def note_freq(note_index)
  2**((note_index - 57) / 12.0) * 440
end

def calc_divider(note_idx)
  1 / note_freq(note_idx) * BASE_FREQ / 16
end

def calc_dividers
  0.upto(127).map { |i| calc_divider(i).round }
end

def divider_to_freq(divider)
  1.0 / (16 * divider / BASE_FREQ)
end

def differences
  calc_dividers.map.with_index do |divider, idx|
    note_freq(idx) / divider_to_freq(divider)
  end
end
