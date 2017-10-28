require 'factory_face/declaration/static'
require 'factory_face/declaration/dynamic'
require 'factory_face/declaration/association'
require 'factory_face/declaration/implicit'

module FactoryBot
  # @api private
  class Declaration
    attr_reader :name

    def initialize(name, ignored = false)
      @name    = name
      @ignored = ignored
    end

    def to_attributes
      build
    end

    protected
    attr_reader :ignored
  end
end
