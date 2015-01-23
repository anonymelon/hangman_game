require 'logger'

class GameLogger
  def initialize(level)
    @logger = Logger.new(STDOUT)
    @logger.level = level
    @logger.formatter = proc do |severity, datetime, progname, msg|
       "#{ severity }: #{msg}\n"
    end
  end

  def debug(msg)
    @logger.debug(msg)
  end

  def info(msg)
    @logger.info(msg)
  end

  def error(msg)
    @logger.error(msg)
  end

  def warn(msg)
    @logger.warn(msg)
  end

end