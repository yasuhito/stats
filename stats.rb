require "rubygems"

require "mathstats"
require "stringio"
require "sub-process"


def popen command
  out = StringIO.new

  SubProcess.create do | shell |
    shell.on_stdout do | line |
      out.puts line
    end
    shell.on_stderr do | line |
      out.puts line
    end
    shell.on_failure do
      # Do nothing.
    end
    shell.exec command
  end

  out.rewind
  out
end


def run_build
  command = "make #{ ARGV.join ' ' }"
  puts "RUNNING: #{ command }"

  # TODO: check for an error exit and then only parse for errors
  out = popen( command )
  results = out.read
  print results

  counts = Hash.new( 0 )
  results.each_line do | each |
    if /^.*:\d+:\d+: (.*):/=~ each
      counts[ $1 ] += 1
    end
  end

  counts
end


class Array
  def sum
    Mathstats.sum self
  end


  def sumsq
    Math.sqrt sum
  end


  def sd
    if self.size > 1
      Mathstats.standard_deviation( self )
    else
      0.0
    end
  end


  def mean
    Mathstats.mean self
  end
end


class History
  attr_reader :data


  def self.load file_name
    if FileTest.exists?( file_name )
      File.open( file_name, "r" ) do | f |
        Marshal.load f
      end
    else
      self.new file_name
    end
  end


  def initialize file_name
    @file_name = file_name
    @data = Hash.new( [] )
  end
  

  def add counts
    ( @data.keys + counts.keys ).uniq.each do | each |
      if counts[ each ]
        @data[ each ] += [ counts[ each ] ]
      else
        @data[ each ] += [ 0 ]
      end
    end
  end


  def save
    File.open( @file_name, "w" ) do | f |
      f.print Marshal.dump( self )
    end
  end
end
