module Dpl
  module Providers
    class Docker < Provider
      status :dev

      register :docker

      description sq(<<-str)
        tbd
      str

      env :docker

      required [:username, :password], :test

      opt '--registry HOST', 'Docker registry hostname'
      opt '--username NAME', 'Docker registry username'
      opt '--password PASS', 'Docker registry password', secret: true
      opt '--context STR',   'Path or URL to the Dockerfile context', default: '.'
      opt '--image NAME',    'Name of the image to build'
      opt '--build_arg ARG', 'Args to build the image with', type: :array
      opt '--target TAG',    'Target image name to tag the image with, and push to', type: :array, required: true
      opt '--test', internal: true

      cmds build:  'docker build %{context} --no-cache -t %{image} %{build_args}',
           tag:    'docker tag %{image} %{target}',
           login:  'docker login --username %{username} --password %{password} %{registry}',
           push:   'docker push %{target}',
           logout: 'docker logout'

      msgs build:  'Building docker image %{image} from %{context}',
           tag:    'Tagging image %{image} as %{target}',
           push:   'Pushing image %{target}'

      def login
        shell :login unless test?
      end

      def deploy
        build if context?
        tag
        push
      end

      def finish
        shell :logout, echo: false unless test?
      end

      private

        def build
          shell :build
        end

        def build_args
          opts_for(%i(build_arg), dashed: true)
        end

        def tag
          target.each do |target|
            shell :tag, target: target
          end
        end

        def push
          target.each do |target|
            shell :push, target: target
          end
        end

        def target
          @target ||= super.map do |target|
            registry? ? [registry, target].join('/') : target
          end
        end
    end
  end
end
