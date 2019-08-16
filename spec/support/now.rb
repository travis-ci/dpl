require 'time'

module Support
  module Now
    def self.included(base)
      base.let(:now) { Time.now }
      base.before { allow(Time).to receive(:now).and_return(now) }
    end
  end
end

# https://stackoverflow.com/questions/44259104/rubyzip-undefined-method-to-binary-dos-time-for
require 'zip'

Zip::DOSTime.instance_eval do
  def now; Zip::DOSTime.new(); end # ugh.
end
