#!/usr/bin/ruby

#
# Checks for known blacklisted file patterns before allowing a merge.
# Author: rbuckheit
#

SEARCH_PATH = File.expand_path(File.dirname(__FILE__), 'js')

COMMIT_HOOKS = [
  {
    :name           => 'remove console.logs',
    :file_pattern   => '*.coffee',
    :pattern        => 'console',
    :exception      => /window.console &&/,
    :explanation    => 'remove console.log statements before commit'
  },
  {
    :name           => 'no raw javascript files',
    :file_pattern   => '*.js',
    :pattern        => '',
    :exception      => /test-main.js|karma.*.conf.js|KryptnosticClient.js/,
    :explanation    => 'raw js files are not allowed, please use coffeescript'
  },
  {
    :name           => 'no TODO comments',
    :file_pattern   => '*.coffee',
    :pattern        => 'TODO',
    :exception      => /authorized/,
    :explanation    => 'fix TODO comments before committing'
  },
  {
    :name           => 'no FIXME comments',
    :file_pattern   => '*.coffee',
    :pattern        => 'FIXME',
    :exception      => /authorized/,
    :explanation    => 'fix FIXME comments before committing'
  },
  {
    :name           => 'no jquery ajax',
    :file_pattern   => '*.coffee',
    :pattern        => 'jquery.ajax',
    :exception      => /authorized/,
    :explanation    => 'please use axios for ajax calls'
  }
]

COMMIT_HOOKS.each do |hook|
  command    = "grep -r -I '#{hook[:pattern]}' #{SEARCH_PATH} --include='#{hook[:file_pattern]}'"
  violations = `#{command}`.split("\n").map(&:chomp).reject{|line| line.match(hook[:exception])}

  violations.each do |violation|
    $stderr.puts "FAILED pattern '#{hook[:name]}'"
    $stderr.puts "  " +  violation + "\n\n"
    $stderr.puts "To fix, you can use an exception pattern: '#{hook[:exception].inspect}' or delete the line."
  end

  if not violations.empty?
    raise 'blacklisted patterns found while checking source. please fix and re-commit'
  else
    puts "commit hook '#{hook[:name]}' passed"
  end
end
