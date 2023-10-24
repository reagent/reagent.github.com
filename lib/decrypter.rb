# frozen_string_literal: true

class Decrypter
  def initialize(path, password)
    @path = path
    @password = password
  end

  def decrypt_to(path)
    File.open(path, 'w') { |f| f << decrypt }
  end

  def decrypt
    Open3.popen2(command) do |stdin, stdout|
      stdin.print @password
      stdin.close

      stdout.read
    end
  end

  private

  def command
    "openssl enc -aes-256-cbc -d -in #{@path} -pass stdin"
  end
end
