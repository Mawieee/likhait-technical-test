require 'rails_helper'

RSpec.describe Expense, type: :model do
  describe "validations" do
    let(:category) { Category.create!(name: "Food") }

    it "is valid with a date of today" do
      expense = Expense.new(
        description: "Coffee",
        amount: 5.0,
        category: category,
        date: Date.today
      )
      expect(expense).to be_valid
    end

    it "is valid with a past date" do
      expense = Expense.new(
        description: "Coffee",
        amount: 5.0,
        category: category,
        date: Date.today - 5
      )
      expect(expense).to be_valid
    end

    it "is invalid with a future date" do
      expense = Expense.new(
        description: "Coffee",
        amount: 5.0,
        category: category,
        date: Date.today + 1
      )
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to include("cannot be in the future")
    end

    it "is invalid without a date" do
      expense = Expense.new(
        description: "Coffee",
        amount: 5.0,
        category: category,
        date: nil
      )
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to include("can't be blank")
    end
  end
end
