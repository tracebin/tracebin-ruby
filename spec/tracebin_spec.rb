require "spec_helper"

RSpec.describe Tracebin do
  it "has a version number" do
    expect(Tracebin::VERSION).not_to be nil
  end
end
