#!/bin/bash

# Script to clean up and properly set up iOS flavor configurations

set -e

echo "Resetting and setting up iOS flavor configurations..."

cd "$(dirname "$0")/../ios" || exit

# Create Ruby script to reset and properly configure
cat > reset_and_setup.rb << 'EOF'
require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Define flavors
flavors = ['development', 'staging', 'production']
base_configs = ['Debug', 'Release', 'Profile']

puts "Step 1: Removing duplicate and flavor configurations from project..."
runner_project = project.root_object
build_config_list = runner_project.build_configuration_list

# Remove all configurations except base ones
configs_to_keep = build_config_list.build_configurations.select { |c| base_configs.include?(c.name) }
build_config_list.build_configurations.clear
configs_to_keep.each { |c| build_config_list.build_configurations << c }

puts "Kept base configurations: #{configs_to_keep.map(&:name).join(', ')}"

puts "\nStep 2: Adding flavor configurations to project..."
flavors.each do |flavor|
  base_configs.each do |base_config|
    config_name = "#{base_config}-#{flavor}"
    puts "Creating project configuration: #{config_name}"

    # Find the base configuration to copy from
    base_configuration = configs_to_keep.find { |c| c.name == base_config }

    if base_configuration
      # Create new configuration
      new_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
      new_config.name = config_name
      new_config.build_settings = base_configuration.build_settings.dup

      # Reference the flavor xcconfig file
      config_file_path = "Flutter/#{flavor.capitalize}.xcconfig"
      config_file_ref = project.files.find { |f| f.path == config_file_path }

      unless config_file_ref
        # Create reference if it doesn't exist
        flutter_group = project.main_group.find_subpath('Flutter', true)
        config_file_ref = flutter_group.new_reference(config_file_path)
      end

      new_config.base_configuration_reference = config_file_ref
      build_config_list.build_configurations << new_config
    end
  end
end

puts "\nStep 3: Setting up target configurations..."
project.targets.each do |target|
  puts "\nProcessing target: #{target.name}"
  target_config_list = target.build_configuration_list

  # Get existing base configurations
  base_target_configs = target_config_list.build_configurations.select { |c| base_configs.include?(c.name) }

  if base_target_configs.empty?
    puts "  Warning: No base configurations found for target, skipping..."
    next
  end

  # Clear and rebuild configurations
  target_config_list.build_configurations.clear
  base_target_configs.each { |c| target_config_list.build_configurations << c }

  puts "  Kept base configurations: #{base_target_configs.map(&:name).join(', ')}"

  # Add flavor configurations for target
  flavors.each do |flavor|
    base_configs.each do |base_config|
      config_name = "#{base_config}-#{flavor}"
      puts "  Creating target configuration: #{config_name}"

      # Find the base target configuration to copy from
      base_target_config = base_target_configs.find { |c| c.name == base_config }

      if base_target_config
        # Create new target configuration
        new_target_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
        new_target_config.name = config_name
        new_target_config.build_settings = base_target_config.build_settings.dup

        # Ensure SWIFT_VERSION is set
        new_target_config.build_settings['SWIFT_VERSION'] = '5.0'

        # For Runner target, reference the flavor xcconfig file
        if target.name == 'Runner'
          config_file_path = "Flutter/#{flavor.capitalize}.xcconfig"
          config_file_ref = project.files.find { |f| f.path == config_file_path }
          new_target_config.base_configuration_reference = config_file_ref if config_file_ref
        end

        target_config_list.build_configurations << new_target_config
      end
    end
  end
end

# Save the project
project.save

puts "\n✅ Project configurations reset and properly configured!"
puts "\nFinal project configurations:"
build_config_list.build_configurations.each { |c| puts "  - #{c.name}" }
EOF

# Run the Ruby script
ruby reset_and_setup.rb

# Clean up
rm reset_and_setup.rb

echo ""
echo "✅ iOS flavor configurations have been properly set up!"
echo ""
echo "Next step: Run 'cd ios && pod install'"
