require 'spec_helper'

RSpec.describe OlapReport::Cube::Adapters::AbstractAdapter do
  describe '#initialize' do
    it 'initializes instance with specified model' do
      expect(described_class.new(Fact)).to be_instance_of(described_class)
    end

    it 'raises ArgumentError if model is nil' do
      expect { described_class.new(nil) }.to raise_error(ArgumentError)
    end
  end

  describe 'method calls' do
    let(:adapter) { described_class.new(Fact) }

    it 'forwards calls of missing methods to @connection' do
      expect(adapter.adapter_name).to eq(Fact.connection.adapter_name)
    end

    it 'raises NoMethodError error if connection does not respond to missing method' do
      expect { adapter.foo }.to raise_error(NoMethodError)
    end
  end
end
