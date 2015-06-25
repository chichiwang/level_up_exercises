require_relative 'commands'

require 'optparse'
require 'json'

class DinoExporter
  def initialize(dino_array)
    @data = JSON.pretty_generate(dino_array)
  end

  def export(params)
    filename = "export"

    opt_parser = OptionParser.new do |opts|
      opts.on('-n FILENAME') { |n| filename = n }
    end

    opt_parser.parse!(params.split(' '))
    write_data(filename.gsub(/\.json/, '') + '.json')
    rescue OptionParser::InvalidOption => e
      Commands.err_flag(e.to_s.gsub(/invalid\soption:\s/, ''))
  end

  private

  def create_dir(path)
    return if Dir.exist?(path)
    Dir.mkdir(path, 0755)
  end

  def filepath(file)
    File.join(File.expand_path(File.dirname(__FILE__)), file)
  end

  def write_data(filename, dirname = 'exports')
    create_dir(File.join(filepath(dirname)))
    fullpath = filepath(File.join(dirname, filename))
    File.open(fullpath, 'w') { |f| f.write(@data) }
    "> File successfully saved to #{fullpath}"
  end
end
