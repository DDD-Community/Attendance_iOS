const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");

const repositoryRoot = path.resolve(__dirname, "..");
const actionReference = "uses: ./.github/actions/setup-ios-runner";

function read(relativePath) {
  return fs.readFileSync(path.join(repositoryRoot, relativePath), "utf8");
}

function occurrences(source, fragment) {
  return source.split(fragment).length - 1;
}

test("iOS workflow는 공통 runner setup action을 사용한다", () => {
  const action = read(".github/actions/setup-ios-runner/action.yml");
  assert.match(action, /using: composite/);

  const expectedCalls = new Map([
    [".github/workflows/ios-pr-coverage.yml", { setup: 3, checkout: 4 }],
    [".github/workflows/ios-develop-sharded-tests.yml", { setup: 3, checkout: 3 }],
    [".github/workflows/ios-cache-warm.yml", { setup: 1, checkout: 1 }],
    [".github/workflows/ios-deploy.yml", { setup: 1, checkout: 1 }],
  ]);

  for (const [workflow, expectedCount] of expectedCalls) {
    const source = read(workflow);
    assert.equal(occurrences(source, actionReference), expectedCount.setup, workflow);
    assert.equal(occurrences(source, "uses: actions/checkout@v4"), expectedCount.checkout, workflow);
    assert.equal(occurrences(source, "Restore gitignored build config"), 0, workflow);
    assert.equal(occurrences(source, "mise install tuist"), 0, workflow);
  }
});

test("공통화 뒤에도 timeout이 필요한 Tuist service step은 workflow에 남긴다", () => {
  const pr = read(".github/workflows/ios-pr-coverage.yml");
  const develop = read(".github/workflows/ios-develop-sharded-tests.yml");

  assert.equal(occurrences(pr, "timeout-minutes: 3"), 6);
  assert.equal(occurrences(develop, "timeout-minutes: 3"), 5);
});
