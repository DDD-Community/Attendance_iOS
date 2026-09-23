const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");
const test = require("node:test");

const repositoryRoot = path.resolve(__dirname, "..");
const generator = path.join(repositoryRoot, "fastlane/app_store_release_notes.rb");
const config = path.join(repositoryRoot, "fastlane/release_notes.yml");

function render(version) {
  const script = `
    require ${JSON.stringify(generator)}
    require "json"
    puts JSON.generate(AppStoreReleaseNotes.render(
      config_path: ${JSON.stringify(config)},
      version: ${JSON.stringify(version)}
    ))
  `;
  const result = spawnSync("ruby", ["-e", script], { encoding: "utf8" });
  assert.equal(result.status, 0, result.stderr);
  return JSON.parse(result.stdout);
}

test("App Store 릴리스 노트는 현재 버전을 포함해 한글과 영어로 생성된다", () => {
  const notes = render("1.1.0");

  assert.deepEqual(Object.keys(notes).sort(), ["en-US", "ko"]);
  assert.match(notes.ko, /^\[v 1\.1\.0\]/);
  assert.match(notes.ko, /\[개선 사항\]/);
  assert.match(notes["en-US"], /^\[v 1\.1\.0\]/);
  assert.match(notes["en-US"], /\[Improvements\]/);
  assert.doesNotMatch(JSON.stringify(notes), /%\{version\}/);
});

test("같은 버전은 같은 문구를 사용하고 버전이 바뀌면 문구 풀이 순환된다", () => {
  assert.deepEqual(render("1.1.0"), render("1.1.0"));

  const koreanNotes = new Set(
    Array.from({ length: 20 }, (_, index) => render(`1.1.${index}`).ko)
  );
  assert.ok(koreanNotes.size > 1);
});

test("release 브랜치 배포가 자동 생성된 릴리스 노트를 사용한다", () => {
  const workflow = fs.readFileSync(
    path.join(repositoryRoot, ".github/workflows/ios-deploy.yml"),
    "utf8"
  );
  const fastfile = fs.readFileSync(path.join(repositoryRoot, "fastlane/Fastfile"), "utf8");

  assert.match(workflow, /branches: \[develop, release\]/);
  assert.equal((workflow.match(/github\.ref_name == 'release'/g) ?? []).length, 2);
  assert.doesNotMatch(workflow, /github\.ref_name == 'main'/);
  assert.equal((fastfile.match(/AppStoreReleaseNotes\.write\(/g) ?? []).length, 2);
});
