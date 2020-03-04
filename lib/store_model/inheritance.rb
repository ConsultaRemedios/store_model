# frozen_string_literal: true

module StoreModel
  module Inheritance
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def inheritance_column
        "_type"
      end

      def new(attributes = {}, &block)
        return super unless attribute_types.key?(inheritance_column)

        attributes = attributes.with_indifferent_access

        if attributes.key?(inheritance_column)
          subclass = subclass_from_attributes(attributes).constantize
          return super if subclass == self
          subclass.new(attributes, &block)
        else
          attributes.merge!(inheritance_column => self.name)
          super
        end
      end

      def subclass_from_attributes(attributes)
        attributes[inheritance_column] || attributes[inheritance_column.to_sym]
      end
    end

    def inspect
      attribute_string = attributes
        .reject { |name| name == self.class.inheritance_column }
        .map { |name, value| "#{name}: #{value.nil? ? 'nil' : value}" }
        .join(', ')

      if attribute_string.present?
        "#<#{self.class.name} #{attribute_string}>"
      else
        "#<#{self.class.name}>"
      end
    end
  end
end
