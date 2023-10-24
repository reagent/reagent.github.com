# frozen_string_literal: true

class MarkdownTarget
  def initialize(source:, destination_path:, config:)
    @source = source
    @destination_path = destination_path
    @config = config
  end

  def save_to(path)
    output_file = Pathname.new(path).join(@destination_path)
    output_file.open('w') { |f| f << @source.to_s }
  end
end
