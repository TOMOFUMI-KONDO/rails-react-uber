module Api
  module V1
    class FoodsController < ApplicationController
      def index
        foods = Restaurant.find(params[:restaurant_id]).foods

        render json: {
          foods: foods
        }, status: :ok
      end
    end
  end
end
