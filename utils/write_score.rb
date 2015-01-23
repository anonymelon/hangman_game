
class WriteScore
  def initialize(file_path)
    @file_path = file_path
  end

  def write(res)
    open(@file_path, 'a') { |file|
      file.puts res
    }
  end
end
