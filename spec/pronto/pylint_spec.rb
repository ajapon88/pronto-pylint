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

      context 'patches with multiple offense' do
        include_context 'test repo'

        let(:patches) { repo.show_commit('641b788') }

        its(:count) { should == 2 }

        it 'returns messages' do
          expect(subject.map(&:msg))
            .to match(
              [
                a_string_matching(%q([C0103] Constant name "model" doesn't conform to UPPER_CASE naming style)),
                a_string_matching('[W0611] Unused import sys')
              ]
            )
        end
      end

      context 'patches with multiple offense' do
        include_context 'test repo'

        before { FileUtils.mv(pylintrc, dot_pylintrc) }
        after { FileUtils.mv(dot_pylintrc, pylintrc) }

        let(:patches) { repo.show_commit('641b788') }

        its(:count) { should == 1 }

        it 'returns first message' do
          expect(subject.first.msg).to include('[W0611] Unused import sys')
        end
      end
    end
  end
end
