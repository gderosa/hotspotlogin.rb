class String
  # bitwise XOR, behaves like in Perl or PHP
  def ^(other)
    # treat as a raw/binary sequence of bytes
    s1 = self.force_encoding  'ASCII-8BIT'
    s2 = other.force_encoding 'ASCII-8BIT'
    length = [s1.length, s2.length].min
    b1 = s1.bytes.to_a
    b2 = s2.bytes.to_a
    bytes_result = []
    0.upto (length - 1) do |i|
      bytes_result << (b1[i] ^ b2[i])
    end
    return bytes_result.map{|b| b.chr}.join
  end
end


