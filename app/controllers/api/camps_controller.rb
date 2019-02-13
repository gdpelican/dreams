# TODO: we'll want to create a controller which defines index and show routes for
# each of our resources, to allow our data to be accessed programmatically from
# other applications
# Docs on the 'include' and 'filter' options:
# http://jsonapi-rb.org/guides/getting_started/rails.html
class Api::CampsController < ApplicationController
  respond_to :json
  before_filter :verify_request!

  def index
    # NB, if we feel the need for more GraphQL-type functionality here, we can
    # do things like look at the request params and put them into the 'include' or
    # 'fields' slots in the hash, or filter results by time / status / etc,
    # which will allow the client to have pretty granular control over what data
    # they receive back from the API.
    render jsonapi: Camp.all,
           include: [:grants],
           fields: {
             camps: [:name, :subtitle],
             grants: [:amount]
           }
  end

  def show
    render jsonapi: Camp.find(params[:id])
  end

  def create
    # TODO: We may wish to leave this for a later iteration, but it wouldn't
    # be too hard to put in some routes that actually created / modified / destroyed
    # records in addition to simply show and index
    # @camp = Camp.new(camp_params)
    # if @camp.save
    #   render jsonapi: @camp
    # else
    #   render json: { data: { errors: @camp.errors } }
    # end
  end

  private

  # This isn't a super flexible method, but it's a quick and easy way to get a little
  # security onto what the API will hand out; essentially we put a master API key
  # into the ENV, and check it each time an API call is made, returning an error
  # if there's a mismatch. Note that leaving this ENV empty will allow _anyone_ to
  # make requests against the API... probably not the thing you want.
  # So from here we simply generate a token of some kind, put that token into the ENV,
  # and share that token with any apps who need access to this API.
  # (NB that this will want to go into a parent controller which runs this check
  # before each request)
  def verify_request!
    render json: { error: "Invalid API KEY!" } unless params[:token] == ENV['API_TOKEN']
  end
end
