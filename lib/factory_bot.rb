require 'set'
require 'active_support/core_ext/module/delegation'
require 'active_support/deprecation'
require 'active_support/notifications'

require 'factory_face/definition_hierarchy'
require 'factory_face/configuration'
require 'factory_face/errors'
require 'factory_face/factory_runner'
require 'factory_face/strategy_syntax_method_registrar'
require 'factory_face/strategy_calculator'
require 'factory_face/strategy/build'
require 'factory_face/strategy/create'
require 'factory_face/strategy/attributes_for'
require 'factory_face/strategy/stub'
require 'factory_face/strategy/null'
require 'factory_face/registry'
require 'factory_face/null_factory'
require 'factory_face/null_object'
require 'factory_face/evaluation'
require 'factory_face/factory'
require 'factory_face/attribute_assigner'
require 'factory_face/evaluator'
require 'factory_face/evaluator_class_definer'
require 'factory_face/attribute'
require 'factory_face/callback'
require 'factory_face/callbacks_observer'
require 'factory_face/declaration_list'
require 'factory_face/declaration'
require 'factory_face/sequence'
require 'factory_face/attribute_list'
require 'factory_face/trait'
require 'factory_face/aliases'
require 'factory_face/definition'
require 'factory_face/definition_proxy'
require 'factory_face/syntax'
require 'factory_face/syntax_runner'
require 'factory_face/find_definitions'
require 'factory_face/reload'
require 'factory_face/decorator'
require 'factory_face/decorator/attribute_hash'
require 'factory_face/decorator/class_key_hash'
require 'factory_face/decorator/disallows_duplicates_registry'
require 'factory_face/decorator/invocation_tracker'
require 'factory_face/decorator/new_constructor'
require 'factory_face/linter'
require 'factory_face/version'

module FactoryBot
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset_configuration
    @configuration = nil
  end

  # Look for errors in factories and (optionally) their traits.
  # Parameters:
  # factories - which factories to lint; omit for all factories
  # options:
  #   traits: true - to lint traits as well as factories
  #   strategy: :create - to specify the strategy for linting
  def self.lint(*args)
    options = args.extract_options!
    factories_to_lint = args[0] || FactoryBot.factories
    linting_strategy = options[:traits] ? :factory_and_traits : :factory
    factory_strategy = options[:strategy] || :create
    Linter.new(factories_to_lint, linting_strategy, factory_strategy).lint!
  end

  class << self
    delegate :factories,
             :sequences,
             :traits,
             :callbacks,
             :strategies,
             :callback_names,
             :to_create,
             :skip_create,
             :initialize_with,
             :constructor,
             :duplicate_attribute_assignment_from_initialize_with,
             :duplicate_attribute_assignment_from_initialize_with=,
             :allow_class_lookup,
             :allow_class_lookup=,
             :use_parent_strategy,
             :use_parent_strategy=,
             to: :configuration
  end

  def self.register_factory(factory)
    factory.names.each do |name|
      factories.register(name, factory)
    end
    factory
  end

  def self.factory_by_name(name)
    factories.find(name)
  end

  def self.register_sequence(sequence)
    sequence.names.each do |name|
      sequences.register(name, sequence)
    end
    sequence
  end

  def self.sequence_by_name(name)
    sequences.find(name)
  end

  def self.register_trait(trait)
    trait.names.each do |name|
      traits.register(name, trait)
    end
    trait
  end

  def self.trait_by_name(name)
    traits.find(name)
  end

  def self.register_strategy(strategy_name, strategy_class)
    strategies.register(strategy_name, strategy_class)
    StrategySyntaxMethodRegistrar.new(strategy_name).define_strategy_methods
  end

  def self.strategy_by_name(name)
    strategies.find(name)
  end

  def self.register_default_strategies
    register_strategy(:build,          FactoryBot::Strategy::Build)
    register_strategy(:create,         FactoryBot::Strategy::Create)
    register_strategy(:attributes_for, FactoryBot::Strategy::AttributesFor)
    register_strategy(:build_stubbed,  FactoryBot::Strategy::Stub)
    register_strategy(:null,           FactoryBot::Strategy::Null)
  end

  def self.register_default_callbacks
    register_callback(:after_build)
    register_callback(:after_create)
    register_callback(:after_stub)
    register_callback(:before_create)
  end

  def self.register_callback(name)
    name = name.to_sym
    callback_names << name
  end
end

FactoryBot.register_default_strategies
FactoryBot.register_default_callbacks
