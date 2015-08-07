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

BUMP_TYPES = [ :major, :minor, :hotfix ]

def usage
  $stderr.puts "usage: ./bump.rb [ bump_type ]"
  $stderr.puts "  bump_type: one of 'major', 'minor', 'hotfix' "
  exit()
end

def get_bump_type
  proposed = "#{ARGV[0]}".to_sym

  if BUMP_TYPES.include?(proposed)
    return proposed
  elsif proposed.to_s.empty?
    return :hotfix
  else
    $stderr.puts "illegal bump type: #{proposed.inspect}"
    usage()
  end
end

def read_version(file)
  File.readlines(BOWER_FILE).each do |line|
    if line.include?(VERSION_IDENTIFIER)
      return line.split(':').last.strip().gsub("\"", '').gsub(',','')
    end
  end
end

def bump_version(version, bump_type)
  major, minor, hotfix = version.split('.')

  if (bump_type == :major)
    major  = (major.to_i + 1)
    minor  = 0
    hotfix = 0
  elsif (bump_type == :minor)
    minor  = (minor.to_i + 1)
    hotfix = 0
  elsif (bump_type == :hotfix)
    hotfix = (hotfix.to_i + 1)
  end

  return [ major, minor, hotfix ].join('.')
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

bump_type = get_bump_type()
puts "bumping with version type: #{bump_type.inspect}"

version = read_version(VERSION_IDENTIFIER)
puts "current version is v#{version}"
new_version = bump_version(version, bump_type)

puts "will release version v#{new_version} and push it. [y/n]"
unless $stdin.gets().start_with?('y')
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
