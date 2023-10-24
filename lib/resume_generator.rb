# frozen_string_literal: true

require_relative './markdown_target'
require_relative './pdf_target'

class ResumeGenerator
  def initialize(root_path:, source_path:, config:)
    @root_path = root_path
    @source_path = source_path
    @config = config
  end

  def targets
    @targets ||= @config.map do |path, config|
      source = ComponentSource.new(
        path: @source_path,
        components: config[:components]
      )

      case config[:format]
      when 'markdown'
        MarkdownTarget.new(
          source:,
          destination_path: path,
          config:
        )
      when 'pdf'
        PdfTarget.new(
          source:,
          stylesheet_path: @source_path,
          destination_path: path,
          config:
        )
      else
        raise "Invalid format: '#{@config[:format]}''"
      end
    end
  end

  def save_to(path)
    targets.each do |target|
      target.save_to(path)
    end
  end
end
