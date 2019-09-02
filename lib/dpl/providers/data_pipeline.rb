module Dpl
  module Providers
    class DataPipeline < Provider
      status :alpha

      full_name 'AWS Data Pipeline'

      description sq(<<-str)
        tbd
      str

      gem 'aws-sdk-datapipeline', '~> 1.0'

      env :aws
      config '~/.aws/credentials', '~/.aws/config', prefix: 'aws'

      opt '--access_key_id ID', 'AWS access key', required: true, secret: true
      opt '--secret_access_key KEY', 'AWS secret access key', required: true, secret: true
      opt '--definition FILE', 'Path to a pipeline definition file', required: true
      opt '--name NAME', 'Pipeline name', required: true
      opt '--region REGION', 'AWS availability zone', default: 'us-east-1'
      opt '--tags TAGS', 'Pipeline tags', type: :array, sep: ','
      opt '--description DESCR', 'Pipeline description'

      msgs login:    'Using Access Key: %{access_key_id}',
           deploy:   'Deploying pipeline %{name} with pipeline definition %{definition}',
           delete:   'Deleting pipeline %{id}',
           create:   'Creating pipeline %{name}',
           update:   'Updating pipeline %{id}',
           error:    'Failed to %{action} pipeline: %{errors}',
           done:     'Done.'

      def login
        info :login
      end

      def deploy
        delete_all if pipelines.any?
        id = create
        update(id)
      end

      def delete_all
        pipelines.each { |pipeline| delete(pipeline.id) }
      end

      def delete(id)
        info :delete, id: id
        client.delete_pipeline(pipeline_id: id)
      end

      def create
        info :create
        res = client.create_pipeline(
          name: name,
          unique_id: name,
          description: description,
          tags: tags
        )
        info :done
        res.pipeline_id
      end

      def update(id)
        info :update, id: id
        res = client.put_pipeline_definition(
          pipeline_id: id,
          pipeline_objects: definition.objects,
          parameter_objects: definition.params,
          parameter_values: definition.values
        )
        error :failed, action: action, errors: res[:validation_errors] if res[:errored]
        info :done
      end

      def pipelines
        list_pipelines.select { |pipeline| pipeline.name == name }
      end
      memoize :pipelines

      def list_pipelines(opts = {})
        res = client.list_pipelines(opts)
        all = res.pipeline_id_list
        all.concat(list_pipelines(marker: res.marker)) if res.has_more_results
        all
      end

      def tags
        Array(super).map { |tag| tag.split('=', 2) }.to_h
      end

      def definition
        @definition ||= Definition.new(JSON.parse(File.read(super)))
      end

      def client
        @client ||= Aws::DataPipeline::Client.new(client_opts)
      end

      def client_opts
        compact(region: region, credentials: credentials)
      end

      def credentials
        Aws::Credentials.new(access_key_id, secret_access_key)
      end

      class Definition < Struct.new(:definition)
        def objects
          data = Array(definition['objects'])
          data.map { |obj| to_obj(obj) }
        end

        def params
          data = Array(definition['parameters'])
          data.map { |obj| to_params(obj) }
        end

        def values
          data = definition['values']
          data.map { |pair| to_param(*pair) }.flatten if data
        end

        private

          def to_obj(obj)
            {
              id: obj['id'],
              name: obj['name'],
              fields: to_pairs(except(obj, 'id', 'name'))
            }
          end

          def to_params(obj)
            {
              id: obj['id'],
              attributes: to_pairs(except(obj, 'id'))
            }
          end

          def to_param(key, value)
            {
              id: key,
              string_value: value.to_s
            }
          end

          def to_pairs(obj)
            obj.map { |key, value| to_pair(key, value) }
          end

          def to_pair(key, value)
            if ref?(value)
              { key: key, ref_value: value['ref'] }
            else
              { key: key, string_value: value.to_s }
            end
          end

          def ref?(value)
            value.is_a?(Hash) && value.keys == ['ref']
          end

          def except(hash, *keys)
            hash.reject { |key, _| keys.include?(key) }
          end
      end
    end
  end
end
