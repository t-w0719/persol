class LChika
  attr :port, :is_on
 
  def self.open(port = 25)
    LChika.new(port) { |l_chika|
      yield(l_chika)
    }
  end
 
  def on
    toggle(true)
  end
 
  def on?
    @is_on
  end
 
  def off
    toggle(false)
  end
 
  def toggle(is_on)
    File.open("/sys/class/gpio/gpio#{@port}/value", "w") do |v|
      v.write is_on ? 1 : 0
    end
    @is_on = is_on
  end
 
  protected
 
  def initialize(port=25)
    @port = port
    File.open("/sys/class/gpio/export", "w") do |io|
      io.write(@port)
    end
    dir = File.open("/sys/class/gpio/gpio#{@port}/direction", "w") do |dir|
      dir.write("out")
    end
 
    yield(self)
  ensure
    self.class.cleanup(@port)
  end
 
  class << self
    def cleanup(port)
      File.open("/sys/class/gpio/unexport", "w") do |unexport|
        unexport.write(port)
      end
    end
  end
end
