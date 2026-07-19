#!/bin/bash

# Script to set up iOS flavor configurations for Flutter multi-flavor project
# This script adds the necessary build configurations to Xcode project

set -e

echo "Setting up iOS flavor configurations..."

# Navigate to iOS directory
cd "$(dirname "$0")/../ios" || exit

# Check if xcodeproj gem is installed
if ! gem list xcodeproj -i > /dev/null 2>&1; then
    echo "Installing xcodeproj gem..."
    sudo gem install xcodeproj
fi

# Create Ruby script to add configurations
cat > add_configurations.rb << 'EOF'
require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Define flavors
flavors = ['development', 'staging', 'production']
base_configs = ['Debug', 'Release', 'Profile']

# Get the project
runner_project = project.root_object

# Get existing configurations
build_config_list = runner_project.build_configuration_list
existing_configs = build_config_list.build_configurations.map(&:name)
puts "Existing configurations: #{existing_configs.join(', ')}"

flavors.each do |flavor|
  base_configs.each do |base_config|
    config_name = "#{base_config}-#{flavor}"

    # Skip if configuration already exists
    if existing_configs.include?(config_name)
      puts "Configuration '#{config_name}' already exists, skipping..."
      next
    end

    puts "Creating configuration: #{config_name}"

    # Find the base configuration
    base_configuration = build_config_list.build_configurations.find { |c| c.name == base_config }

    if base_configuration
      # Create new configuration based on base
      new_config = project.add_build_configuration(config_name, base_configuration.type)

      # Copy build settings from base configuration
      new_config.build_settings = base_configuration.build_settings.dup

      # Set the xcconfig file based on flavor
      config_file = "Flutter/#{flavor.capitalize}.xcconfig"

      # Set base configuration reference
      config_file_ref = project.files.find { |f| f.path == config_file }
      unless config_file_ref
        # Create reference if it doesn't exist
        flutter_group = project.main_group.find_subpath('Flutter', true)
        config_file_ref = flutter_group.new_reference(config_file)
      end
      new_config.base_configuration_reference = config_file_ref

      # Add to build configuration list
      build_config_list.build_configurations << new_config
      existing_configs << config_name  # Update our tracking list
    else
      puts "Warning: Base configuration '#{base_config}' not found!"
    end
  end
end

# Update all targets with new configurations
project.targets.each do |target|
  puts "\nUpdating target: #{target.name}"

  target_config_list = target.build_configuration_list
  target_configs = target_config_list.build_configurations.map(&:name)

  flavors.each do |flavor|
    base_configs.each do |base_config|
      config_name = "#{base_config}-#{flavor}"

      # Skip if target configuration already exists
      if target_configs.include?(config_name)
        puts "  Target configuration '#{config_name}' already exists, skipping..."
        next
      end

      puts "  Adding target configuration: #{config_name}"

      # Find the base target configuration
      base_target_config = target_config_list.build_configurations.find { |c| c.name == base_config }

      if base_target_config
        # Create new configuration for target
        new_target_config = Xcodeproj::Project::Object::XCBuildConfiguration.new(project, base_target_config.uuid)
        new_target_config.name = config_name
        new_target_config.build_settings = base_target_config.build_settings.dup

        # For Runner target, set the xcconfig file
        if target.name == 'Runner'
          config_file = "Flutter/#{flavor.capitalize}.xcconfig"
          config_file_ref = project.files.find { |f| f.path == config_file }
          new_target_config.base_configuration_reference = config_file_ref if config_file_ref
        end

        # Add to target's configuration list
        target_config_list.build_configurations << new_target_config
        target_configs << config_name
      end
    end
  end
end

# Save the project
project.save
puts "\nProject configurations updated successfully!"
puts "New configurations added for flavors: #{flavors.join(', ')}"
EOF

# Run the Ruby script
ruby add_configurations.rb

# Clean up
rm add_configurations.rb

echo "✅ iOS flavor configurations have been set up!"
echo ""
echo "Next steps:"
echo "1. Update Podfile to include flavor configurations"
echo "2. Run 'cd ios && pod install'"
echo "3. Try building again with your flavor script"
