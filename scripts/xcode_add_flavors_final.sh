#!/bin/bash

# Final attempt at automated iOS flavor setup

set -e

cd "$(dirname "$0")/../ios" || exit

echo "Adding iOS flavor configurations to Xcode project..."
echo ""

ruby << 'RUBY_SCRIPT'
require 'xcodeproj'

project = Xcodeproj::Project.open('Runner.xcodeproj')

# Define our flavors and base configurations
flavors = {
  'development' => 'Flutter/Development.xcconfig',
  'staging' => 'Flutter/Staging.xcconfig',
  'production' => 'Flutter/Production.xcconfig'
}

base_configs = ['Debug', 'Release', 'Profile']

puts "Step 1: Adding project-level configurations"
puts "=" * 50

# Get project configuration list
project_config_list = project.root_object.build_configuration_list

flavors.each do |flavor_name, xcconfig_path|
  puts "\nAdding #{flavor_name} flavor:"

  # Find xcconfig file reference
  xcconfig_ref = project.files.find { |f| f.path == xcconfig_path }

  base_configs.each do |base_name|
    config_name = "#{base_name}-#{flavor_name}"

    # Skip if exists
    if project_config_list.build_configurations.any? { |c| c.name == config_name }
      puts "  #{config_name} already exists, skipping"
      next
    end

    # Find base configuration to duplicate
    base_config = project_config_list.build_configurations.find { |c| c.name == base_name }

    if base_config
      # Create new configuration object
      new_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
      new_config.name = config_name
      new_config.build_settings = base_config.build_settings.dup

      # Set xcconfig reference
      new_config.base_configuration_reference = xcconfig_ref if xcconfig_ref

      # Add to configuration list
      project_config_list.build_configurations << new_config

      puts "  Created #{config_name}"
    else
      puts "  WARNING: Base config #{base_name} not found!"
    end
  end
end

puts "\nStep 2: Adding target-level configurations"
puts "=" * 50

project.targets.each do |target|
  puts "\nTarget: #{target.name}"
  target_config_list = target.build_configuration_list

  flavors.each do |flavor_name, xcconfig_path|
    # Only Runner target should use the xcconfig file
    xcconfig_ref = nil
    if target.name == 'Runner'
      xcconfig_ref = project.files.find { |f| f.path == xcconfig_path }
    end

    base_configs.each do |base_name|
      config_name = "#{base_name}-#{flavor_name}"

      # Skip if exists
      if target_config_list.build_configurations.any? { |c| c.name == config_name }
        puts "  #{config_name} already exists, skipping"
        next
      end

      # Find base configuration to duplicate
      base_config = target_config_list.build_configurations.find { |c| c.name == base_name }

      if base_config
        # Create new configuration object
        new_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
        new_config.name = config_name
        new_config.build_settings = base_config.build_settings.dup
        new_config.build_settings['SWIFT_VERSION'] = '5.0'

        # Set xcconfig reference for Runner target
        new_config.base_configuration_reference = xcconfig_ref if xcconfig_ref

        # Add to configuration list
        target_config_list.build_configurations << new_config

        puts "  Created #{config_name}"
      else
        puts "  WARNING: Base config #{base_name} not found for target!"
      end
    end
  end
end

# Save the project
puts "\n" + "=" * 50
puts "Saving project..."
project.save

puts "\nSuccess! Added configurations:"
project_config_list.build_configurations.map(&:name).sort.each do |name|
  puts "  - #{name}"
end

puts "\nNext steps:"
puts "1. Run: cd ios && export LANG=en_US.UTF-8 && pod install"
puts "2. Build: ./scripts/build_ipa_dev.sh"
RUBY_SCRIPT
