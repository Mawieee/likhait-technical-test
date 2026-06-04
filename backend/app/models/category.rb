class Category < ApplicationRecord
  has_many :expenses, dependent: :destroy

  # Validates that a category has a name, its name is unique (case-insensitive),
  # and does not exceed 100 characters in length.
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
end
