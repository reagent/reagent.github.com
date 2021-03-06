class Encrypter
  def initialize(path, base_name, password)
    @path, @base_name, @password = path, base_name, password
  end

  def encrypt_to(path)
    command = encrypt_command(path)

    Open3.popen2(command) do |stdin, stdout|
      stdin.print @password
      stdin.close
    end
  end

  private

  def source_file
    Pathname.new(@path).join(@base_name)
  end

  def encrypt_command(output_path)
    "openssl enc -aes-256-cbc -in #{source_file} -out #{output_path} -pass stdin"
  end
end