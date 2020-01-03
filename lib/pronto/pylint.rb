# frozen_string_literal: true

require 'shellwords'
require 'json'

require 'pronto'
require 'pronto/pylint/version'

module Pronto
  class Pylint < Runner
    SEVERITIES = {
      'info' => :warning,
      'refactor' => :warning,
      'convention' => :warning,
      'warning' => :warning,
      'error' => :error,
      'fatal' => :fatal
    }.freeze

    def run
      return [] unless @patches

      @patches.select { |patch| valid_patch?(patch) }
              .map { |patch| inspect(patch) }
              .flatten
              .compact
    end

    def valid_patch?(patch)
      return false unless patch.additions > 0

      python_file?(patch.new_file_full_path)
    end

    def inspect(patch)
      run_pylint(patch).map do |violation|
        patch.added_lines
             .select { |line| line.new_lineno == violation['line'] }
             .map { |line| new_message(violation, line) }
      end
    end

    def new_message(violation, line)
      path = line.patch.delta.new_file[:path]
      Message.new(path, line, SEVERITIES[violation['type']], "[#{violation['message-id']}] #{violation['message']}", nil, self.class)
    end

    private

    def python_file?(path)
      File.extname(path) == '.py'
    end

    def run_pylint(patch)
      file_path = patch.new_file_full_path.to_s
      ret = `pylint #{Shellwords.shellescape(file_path)} -f json`
      raise ret unless system("pylint-exit #{$CHILD_STATUS.exitstatus} > /dev/null")

      JSON.parse(ret)
    end
  end
end
