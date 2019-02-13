class Api::GrantsController < ApplicationController
  respond_to :json

  def index
    render jsonapi: Grant.all
  end

  def show
    render jsonapi: Grant.find(params[:id])
  end
end
