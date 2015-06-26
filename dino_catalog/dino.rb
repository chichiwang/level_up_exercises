class Dino
  attr_accessor :name, :period, :continent,
                :diet, :weight, :locomotion, :info

  def size(threshhold = 4000)
    return '' unless @weight
    return 'big' if @weight.to_i > threshhold
    'small'
  end

  def weight
    pretty_integer(@weight) + ' lbs' if @weight
  end

  def synopsis
    instance_variables.map do |prop|
      prop_name = prop.to_s.gsub(/^@/, '')
      val = send(prop_name)
      val ? "#{prop_name.capitalize}: #{val}\n" : ""
    end.join('')
  end

  def herbivore
    @diet.downcase == 'herbivore'
  end

  private

  def pretty_integer(num_string)
    num_string.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
  end
end
