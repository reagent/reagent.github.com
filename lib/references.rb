class References
  def initialize(
    path:,
    stylesheet_path:,
    destination_path:,
    config:,
    initials:,
    password:
  )
    @path = path
    @stylesheet_path = stylesheet_path
    @destination_path = destination_path
    @config = config
    @initials = initials
    @password = password
  end

  def save_to(path)
    PdfTarget.new(
      source: source,
      stylesheet_path: @stylesheet_path,
      destination_path: path,
      config: @config
    ).save_to(@destination_path)
  end

  def source
    BufferSource.new(buffer: ERB.new(template).result(binding))
  end

  def references
    @references ||= @initials.map do |initial|
      Reference.new(
        path: @path.join('data'),
        initial: initial,
        password: @password
      )
    end
  end

  def template
    <<~EOF
    # References for Patrick Reagan

    <%= references.map(&:out).join("\n") %>
    EOF
  end
end