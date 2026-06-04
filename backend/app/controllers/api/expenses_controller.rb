class Api::ExpensesController < ApplicationController
  # Purpose: Lists all expenses, ordered by the most recent expense date first.
  # An optional year+month filter narrows results to a specific calendar month.
  #
  # Query Params:
  #   - year (Integer): The calendar year to filter by (e.g. 2024).
  #   - month (Integer): The calendar month to filter by (e.g. 3 for March).
  #
  # Returns: JSON array of expense objects, ordered by date DESC, then created_at DESC.
  # Side Effects: None. Read-only database query.
  def index
    # BUG-001 FIX: Order by the expense's actual `date` column (descending) first,
    # then use `created_at` as a tiebreaker for expenses on the same date.
    # Previously this was ordered only by `created_at`, which caused newly entered
    # old-dated expenses to appear at the top of the list incorrectly.
    expenses = Expense.includes(:category).order(date: :desc, created_at: :desc)

    if params[:year].present? && params[:month].present?
      year = params[:year].to_i
      month = params[:month].to_i

      start_date = Date.new(year, month, 1)
      end_date = start_date.end_of_month

      # BUG-001 FIX: Filter by the `date` column (the actual expense date), not
      # `created_at` (when the record was entered). This ensures month filtering
      # reflects the true expense period rather than data entry time.
      expenses = expenses.where(date: start_date..end_date)
    end

    render json: expenses.map { |expense| format_expense(expense) }
  end

  # Purpose: Creates a new expense record from the submitted request body.
  # Returns a 201 Created with the new expense JSON, or 422 Unprocessable Entity
  # with a list of validation errors if the record fails to save.
  #
  # Returns: JSON of the new expense on success, or { errors: [...] } on failure.
  # Side Effects: Inserts a new row into the expenses table.
  def create
    expense = Expense.new(expense_params)

    if expense.save
      render json: format_expense(expense), status: :created
    else
      render json: { errors: expense.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Purpose: Updates an existing expense identified by its ID in the URL.
  # Returns the updated expense JSON on success, or validation errors on failure.
  #
  # Params:
  #   - id (Integer): The ID of the expense to update, taken from the URL.
  #
  # Returns: Updated expense JSON on success, or { errors: [...] } on failure.
  # Side Effects: Updates the matching row in the expenses table.
  def update
    expense = Expense.find(params[:id])

    if expense.update(expense_params)
      render json: format_expense(expense)
    else
      render json: { errors: expense.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Purpose: Deletes an expense record permanently from the database.
  # Returns a 204 No Content response (empty body) on success.
  #
  # Params:
  #   - id (Integer): The ID of the expense to delete, taken from the URL.
  #
  # Returns: 204 No Content (empty body).
  # Side Effects: Permanently removes the matching row from the expenses table.
  def destroy
    expense = Expense.find(params[:id])
    expense.destroy
    head :no_content
  end

  private

  # Purpose: Defines the allowed (whitelisted) parameters for creating and updating
  # an expense. This prevents mass-assignment vulnerabilities by only allowing
  # the specific fields we explicitly list here.
  #
  # Returns: ActionController::Parameters with only the permitted keys.
  # Side Effects: None. Pure function.
  def expense_params
    params.require(:expense).permit(:description, :amount, :category_id, :date)
  end

  # Purpose: Serializes an Expense ActiveRecord object into a plain Ruby Hash
  # that will be rendered as JSON in API responses. This keeps the response
  # shape consistent across all expense endpoints.
  #
  # Params:
  #   - expense (Expense): The ActiveRecord expense object to serialize.
  #
  # Returns: Hash with id, description, amount (Float), category name, date string,
  #          created_at, and updated_at.
  # Side Effects: None. Pure function.
  def format_expense(expense)
    {
      id: expense.id,
      description: expense.description,
      amount: expense.amount.to_f,
      category: expense.category.name,
      date: expense.date.to_s,
      created_at: expense.created_at,
      updated_at: expense.updated_at
    }
  end
end
