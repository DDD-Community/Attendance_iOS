# frozen_string_literal: true
require "json"
require "net/http"
require "fileutils"

# CI 전용. Slack 장애는 배포 결과를 바꾸지 않고 로그에만 남긴다.
module CISlack
  module_function

  def api(method, payload)
    uri = URI("https://slack.com/api/#{method}")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{ENV.fetch('SLACK_BOT_TOKEN')}"
    request["Content-Type"] = "application/json; charset=utf-8"
    request.body = JSON.generate(payload)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 3, read_timeout: 5) { |http| http.request(request) }
    raise "Slack HTTP failure" unless response.code == "200"
    result = JSON.parse(response.body)
    raise "Slack API failure" unless result["ok"]
    result
  end

  def notify(phase, version: nil, build: nil)
    return false unless ENV["CI_SLACK_ENABLED"] == "1"
    if ENV["SLACK_BOT_TOKEN"].to_s.empty?
      warn "::warning::Slack 배포 알림 미전송: SLACK_BOT_TOKEN이 없습니다."
      return false
    end
    path = ENV.fetch("CI_SLACK_STATE_PATH")
    state = File.exist?(path) ? JSON.parse(File.read(path)) : {}
    state["version"] = version if version
    state["build"] = build if build
    branch = ENV.fetch("GITHUB_REF_NAME", "unknown")
    target = branch == "develop" ? "STAGE · TestFlight" : "PROD · App Store"
    labels = {
      "start" => "🚀 CI 배포 시작", "prepare" => "📦 의존성 준비 중",
      "generate" => "🧩 Xcode 프로젝트 생성 중", "fastlane" => "🚀 Fastlane 배포 시작",
      "sign" => "🔐 서명 인증서 준비 중", "build" => "🛠️ 빌드·아카이브·IPA 생성 중",
      "upload" => "☁️ Apple 업로드·처리 대기 중", "uploaded" => "📦 업로드 단계 완료",
      "review" => "📋 App Store 심사 제출 중", "submitted" => "📋 심사 제출 단계 완료",
      "preview" => "🔗 Tuist Preview 공유 중", "success" => "✅ CI 배포 완료",
      "failure" => "❌ CI 배포 실패", "cancelled" => "⏹️ CI 배포 취소"
    }
    title = labels.fetch(phase)
    terminal = %w[success failure cancelled].include?(phase)
    details = ["Attendance · #{target}", "버전 #{state['version'] || '확인 중'} · 빌드 #{state['build'] || '확인 중'}",
               "브랜치 #{branch} · 커밋 #{ENV.fetch('GITHUB_SHA', '')[0, 8]}",
               "실행자: #{ENV.fetch('GITHUB_TRIGGERING_ACTOR', ENV.fetch('GITHUB_ACTOR', 'unknown'))}"]
    details << "마지막 단계: #{labels[state['phase']]}" if terminal && state["phase"]
    details << "Apple 심사 승인·스토어 출시는 별도 상태입니다." if phase == "success"
    url = "https://github.com/#{ENV.fetch('GITHUB_REPOSITORY')}/actions/runs/#{ENV.fetch('GITHUB_RUN_ID')}"
    payload = { channel: ENV.fetch("SLACK_DEPLOY_CHANNEL_ID"), text: ([title] + details + [url]).join("\n"),
                mrkdwn: false, unfurl_links: false, unfurl_media: false,
                blocks: [{ type: "header", text: { type: "plain_text", text: title } },
                         { type: "section", text: { type: "plain_text", text: details.join("\n") } },
                         { type: "actions", elements: [{ type: "button", text: { type: "plain_text", text: "GitHub Actions 보기" }, url: url }] }] }
    state["phase"] = phase unless terminal
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.generate(state))
    # 시작 메시지를 최신 상태로 갱신하고, 단계 이력은 스레드에 남긴다.
    if state["ts"]
      api("chat.update", payload.merge(ts: state["ts"]))
      api("chat.postMessage", terminal ? payload : payload.merge(thread_ts: state["ts"]))
    else
      state["ts"] = api("chat.postMessage", payload).fetch("ts")
    end
    File.write(path, JSON.generate(state))
    true
  rescue StandardError
    warn "::warning::Slack 배포 알림 실패: 토큰·채널 권한·연결을 확인하세요. 배포는 계속합니다."
    false
  end
end

CISlack.notify(ARGV.fetch(0)) if $PROGRAM_NAME == __FILE__
