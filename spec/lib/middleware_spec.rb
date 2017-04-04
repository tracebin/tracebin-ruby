require 'spec_helper'

describe Vizsla::Middleware do
  let(:app) { double 'app', call: ['ststus', 'headers', 'response'] }
  let(:env) { double 'env' }
  let(:timer) do
    instance_double 'Vizsla::Timer',
    start!: nil,
    stop!: nil,
      elapsed: '0s'
  end
  let(:logger) { double 'logger', debug: nil }
  let(:middleware) { Vizsla::Middleware.new(app) }

  before do
    rails = double 'Rails', logger: logger
    stub_const 'Vizsla::Middleware::Rails', rails

    Vizsla::Timer.stub(:new).and_return timer
  end

  after do

  end

  describe '#call' do
    it 'starts a timer' do
      expect(timer).to receive(:start!)
      middleware.call env
    end

    it 'continues execution of the middleware' do
      expect(app).to receive(:call).with(env)
      middleware.call env
    end

    it 'stops the timer' do
      expect(timer).to receive(:stop!)
      middleware.call env
    end

    it 'logs the results' do

    end
  end
end
