# Author: Lloyd Hilaiel <lloydh@yahoo-inc.com>
# Purpose: log irc messages to a mysql database 
# Modified for newer rbot by: Dav Glass <davglass@gmail.com>

require "mysql"

class Logger < Plugin

    Config.register Config::BooleanValue.new('logger.listen',
        :default => false,
        :desc => "Activate the logger, default: false"
    )

    Config.register Config::StringValue.new('logger.table',
        :default => 'chat',
        :desc => "The table to store our data, default: chat"
    )

    Config.register Config::StringValue.new('logger.who',
        :default => 'who',
        :desc => "The field to insert the nick in, default: who"
    )

    Config.register Config::StringValue.new('logger.channel',
        :default => 'channel',
        :desc => "The field to insert the channel name in, default: channel"
    )

    Config.register Config::StringValue.new('logger.utterance',
        :default => 'utterance',
        :desc => "The field to insert the log line in, default: utterance"
    )

    Config.register Config::StringValue.new('logger.dbserver',
        :default => 'localhost',
        :desc => "The database server to use, default: localhost"
    )

    Config.register Config::StringValue.new('logger.database',
        :default => '',
        :desc => "The database to use"
    )

    Config.register Config::StringValue.new('logger.dbuser',
        :default => '',
        :desc => "The database user"
    )

    Config.register Config::StringValue.new('logger.dbpasswd',
        :default => '',
        :desc => "The database password."
    )

    def initialize
        super
        @listen = @bot.config['logger.listen']
        if @listen
            connect()
            @tableName = @bot.config['logger.table']
            @whoColumn = @bot.config['logger.who']
            @whatColumn = @bot.config['logger.utterance']
            @channelColumn = @bot.config['logger.channel']
        end
    end

    def connect
        @dbconn = Mysql::new(@bot.config['logger.dbserver'],
                         @bot.config['logger.dbuser'],
                         @bot.config['logger.dbpasswd'],
                         @bot.config['logger.database'])
    end

    def help(plugin, topic="")
        "Logger: log all irc traffic to a database"
    end

    def replay(m, args)
        nick = m.source.nick
        channel = m.channel.to_s
        begin
            @dbconn.ping()
        rescue
            connect()
        end
        channel_sql = ""
        if channel
            channel_sql = " (channel = '#{channel}') and "
        end

        sql = "select #{@whoColumn}, #{@whatColumn} from #{@tableName} where #{channel_sql} (UNIX_TIMESTAMP(stamp) > (UNIX_TIMESTAMP(NOW()) - (60 * #{args[:time]})))"
        @bot.say nick, "#{nick}, Replaying log from #{args[:time]} minutes ago for #{channel}.."
        res = @dbconn.query(sql)
        while row = res.fetch_row do
            @bot.say nick, "#{row[0]}:  #{row[1]}"
        end

    end

    def listen(m)
        if @listen
            if not m.private?
                begin
                    @dbconn.ping()
                rescue
                    connect()
                end
        
                query =  "INSERT INTO #{@tableName}(#{@whoColumn},#{@whatColumn}, #{@channelColumn})"
                query += "VALUE('#{Mysql.quote(m.sourcenick)}',"
                query += "'#{Mysql.quote(m.message)}', '#{Mysql.quote(m.channel.to_s)}')"

                #execute the query
                @dbconn.query(query)
            end
        end
    end
end

plugin = Logger.new
plugin.map 'logger replay :time [*10]', :action => 'replay'
