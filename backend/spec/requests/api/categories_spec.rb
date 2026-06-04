require 'rails_helper'

RSpec.describe "Api::Categories", type: :request do
  describe "GET /api/categories" do
    let!(:food) { Category.create!(name: "Food") }
    let!(:transport) { Category.create!(name: "Transport") }
    let!(:supplies) { Category.create!(name: "Supplies") }

    it "returns all categories" do
      get "/api/categories"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(3)
      expect(json.map { |c| c["name"] }).to include("Food", "Transport", "Supplies")
    end

    it "returns categories in alphabetical order" do
      get "/api/categories"

      json = JSON.parse(response.body)
      expect(json.map { |c| c["name"] }).to eq([ "Food", "Supplies", "Transport" ])
    end
  end

  # -------------------------------------------------------------------------
  # POST /api/categories
  # -------------------------------------------------------------------------
  describe "POST /api/categories" do
    context "with valid parameters" do
      let(:valid_params) { { category: { name: "Entertainment" } } }

      it "creates a new category and returns 201 Created" do
        expect {
          post "/api/categories", params: valid_params, as: :json
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("Entertainment")
      end
    end

    context "with invalid parameters" do
      it "returns 422 Unprocessable Entity when name is blank" do
        invalid_params = { category: { name: "" } }

        post "/api/categories", params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Name can't be blank")
      end

      it "returns 422 Unprocessable Entity when name is a duplicate" do
        Category.create!(name: "Utilities")
        duplicate_params = { category: { name: "utilities" } } # Check case-insensitivity

        post "/api/categories", params: duplicate_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Name has already been taken")
      end
    end
  end
end
