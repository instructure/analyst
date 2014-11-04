require 'ephemeral'
require 'poro_plus'
require 'fileutils'
require 'haml'
require 'parser/current'

require_relative "analyst/entities/entity"
require_relative "analyst/entities/empty"
require_relative "analyst/entities/root"
require_relative "analyst/entities/begin"
require_relative "analyst/entities/module"
require_relative "analyst/entities/class"
require_relative "analyst/entities/interpolated_string"
require_relative "analyst/entities/constant"
require_relative "analyst/entities/conditional"
require_relative "analyst/entities/method"
require_relative "analyst/entities/method_call"
require_relative "analyst/entities/singleton_class"
require_relative "analyst/entities/hash"
require_relative "analyst/entities/pair"
require_relative "analyst/entities/symbol"
require_relative "analyst/entities/string"
require_relative "analyst/parser"
require_relative "analyst/version"

module Analyst
  def self.new(path_to_files)
    Analyst::Parser.new(FileProcessor.new(path_to_files).ast)
  end

  def self.for_source(source)
    Analyst::Parser.new(SourceProcessor.new(source).ast)
  end

  class FileProcessor

    attr_reader :path_to_files

    def initialize(path_to_files)
      @path_to_files = path_to_files
    end

    def source_files
      if File.directory?(path_to_files)
        return Dir.glob(File.join(path_to_files, "**", "*.rb"))
      else
        return [path_to_files]
      end
    end

    def ast
      asts = source_files.map do |file|
        content = File.open(file, "r").read
        ::Parser::CurrentRuby.parse(content)
      end
      AstCompiler.compile(asts)
    end

  end

  class SourceProcessor

    attr_reader :source

    def initialize(source)
      @source = source
    end

    def ast
      AstCompiler.compile ::Parser::CurrentRuby.parse(source)
    end
  end

  module AstCompiler

    def self.compile(asts)
      asts = asts.is_a?(Array) ? asts : [asts]
      # NOTE: `asts = Array(asts)` is problematic due to some implementation
      # detail of ::Parser::AST::Node, so above line is necessary
      ::Parser::AST::Node.new(:root, asts)
    end

  end

end
