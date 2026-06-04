require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "validations" do
    it "is valid with a unique name under 100 characters" do
      category = Category.new(name: "Healthcare")
      expect(category).to be_valid
    end

    it "is invalid without a name" do
      category = Category.new(name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it "is invalid with a duplicate name" do
      Category.create!(name: "Food")
      duplicate = Category.new(name: "food")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "is invalid with a name longer than 100 characters" do
      category = Category.new(name: "A" * 101)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("is too long (maximum 100 characters)")
    end
  end
end
