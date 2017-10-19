require "spec_helper"
require "ostruct"

RSpec.describe Cavalry do
  class Horse
    attr_reader :id
    attr_reader :name

    def initialize(id, name)
      @id = id
      @name = name
    end

    def attributes
      {
        id: id,
        name: name
      }
    end

    # association mock
    def owner
      Object.new
    end

    # association mock
    def carrot
      return if id == 4
      Object.new
    end

    class << self
      def all
        @records ||= [].tap do |records|
          records << new(1, "shika")
          records << new(2, "okey")
          records << new(3, "nagumo")
          records << new(4, "july")
        end
      end

      def where(name: "")
        all.select { |r| r.name == name }
      end

      def reflections
        {
          owner: OpenStruct.new(name: :owner),
          carrot: OpenStruct.new(name: :carrot)
        }
      end
    end
  end

  class Cow
    attr_reader :id
    attr_reader :name

    def initialize(id, name)
      @id = id
      @name = name
    end

    def attributes
      {
        id: id,
        name: name
      }
    end

    class << self
      def all
        @records ||= [].tap do |records|
          records << new(1, "USHI")
          records << new(2, "COWCOW")
          records << new(2, "mowmow")
          records << new(2, "AWESOME")
        end
      end

      def where(name: "")
        all.select { |r| r.name == name }
      end
    end
  end

  class HorseValidator < Cavalry::Validator
    validate_for Horse

    validate_each do
      validates :id, presence: true
      validates :name, presence: true, length: { maximum: 6 }

      validate :name_is_lowercase

      def name_is_lowercase
        if name != name.downcase
          errors.add(:name, "should be downcase.")
        end
      end
    end

    validate_group do
      validate do |records|
        return if records.count < 5
        errors.add(:base, "records should be lesser than 5")
      end

      validate.where(name: "cat") do |records|
        return if records.count < 2
        errors.add(:name, "cats should be lesser than 2")
      end

      validate :id_is_unique, :ids_are_ordered

      def id_is_unique(records)
        return if records.map(&:id).uniq.count == records.count
        errors.add(:base, "ids should be unique")
      end

      def ids_are_ordered
        all_ids = Horse.all.map(&:id)
        return if  all_ids == all_ids.sort
        errors.add(:base, "ids should be ordered")
      end
    end
  end

  class CowValidator < Cavalry::Validator
    validate_for Cow

    validate_each do
      validates :id, presence: true
      validates :name, presence: true, length: { maximum: 6 }

      validate :name_is_uppercase

      def name_is_uppercase
        if name != name.upcase
          errors.add(:name, "should be uppercase.")
        end
      end
    end

    validate_group do
      validate do |records|
        return unless records.count > 5
        errors.add(:base, "records should be lesser than 5")
      end

      validate.where(name: "cat") do |records|
        return unless records.count > 2
        errors.add(:name, "cats should be lesser than 2")
      end

      validate :id_is_unique

      def id_is_unique(records)
        return if records.map(&:id).uniq.count == records.count
        errors.add(:base, "ids should be unique")
      end
    end
  end


  describe "Cavalry.run" do
    subject { Cavalry.run }

    it "can execute validation" do
      expect { subject }.to_not raise_error
    end

    it "makes 2 validation error" do
      subject
      expect(Cavalry.errors.count).to eq(3)
    end
  end

  let(:validation_error) do
    [
      {
         record: "Cow",
         attributes: {
           id: 2,
           name: "mowmow"
         },
         errors: {
           name: ["should be uppercase."]
         }
      },
      {
        record: "Cow",
        attributes: {
          id: 2,
          name: "AWESOME"
        },
        errors: {
          name: ["is too long (maximum is 6 characters)"]
        }
      },
      {
        record: "GroupValidation",
        errors: {
          base: ["ids should be unique"]
        }
      }
    ]
  end

  describe "Cavalry.dump" do
    subject do
      Cavalry.run
      Cavalry.dump
    end

    it "can receive errors by hash" do
      expect(subject).to eq(validation_error)
    end
  end

  describe "force_check_belongs_to_association" do
    before do
      Cavalry.configure do |config|
        config.force_check_belongs_to_association = true
      end

      # define mock active record refrections
      module ActiveRecord
        module Reflection
          const_set("BelongsToReflection", Object)
        end
      end
    end

    subject do
      Cavalry.run
      Cavalry.dump
    end


    let(:belongs_to_errors) do
      [
        {
          record: "Horse",
          attributes: {
            id: 4,
            name: "july"
          },
          errors: {
            carrot: ["can't be blank"]
          }
        }
      ]

    end

    it "can receive errors with Horse's association error" do
      expect(subject).to eq(belongs_to_errors + validation_error)
    end
  end
end
