#!/bin/bash

# Script to fix Swift version conflicts in Xcode project

set -e

echo "Fixing Swift version in all configurations..."

cd "$(dirname "$0")/../ios" || exit

# Create Ruby script to fix Swift versions
cat > fix_swift.rb << 'EOF'
require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Set Swift version for all targets
project.targets.each do |target|
  puts "Fixing Swift version for target: #{target.name}"

  target.build_configuration_list.build_configurations.each do |config|
    # Set or update SWIFT_VERSION to 5.0
    config.build_settings['SWIFT_VERSION'] = '5.0'
    puts "  #{config.name}: SWIFT_VERSION = 5.0"
  end
end

# Save the project
project.save
puts "\nSwift version fixed successfully!"
EOF

# Run the Ruby script
ruby fix_swift.rb

# Clean up
rm fix_swift.rb

echo "✅ Swift version fixed in all configurations!"
