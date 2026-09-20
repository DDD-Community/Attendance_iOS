require "digest"
require "fileutils"
require "yaml"

module AppStoreReleaseNotes
  module_function

  def render(config_path:, version:)
    config = YAML.safe_load(File.read(config_path), aliases: false)
    locales = config.fetch("app_store")

    locales.to_h do |locale, templates|
      candidates = Array(templates)
      raise "App Store release note templates are empty for #{locale}" if candidates.empty?

      index = Digest::SHA256.hexdigest("#{version}:#{locale}").to_i(16) % candidates.length
      note = candidates.fetch(index).gsub("%{version}", version).rstrip
      [locale, "#{note}\n"]
    end
  end

  def write(config_path:, metadata_path:, version:)
    render(config_path: config_path, version: version).each do |locale, note|
      locale_path = File.join(metadata_path, locale)
      FileUtils.mkdir_p(locale_path)
      File.write(File.join(locale_path, "release_notes.txt"), note)
    end
  end
end
