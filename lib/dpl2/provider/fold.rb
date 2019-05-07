module Dpl
  module Fold
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def fold(name)
      end
    end
  end
end
