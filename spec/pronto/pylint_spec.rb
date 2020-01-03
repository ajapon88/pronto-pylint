# frozen_string_literal: true

require 'spec_helper'

module Pronto
  RSpec.describe Pylint do
    let(:pylint) { Pylint.new(patches) }
    let(:patches) { nil }

    describe '#run' do
      subject { pylint.run }

      context 'patches are nil' do
        it { should == [] }
      end

      context 'no patches' do
        let(:patches) { [] }
        it { should == [] }
      end

      context 'patches with an offense' do
        include_context 'test repo'

        let(:patches) { repo.show_commit('f44a11a') }

        its(:count) { should == 1 }

        it 'includes the offense message' do
          expect(subject.first.msg).to include("[C0325] Unnecessary parens after 'print' keyword")
        end
      end

      context 'patches with multiple offense' do
        include_context 'test repo'

        let(:patches) { repo.show_commit('7b7f452') }

        its(:count) { should == 6 }

        it 'returns messages' do
          expect(subject.map(&:msg))
            .to match(
              [
                a_string_matching("[C0325] Unnecessary parens after 'print' keyword"),
                a_string_matching("[C0111] Missing module docstring"),
                a_string_matching("[E0401] Unable to import 'wsgi'"),
                a_string_matching("[C0103] Constant name \"server\" doesn't conform to UPPER_CASE naming style"),
                a_string_matching("[W0611] Unused import BaseHTTPServer"),
                a_string_matching("W0611] Unused import CGIHTTPServer")
              ]
            )
        end
      end
    end
  end
end
