class JoinMsg < Plugin

    Config.register Config::StringValue.new('joinmsg.message',
      :default => 'Default Welcome Message',
      :desc => "Default Welcome Message...")

    def help(plugin, topic="")
        return "Help for Join Message"
    end

    def join(m)
        nick = m.source.nick
        channel = m.channel.to_s
        key = "#{channel}::#{nick}"
        if !@registry[key]
            @registry[key] = true
            @bot.say nick, "#{nick}, #{@bot.config['joinmsg.message']}"
        end
        return
    end

    def rm(m, params)
        @registry.clear()
        m.okay
    end
end

plugin = JoinMsg.new

plugin.map 'joinmsg rm', :action => 'rm'

plugin.default_auth('*',false)
