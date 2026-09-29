# frozen_string_literal: true

require "minitest/autorun"

# Fastfile의 레인 흐름을 실행하되 빌드, Apple, Slack 호출은 하지 않는다.
class ReleaseLaneHarness
  attr_reader :calls

  def initialize
    @lanes = {}
    @calls = []
    fastfile = File.expand_path("../fastlane/Fastfile", __dir__)
    instance_eval(File.read(fastfile), fastfile, 1)
    define_singleton_method(:current_app_version) { "1.1.1" }
    define_singleton_method(:next_build_number) { "2609291000" }
    define_singleton_method(:apply_build_number) { |number| @calls << [:build_number, number] }
    define_singleton_method(:build_ipa) { |scheme| @calls << [:build, scheme]; "Prod.ipa" }
  end

  def default_platform(*)
  end

  def platform(*)
    yield
  end

  def before_all
  end

  def desc(*)
  end

  def lane(name, &block)
    @lanes[name] = block
  end

  def error
  end

  def run(name)
    instance_exec({}, &@lanes.fetch(name))
  end

  def app_store_connect_api_key(**)
  end

  def match(**)
  end

  def upload_to_testflight(**options)
    @calls << [:testflight, options]
    raise "Another build is in review" unless options[:skip_submission]
  end

  def upload_to_app_store(**options)
    @calls << [:app_store, options]
  end
end

class ReleaseLaneTest < Minitest::Test
  def setup
    @harness = ReleaseLaneHarness.new
  end

  def offline
    ui = Object.new
    %i[success important message].each { |name| ui.define_singleton_method(name) { |*| } }
    @harness.singleton_class.const_set(:UI, ui)
    originals = [[CISlack, :notify], [AppStoreReleaseNotes, :write]].map do |target, name|
      original = target.method(name)
      target.define_singleton_method(name) { |*args, **kwargs| nil }
      [target, name, original]
    end
    capture_io { yield }
  ensure
    originals&.each { |target, name, original| target.define_singleton_method(name, original) }
  end

  def test_release_continues_to_app_store_when_another_beta_build_is_in_review
    offline { @harness.run(:release) }

    uploads = @harness.calls.select { |name, _| %i[testflight app_store].include?(name) }
    assert_equal %i[testflight app_store], uploads.map(&:first)
    testflight = uploads.first.last
    app_store = uploads.last.last
    assert_equal true, testflight[:skip_submission]
    assert_equal false, testflight[:skip_waiting_for_build_processing]
    refute testflight.key?(:groups)
    refute testflight.key?(:notify_external_testers)
    assert_equal true, app_store[:skip_binary_upload]
    assert_equal "2609291000", app_store[:build_number]
    assert_equal "1.1.1", app_store[:app_version]
  end

  def test_actual_upload_failure_stops_before_app_store_connection
    @harness.define_singleton_method(:upload_to_testflight) { |**| raise "Upload rejected" }
    error = assert_raises(RuntimeError) { offline { @harness.run(:release) } }
    assert_equal "Upload rejected", error.message
    refute @harness.calls.any? { |name, _| name == :app_store }
  end

  def test_qa_keeps_external_beta_distribution
    offline { @harness.run(:QA) }
    options = @harness.calls.find { |name, _| name == :testflight }.last
    assert_equal ["DDD", "ddd"], options[:groups]
    assert_equal true, options[:notify_external_testers]
    refute options[:skip_submission]
  end
end
