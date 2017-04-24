require 'spec_helper'

describe Tracebin::Middleware do
  let(:app) { double 'app', call: ['ststus', 'headers', 'response'] }
  let(:env) { double 'env' }
  let(:timer) do
    instance_double 'Tracebin::Timer',
    start!: nil,
    stop!: nil,
      elapsed: '0s'
  end
  let(:logger) { double 'logger', debug: nil }
  let(:rails) { double 'Rails', logger: logger }
  let(:middleware) { Tracebin::Middleware.new(app) }

  before do
    stub_const 'Tracebin::Middleware::Rails', rails
    Tracebin::Timer.stub(:new).and_return timer
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
      expect(rails.logger).to receive(:debug)
      middleware.call env
    end
  end
end
