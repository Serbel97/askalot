require 'spec_helper'
require 'shared/redcurtain/renderer/replacer'

describe Redcurtain::Renderer::Replacer do
  subject { described_class.new(:replacer) }

  describe '.render' do
    let(:replacement) { lambda { |match| "@#{match}" } }

    it 'replaces occurance of regex' do
      text = 'such doge, wow'

      result = subject.render(text, replacement: replacement, regex: /doge/)

      expect(result).to eql('such @doge, wow')
    end
  end
end
