class Expense < ApplicationRecord
  belongs_to :category

  validates :date, presence: true
  validate :date_cannot_be_in_the_future

  private

  # Purpose: Validation helper to ensure that the expense date is not set in the future.
  # Adds a validation error to the :date attribute if it is after the current day.
  #
  # Returns: nil.
  # Side Effects: Adds validation errors to the model instance.
  def date_cannot_be_in_the_future
    if date.present? && date > Date.today
      errors.add(:date, "cannot be in the future")
    end
  end
end
