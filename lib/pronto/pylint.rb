# frozen_string_literal: true

require 'shellwords'
require 'json'

require 'pronto'
require 'pronto/pylint/patch_lint'
require 'pronto/pylint/version'

module Pronto
  class Pylint < Runner
    def run
      return [] unless @patches

      @patches.select { |patch| valid_patch?(patch) }
              .flat_map { |patch| PatchLint.new(patch).messages }
    end

    def valid_patch?(patch)
      patch.additions > 0 && python_file?(patch.new_file_full_path)
    end

    def python_file?(path)
      py_file?(path) || python_executable?(path)
    end

    def py_file?(path)
      File.extname(path) == '.py'
    end

    def python_executable?(path)
      return false if File.directory?(path)

      line = File.open(path, &:readline)
      line =~ /#!.*python/
    rescue ArgumentError, EOFError
      false
    end
  end
end
