#!/bin/bash

# Simplified script to add iOS flavor configurations for Flutter

set -e

echo "Adding iOS flavor configurations..."
echo ""

cd "$(dirname "$0")/../ios" || exit

# Check if xcodeproj gem is installed
if ! gem list xcodeproj -i > /dev/null 2>&1; then
    echo "Installing xcodeproj gem..."
    sudo gem install xcodeproj
    echo ""
fi

# Create a simple Ruby script
ruby << 'RUBY'
require 'xcodeproj'

def add_configurations_to_list(config_list, base_config_name, flavor_name, project, xcconfig_ref = nil)
  base_config = config_list.build_configurations.find { |c| c.name == base_config_name }
  return nil unless base_config

  new_config_name = "#{base_config_name}-#{flavor_name}"

  # Check if it already exists
  if config_list.build_configurations.any? { |c| c.name == new_config_name }
    puts "  #{new_config_name} already exists, skipping"
    return nil
  end

  # Create new configuration
  new_config = config_list.build_configuration(new_config_name, base_config.type)
  new_config.build_settings = base_config.build_settings.dup
  new_config.build_settings['SWIFT_VERSION'] = '5.0'
  new_config.base_configuration_reference = xcconfig_ref if xcconfig_ref

  puts "  Created #{new_config_name}"
  new_config
end

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

flavors = {
  'development' => 'Development.xcconfig',
  'staging' => 'Staging.xcconfig',
  'production' => 'Production.xcconfig'
}

base_configs = ['Debug', 'Release', 'Profile']

puts "Setting up project-level configurations..."
puts ""

# Add project-level configurations
project_config_list = project.root_object.build_configuration_list

flavors.each do |flavor_name, xcconfig_file|
  puts "Adding #{flavor_name} flavor to project:"

  # Find or create xcconfig file reference
  xcconfig_path = "Flutter/#{xcconfig_file}"
  xcconfig_ref = project.files.find { |f| f.path == xcconfig_path }

  base_configs.each do |base_config|
    add_configurations_to_list(project_config_list, base_config, flavor_name, project, xcconfig_ref)
  end

  puts ""
end

puts "Setting up target-level configurations..."
puts ""

# Add target-level configurations
project.targets.each do |target|
  puts "Configuring target: #{target.name}"
  target_config_list = target.build_configuration_list

  flavors.each do |flavor_name, xcconfig_file|
    # For Runner target, use the xcconfig reference
    # For other targets (like RunnerTests), don't use xcconfig
    xcconfig_ref = nil
    if target.name == 'Runner'
      xcconfig_path = "Flutter/#{xcconfig_file}"
      xcconfig_ref = project.files.find { |f| f.path == xcconfig_path }
    end

    base_configs.each do |base_config|
      add_configurations_to_list(target_config_list, base_config, flavor_name, project, xcconfig_ref)
    end
  end

  puts ""
end

# Save project
puts "Saving project..."
project.save

puts "Successfully added flavor configurations!"
puts ""
puts "Configurations added:"
project_config_list.build_configurations.each do |config|
  puts "  - #{config.name}"
end
RUBY

echo ""
echo "Done! Next steps:"
echo "1. Run: export LANG=en_US.UTF-8 && cd ios && pod install"
echo "2. Try your build script again: ./scripts/build_ipa_dev.sh"
