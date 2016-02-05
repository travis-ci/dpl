module DPL
  class Provider
    class APM < Provider
      experimental "Atom Package Manager"
      apt_get "build-essential git libgnome-keyring-dev fakeroot"

      def needs_key?
        false
      end

      def travis_tag
        # Check if $TRAVIS_TAG is unset or set but empty
        if context.env.fetch('TRAVIS_TAG','') == ''
          nil
        else
          context.env['TRAVIS_TAG']
        end
      end

      def get_tag
        if travis_tag.nil?
          @tag ||= `git describe --tags --exact-match 2>/dev/null`.chomp
        else
          @tag ||= travis_tag
        end
      end

      def check_auth
        context.env['ATOM_ACCESS_TOKEN'] = option(:api_key)
      end

      def push_app
        context.shell <<-bash
          echo "Downloading latest Atom release..."
          ATOM_CHANNEL="${ATOM_CHANNEL:=stable}"

          if [ "$TRAVIS_OS_NAME" = "osx" ]; then
            curl -s -L "https://atom.io/download/mac?channel=$ATOM_CHANNEL" \
              -H 'Accept: application/octet-stream' \
              -o "atom.zip"
            mkdir atom
            unzip -q atom.zip -d atom
            if [ "$ATOM_CHANNEL" = "stable" ]; then
              export ATOM_APP_NAME="Atom.app"
              export ATOM_SCRIPT_NAME="atom.sh"
              export ATOM_SCRIPT_PATH="./atom/${ATOM_APP_NAME}/Contents/Resources/app/atom.sh"
            else
              export ATOM_APP_NAME="Atom ${ATOM_CHANNEL}.app"
              export ATOM_SCRIPT_NAME="atom-${ATOM_CHANNEL}"
              export ATOM_SCRIPT_PATH="./atom-${ATOM_CHANNEL}"
              ln -s "./atom/${ATOM_APP_NAME}/Contents/Resources/app/atom.sh" "${ATOM_SCRIPT_PATH}"
            fi
            export PATH="$PWD/atom/${ATOM_APP_NAME}/Contents/Resources/app/apm/bin:$PATH"
            export ATOM_PATH="./atom"
            export APM_SCRIPT_PATH="./atom/${ATOM_APP_NAME}/Contents/Resources/app/apm/node_modules/.bin/apm"
          else
            curl -s -L "https://atom.io/download/deb?channel=$ATOM_CHANNEL" \
              -H 'Accept: application/octet-stream' \
              -o "atom.deb"
            /sbin/start-stop-daemon --start --quiet --pidfile /tmp/custom_xvfb_99.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -ac -screen 0 1280x1024x16
            export DISPLAY=":99"
            dpkg-deb -x atom.deb "$HOME/atom"
            if [ "$ATOM_CHANNEL" = "stable" ]; then
              export ATOM_SCRIPT_NAME="atom"
              export APM_SCRIPT_NAME="apm"
            else
              export ATOM_SCRIPT_NAME="atom-$ATOM_CHANNEL"
              export APM_SCRIPT_NAME="apm-$ATOM_CHANNEL"
            fi
            export ATOM_SCRIPT_PATH="$HOME/atom/usr/bin/$ATOM_SCRIPT_NAME"
            export APM_SCRIPT_PATH="$HOME/atom/usr/bin/$APM_SCRIPT_NAME"
          fi


          echo "Using Atom version:"
          "$ATOM_SCRIPT_PATH" -v
          echo "Using APM version:"
          "$APM_SCRIPT_PATH" -v

          echo "Deploying package:"
          "$APM_SCRIPT_PATH" publish --tag "$TRAVIS_TAG"
        bash
      end
    end
  end
end
