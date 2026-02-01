#!/usr/bin/env bash

# This script configures pipewire to work both in the graphical environment and in the console with root apps.

if [[ $(whoami) != "root" ]]; then
    # Get the current user's XDG_HOME
    xdgPath="${XDG_CONFIG_HOME:-$HOME/.config}"
    
    # Ensure directories exist
    mkdir -p "$xdgPath/pipewire"
    # WirePlumber 0.4 (Old)
    mkdir -p "$xdgPath/wireplumber/main.lua.d"
    mkdir -p "$xdgPath/wireplumber/bluetooth.lua.d"
    # WirePlumber 0.5+ (New)
    mkdir -p "$xdgPath/wireplumber/wireplumber.conf.d"

    # --- pipewire-pulse.conf ---
    # Warn user if we are going to overwrite an existing pipewire-pulse.conf
    if [ -f "$xdgPath/pipewire/pipewire-pulse.conf" ]; then
        read -p "This will replace the current file located at $xdgPath/pipewire/pipewire-pulse.conf, press enter to continue or control+c to abort. " continue
    fi
    
    cat << "EOF" > "$xdgPath/pipewire/pipewire-pulse.conf"
# PulseAudio config file for PipeWire #
#
# Copy and edit this file in /etc/pipewire for system-wide changes
# or in ~/.config/pipewire for local changes.
#

context.properties = {
    ## Configure properties in the system.
    #mem.warn-mlock  = false
    #mem.allow-mlock = true
    #mem.mlock-all   = false
    #log.level       = 2
}

context.spa-libs = {
    audio.convert.* = audioconvert/libspa-audioconvert
    support.*       = support/libspa-support
}

context.modules = [
    { name = libpipewire-module-rt
        args = {
            nice.level   = -11
            #rt.prio      = 88
            #rt.time.soft = -1
            #rt.time.hard = -1
        }
        flags = [ ifexists nofail ]
    }
    { name = libpipewire-module-protocol-native }
    { name = libpipewire-module-client-node }
    { name = libpipewire-module-adapter }
    { name = libpipewire-module-metadata }

    { name = libpipewire-module-protocol-pulse
        args = {
        # contents of pulse.properties can also be placed here
        # to have config per server.
        }
    }
]

# Extra modules can be loaded here. Setup in default.pa can be moved here
context.exec = [
    { path = "pactl"        args = "load-module module-always-sink" }
    { path = "pactl"        args = "load-module module-switch-on-connect" }
    #{ path = "sh"           args = "~/.config/pipewire/default.pw" }
]

stream.properties = {
    #node.latency          = 1024/48000
    #node.autoconnect      = true
    #resample.quality      = 4
    #channelmix.normalize  = false
    #channelmix.mix-lfe    = false
    #channelmix.upmix      = true
    #channelmix.upmix-method = simple  # none, psd
    #channelmix.lfe-cutoff = 120
    #channelmix.fc-cutoff  = 6000
    #channelmix.rear-delay = 12.0
    #channelmix.stereo-widen = 0.1
    #channelmix.hilbert-taps = 0
}

pulse.properties = {
    # the addresses this server listens on
    server.address = [
        "unix:native"
        "unix:/tmp/pulse.sock"              # absolute paths may be used
        #"tcp:4713"                         # IPv4 and IPv6 on all addresses
        #"tcp:[::]:9999"                    # IPv6 on all addresses
        #"tcp:127.0.0.1:8888"               # IPv4 on a single address
    ]
    #pulse.min.req          = 256/48000     # 5ms
    #pulse.default.req      = 960/48000     # 20 milliseconds
    #pulse.min.frag         = 256/48000     # 5ms
    #pulse.default.frag     = 96000/48000   # 2 seconds
    #pulse.default.tlength  = 96000/48000   # 2 seconds
    #pulse.min.quantum      = 256/48000     # 5ms
    #pulse.default.format   = F32
    #pulse.default.position = [ FL FR ]
    # These overrides are only applied when running in a vm.
    vm.overrides = {
        pulse.min.quantum = 1024/48000      # 22ms
    }
}

