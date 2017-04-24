# server.rb
require 'sinatra'
require "sinatra/namespace"
require 'mongoid'

# DB Setup
Mongoid.load! "mongoid.config"

# Models
class Location
  include Mongoid::Document

  field :user, type: String
  field :longitude, type: Float
  field :latitude, type: Float

  validates :user, presence: true
  validates :longitude, presence: true
  validates :latitude, presence: true

  index({ user: 'text' }, { unique: true })

  scope :user, -> (user) { where(user: /^#{user}$/) }
end

# Serializers
class LocationSerializer

  def initialize(loc)
    @loc = loc
  end

  def as_json(*)
    data = {
      id: @loc.id.to_s,
      user: @loc.user,
      longitude: @loc.longitude,
      latitude: @loc.latitude
    }
    data[:errors] = @loc.errors if @loc.errors.any?
    data
  end

end

# Endpoints
get '/' do
  'Welcome to Location Services!'
end

namespace '/api/v1' do

  before do
    content_type 'application/json'
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end

    def json_params
      begin
        JSON.parse(request.body.read)
      rescue
        halt 400, { message: 'Invalid JSON' }.to_json
      end
    end

    def loc
      @loc ||= Location.where(id: params[:id]).first
    end

    def halt_if_not_found!(loc)
      halt(404, { message: 'User Not Found'}.to_json) unless loc
    end

    def serialize(loc)
      LocationSerializer.new(loc).to_json
    end
  end

  get '/location' do
    locs = Location.all

    [:user, :longitude, :latitude].each do |filter|
      locs = locs.send(filter, params[filter]) if params[filter]
    end

    locs.map { |loc| LocationSerializer.new(loc) }.to_json
  end

  post '/location' do
    loc = Location.new(json_params)
    halt 422, serialize(loc) unless loc.save
    response.headers['Location'] = "#{base_url}/api/v1/location/#{loc.id}"
    status 201
  end

  patch '/location/:user' do |user|
    loc = Location.where(:user_id => user)
    halt_if_not_found! loc
    halt 422, serialize(loc) unless loc.update_attributes(json_params)
    serialize(loc)
  end

end
