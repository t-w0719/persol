SRC_DIR = File.expand_path(File.dirname(__FILE__))
 
class Command
  attr :name, :sub_commands, :voice, :proc, :kill_child
 
  def initialize(args = {})
    @name = args[:name]
    @sub_commands = args[:sub_commands]
    @voice = args[:voice]
    @proc = args[:proc]
    @kill_child = args[:kill_child]
  end
 
  def execute
    if voice
      talk(voice)
    end
 
    if proc
      pid = @proc.call
      result = { status: :finished }
      result = result.merge(pid: pid) if pid 
      return result
    elsif @sub_commands
      return { status: :forward, sub_commands: @sub_commands }
    elsif @kill_child
      return { status: :kill_child }
    else
      return { status: :finished }
    end
  end
 
  def match?(str)
    @name == str
  end
 
  private
 
  def talk(str)
    system(File.expand_path(File.dirname(__FILE__)) + '/extensions/jtalk.sh', str)
  end
end
 
class Commands
  include Enumerable
  extend Forwardable
 
  def initialize(elements = [])
    @commands = elements
  end
 
  def add(e)
    @commands << e
    self
  end
  alias_method :<<, :add
 
  def each
    @commands.each { |e| yield(e) }
  end
 
  def evaluate(name)
    raise ArgumentError unless name
    command = @commands.find{ |c| c.match?(name) }
    if command
      command.execute
    else
      { status: :unknown }
    end
  end
 
  def self.defaults
    commands = {}
    commands[:sing] = Command.new(name: '歌ってください', voice: "はい、歌ってくださいですね。", proc: -> {
       pid = spawn("aplay", "-q", File.expand_path(File.dirname(__FILE__)) + '/samples/test.wav')
       pid
    })
 
    commands[:light] = Command.new(name: '光ってください', voice: "はい、光ってくださいですね。", proc: -> {
       LChika.open(21) { |lc|
         10.times.each do |i|
           i % 2 == 0 ? lc.on : lc.off
           sleep 0.2
         end
         lc.off
       }
    })
    
    commands[:sleep] = Command.new(name: '寝てください', voice: "もう一度、寝てくださいと言ってみてください。", sub_commands: Commands.new([
      Command.new(name: '寝てください', voice: "はい、わかりました。寝れば良いんでしょ?", proc: -> {
        exit
      })
    ]))
    
    commands[:end] = Command.new(name: 'おわり', voice: "はい、おわりですね。", kill_child: true)    
    commands[:shutoff] = Command.new(name: '消えろ', voice: "はい、消えろですね。何もしません。")    
    commands[:init] = Command.new(name: '留吉', voice: 'へい、親方', sub_commands: Commands.new(commands.values))
    cmds = Commands.new
    cmds << commands[:init]
  end
end