# client/stream specific properties
pulse.rules = [
    {
        matches = [
            {
                # all keys must match the value. ~ starts regex.
                #client.name                = "Firefox"
                #application.process.binary = "teams"
                #application.name           = "~speech-dispatcher.*"
            }
        ]
        actions = {
            update-props = {
                #node.latency = 512/48000
            }
            # Possible quirks:"
            #    force-s16-info                 forces sink and source info as S16 format
            #    remove-capture-dont-move       removes the capture DONT_MOVE flag
            #quirks = [ ]
        }
    }
    {
        # skype does not want to use devices that don't have an S16 sample format.
        matches = [
             { application.process.binary = "teams" }
             { application.process.binary = "skypeforlinux" }
        ]
        actions = { quirks = [ force-s16-info ] }
    }
    {
        # firefox marks the capture streams as don't move and then they
        # can't be moved with pavucontrol or other tools.
        matches = [ { application.process.binary = "firefox" } ]
        actions = { quirks = [ remove-capture-dont-move ] }
    }
    {
        # speech dispatcher asks for too small latency and then underruns.
        matches = [ { application.name = "~speech-dispatcher*" } ]
        actions = {
            update-props = {
                pulse.min.req          = 1024/48000     # 21ms
                pulse.min.quantum      = 1024/48000     # 21ms
            }
        }
    }
]
EOF

    # --- WirePlumber: Disable Suspend ---
    
    # WP 0.5+ (New Format) - SPA-JSON
    echo 'monitor.alsa.rules = [
  {
    matches = [
      { device.name = "~alsa_card.*" }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
        api.alsa.disable-power-save = true
      }
    }
  }
  {
    matches = [
      { node.name = "~alsa_input.*" }
      { node.name = "~alsa_output.*" }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]' > "$xdgPath/wireplumber/wireplumber.conf.d/50-do-not-suspend.conf"

    # WP 0.4 (Old Format) - Lua
    if [ -f "$xdgPath/wireplumber/main.lua.d/50-do-not-suspend.lua" ]; then
        echo "Updating existing $xdgPath/wireplumber/main.lua.d/50-do-not-suspend.lua"
    fi
    echo 'alsa_monitor.rules = {
  {
    matches = {
      {
                { "device.name", "matches", "alsa_card.*" },
      },
    },
   apply_properties = {
      ["api.alsa.use-acp"] = true,
      ["api.acp.auto-profile"] = false,
      ["api.acp.auto-port"] = false,
["session.suspend-timeout-seconds"] = 0
    },
  },
  {
    matches = {
      {        
        { "node.name", "matches", "alsa_input.*" },
      },
      {
        { "node.name", "matches", "alsa_output.*" },
      },
    },
    apply_properties = {
      ["session.suspend-timeout-seconds"] = 0
    },
  },
}' > "$xdgPath/wireplumber/main.lua.d/50-do-not-suspend.lua"


    # --- WirePlumber: Bluez Monitor Logind Fix ---
    
    # WP 0.5+ (New Format)
    # Disable logind module for wireplumber to prevent bluetooth disconnects on TTY switch
    echo 'monitor.bluez.properties = {
  with-logind = false
}' > "$xdgPath/wireplumber/wireplumber.conf.d/50-bluez-logind.conf"

    # WP 0.4 (Old Format)
    if [ -f "$xdgPath/wireplumber/bluetooth.lua.d/30-bluez-monitor.lua" ]; then
        echo "Updating existing $xdgPath/wireplumber/bluetooth.lua.d/30-bluez-monitor.lua"
    fi
    echo 'bluez_monitor = {}
bluez_monitor.properties = {}
bluez_monitor.rules = {}

function bluez_monitor.enable()
  load_monitor("bluez", {
    properties = bluez_monitor.properties,
    rules = bluez_monitor.rules,
  })

end' > "$xdgPath/wireplumber/bluetooth.lua.d/30-bluez-monitor.lua"

    echo "WirePlumber configuration updated (supports both legacy and new 0.5+ formats)."
    echo "Please ensure that your user is added to the audio group."
    echo "If you have not yet done so, please run this script as root to write the client.conf file."

else
    # --- Root Section ---
    xdgPath="/root/.config"
    mkdir -p "$xdgPath/pulse"

    # Fix: Correctly warn about the file we are actually modifying
    if [ -f "$xdgPath/pulse/client.conf" ]; then
        read -p "This will replace the current file located at $xdgPath/pulse/client.conf, press enter to continue or control+c to abort. " continue
    fi

    cat << EOF > "$xdgPath/pulse/client.conf"
# This file is part of PulseAudio.
# Configured for PipeWire socket access.

default-server = unix:/tmp/pulse.sock 

autospawn = no
# autospawn = yes
# daemon-binary = /run/current-system/sw/bin/pulseaudio
# extra-arguments = --log-target=syslog

; cookie-file =

; enable-shm = yes
; shm-size-bytes = 0 # setting this 0 will use the system-default, usually 64 MiB

; auto-connect-localhost = no
; auto-connect-display = no
EOF
    echo "Root configuration (client.conf) created."
    echo "If you have not yet done so, run this script as your normal user to write the user configs"
fi

# If there were no errors tell user to restart, else warn them errors happened.
if [ $? -eq 0 ]; then
    echo "Configuration created successfully, please restart both Pipewire-pulseaudio and Wireplumber or your system, for changes to take affect."
else
    echo "Errors were encountered whilst writing the configuration, please correct them manually."
fi
exit 0
