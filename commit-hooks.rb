#!/usr/bin/ruby

#
# Checks for known blacklisted file patterns before allowing a build.
# Author: rbuckheit
#

SEARCH_PATHS = [
  'js',
]
COMMIT_HOOKS = [
  { :pattern => 'console', :exceptions => ['*', 'window.console &&'], :explanation => 'console is not available in IE' }
]


SEARCH_PATHS.each do |path|
  puts 'searching path ' + path
  search_path = File.expand_path(File.dirname(__FILE__), path)
  COMMIT_HOOKS.each do |hook|
    command = "grep -r -I \"#{hook[:pattern]}\" \"#{search_path}\""
    puts command
    violations = `#{command}`.split("\n").map(&:chomp)
    violations.reject!{|v| hook[:exceptions].any?{|e| v.include?(e)}}
    unless violations.empty?
      violations.each do |violation|
        $stderr.puts "FAILED pattern \"#{hook[:pattern]}\""
        $stderr.puts "To fix, you can use an exception pattern: \"#{hook[:exceptions].inspect}\" or delete the line."
        $stderr.puts "  " +  violation + "\n\n"
      end
      raise 'blacklisted patterns found while checking source. please fix and re-commit'
    else
      puts "check passed!"
    end
  end
  puts
end
