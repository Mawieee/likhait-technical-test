require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  # Shared categories used across multiple test groups below.
  let!(:food_category)      { Category.create!(name: "Food") }
  let!(:transport_category) { Category.create!(name: "Transport") }

  # -------------------------------------------------------------------------
  # GET /api/expenses
  # -------------------------------------------------------------------------
  describe "GET /api/expenses" do
    # Create two expenses with different dates so we can verify sort order.
    let!(:older_expense) do
      Expense.create!(
        description: "Lunch",
        amount: 100.00,
        category: food_category,
        # Give this expense an older date so it should appear LAST in the list.
        date: Date.today - 1
      )
    end

    let!(:newer_expense) do
      Expense.create!(
        description: "Taxi",
        amount: 50.00,
        category: transport_category,
        # Give this expense today's date so it should appear FIRST in the list.
        date: Date.today
      )
    end

    it "returns all expenses with category information" do
      get "/api/expenses"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    # BUG-001 regression test: Expenses must be ordered by their `date` column
    # descending, NOT by their `created_at` timestamp. This test validates that
    # an expense with a more recent *date* appears first regardless of insertion order.
    it "returns expenses ordered by expense date descending (BUG-001)" do
      get "/api/expenses"

      json = JSON.parse(response.body)

      # The expense with today's date must come first.
      expect(json.first["id"]).to eq(newer_expense.id)
      # The expense with yesterday's date must come last.
      expect(json.last["id"]).to eq(older_expense.id)
    end

    # Additional BUG-001 scenario: When an old-dated expense is entered AFTER a
    # newer one, it should NOT appear at the top — it should sort by its date.
    it "sorts by expense date, not by insertion order" do
      # Create an expense dated 30 days ago, inserted AFTER the other two.
      old_backdated_expense = Expense.create!(
        description: "Old Receipt",
        amount: 200.00,
        category: food_category,
        date: Date.today - 30
      )

      get "/api/expenses"

      json = JSON.parse(response.body)
      ids_in_response_order = json.map { |e| e["id"] }

      # Expected order: newer_expense (today) → older_expense (yesterday) → old_backdated (30 days ago)
      expect(ids_in_response_order).to eq([
        newer_expense.id,
        older_expense.id,
        old_backdated_expense.id
      ])
    end

    it "filters expenses by month and year using the expense date column (BUG-001)" do
      # Create an expense in a completely different month to confirm it's excluded.
      Expense.create!(
        description: "Last Month Expense",
        amount: 75.00,
        category: food_category,
        date: Date.today.prev_month
      )

      get "/api/expenses", params: { year: Date.today.year, month: Date.today.month }

      json = JSON.parse(response.body)

      # Only the expenses dated in the current month should be returned.
      # older_expense is yesterday (still this month); newer_expense is today.
      expect(json.length).to eq(2)
      returned_ids = json.map { |e| e["id"] }
      expect(returned_ids).to include(newer_expense.id, older_expense.id)
    end
  end

  # -------------------------------------------------------------------------
  # POST /api/expenses
  # -------------------------------------------------------------------------
  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today
          }
        }
      end

      it "creates a new expense and returns 201 Created" do
        expect {
          post "/api/expenses", params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq(150.5)
      end
    end

    context "with invalid parameters" do
      it "still persists an expense with a negative amount (no model validation yet)" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "still persists an expense with an empty description (no model validation yet)" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
