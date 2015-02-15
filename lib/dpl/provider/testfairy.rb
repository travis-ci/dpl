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
                        @@SERVER = "http://giltsl.gs.dev.testfairy.net"
                        @@UPLOAD_URL_PATH = "/api/upload";
                        @@UPLOAD_SIGNED_URL_PATH = "/api/upload-signed";

                        @@zipPath = "/usr/bin/zip"
                        @@jarsignerPath = nil #"/usr/bin/jarsigner"
                        @@zipAlignPath = nil #"/Users/gilt/apps/testfairy_git/server/deployment/bin/darwin/platform-tools/zipalign"

                        def check_auth

                                set_environment

                                puts "check_auth #{@@tag}"
                                puts "api-key = #{option(:api_key)} proguard-file = #{options[:proguard_file]}"
                                puts "keystore-file = #{options[:keystore_file]} storepass = #{option(:storepass)} alias = #{option(:alias)}"

                        end

                        def set_environment
                                puts "which zip = #{%x[which 'zip']}"
                                puts "zip was found in :#{@@zipPath}"
                                android_home_path = context.env.fetch('ANDROID_HOME','/')
                                zipalign_list = %x[find #{android_home_path} -name 'zipalign']
                                @@zipAlignPath = zipalign_list.split("\n").first
                                puts "zipalign was found in :#{@@zipAlignPath}"

                                java_home_path = context.env.fetch('JAVA_HOME','/')
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
                                puts response['instrumented_url']
                                instrumentedFile = download_from_url response['instrumented_url']
                                if "#{option(:platform)}" == "android"
                                        signedApk = signing_apk instrumentedFile
                                        upload_signed_apk signedApk
                                end
                                puts "Upload access!, check your build on #{response['build_url']}"
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
                                params = add_file_param params, 'proguard_file', options[:proguard_file]
                                params = add_param params, 'testers-groups', options[:testers_groups], ''
                                params = add_boolean_param params, 'notify', options[:notify], false
                                params = add_boolean_param params, 'auto-update', options[:auto_update], false

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
                                params = add_file_param params, 'apk_file', option(:apk)
                                params = add_param params, 'changelog', options[:changelog], ''
                                params = add_param params, 'video-quality', options[:video_qualit], 'low'
                                params = add_param params, 'screenshot-interval', options[:screenshot_interval], '5'
                                params = add_param params, 'max-duration', options[:max_duration], '60m'
                                params = add_param params, 'testers-groups', options[:testers_groups], ''
                                params = add_param params, 'advanced-options', options[:advanced_options], ''
                                params = add_boolean_param params, 'data-only-wifi', options[:data_only_wifi], true
                                params = add_boolean_param params, 'record-on-background', options[:record_on_background], true
                                params = add_boolean_param params, 'video', options[:video], true
                                params = add_boolean_param params, 'notify', options[:notify], false
                                params = add_boolean_param params, 'icon-watermark', options[:icon_watermark], false
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

                        def add_param params, paramName, param, default
                                if (param.nil? || param.empty?)
                                        param = default
                                end
                                params[paramName] = param
                                return params
                        end

                        def add_boolean_param params, paramName, param, default
                                if (param.nil? || param.empty?)
                                        param = default
                                end
                                params[paramName] = (param == true) ? "on" : "off"
                                return params
                        end
                end
        end
end

# api-key=123456789 --proguard-file-name="proguard file name"--keystore-file="keystore file" --storepass="storepass string" --alias="alias string"

# ---initialize ---- provider
# ---user_agent ---- provider
# ---option ---- provider
# ---initialize ---- provider
# ---user_agent ---- provider
# ---deploy ---- provider
# ---setup_git_credentials ---- provider
# Preparing deploy
# check_auth -Testfairy-
# ---check_app ---- provider
# ---cleanup ---- provider
# Saved working directory and index state WIP on testfairy: f8fa256 Merge branch 'master' of github.com:travis-ci/dpl
# HEAD is now at f8fa256 Merge branch 'master' of github.com:travis-ci/dpl
# Deploying application
# ---uncleanup ---- provider



