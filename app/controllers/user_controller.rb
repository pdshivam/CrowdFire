require 'twitter'
class UserController < ApplicationController
	 before_action :create_client, only: [:new]

	def new
		User.connection
		@user = User.new
	end

	def create
		
	end


	def create_client
		client = Twitter::REST::Client.new do |config|
			config.consumer_key        = "RTnQEsvfClSjvmn4gl9oQ"
			config.consumer_secret     = "ZxIXodjGZ5VyJgj6Vjdels8Pcf5zqhOBv982cRYng"
			config.access_token        = "166959745-ac5VenrCsJorfn8HnK01K0RPeDbEgSMDDC0kjEM7"
			config.access_token_secret = "yW11ryJhh773XQHrcKekzf9X7mXElF4cEWPetqN4vk"

		end
		 @user_followers = client.followers('shtj_mlhtra')
         # populate_day_time_hash

	end

	def populate_day_time_hash
		@day_hash = {}
		@time_hash = {}
		@user_followers.each do |follower|
		    tweet_latest_status = follower.status
		    if tweet_latest_status.present?
		       tweet_posted_date = tweet_latest_status.created_at.to_s.split[0]
		       tweet_posted_time = tweet_latest_status.created_at.to_s.split[1]
		       populate_day_hash(tweet_posted_date)
		       populate_time_hash(tweet_posted_time)
		    end
        end
        best_day_to_tweet = largest_hash_key(@day_hash)
        best_time_to_tweet = largest_hash_key(@time_hash)
        puts 'Best Day to tweet is ' + best_day_to_tweet[0].to_s + ' and Best Time to tweet is  between ' + best_time_to_tweet[0].to_s + '00 hours and ' + ((best_time_to_tweet[0].to_i + 1)%24).to_s + '00 hours'
        puts @day_hash
        puts @time_hash
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
