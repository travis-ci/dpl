module DPL
        class Provider
                class TestFairy < Provider

                        require "net/http"
                        require "uri"
                        require 'net/http/post/multipart'
                        require 'json'
                        require 'open-uri'
                        require 'tempfile'


                        @@VERSION = "0.1"
                        @@tag = "-Testfairy-"
                        @@SERVER = "http://api.testfairy.com"
                        # @@SERVER = "http://giltsl.gs.dev.testfairy.net"
                        @@UPLOAD_URL_PATH = "/api/upload";
                        @@UPLOAD_SIGNED_URL_PATH = "/api/upload-signed";

                        @@zipPath = "/usr/bin/zip"
                        @@jarsignerPath = nil #"/usr/bin/jarsigner"
                        @@zipAlignPath = nil #"/Users/gilt/apps/testfairy_git/server/deployment/bin/darwin/platform-tools/zipalign"

                        def check_auth
                                if android?
                                        set_environment
                                end

                                puts "api-key = #{option(:api_key)} symbols-file = #{options[:symbols_file]}"
                                puts "keystore-file = #{options[:keystore_file]} storepass = #{options[:storepass]} alias = #{options[:alias]}"

                        end

                        def android?
                                option(:app_file).include? "apk"
                        end

                        def set_environment
                                puts "which zip = #{%x[which 'zip']}"
                                puts "zip was found in :#{@@zipPath}"
                                android_home_path = context.env.fetch('ANDROID_HOME',nil)
                                if android_home_path.nil?
                                        raise Error, "Can't find ANDROID_HOME"
                                end
                                zipalign_list = %x[find #{android_home_path} -name 'zipalign']
                                @@zipAlignPath = zipalign_list.split("\n").first
                                puts "zipalign was found in :#{@@zipAlignPath}"

                                java_home_path = context.env.fetch('JAVA_HOME','/')
                                if java_home_path.nil?
                                        raise Error, "Can't find JAVA_HOME"
                                end
                                jarsigner_list = %x[find #{java_home_path} -name 'jarsigner']
                                @@jarsignerPath = jarsigner_list.split("\n").first
                                puts "jarsigner was found in :#{@@jarsignerPath}"
                        end

                        def deploy
                                super
                                puts "deploy #{@@tag}"
                        end

                        def needs_key?
                                false
                        end

                        def push_app
                                puts "push_app #{@@tag}"
                                response = upload_app
                                if android?
                                        puts response['instrumented_url']
                                        instrumentedFile = download_from_url response['instrumented_url']
                                        signedApk = signing_apk instrumentedFile
                                        response = upload_signed_apk signedApk
                                end
                                puts "Upload success!, check your build on #{response['build_url']}"
                        end

                        def signing_apk(instrumentedFile)

                                signed = Tempfile.new(['instrumented-signed', '.apk'])

                                context.shell "ls #{instrumentedFile}"
                                context.shell "#{@@zipPath} -qd #{instrumentedFile} META-INF/*"
                                context.shell "#{@@jarsignerPath} -keystore #{option(:keystore_file)} -storepass #{option(:storepass)} -digestalg SHA1 -sigalg MD5withRSA #{instrumentedFile} #{option(:alias)}"
                                context.shell "#{@@jarsignerPath} -verify  #{instrumentedFile}"

                                context.shell "#{@@zipAlignPath} -f 4 #{instrumentedFile} #{signed.path}"
                                puts "signing Apk finished: #{signed.path()}  (file size:#{File.size(signed.path())} )"
                                signed.path()
                        end

                        def download_from_url(url)
                                puts "downloading  from #{url} "
                                uri = URI.parse(url)
                                instrumentedFile = Net::HTTP.start(uri.host, uri.port) do |http|
                                        resp = http.get(uri.path)
                                        file = Tempfile.new(['instrumented', '.apk'])
                                        file.write(resp.body)
                                        file.flush
                                        file
                                end
                                puts "Done #{instrumentedFile.path()}  (file size:#{File.size(instrumentedFile.path())} )"
                                instrumentedFile.path()
                        end

                        def upload_app
                                uploadUrl = @@SERVER + @@UPLOAD_URL_PATH
                                params = get_params
                                post uploadUrl, params
                        end

                        def upload_signed_apk (apkPath)

                                uploadSignedUrl = @@SERVER + @@UPLOAD_SIGNED_URL_PATH

                                params = {"api_key" => "#{option(:api_key)}"}
                                params = add_file_param params , 'apk_file', apkPath
                                params = add_file_param params, 'symbols_file', options[:symbols_file]
                                params = add_param params, 'testers-groups', options[:testers_groups]
                                params = add_boolean_param params, 'notify', options[:notify]
                                params = add_boolean_param params, 'auto-update', options[:auto_update]

                                post uploadSignedUrl, params
                        end

                        def post url, params
                                puts "Upload params = #{JSON.pretty_generate(params)} \n to #{url}"
                                uri = URI.parse(url)
                                request = Net::HTTP::Post::Multipart.new(uri.path, params, 'User-Agent' => "Travis plugin version=#{@@VERSION}")
                                res = Net::HTTP.start(uri.host, uri.port) do |http|
                                        http.request(request)
                                end
                                puts res.body
                                resBody = JSON.parse(res.body)
                                if (resBody['status'] == 'fail')
                                        raise Error, resBody['message']
                                end
                                return resBody
                        end

                        def get_params
                                params = {'api_key' => "#{option(:api_key)}"}
                                params = add_file_param params, 'apk_file', option(:app_file)
                                params = add_file_param params, 'symbols_file', options[:symbols_file]
                                params = add_param params, 'video-quality', options[:video_quality]
                                params = add_param params, 'screenshot-interval', options[:screenshot_interval]
                                params = add_param params, 'max-duration', options[:max_duration]
                                params = add_param params, 'testers-groups', options[:testers_groups]
                                params = add_param params, 'advanced-options', options[:advanced_options]
                                params = add_boolean_param params, 'data-only-wifi', options[:data_only_wifi]
                                params = add_boolean_param params, 'record-on-background', options[:record_on_background]
                                params = add_boolean_param params, 'video', options[:video]
                                params = add_boolean_param params, 'notify', options[:notify]
                                params = add_boolean_param params, 'icon-watermark', options[:icon_watermark]
                                params = add_boolean_param params, 'metrics', options[:metrics]

                                travisCommitRange = context.env.fetch('TRAVIS_COMMIT_RANGE',nil)
                                if !travisCommitRange.nil?
                                        changelog = %x[git log  --pretty=oneline --abbrev-commit #{travisCommitRange}]
                                        params = add_param params, 'changelog', changelog
                                end
                                return params
                        end

                        def add_file_param params, fileName, filePath
                                if (!filePath.nil? && !filePath.empty?)
                                        puts "file name last = #{filePath.split("/").last}"
                                        params[fileName] = UploadIO.new(File.new(filePath), "", filePath.split("/").last)
                                        puts "file name = #{params[fileName]}"
                                end
                                return params
                        end

                        # def add_param_whit_default params, paramName, param, default
                        #         if (param.nil? || param.empty?)
                        #                 param = default
                        #         end
                        #         params[paramName] = param
                        #         return params
                        # end

                        def add_param params, paramName, param
                                if (!param.nil? && !param.empty?)
                                        params[paramName] = param
                                end
                                return params
                        end

                        # def add_boolean_param_whit_default params, paramName, param, default
                        #         if (param.nil? || param.empty?)
                        #                 param = default
                        #         end
                        #         params[paramName] = (param == true) ? "on" : "off"
                        #         return params
                        # end

                        def add_boolean_param params, paramName, param
                                if (!param.nil? && !param.empty?)
                                        params[paramName] = (param == true) ? "on" : "off"
                                end
                                return params
                        end
                end
        end
end


