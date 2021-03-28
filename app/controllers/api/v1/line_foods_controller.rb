module Api
  module V1
    class LineFoodsController < ApplicationController
      before_action :set_food, only: %i[create replace]

      def index
        line_foods = LineFood.active

        if line_foods.exists?
          render json: {
            line_food_ids: line_foods.map(&:id),
            restaurant: line_foods[0].restaurant,
            count: line_foods.sum { |line_food| line_food[:count] },
            amount: line_foods.sum(&:total_amount)
          }, status: :ok
        else
          render json: {}, status: :no_content
        end
      end

      def create
        other_restaurant = LineFood.active.other_restaurant(@ordered_food.restaurant.id)

        if other_restaurant.exists?
          return render json: {
            existing_restaurant: other_restaurant.first.restaurant.name,
            new_restaurant: @ordered_food.restaurant.name
          }, status: :not_acceptable
        end

        set_line_food(@ordered_food)
        puts @line_food.present?

        if @line_food.save
          render json: {
            line_food: @line_food
          }, status: :created
        else
          render json: {hoge: 'hoge'}, status: :internal_server_error
        end
      end

      def replace
        LineFood.active.other_restaurant(@ordered_food.restaurant.id).each do |line_food|
          line_food.update_attribute(:active, false)
        end

        set_line_food(@ordered_food)

        if @line_food.save
          render json: {
            line_food: @line_food,
          }, status: :created
        else
          render json: {}, status: :internal_server_error
        end
      end

      private

      def set_food
        @ordered_food = Food.find(params[:food_id])
      end

      def set_line_food(ordered_food)
        ordered_line_food = ordered_food.line_food

        if ordered_line_food.present?
          @line_food = ordered_line_food
          @line_food.attributes = {
            count: ordered_line_food.count + params[:count].to_i,
            active: true
          }
        else
          @line_food = ordered_food.build_line_food(
            count: params[:count],
            restaurant: ordered_food.restaurant,
            active: true
          )
        end
      end
    end
  end
end
