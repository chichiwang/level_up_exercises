require_relative '../bomb'

require 'date'

describe "Bomb" do
  let(:bomb) { Bomb.new }

  it "should have a hash value #properties" do
    expect(bomb.properties).to be_a(Hash)
  end

  describe "#properties" do
    it "should populate with default values" do
      expect(bomb.properties[:state]).to eql('boot')
      expect(bomb.properties[:activation_code]).to eql('1234')
      expect(bomb.properties[:deactivation_code]).to eql('0000')
      expect(bomb.properties[:activation_time]).to be_nil
      expect(bomb.properties[:detonation_time]).to be_nil
      expect(bomb.properties[:timer_duration]).to eql(300)
      expect(bomb.properties[:timer_remaining]).to be_nil
    end

    it "should return updated remaining time" do
      bomb.input(1234)
      remaining = bomb.properties[:timer_remaining]
      sleep 2
      new_remaining = bomb.properties[:timer_remaining]

      expect(new_remaining).not_to eql(remaining)
    end

    it "should set state to detonated if timer_remaining is 0" do
      bomb.configure(1234, '0000', 1)
      bomb.input(1234)
      sleep 3

      expect(bomb.properties[:state]).to eql('detonated')
    end
  end

  describe "#configure" do
    it "should set new activation/deactivation codes and timer duration" do
      bomb.configure('5555', '4321', 50)
      expect(bomb.properties[:activation_code]).to eql('5555')
      expect(bomb.properties[:deactivation_code]).to eql('4321')
      expect(bomb.properties[:timer_duration]).to eql(50)
    end

    it "should not set invalid codes" do
      bomb.configure('rm -rf *', 'exit', 50)
      expect(bomb.properties[:activation_code]).to eql('1234')
      expect(bomb.properties[:deactivation_code]).to eql('0000')
    end

    it "should not set invalid timer durations" do
      bomb.configure('1234', 2222, 'five seconds')
      expect(bomb.properties[:timer_duration]).to eql(300)
    end

    it "should not set values if bomb is active" do
      bomb.input(1234)
      bomb.configure(5555, 4321, 50)

      expect(bomb.properties[:activation_code]).to eql('1234')
      expect(bomb.properties[:deactivation_code]).to eql('0000')
      expect(bomb.properties[:timer_duration]).to eql(300)
    end

    it "should not set values if bomb is defused" do
      bomb.cut_wire(bomb.defuse_wire)
      bomb.configure(5555, 4321, 50)

      expect(bomb.properties[:activation_code]).to eql('1234')
      expect(bomb.properties[:deactivation_code]).to eql('0000')
      expect(bomb.properties[:timer_duration]).to eql(300)
    end

    it "should not set values if bomb is detonated" do
      wire = 1
      wire = rand(2..4) while wire == bomb.defuse_wire
      bomb.cut_wire(wire)
      bomb.configure(5555, 4321, 50)

      expect(bomb.properties[:activation_code]).to eql('1234')
      expect(bomb.properties[:deactivation_code]).to eql('0000')
      expect(bomb.properties[:timer_duration]).to eql(300)
    end

    it "should set state to inactive once configured" do
      bomb.configure(5555, 1233, '60')
      expect(bomb.properties[:state]).to eql('inactive')
    end
  end

  describe "#input" do
    it "should not change state if code is invalid" do
      bomb.input('activate')
      bomb.input(1337)
      expect(bomb.properties[:state]).to eql('boot')
    end

    context "passing in the activation code" do
      it "should set the activation_time" do
        bomb.input(1234)
        expect(bomb.properties[:activation_time]).to be_a(Time)
      end

      it "should set the detonation_time to be accurate" do
        bomb.input(1234)
        activation_time = bomb.properties[:activation_time]
        detonation_time = bomb.properties[:detonation_time]
        timer_duration = bomb.properties[:timer_duration]

        expect(detonation_time).to be_a(Time)
        expect(detonation_time - activation_time).to eq(timer_duration)
      end

      it "should set the timer_remaining" do
        bomb.input(1234)
        activation_time = bomb.properties[:activation_time]
        timer_duration = bomb.properties[:timer_duration]
        timer_remaining = bomb.properties[:timer_remaining]

        expect(timer_remaining).to be > (Time.now - activation_time)
      end

      it "should set state to active once activated" do
        bomb.input(1234)
        expect(bomb.properties[:state]).to eql('active')
      end

      it "should not assign new values if bomb is active" do
        bomb.input(1234)
        activation_time = bomb.properties[:activation_time]
        sleep 1
        bomb.input(1234)
        reactivation_time = bomb.properties[:activation_time]

        expect(reactivation_time).to eql(activation_time)
      end

      it "should not change state if bomb is detonated" do
        bomb.configure(1234, '0000', 1)
        bomb.input(1234)
        sleep 2
        state = bomb.properties[:state]
        bomb.input(1234)

        expect(state).to eql('detonated')
      end

      it "should not change state if bomb is defused" do
        bomb.cut_wire(bomb.defuse_wire)

        expect(bomb.properties[:state]).to eql('defused')
        expect(bomb.properties[:activation_time]).to be_nil
        expect(bomb.properties[:detonation_time]).to be_nil
        expect(bomb.properties[:timer_remaining]).to be_nil
      end
    end

    context "passing in the deactivation code" do
      it "should not change state if bomb isn't active" do
        old_state = bomb.properties[:state]
        bomb.input('0000')
        new_state = bomb.properties[:state]

        expect(old_state).to eql(new_state)
      end

      it "should set state to inactive if the bomb is active" do
        bomb.input(1234)
        bomb.input('0000')

        expect(bomb.properties[:state]).to eql('inactive')
      end

      it "should reset activation properties if the bomb is active" do
        bomb.input(1234)
        bomb.input('0000')

        expect(bomb.properties[:activation_time]).to be_nil
        expect(bomb.properties[:detonation_time]).to be_nil
        expect(bomb.properties[:timer_remaining]).to be_nil
      end
    end
  end

  describe "#cut_wire" do
    it "should not change state when passed an invalid value" do
      bomb.cut_wire('red')
      expect(bomb.properties[:state]).to eql('boot')

      bomb.cut_wire(12)
      expect(bomb.properties[:state]).to eql('boot')
    end

    it "should set state to detonated when passed the incorrect defuse wire" do
      wire = 1
      wire = rand(2..4) while wire == bomb.defuse_wire
      bomb.cut_wire(wire)

      expect(bomb.properties[:state]).to eql('detonated')
    end

    it "should reset activation properties when passed the incorrect defuse wire" do
      bomb.input(1234)
      wire = 1
      wire = rand(2..4) while wire == bomb.defuse_wire
      bomb.cut_wire(wire)

      expect(bomb.properties[:activation_time]).to be_nil
      expect(bomb.properties[:detonation_time]).to be_nil
      expect(bomb.properties[:timer_remaining]).to be_nil
    end

    it "should set state to defused when passed the correct defuse wire" do
      bomb.cut_wire(bomb.defuse_wire)
      expect(bomb.properties[:state]).to eql('defused')
    end

    it "should reset activation properties when passed the correct defuse wire" do
      bomb.input(1234)
      bomb.cut_wire(bomb.defuse_wire)

      expect(bomb.properties[:activation_time]).to be_nil
      expect(bomb.properties[:detonation_time]).to be_nil
      expect(bomb.properties[:timer_remaining]).to be_nil
    end
  end
end
