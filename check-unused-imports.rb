#!/usr/bin/ruby

#
# Script to eliminate unused dependencies.
# Author: rbuckheit
#

def bash_green(string)
  return "\033[1m\033[32m#{string}\033[0m\033[22m"
end

REQUIRE_PATTERN = /\s*(.*) = require(.*)/
files = Dir.glob('js/**/*.coffee')

files.each do |file|
  lines         = File.readlines(file)
  require_lines = lines.select{|l| l.match(REQUIRE_PATTERN) }

  require_lines.each do |line|
    moduleName =  line.match(REQUIRE_PATTERN)[1].strip
    hitCount   = lines.select{|l| l.include?(moduleName)}.count

    if hitCount == 1
      $stderr.puts "found unused require in module: #{file}"
      $stderr.puts "variable name is \"#{moduleName}\""
      $stderr.puts "  #{line.strip}"
      raise 'please fix this unused import.'
    end
  end
  puts "#{file} #{bash_green("✓")}"
end
