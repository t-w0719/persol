SRC_DIR = File.expand_path(File.dirname(__FILE__))
 
require 'rubygems'
require 'julius'
#require File.join(SRC_DIR, '/l_chika')
require File.join(SRC_DIR, '/command')
 
class Tomekichi
  def run(julius)
    waiting = Time.now
    commands = Commands.defaults
 
    @child_pid = nil
 
    begin
      julius.each_message do |message, prompt|
        case message.name
        when :RECOGOUT
          prompt.pause
        
          shypo = message.first
          whypo = shypo.first
          confidence = whypo.cm.to_f
  
          puts "#{message.sentence} #{confidence}"
          # confidenceの値が大きいほど、認識の確度が高い。認識率を変えたい場合、この条件を返るのが一番簡単な方法
          if confidence > 0.90 
            result = commands.evaluate(message.sentence)
            case result[:status]
            when :finished then
              if result[:pid]
                kill_child # kill previous child process
                @child_pid = result[:pid]
              end
              #l_chika.off
              waiting = Time.now
              commands = Commands.defaults
            when :forward then
              #l_chika.on
              waiting = Time.now
              commands = result[:sub_commands]
            when :kill_child
              kill_child
              #l_chika.off
              waiting = Time.now
              commands = Commands.defaults
            when :unknown
              #current = l_chika.on?
              #l_chika.toggle(!current)
              #sleep 0.3
              #l_chika.toggle(current)
            end
          end
          prompt.resume
        end
    
        if (Time.now - waiting) > 5
          commands = Commands.defaults
          waiting = Time.now
          #l_chika.off
        end
      end
    rescue REXML::ParseException
      puts "retry…"
      retry
    end
  end
 
  def kill_child
    if @child_pid && process_exists?(@child_pid)
      puts "Killing #{@child_pid}..."
      Process.kill('QUIT', @child_pid)
    end
    @child_pid = nil
  end
 
  def process_exists?(pid)
    gid = Process.getpgid(pid)
    return true
  rescue => ex
    puts ex
    return false
  end
end
 
#LChika.open do |l_chika|
  puts "接続中…"
 
  julius = Julius.new
 
  puts "呼びかけて!"
 
  tomekichi = Tomekichi.new
  tomekichi.run(julius)
#end
