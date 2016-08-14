require 'twitter'
class UsersController < ApplicationController
	 before_action :set_twitter_default, only: [:create]

	def new
		@user = User.new
		@best_time_to_tweet = Rails.cache.read("display_message").to_s if Rails.cache.read("display_message").present?
		Rails.cache.clear
	end

	def create
		Rails.cache.write("display_message",@best_time_to_tweet)
		redirect_to new_user_path
	end



	def set_twitter_default
		username = params[:user][:username]
		userid = params[:user][:userid]
		if(username.present?)
			@twitter_request_param = username
		elsif (userid.present?)
			@twitter_request_param = userid
		else
			@best_time_to_tweet = "Please enter valid Twitter Credential"
			return
		end	
		@best_time_to_tweet = ""
		if create_client
			populate_day_time_hash
		end
	end


	def create_client
		client = Twitter::REST::Client.new do |config|
			config.consumer_key        = "RTnQEsvfClSjvmn4gl9oQ"
			config.consumer_secret     = "ZxIXodjGZ5VyJgj6Vjdels8Pcf5zqhOBv982cRYng"
			config.access_token        = "166959745-ac5VenrCsJorfn8HnK01K0RPeDbEgSMDDC0kjEM7"
			config.access_token_secret = "yW11ryJhh773XQHrcKekzf9X7mXElF4cEWPetqN4vk"

		end
		 begin
		    @user_followers = client.followers(@twitter_request_param.to_s)
		 rescue Exception => e
		 	@best_time_to_tweet = e.message.to_s
		 	return false
		 end
		 return true
	end

	def populate_day_time_hash
		@day_hash = {}
		@time_hash = {}
		begin
		    @user_followers.each do |follower|
		        tweet_latest_status = follower.status
		        if tweet_latest_status.present?
		           tweet_posted_date = tweet_latest_status.created_at.to_s.split[0]
		           tweet_posted_time = tweet_latest_status.created_at.to_s.split[1]
		           populate_day_hash(tweet_posted_date)
		           populate_time_hash(tweet_posted_time)
		        end
            end
		rescue Exception => e
		 	@best_time_to_tweet = e.message.to_s
		 	return
		end
        best_day_to_tweet = largest_hash_key(@day_hash)
        best_time_to_tweet = largest_hash_key(@time_hash)
        @best_time_to_tweet =  'Best Day to tweet is ' + best_day_to_tweet[0].to_s + ' and Best Time to tweet is  between ' + best_time_to_tweet[0].to_s + '00 hours and ' + ((best_time_to_tweet[0].to_i + 1)%24).to_s + '00 hours'
	end

	def populate_day_hash(tweet_posted_date)
		tweet_posted_day =  Date.parse(tweet_posted_date).strftime("%A")
		if @day_hash[tweet_posted_day].present?
		   @day_hash[tweet_posted_day] += 1
		else
		   @day_hash[tweet_posted_day] = 1
		end
	end

	def populate_time_hash(tweet_posted_time)
		tweet_posted_time_in_hour = tweet_posted_time.split(':')[0]
		if @time_hash[tweet_posted_time_in_hour].present?
		   @time_hash[tweet_posted_time_in_hour] += 1
		else
		   @time_hash[tweet_posted_time_in_hour] = 1
		end
	end

	def largest_hash_key(hash)
        hash.max_by{|k,v| v}
    end
end
