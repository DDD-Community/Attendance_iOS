const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const test = require("node:test");

const tuistConfig = readFileSync("Tuist.swift", "utf8");
const projectSettings = readFileSync(
  "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Setting/Project+Settings.swift",
  "utf8"
);
const settingDictionary = readFileSync(
  "Plugins/ProjectTemplatePlugin/ProjectDescriptionHelpers/Setting/SettingDictionary.swift",
  "utf8"
);
const buildConfiguration = `${tuistConfig}\n${projectSettings}\n${settingDictionary}`;

test("Swift 6.4 precise module tracking을 명시적으로 사용한다", () => {
  assert.match(tuistConfig, /swiftVersion: \.some\("6\.4\.0"\)/);
  assert.match(settingDictionary, /"CLANG_ENABLE_EXPLICIT_MODULES"/);
  assert.match(settingDictionary, /"SWIFT_ENABLE_EXPLICIT_MODULES"/);
  assert.match(projectSettings, /\.setExplicitlyBuiltModules\(\)/);
});

test("Swift 6.4에서 폐기된 module debug 플래그를 직접 전달하지 않는다", () => {
  assert.doesNotMatch(buildConfiguration, /-modulewrap/);
  assert.doesNotMatch(buildConfiguration, /-add_ast_path/);
  assert.doesNotMatch(buildConfiguration, /-debug-module-path/);
});
