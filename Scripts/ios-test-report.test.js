const assert = require("node:assert/strict");
const test = require("node:test");

const { internalCoverageTargetNames, mergeCoverage } = require("./ios-test-report.js").__test__;

test("프로젝트 매니페스트에서 자사 커버리지 대상을 구성한다", () => {
  const targets = internalCoverageTargetNames();

  assert.equal(targets.has("DDDAttendance"), true);
  assert.equal(targets.has("APIEndpoint"), true);
  assert.equal(targets.has("DDDNetworkInterface"), true);
  assert.equal(targets.has("Alamofire"), false);
  assert.equal(targets.has("SwiftUIX"), false);
});

test("커버리지 리포트는 내부 모듈만 집계한다", () => {
  const allowedTargets = new Set(["API", "DDDNetwork", "DDDNetworkInterface"]);
  const coverage = mergeCoverage(
    [
      [
        { name: "API.framework", coveredLines: 10, executableLines: 100 },
        { name: "DDDNetwork", coveredLines: 20, executableLines: 200 },
        { name: "DDDNetworkInterface", coveredLines: 5, executableLines: 50 },
        { name: "Alamofire", coveredLines: 500, executableLines: 10_000 },
        { name: "SwiftUIX", coveredLines: 1_000, executableLines: 30_000 },
        { name: "APITests.xctest", coveredLines: 10, executableLines: 10 },
      ],
    ],
    allowedTargets,
  );

  assert.deepEqual(
    coverage.targets.map((target) => target.name).sort(),
    ["API", "DDDNetwork", "DDDNetworkInterface"],
  );
  assert.equal(coverage.coveredLines, 35);
  assert.equal(coverage.executableLines, 350);
});
