/**
 * PR 테스트 결과(xcresult)를 읽어 마크다운 리포트를 만들고 PR 에 코멘트로 남긴다.
 * actions/github-script 스텝에서 require 해서 호출한다.
 *
 * 환경변수
 *   RESULT_BUNDLE_DIR — tuist test --result-bundle-path 에 넘긴 경로
 *   TEST_OUTCOME      — 테스트 스텝의 outcome (success | failure | cancelled)
 */

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

// 새 코멘트를 달지 않고 이 마커로 기존 리포트를 찾아 갱신한다
const MARKER = "<!-- pr-test-report -->";

// GitHub 코멘트 본문 상한(65,536자)에 걸리지 않도록 자른다
const MAX_FAILURES = 40;
const MAX_FAILURE_TEXT = 600;
const MAX_BUILD_ERRORS = 20;

// 커버리지 막대 칸 수 (한 칸 = 5%)
const BAR_WIDTH = 20;

function xcrun(args) {
  return execFileSync("xcrun", args, {
    encoding: "utf8",
    maxBuffer: 256 * 1024 * 1024,
    stdio: ["ignore", "pipe", "pipe"],
  });
}

function findResultBundles(root) {
  if (!root || !fs.existsSync(root)) return [];

  // tuist 는 <path>.xcresult 를 만들고 <path> 심볼릭 링크를 건다. xcresulttool 은
  // 링크를 따라가지만 xccov 는 "unrecognized file format" 으로 거부한다.
  root = fs.realpathSync(root);

  const found = [];
  const walk = (dir, depth) => {
    if (depth > 3) return;
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const child = path.join(dir, entry.name);
      if (entry.name.endsWith(".xcresult")) found.push(child);
      else walk(child, depth + 1);
    }
  };

  if (root.endsWith(".xcresult")) return [root];
  walk(root, 0);
  // 번들이 확장자 없이 지정 경로 그대로 만들어진 경우
  return found.length > 0 ? found : [root];
}

function readSummary(bundle) {
  try {
    return JSON.parse(
      xcrun(["xcresulttool", "get", "test-results", "summary", "--path", bundle, "--format", "json"]),
    );
  } catch {
    return null;
  }
}

function readCoverage(bundle) {
  try {
    return JSON.parse(xcrun(["xccov", "view", "--report", "--json", "--only-targets", bundle]));
  } catch {
    // 커버리지 미수집 번들이면 xccov 가 에러를 낸다
    return [];
  }
}

// 빌드가 깨지면 테스트가 0개로 끝나 실패 원인이 안 보인다
function readBuildErrors(bundle) {
  try {
    const results = JSON.parse(
      xcrun(["xcresulttool", "get", "build-results", "--path", bundle, "--format", "json"]),
    );
    return results.errors || [];
  } catch {
    return [];
  }
}

function mergeSummaries(summaries) {
  const merged = {
    passed: 0,
    failed: 0,
    skipped: 0,
    expectedFailures: 0,
    failures: [],
    startTime: Infinity,
    finishTime: 0,
    device: null,
  };

  for (const s of summaries) {
    merged.passed += s.passedTests || 0;
    merged.failed += s.failedTests || 0;
    merged.skipped += s.skippedTests || 0;
    merged.expectedFailures += s.expectedFailures || 0;
    merged.failures.push(...(s.testFailures || []));
    if (s.startTime) merged.startTime = Math.min(merged.startTime, s.startTime);
    if (s.finishTime) merged.finishTime = Math.max(merged.finishTime, s.finishTime);
    merged.device ||= s.devicesAndConfigurations?.[0]?.device || null;
  }

  return merged;
}

function mergeCoverage(reports) {
  const byName = new Map();

  for (const target of reports.flat()) {
    if (!target?.name || target.name.endsWith(".xctest")) continue;
    if (!target.executableLines) continue;

    const name = target.name.replace(/\.(framework|app|bundle|a|dylib)$/, "");
    const acc = byName.get(name) || { name, coveredLines: 0, executableLines: 0 };
    acc.coveredLines += target.coveredLines || 0;
    acc.executableLines += target.executableLines;
    byName.set(name, acc);
  }

  const targets = [...byName.values()].sort(
    (a, b) => a.coveredLines / a.executableLines - b.coveredLines / b.executableLines,
  );
  const coveredLines = targets.reduce((sum, t) => sum + t.coveredLines, 0);
  const executableLines = targets.reduce((sum, t) => sum + t.executableLines, 0);

  return { targets, coveredLines, executableLines };
}

