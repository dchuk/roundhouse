# Base keeps this routing regression independent of the API controller gap.
class FormatsController < ActionController::Base
  def literal
    render plain: "literal"
  end

  def index
    render plain: "collection"
  end

  def show
    render plain: params[:id]
  end
end
