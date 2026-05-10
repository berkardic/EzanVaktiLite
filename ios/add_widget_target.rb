#!/usr/bin/env ruby
# Adds the EzanVaktiWidget extension target to the Xcode project.
# Run from the Flutter project root:
#   ruby ios/add_widget_target.rb
#
# After running, open Runner.xcworkspace in Xcode and:
#   1. Select EzanVaktiWidget target → Signing & Capabilities
#      → "+ Capability" → "App Groups" → add "group.com.yba.EzanVaktiLite"
#   2. Select Runner target → Signing & Capabilities
#      → "+ Capability" → "App Groups" → add "group.com.yba.EzanVaktiLite"
#   3. cd ios && pod install

require 'xcodeproj'

PROJECT_PATH = 'ios/Runner.xcodeproj'
WIDGET_NAME  = 'EzanVaktiWidget'
BUNDLE_ID    = 'com.yba.EzanVaktiLite.widget'
TEAM_ID      = 'QCUX6Z67PV'
DEPLOY_VER   = '14.0'

project = Xcodeproj::Project.open(PROJECT_PATH)

# Guard: skip if already added
if project.targets.any? { |t| t.name == WIDGET_NAME }
  puts "⚠️  '#{WIDGET_NAME}' target already exists. Nothing to do."
  exit 0
end

# ── 1. Create app extension target ──────────────────────────────────────────
widget_target = project.new_target(:app_extension, WIDGET_NAME, :ios, DEPLOY_VER)
widget_target.product_type = 'com.apple.product-type.widgetkit-extension'

# ── 2. Configure build settings for all configurations ──────────────────────
widget_target.build_configurations.each do |cfg|
  s = cfg.build_settings

  # Remove settings that don't apply to an extension
  %w[
    ASSETCATALOG_COMPILER_APPICON_NAME
    CURRENT_PROJECT_VERSION
    VERSIONING_SYSTEM
    SWIFT_OBJC_BRIDGING_HEADER
  ].each { |k| s.delete(k) }

  s['PRODUCT_BUNDLE_IDENTIFIER']             = BUNDLE_ID
  s['PRODUCT_NAME']                          = '$(TARGET_NAME)'
  s['SWIFT_VERSION']                         = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET']            = DEPLOY_VER
  s['TARGETED_DEVICE_FAMILY']                = '1,2'
  s['DEVELOPMENT_TEAM']                      = TEAM_ID
  s['SKIP_INSTALL']                          = 'YES'
  s['CODE_SIGN_STYLE']                       = 'Automatic'
  s['CODE_SIGN_ENTITLEMENTS']                = "#{WIDGET_NAME}/#{WIDGET_NAME}.entitlements"
  s['INFOPLIST_FILE']                        = "#{WIDGET_NAME}/Info.plist"
  s['GENERATE_INFOPLIST_FILE']               = 'NO'
  s['LD_RUNPATH_SEARCH_PATHS']               = [
    '$(inherited)',
    '@executable_path/Frameworks',
    '@executable_path/../../Frameworks'
  ]
  s['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
  s['CLANG_ENABLE_MODULES']                  = 'YES'
  s['ENABLE_BITCODE']                        = 'NO'

  if cfg.name == 'Debug'
    s['SWIFT_OPTIMIZATION_LEVEL']            = '-Onone'
    s['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
  end
end

# ── 3. Create source group and add files ─────────────────────────────────────
widget_group = project.main_group.new_group(WIDGET_NAME, WIDGET_NAME)

swift_ref = widget_group.new_file("#{WIDGET_NAME}.swift")
swift_ref.last_known_file_type = 'sourcecode.swift'
widget_target.source_build_phase.add_file_reference(swift_ref)

plist_ref = widget_group.new_file('Info.plist')
plist_ref.last_known_file_type = 'text.plist.xml'
widget_target.resources_build_phase.add_file_reference(plist_ref)

# Entitlements — just a file reference, not built
ent_ref = widget_group.new_file("#{WIDGET_NAME}.entitlements")
ent_ref.last_known_file_type = 'text.plist.entitlements'

# ── 4. Add Runner.entitlements to the Runner group ───────────────────────────
runner_group = project.main_group.children.find do |c|
  c.is_a?(Xcodeproj::Project::Object::PBXGroup) &&
    (c.path == 'Runner' || c.name == 'Runner')
end

if runner_group
  has_ent = runner_group.children.any? do |c|
    c.respond_to?(:path) && c.path == 'Runner.entitlements'
  end
  unless has_ent
    runner_ent_ref = runner_group.new_file('Runner.entitlements')
    runner_ent_ref.last_known_file_type = 'text.plist.entitlements'
  end
end

# Point Runner target at its entitlements file
runner_target = project.targets.find { |t| t.name == 'Runner' }
runner_target.build_configurations.each do |cfg|
  cfg.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

# ── 5. Embed widget extension inside Runner ──────────────────────────────────
# dst_subfolder_spec 13 = "PlugIns" (app extensions live here)
embed_phase = runner_target.copy_files_build_phases.find do |p|
  p.dst_subfolder_spec == '13'
end
unless embed_phase
  embed_phase = runner_target.new_copy_files_build_phase('Embed Foundation Extensions')
  embed_phase.dst_subfolder_spec = '13'
end

build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
build_file.file_ref = widget_target.product_reference
build_file.settings  = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
embed_phase.files << build_file

# ── 6. Save ──────────────────────────────────────────────────────────────────
project.save

puts ""
puts "✅  EzanVaktiWidget target successfully added to #{PROJECT_PATH}"
puts ""
puts "Next steps (required — must be done in Xcode):"
puts "  1. Open ios/Runner.xcworkspace in Xcode"
puts "  2. Select the 'EzanVaktiWidget' target → 'Signing & Capabilities' tab"
puts "     → click '+ Capability' → choose 'App Groups'"
puts "     → add 'group.com.yba.EzanVaktiLite'"
puts "  3. Select the 'Runner' target → 'Signing & Capabilities' tab"
puts "     → click '+ Capability' → choose 'App Groups'"
puts "     → add 'group.com.yba.EzanVaktiLite'"
puts "  4. cd ios && pod install"
puts "  5. Build & run from Xcode"
