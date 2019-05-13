module Support
  module Env
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def env(vars)
        prepend_before { define_env(vars) }
      end
    end

    def define_env(vars)
      vars.each do |key, value|
        ENV[key.to_s] = value.is_a?(Proc) ? instance_eval(&value).to_s : value.to_s
      end
      self.class.after { undefine_env(vars) }
    end

    def undefine_env(vars)
      vars.each { |key, _| ENV.delete(key.to_s) }
    end
  end
end
