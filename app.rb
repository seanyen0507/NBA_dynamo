require 'sinatra/base'
require_relative 'model/nbaplayer'
require 'NBA_info'
require 'json'
require 'sinatra/flash'

require 'httparty'

# Simple version of nba_scrapper
class NBACatcherApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride
  configure :production, :development do
    enable :logging
  end

  API_BASE_URI = 'http://localhost:9292'
  helpers do
    def get_profile(playername)
      sam = Scraper.new
      profile_after = {
        'name' => playername, 'profiles' => []
      }
      begin
        begin
          name = params[:playername]
          sam.profile(name)[0].each do |key, value|
            profile_after['profiles'].push('Box-score' => key, 'Record' => value)
          end
        rescue
          nil
        else
          profile_after
        end
      rescue
        halt 404
      end
    end

    def check_start_lineup(playernames, des)
      @lineup = {}
      @body_null = true
      sean = Scraper.new
      # begin
      #   get_profile(playernames).nil ? @player_wrong = false : @player_wrong=\
      # true
      #   fail 'err' if @player_wrong == false
      # rescue
      #   halt 404
      # end
      begin
        playernames == '' ? @body_null = false : @body_null = true
        fail 'err' if @body_null == false
      rescue
        halt 400
      end
      begin
        po = sean.game[0]
        s = sean.game[2]
        po.each do |key, _value|
          if key.include? 'PM'
            5.times do
              temp = s.shift
              playernames.each do |playername|
                lastname = playername.split(' ').last
                if temp.include?(lastname.capitalize)
                  @lineup[playername] = 'Yes, he is in start lineup today.'
                end
              end
            end
          else
            3.times { s.shift }
          end
        end
        playernames.each do |playername|
          unless @lineup.key?(playername)
            @lineup[playername] = 'No, he is not in start lineup today.'
          end
        end
      rescue
        halt 404
      else
        @lineup
      end
    end

    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end
  end

  get '/' do
    'NBA catcher is up.'
  end

  get '/api/v1/player/:playername.json' do
    content_type :json
    get_profile(params[:playername]).to_json
  end

  post '/api/v1/nbaplayers' do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
      halt 400
    end
    nbaplayer = Nbaplayer.new
    nbaplayer.description = req['description'].to_json
    nbaplayer.playernames = req['playernames'].to_json

    redirect "api/v1/nbaplayers/#{nbaplayer.id}" if nbaplayer.save
  end

  get '/api/v1/nbaplayers/:id' do
    content_type :json
    begin
      @nbaplayer = Nbaplayer.find(params[:id])
      description = JSON.parse(@nbaplayer.description)
      playernames = JSON.parse(@nbaplayer.playernames)
    rescue
      halt 400
    end
    check_start_lineup(playernames, description).to_json
  end

  put '/api/v1/nbaplayers/:id' do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
      halt 400
    end
    nbaplayer = Nbaplayer.update(params[:id],req['playernames'].to_json)
  end

  delete '/api/v1/nbaplayers/:id' do
    nbaplayer = Nbaplayer.destroy(params[:id])
  end
end
