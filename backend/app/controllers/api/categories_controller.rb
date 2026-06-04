class Api::CategoriesController < ApplicationController
  # Purpose: Lists all categories, ordered alphabetically by name.
  # Returns a JSON array of all categories.
  # Side Effects: None. Read-only database query.
  def index
    categories = Category.order(:name)
    render json: categories
  end

  # Purpose: Creates a new category record from the submitted request body.
  # Returns a 201 Created with the new category JSON on success,
  # or 422 Unprocessable Entity with validation errors on failure.
  #
  # Params:
  #   - category (Hash): Group containing permitted attributes:
  #     - name (String): Unique name for the category.
  #
  # Returns: JSON of the new category on success, or { errors: [...] } on failure.
  # Side Effects: Inserts a new row into the categories table.
  def create
    category = Category.new(category_params)

    if category.save
      render json: category, status: :created
    else
      render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Purpose: Whitelists parameters allowed for creating a category.
  # Returns: ActionController::Parameters with permitted keys.
  # Side Effects: None. Pure function.
  def category_params
    params.require(:category).permit(:name)
  end
end
