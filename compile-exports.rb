#!/usr/bin/ruby

#
# Generates coffeescript file used to export the library.
# Author: rbuckheit
#

JS_LIB_EXPORTS = [
  'bluebird',
  'forge',
  'jquery',
  'lodash',
  'loglevel',
  'pako',
  'require',
  'revalidator'
]

EXPORT_FILE_PATH = 'js/src/soteria.coffee'

COFFEE_FILES = `find js/src -name "*.coffee"`.split.reject{|c| c.end_with?(EXPORT_FILE_PATH)}

def get_relative_path(path)
  return path.gsub('js/src/', '')
end

def remove_extension(file_name)
  return file_name.chomp('.js').chomp('.coffee')
end


COFFEE_EXPORTS = COFFEE_FILES.map{|f| get_relative_path(f)}.map{|f| remove_extension(f)}.sort

EXPORT_FILE_CONTENT = """
#
# AUTO_GENERATED: #{Time.new.inspect}
# Pseudo-module which includes all modules exported as part of soteria.
# This file is for optimizer build purposes only and should not be required or edited.
#

EXPORTED_MODULES = [
  # library
  # =======
  #{JS_LIB_EXPORTS.map{|ln| "'#{ln}'"}.join("\n  ")}

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
