# A SML Message
# This class isn't as generic as it should be. There is a lot of
# specialized stuff in it.
class SmlMessage
  attr_accessor :bytes

  def initialize
    @bytes = []
  end

  # Adds a new value to the bytes array
  # and ensures that the message will start
  def <<(val)
    if @bytes.length < 8
      @bytes << val.to_i
    else
      @bytes.shift unless started?
      @bytes << val.to_i
    end
  end

  # Returns true if the start escape sequence
  # and the version header is written
  # Start with 1B 1B 1B 1B 01 01 01 01 (27 27 27 27 1 1 1 1)
  def started?
    return false if @bytes.length < 8
    header = [27, 27, 27, 27, 1, 1, 1, 1]
    current_header = @bytes.take(8)

    match_sequences(current_header, header)
  end

  # Return true if the end escape sequence exists
  # This is not correct because there is some data
  # behind the end sequence
  def finished?
    return false unless started?
    sequence = [27, 27, 27, 27]
    current_sequence = @bytes.last(4)

    match_sequences(current_sequence, sequence)
  end

  # Compares to arrays if they contains the same sequence
  def match_sequences(a1, a2)
    a1.each_with_index do |a, i|
      return false if a != a2[i]
    end
    true
  end

  def contains_sequence(s)
    @bytes.each_with_index do |b, i|
      return true if s[0] == b &&
                     match_sequences(s, @bytes[i..i + s.length - 1])
    end
    false
  end

  # Returns a sequence described by the pattern p
  # a pattern must include wildcard * - this will match 1..n bytes
  # The wildcard match will be returned
  def find_sequence(p, offset)
    pattern_count = 0
    current_wildcard = 0
    # Initialize the pattern match result with n empty arrays
    pattern_match = []
    (0..p.count('*') - 1).each do  |i|
      pattern_match[i] = []
    end

    @bytes.drop(offset).each_with_index do |b, i|
      return pattern_match, i + offset if pattern_count == p.length
      if p[pattern_count] == '*'
        pattern_match[current_wildcard] << b
        if @bytes[i + 1 + offset] == p[pattern_count + 1]
          pattern_count += 1
          current_wildcard += 1
        end
      elsif p[pattern_count] == b
        pattern_count += 1
      else
        pattern_count = 0
        current_wildcard = 0
        pattern_match = []
        (0..p.count('*') - 1).each do  |n|
          pattern_match[n] = []
        end
      end
    end
    nil
  end

  def find_sequences(p)
    results = []
    offset = 0
    while @bytes.length > offset
      reading, offset = find_sequence(p, offset)
      break if reading.nil?
      results << reading
    end
    results
  end

  def human_readable_hex(i)
    hex = i.to_s(16)
    hex = "0#{hex}" if hex.length == 1
    hex.upcase
  end

  # calcualtes the counter value based on an array of bytes
  def counter_value(c)
    c.reduce(0) { |a, e| a * 256 + e  } / 10_000.0
  end

  # Zaehlerkennung
  def identifier
    # Hager EHZ 363Z5 77 07 81 81 C7 82 03 FF 01 01 01 01 04 48 41 47 01
    hager_ehz = [119, 7, 129, 129, 199, 130, 3, 255,
                 1, 1, 1, 1, 4, 72, 65, 71, 1]
    return 'Hager EHZ' if contains_sequence(hager_ehz)
    'Unknown'
  end

  # Zaehlerstaende
  def readings
    readings = []
    patterns = [[119, 7, 1, '*', 255, 1, 1, 98, 30, 82, 255, 85, '*', 1],
                [119, 7, 1, '*', 255, 1, 1, 98, 30, 82, 255, 83, '*', 1],
                [119, 7, 1, '*', 255, 98, 162, 1, 98, 30, 82, 255, 85, '*', 1]]
    patterns.each do |p|
      find_sequences(p).each do |s|
        readings << Reading.new(id: s[0].join(''), value: counter_value(s[1]))
      end
    end
    readings
  end

  def to_s
    @bytes.map { |b| "#{human_readable_hex(b.to_i)} " }.join
  end
end
