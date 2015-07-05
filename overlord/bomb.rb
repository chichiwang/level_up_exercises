class Bomb
  attr_reader :properties, :defuse_wire

  PROPERTIES = {
    state: 'boot',
    activation_code: '1234',
    deactivation_code: '0000',
    activation_time: nil,
    detonation_time: nil,
    timer_duration: 300,
    timer_remaining: nil,
  }

  def initialize
    @properties = PROPERTIES.merge({})
    @defuse_wire = rand(1..4)
  end

  def configure(act_code, deact_code, time)
    return unless %w(boot inactive).include?(@properties[:state])
    @properties[:activation_code] = act_code.to_s if valid_code?(act_code)
    @properties[:deactivation_code] = deact_code.to_s if valid_code?(deact_code)
    @properties[:timer_duration] = time.to_i if valid_duration?(time)
    @properties[:state] = 'inactive'
  end

  def cut_wire(wire)
    return unless wire.to_s.match(/^\d+$/) && (1..4).include?(wire.to_i)
    @properties[:state] = 'defused' if wire.to_i == @defuse_wire
    @properties[:state] = 'detonated' if wire.to_i != @defuse_wire
    reset_activation
  end

  def input(code)
    activate if code.to_s == @properties[:activation_code].to_s
    deactivate if code.to_s == @properties[:deactivation_code].to_s
  end

  def properties
    if @properties[:timer_remaining]
      @properties[:timer_remaining] = timer_remaining if active?
      @properties[:state] = 'detonated' if @properties[:timer_remaining] == 0
    end
    @properties
  end

  private

  def activate
    valid_states = %w(boot inactive)
    return unless valid_states.include?(@properties[:state])
    activate_properties
    @properties[:state] = 'active'
  end

  def activate_properties
    activation_time = Time.now
    detonation_time = activation_time + @properties[:timer_duration]
    @properties[:activation_time] = activation_time
    @properties[:detonation_time] = detonation_time
    @properties[:timer_remaining] = detonation_time - Time.now
  end

  def active?
    @properties[:state] == 'active'
  end

  def deactivate
    return unless active?
    @properties[:state] = 'inactive'
    reset_activation
  end

  def reset_activation
    @properties[:activation_time] = nil
    @properties[:detonation_time] = nil
    @properties[:timer_remaining] = nil
  end

  def timer_remaining
    now = Time.now
    detonation_time = @properties[:detonation_time]
    return detonation_time - now if detonation_time >= now
    0
  end

  def valid_code?(code)
    true if code.to_s =~ /^\d\d\d\d$/
  end

  def valid_duration?(duration)
    true if duration.to_s =~ /^\d+$/ && duration.to_i < 10000
  end
end
