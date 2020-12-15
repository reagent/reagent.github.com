require "pathname"
require "commonmarker"
require "pdfkit"
require "nokogiri"

class ComponentSource
  def initialize(path:, components:)
    @path, @components = path, components
  end

  def to_s
    @components.map {|f| @path.join(f).read }.join
  end
end

class BufferSource
  def initialize(buffer:)
    @buffer = buffer
  end

  def to_s
    @buffer
  end
end

class PdfTarget
  def initialize(source:, stylesheet_path:, destination_path:, config:)
    @source = source
    @stylesheet_path = stylesheet_path
    @destination_path = destination_path
    @config = config
  end

  def save_to(path)
    markdown_args = [@source.to_s]
    render_options = @config.dig(:markdown_options, :render)

    markdown_args << render_options if render_options

    html = CommonMarker.render_html(*markdown_args)
    document = Nokogiri::HTML(html)

    html_node = document.at_css("html")

    style_content = String.new.tap do |content|
      @config[:stylesheets].each do |filename|
        content << @stylesheet_path.join(filename).read
      end
    end

    # Adding stylesheet
    html_node.first_element_child.before(<<-HTML
      <head>
        <style>
          #{style_content}
        </style>
      </head>
    HTML
    )

    # Adding IDs to sections
    (document / "h1,h2,h3,h4,h5,h6").each do |node|
      node["id"] = node.text.downcase.gsub(/\W+/, "-").squeeze("-")
    end

    output_file = Pathname.new(path).join(@destination_path)
    PDFKit.new(document.to_s, @config[:pdf_options]).to_file(output_file)
  end
end