namespace :settings do
  desc "Create setting to all users"
  task :create_settings => :environment do
  	all_users = User.all
  	all_users.each do |user|
  		if(user.settings.blank?)
  			user.create_settings!
  		end
  	end
  end
end