const percent = (covered, total) => (total > 0 ? `${((covered / total) * 100).toFixed(1)}%` : "—");
const comma = (n) => n.toLocaleString("en-US");

function formatDuration(seconds) {
  if (!Number.isFinite(seconds) || seconds <= 0) return null;
  const total = Math.round(seconds);
  const min = Math.floor(total / 60);
  return min > 0 ? `${min}m ${total % 60}s` : `${total}s`;
}

function renderFailures(failures) {
  const shown = failures.slice(0, MAX_FAILURES);

  const byTarget = new Map();
  for (const failure of shown) {
    const target = failure.targetName || "Unknown";
    if (!byTarget.has(target)) byTarget.set(target, []);
    byTarget.get(target).push(failure);
  }

  const lines = [`### ❌ 실패한 테스트 ${failures.length}개`, ""];

  for (const [target, items] of byTarget) {
    lines.push("<details open>", `<summary><code>${target}</code> · ${items.length}개</summary>`, "");

    for (const failure of items) {
      const id = failure.testIdentifierString || failure.testName || "(이름 없음)";
      lines.push(`**\`${id}\`**`);

      // testName 은 @Test("...") 로 붙인 표시 이름 — 식별자와 다를 때만 같이 보여준다
      if (failure.testName && !id.includes(failure.testName)) lines.push(failure.testName);

      const text = (failure.failureText || "").replace(/```/g, "'''").trim();
      if (text) {
        const clipped =
          text.length > MAX_FAILURE_TEXT ? `${text.slice(0, MAX_FAILURE_TEXT)}\n… (생략)` : text;
        lines.push("```text", clipped, "```");
      }
      lines.push("");
    }

    lines.push("</details>", "");
  }

  if (failures.length > shown.length) {
    lines.push(`> 이하 ${failures.length - shown.length}개는 생략했습니다. 전체는 워크플로 로그를 확인하세요.`, "");
  }

  return lines;
}

// file:///...#StartingLineNumber=32 → "Projects/.../File.swift:32"
function errorLocation(sourceURL) {
  if (!sourceURL) return null;

  const [filePart, fragment = ""] = sourceURL.split("#");
  const file = decodeURIComponent(filePart.replace(/^file:\/\//, ""));
  const relative = path.relative(process.cwd(), file);
  const line = /StartingLineNumber=(\d+)/.exec(fragment)?.[1];

  return line ? `${relative}:${line}` : relative;
}

function renderBuildErrors(errors) {
  // 위치 있는 에러가 있으면 "Testing cancelled because the build failed." 같은
  // 위치 없는 래퍼 에러는 노이즈라 걸러낸다
  const located = errors.filter((e) => e.sourceURL);
  const shown = (located.length > 0 ? located : errors).slice(0, MAX_BUILD_ERRORS);

  const lines = [`### 🔨 빌드 에러 ${shown.length}개`, ""];

  for (const error of shown) {
    const location = errorLocation(error.sourceURL);
    lines.push(location ? `**\`${location}\`**` : `**${error.issueType || "Error"}**`);

    const message = (error.message || "").replace(/```/g, "'''").trim();
    if (message) lines.push("```text", message, "```");
    lines.push("");
  }

  return lines;
}

function grade(covered, total) {
  if (total <= 0) return "";
  const ratio = covered / total;
  return ratio >= 0.6 ? "🟢" : ratio >= 0.3 ? "🟡" : "🔴";
}

// 백틱으로 감싸 모노스페이스로 렌더해야 칸 너비가 어긋나지 않는다
function bar(covered, total) {
  if (total <= 0) return "";

  let filled = Math.round((covered / total) * BAR_WIDTH);
  // 반올림 때문에 0% / 100% 가 아닌데 텅 비거나 꽉 차 보이는 것을 막는다
  if (covered > 0) filled = Math.max(filled, 1);
  if (covered < total) filled = Math.min(filled, BAR_WIDTH - 1);

  return `\`${"█".repeat(filled)}${"░".repeat(BAR_WIDTH - filled)}\``;
}

function renderCoverage(coverage) {
  if (coverage.targets.length === 0) {
    return ["### 📊 커버리지", "", "> 커버리지 데이터가 없습니다.", ""];
  }

  const lines = [
    `### 📊 커버리지 ${percent(coverage.coveredLines, coverage.executableLines)} ` +
      `(${comma(coverage.coveredLines)} / ${comma(coverage.executableLines)} 라인)`,
    "",
    `${grade(coverage.coveredLines, coverage.executableLines)} ${bar(coverage.coveredLines, coverage.executableLines)}`,
    "",
    "<details><summary>모듈별 커버리지</summary>",
    "",
    "| 모듈 | 커버리지 | | 라인 |",
    "| --- | --- | ---: | ---: |",
  ];

  for (const t of coverage.targets) {
    lines.push(
      `| ${grade(t.coveredLines, t.executableLines)} ${t.name} | ${bar(t.coveredLines, t.executableLines)} | ${percent(t.coveredLines, t.executableLines)} | ${comma(t.coveredLines)} / ${comma(t.executableLines)} |`,
    );
  }

  lines.push("", "</details>", "");
  return lines;
}

function renderReport({ summary, coverage, buildErrors, outcome, runUrl, sha }) {
  const lines = [MARKER, ""];
  const footer = [`\`${sha.slice(0, 7)}\``, `[워크플로 로그](${runUrl})`].join(" · ");

  if (!summary) {
    lines.push(
      "## ⚠️ 테스트 결과를 읽지 못했습니다",
      "",
      `테스트 스텝 결과: \`${outcome}\`. 결과 번들이 만들어지지 않았습니다.`,
      "",
      footer,
    );
    return lines.join("\n");
  }

  const total = summary.passed + summary.failed + summary.skipped;

  if (total === 0 && buildErrors.length > 0) {
    lines.push("## 🔨 빌드 실패", "", "컴파일 에러로 테스트를 실행하지 못했습니다.", "", footer, "");
    lines.push(...renderBuildErrors(buildErrors));
    return lines.join("\n");
  }

  const passing = summary.failed === 0 && outcome === "success";

  lines.push(passing ? "## ✅ 테스트 통과" : "## ❌ 테스트 실패", "");

  const counts = [`**${comma(summary.passed)} passed**`];
  if (summary.failed > 0) counts.push(`**${comma(summary.failed)} failed**`);
  if (summary.skipped > 0) counts.push(`${comma(summary.skipped)} skipped`);
  if (summary.expectedFailures > 0) counts.push(`${comma(summary.expectedFailures)} expected failures`);

  const duration = formatDuration(summary.finishTime - summary.startTime);
  if (duration) counts.push(duration);
  lines.push(`${counts.join(" · ")} · 총 ${comma(total)}개`, "");

  const meta = [];
  if (summary.device) {
    meta.push(`${summary.device.modelName} (${summary.device.platform} ${summary.device.osVersion})`);
  }
  meta.push(footer);
  lines.push(meta.join(" · "), "");

  if (summary.failures.length > 0) lines.push(...renderFailures(summary.failures));
  lines.push(...renderCoverage(coverage));

  return lines.join("\n");
}

module.exports = async ({ github, context, core }) => {
  const bundles = findResultBundles(process.env.RESULT_BUNDLE_DIR);
  const summaries = bundles.map(readSummary).filter(Boolean);
  const coverage = mergeCoverage(bundles.map(readCoverage));
  const buildErrors = bundles.flatMap(readBuildErrors);

  const body = renderReport({
    summary: summaries.length > 0 ? mergeSummaries(summaries) : null,
    coverage,
    buildErrors,
    outcome: process.env.TEST_OUTCOME || "unknown",
    runUrl: `${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${context.runId}`,
    sha: context.payload.pull_request.head.sha,
  });

  const target = {
    owner: context.repo.owner,
    repo: context.repo.repo,
    issue_number: context.payload.pull_request.number,
  };

  const comments = await github.paginate(github.rest.issues.listComments, { ...target, per_page: 100 });
  const existing = comments.find((c) => c.body?.includes(MARKER));

  if (existing) {
    await github.rest.issues.updateComment({ ...target, comment_id: existing.id, body });
  } else {
    await github.rest.issues.createComment({ ...target, body });
  }

  await core.summary.addRaw(body.replace(MARKER, "")).write();
};
