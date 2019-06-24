require 'logger'
require 'singleton'

class Log

  #シングルトン
  include Singleton

  #コンストラクタ
  def initialize
    @@log = Logger.new('/script/log/script.log', 'weekly')
  end

  #クラスメソッド
  class << self

    #呼び出し元のファイル名を、動的に取得したかったからメソッド内でそれぞれcallerしてる。
    def debug(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}:#{$2}"
      @@log.debug(msg)
    end

    def info(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}:#{$2}"
      @@log.info(msg)
    end

    def warn(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}:#{$2}"
      @@log.warn(msg)
    end

    def error(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}:#{$2}"
      @@log.error(msg)
    end

    def fatal(msg)
      caller()[0] =~ /(.*?):(\d+)/
      @@log.progname = "#{$1}:#{$2}"
      @@log.fatal(msg)
    end

  end

end