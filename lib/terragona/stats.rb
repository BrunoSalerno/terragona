# Taken from:
# http://stackoverflow.com/questions/7749568/how-can-i-do-standard-deviation-in-ruby

module Enumerable

  def sum
    return self.inject(0){|accum, i| accum + i }
  end

  def mean
    return if self.empty?
    return self.sum / self.length.to_f
  end

  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum + (i - m) ** 2 }
    return sum / (self.length - 1).to_f
  end

  def standard_deviation
    return Math.sqrt(self.sample_variance)
  end

end