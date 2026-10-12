class ProbesController < ApplicationController
  skip_forgery_protection
  layout false

  # html arm calls a helper that renders
  def html_helper
    @who = "html_helper"
    respond_to do |format|
      format.html { fail_it }
      format.turbo_stream
    end
  end

  # html arm calls a helper that redirects
  def html_helper_redirect
    @who = "html_helper_redirect"
    respond_to do |format|
      format.html { go_away }
      format.turbo_stream
    end
  end

  def html_cond_redirect
    @who = "html_cond_redirect"
    respond_to do |format|
      format.html { redirect_to "/x" if params[:r] }
      format.turbo_stream
    end
  end

  def html_cond_head
    @who = "html_cond_head"
    respond_to do |format|
      format.html { head :accepted if params[:r] }
      format.turbo_stream
    end
  end

  def html_unless_render
    @who = "html_unless_render"
    respond_to do |format|
      format.html do
        unless params[:r]
          render :other
        end
      end
      format.turbo_stream
    end
  end

  def html_early_return
    @who = "html_early_return"
    respond_to do |format|
      format.html do
        return redirect_to("/x") if params[:r]
        @side = 1
      end
      format.turbo_stream
    end
  end

  def html_rescue
    @who = "html_rescue"
    respond_to do |format|
      format.html do
        begin
          render :other
        rescue StandardError
          @side = 1
        end
      end
      format.turbo_stream
    end
  end

  def html_status
    @who = "html_status"
    respond_to do |format|
      format.html { render :html_status, status: :unprocessable_entity }
      format.turbo_stream
    end
  end

  # local assign before the arms
  def pre_assign
    @who = "pre_assign"
    respond_to do |format|
      @pre = 1
      format.html
      format.json { render json: [1, 2].map { |i| i * 2 } }
    end
  end

  # scaffold shape: arms inside if/else, plus a statement before
  def seq_if
    @who = "seq_if"
    respond_to do |format|
      @pre = 1
      if params[:ok]
        format.html { render html: "ok" }
        format.json { render json: { ok: true } }
      else
        format.html { render :other, status: :unprocessable_entity }
        format.json { render json: { ok: false }, status: :unprocessable_entity }
      end
    end
  end

  def top_if
    @who = "top_if"
    respond_to do |format|
      if params[:ok]
        format.html { render html: "ok" }
        format.json { render json: { ok: true } }
      else
        format.html { render :other, status: :unprocessable_entity }
        format.json { render json: { ok: false }, status: :unprocessable_entity }
      end
    end
  end

  def wants_param
    @who = "wants_param"
    respond_to do |wants|
      wants.html
      wants.json { render json: { w: 1 } }
    end
  end

  def multi_turbo
    respond_to do |format|
      format.html { render html: "h" }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("a"),
          turbo_stream.remove("b")
        ]
      end
    end
  end

  def three
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("x") }
      format.html { render html: "h" }
      format.json { render json: { a: 1 } }
    end
  end

  def json_only
    respond_to do |format|
      format.json { render json: { a: 1 } }
    end
  end

  def html_only
    respond_to do |format|
      format.html { render html: "h" }
    end
  end

  def plain_two
    @who = "plain_two"
  end

  private

  def fail_it
    render html: "failed"
  end

  def go_away
    redirect_to "/gone"
  end
end
