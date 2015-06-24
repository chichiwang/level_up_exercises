require 'json'
require 'csv'

class FileSystem
  def json_to_hash(filepath)
    JSON.parse(File.read(absolute_path(filepath)))
  end

  def txt_to_string(filepath)
    File.read(absolute_path(filepath))
  end

  def csv_to_array(filepath)
    rows = CSV.read(absolute_path(filepath))
    keys = rows.shift
    [keys, rows]
  end

  def create_dir(path)
    return if Dir.exist?(path)
    Dir.mkdir(path, 0755)
  end

  def write(str, file)
    File.open(file, 'w') { |f| f.write(str) }
  end

  def current_dir
    File.expand_path(File.dirname(__FILE__))
  end

  private

  def absolute_path(path)
    File.join(File.expand_path(File.dirname(__FILE__)), path)
  end
end
