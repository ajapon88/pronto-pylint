# frozen_string_literal: true

RSpec.describe Pronto::Pylint do
  it "has a version number" do
    expect(Pronto::PylintVersion::VERSION).not_to be nil
  end
end
