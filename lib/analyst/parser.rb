require 'fileutils'
require 'pry'

module Analyst

  class Parser

    extend Forwardable

    attr_reader :start_path

    def_delegators :root, :classes, :top_level_classes

    # TODO: Empty -> Unhandled (or something like that)
    PROCESSORS = Hash.new(Entities::Empty).merge!(
      :root => Entities::Root,
      :class => Entities::Class,
      :def => Entities::InstanceMethod,
      :defs => Entities::SingletonMethod,
      :begin => Entities::Begin,
      :module => Entities::Module,
      :send => Entities::MethodCall,
      :sclass => Entities::SingletonClass,
      :dstr => Entities::InterpolatedString,
      :sym => Entities::Symbol,
      :str => Entities::String,
      :hash => Entities::Hash,
      :pair => Entities::Pair,
      :const => Entities::Constant
   )

    def self.process_node(node, parent)
      return if node.nil? # TODO: maybe a Entities:Nil would be appropriate? maybe?
      return unless node.respond_to?(:type)
      PROCESSORS[node.type].new(node, parent)
    end

    def initialize(ast)
      @ast = ast
    end

    def inspect
      "\#<#{self.class}:#{object_id}>"
    end

    private

    def root
      @root ||= self.class.process_node(@ast, nil)
    end

  end

end
