#!/usr/bin/ruby

#
# Generates coffeescript file used to export the library.
# Author: rbuckheit
#

EXPORT_FILE_PATH = 'js/src/soteria.coffee'

COFFEE_FILES = `find js/src -name "*.coffee"`.split.reject{|c| c.end_with?(EXPORT_FILE_PATH)}
JS_FILES     = `find js/src -name "*.js"`.split
JS_LIB_FILES = `find js/lib -name "*.js"`.split

def get_filename(path)
  return path.split(File::SEPARATOR).last
end

def get_relative_path(path)
  return path.gsub('js/src/', '')
end

def remove_extension(file_name)
  return file_name.chomp('.js').chomp('.coffee')
end


JS_LIB_NAMES   = JS_LIB_FILES.map{|f| get_filename(f)}.map{|f| remove_extension(f)}.sort
JS_EXPORTS     = JS_FILES.map{|f| get_relative_path(f)}.map{|f| remove_extension(f)}.sort
COFFEE_EXPORTS = COFFEE_FILES.map{|f| get_relative_path(f)}.map{|f| remove_extension(f)}.sort

EXPORT_FILE_CONTENT = """
#
# AUTO_GENERATED: #{Time.new.inspect}
# Pseudo-modile which includes all modules exported as part of soteria.
# This file is for optimizer build purposes only and should not be required or edited.
#

EXPORTED_MODULES = [
  # library
  # =======
  #{JS_LIB_NAMES.map{|ln| "'#{ln}'"}.join("\n  ")}

  # soteria
  # =======
  #{COFFEE_EXPORTS.map{|c| "'cs!#{c}'"}.join("\n  ")}
]


define('soteria', EXPORTED_MODULES, (require) ->
  'use strict'
  return {}
)
"""

File.open(EXPORT_FILE_PATH, 'w'){|f| f.write(EXPORT_FILE_CONTENT)}