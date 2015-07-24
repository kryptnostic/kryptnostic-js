#!/usr/bin/ruby

#
# Bumps and releases a new version of the plugin.
# Please install git-tool before using.
# Author: rbuckheit
#

VERSION_IDENTIFIER = '"version"'
SEMVER_SEPARATOR   = '.'
BOWER_FILE         = 'bower.json'
NPM_FILE           = 'package.json'

def read_version(file)
  File.readlines(BOWER_FILE).each do |line|
    if line.include?(VERSION_IDENTIFIER)
      return line.split(':').last.strip().gsub("\"", '').gsub(',','')
    end
  end
end

def bump_version(version)
  major, minor, fix = version.split('.')
  fix = (fix.to_i + 1)
  return [major, minor, fix].join('.')
end

def rewrite_version(file, version)
  lines = File.readlines(file)
  f     = File.open(file, 'w')

  lines.each do |line|
    if line.include?(VERSION_IDENTIFIER)
      key, old_version = line.split(":")
      new_version      = " \"#{version}\",\n"
      new_line         = [key, new_version].join(":")
      puts "rewriting '#{line.chomp()}' to '#{new_line.chomp()}'"
      f.write(new_line)
    else
      f.write(line)
    end
  end
  f.close()
end

puts "reading version..."
version = read_version(VERSION_IDENTIFIER)
puts "current version is v#{version}"
new_version = bump_version(version)
puts "will release version v#{new_version} and push it. [y/n]"

unless gets().start_with?('y')
  exit()
end

puts; puts "starting gitflow release..."
`gtool gitflow_release_start #{new_version}`

puts; puts "bumping to v#{new_version}..."
rewrite_version(NPM_FILE, new_version)
rewrite_version(BOWER_FILE, new_version)

puts; puts "building release dists..."
`./build.sh --release`

puts; puts "committing release bump changes..."
`git add -A && git commit -m 'bump versions and dists'`

puts; puts "finishing gitflow release..."
`gtool gitflow_release_finish #{new_version}`

puts; puts "pushing gitflow release..."
`gtool push_release`

puts; puts "cleaning up dev tag..."
`gtool delete_tag v#{new_version}-dev`

exit()
