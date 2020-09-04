module Support
  module Matchers
    module Aws
      class Base < Struct.new(:opts)
        include Support::Helpers, RSpec::Matchers::BuiltIn,
          RSpec::Mocks::Matchers, RSpec::Mocks::ArgumentMatchers
      end

      class HaveRequested < Base
        def matches?(*)
          !!request
        end

        def description
          "have requested #{operation}"
        end

        def failure_message
          msg = "Expected the operation #{operation.inspect} to be requested#{" with #{format_opts}" if opts.any?}, but it wasn't."
          msg << "\n\nInstead the following requests were made:\n\n  #{format_requests}" if requests.any?
          msg
        end

        def failure_message_when_negated
          "Expected the operation #{operation.inspect} to not be requested#{" with #{format_opts}" if opts.any?}, but it was."
        end

        def request
          host, path, body, file, headers = opts.values_at(:host, :path, :body, :file, :headers)
          headers ||= except(opts, :host, :path, :body, :file, :client, :operation)
          headers = stringify(headers)
          reqs = requests.select { |r| r[:operation] == operation }
          reqs = reqs.select { |r| match?(r[:host], host) } if host
          reqs = reqs.select { |r| r[:path] == path } if path
          reqs = reqs.select { |r| match?(r[:body], body) } if body
          reqs = reqs.select { |r| r[:file] == file } if file
          reqs = reqs.select { |r| include?(r[:headers], headers) } if headers
          reqs.any? and reqs[0][:request]
        end

        def requests
          client.api_requests.map do |req|
            compact(
              operation: req[:operation_name],
              host:      req[:context].http_request.endpoint.host,
              path:      req[:context].http_request.endpoint.path,
              body:      body_from(req[:context].http_request.body),
              file:      req[:params][:body] && req[:params][:body].path,
              headers:   req[:context].http_request.headers,
              request:   req[:context].http_request
            )
          end
        end

        def body_from(obj)
          case obj
          when StringIO
            obj.string
          when ::Aws::Query::ParamList::IoWrapper
            obj.read
          end
        end

        def format_opts
          except(opts, :client, :operation).map { |pair| pair.join('=') }.join(' ')
        end

        def format_requests
          requests.map { |r| except(r, :request).map { |key, value| [key, value.inspect].join(': ') }.join("\n  ") }.join("\n\n")
        end

        def match?(actual, expected)
          case expected
          when String then actual.include?(expected)
          when Regexp then actual =~ expected
          when Hash   then include?(JSON.parse(actual), stringify(expected))
          end
        end

        def include?(hash, other)
          # Include.new(other).matches?(hash)
          other.all? do |key, value|
            case value
            when RSpec::Mocks::ArgumentMatchers::InstanceOf
              # just can't get this working in any other way ...
              hash[key].is_a?(value.instance_variable_get(:@klass))
            when Hash
              include?(hash[key], value)
            else
              hash[key] == value
            end
          end
        end

        def client
          opts[:client]
        end

        def operation
          opts[:operation]
        end
      end

      class CreateClient < Base
        def matches?(*)
          matcher.matches?(::Aws::S3::Client)
        end

        def description
          matcher.description
        end

        def failure_message
          matcher.failure_message
        end

        def failure_message_when_negated
          matcher.failure_message_when_negated
        end

        def matcher
          @matchers ||= HaveReceived.new(:new).with(hash_including(opts))
        end
      end

      def create_client(opts)
        CreateClient.new(opts)
      end

      def have_requested(operation, opts = {})
        HaveRequested.new(opts.merge(client: client, operation: operation))
      end

      # elasticbeanstalk

      def create_app_version(body = nil)
        have_requested(:create_application_version, compact(body: body))
      end

      def update_environment
        have_requested(:update_environment)
      end

      # lambda

      def create_function(params)
        have_requested(:create_function, body: params)
      end

      def update_function_config(params)
        have_requested(:update_function_configuration, body: params)
      end

      def update_function_code(params)
        have_requested(:update_function_code, body: params)
      end

      def tag_resource(params)
        have_requested(:tag_resource, body: params)
      end

      # codedeploy and opsworks

      def create_deployment(params)
        have_requested(:create_deployment, body: params)
      end

      def get_deployment
        have_requested(:get_deployment)
      end

      def describe_deployments(params)
        have_requested(:describe_deployments, body: params)
      end

      def update_app(params)
        have_requested(:update_app, body: params)
      end

      # s3

      def put_object(file, opts = {})
        have_requested(:put_object, opts.merge(file: file))
      end

      def put_bucket_website_suffix(suffix)
        have_requested(:put_bucket_website, body: %r(<Suffix>#{suffix}</Suffix>))
      end
    end
  end
end

