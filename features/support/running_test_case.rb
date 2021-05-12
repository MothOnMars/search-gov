# HACK: this method was available in cucumber 3.1 but not cucumber 4 and VCR relies on it to
# generate cassette names.
# https://github.com/vcr/vcr/issues/825
module Cucumber
  module RunningTestCase
    class TestCase < SimpleDelegator
      def feature
        string = File.read(location.file)
        document = ::Gherkin::Parser.new.parse(string)
        document[:feature]
      end
    end
  end
end
