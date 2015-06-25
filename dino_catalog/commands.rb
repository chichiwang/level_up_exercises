module Commands
  COMMANDS = %w(help list export exit manual)
  ERROR = {
    cmd: "> Unrecognized command: ",
    flag: "> Invalid flag: ",
    params: "> Unrecognized parameters: ",
  }

  def self.err_cmd(cmd)
    ERROR[:cmd] + "#{cmd}\n\n"
  end

  def self.err_flag(flag)
    ERROR[:flag] + "#{flag}\n\n"
  end

  def self.err_params(params)
    ERROR[:params] + "#{params}\n\n"
  end

  def self.valid_cmd?(cmd)
    COMMANDS.include?(cmd.downcase)
  end
end
