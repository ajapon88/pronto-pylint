# frozen_string_literal: true

require 'shellwords'
require 'json'

require 'pronto'
require 'pronto/pylint/version'

module Pronto
  class Pylint < Runner
    class PatchLint
      def initialize(patch)
        @patch = patch
      end

      def messages
        offences.flat_map do |offence|
          @patch.added_lines
                .select { |line| line.new_lineno == offence['line'] }
                .map { |line| new_message(offence, line) }
        end
      end

      private

      SEVERITIES = {
        'info' => :warning,
        'refactor' => :warning,
        'convention' => :warning,
        'warning' => :warning,
        'error' => :error,
        'fatal' => :fatal
      }.freeze

      def new_message(offence, line)
        path = line.patch.delta.new_file[:path]
        level = SEVERITIES[offence['type']]
        message = "[#{offence['message-id']}] #{offence['message']}"
        Message.new(path, line, level, message, nil, Pronto::Pylint)
      end

      def git_repo_path
        @git_repo_path ||= Rugged::Repository.discover(@patch.repo.path).workdir
      end

      def offences
        @offences ||= Dir.chdir(git_repo_path) do
          file_path = @patch.new_file_full_path.to_s
          ret = `pylint #{Shellwords.shellescape(file_path)} -f json`
          raise ret unless system("pylint-exit #{$CHILD_STATUS.exitstatus} > /dev/null")

          JSON.parse(ret)
        end
      end
    end
  end
end
