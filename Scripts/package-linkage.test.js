const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const test = require("node:test");

const packageManifest = readFileSync("Tuist/Package.swift", "utf8");

test("Point-Free Sharing은 앱에서 한 번만 로드되고 Apple private Sharing과 실행 파일명이 겹치지 않는다", () => {
  assert.match(packageManifest, /"Sharing": \.framework/);
  assert.match(packageManifest, /"Sharing1": \.staticFramework/);
  assert.match(packageManifest, /"Sharing2": \.staticFramework/);
  assert.match(packageManifest, /"SQLiteData": \.framework/);
  assert.match(packageManifest, /"Sharing": \.settings\([\s\S]*?"EXECUTABLE_NAME": "DDDPointFreeSharing"/);
  assert.doesNotMatch(packageManifest, /PRODUCT_(?:MODULE_)?NAME[^\n]*Sharing/);
});
