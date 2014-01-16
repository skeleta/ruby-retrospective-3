class Integer
  def prime?
    gcds = []
    (2..self+1).each { |number| gcds << self.gcd(number) }
    is_prime = gcds.uniq.length == 2 ? true : false
  end

  def prime_factors
    number = self < 0 ? -self : self
    pos = 2
    factors = []
    while pos <= number
      number, pos, factors = prime_factors_help(number, pos, factors)
    end
    factors
  end

  def prime_factors_help(number, pos, factors)
    if number%pos == 0
        factors << pos
        number /= pos
        pos = 2
      else
        pos += 1
      end
    return number, pos, factors
  end

  def harmonic
    k, sum = 1, 0
    while k <= self
      sum += Rational(1, k)
      k += 1
    end
    sum.to_r
  end

  def digits
    number = self < 0 ? -self : self
    splitet_number = number.to_s.split(//)
    digits_list = []
    splitet_number.each { |digit| digits_list << digit.to_i }
    digits_list
  end
end


class Array
  def frequencies
    result = {}
    self.each { |n| if result[n] then result[n] += 1 else result[n] = 1 end }
    result
  end

  def average
    sum = 0
    length = self.each { |element| sum += element }.length
    average_number = sum.to_f / length.to_f
  end

  def drop_every(position)
    new_list = []
    position_to_deleat = position - 1
    while self.length >= position_to_deleat
      new_list << self[position_to_deleat]
      position_to_deleat += position
    end
    self - new_list
  end

  def combine_with(other)
    i, combined = 0, []
    while i < [self.length, other.length].min
      combined << self[i] << other[i]
      i += 1
    end
    larger_list = self[i] ? self : other
    combined + larger_list[i..larger_list.length-1]
  end
end
