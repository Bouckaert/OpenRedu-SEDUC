Redu::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Nome e URL do app
  config.url = "localhost:3000"

  config.action_mailer.default_url_options = { :host => config.url }

  # Armazena no sist. de arquivos
  config.paperclip = {
    :path => File.join(Rails.root.to_s, "public/images/:class/:attachment/:id/:style/:basename.:extension"),
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    :default_url => "/images/new/missing_:class_:style.png"
  }

  config.paperclip_environment.merge!(config.paperclip)
  config.paperclip_user.merge!(config.paperclip)

  config.paperclip_documents = config.paperclip.merge({
    :styles => {},
    :default_url => ''
  })
  config.paperclip_myfiles = config.paperclip.merge({:styles => {}})
  config.video_original = config.paperclip.merge({:styles => {}})
  config.video_transcoded = config.paperclip.merge({:styles => {}})

  # Só converte os 5 primeiros segundos (grátis)
  config.zencoder[:test] = 1
end
