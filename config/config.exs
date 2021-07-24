# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :noizu_scaffolding,
       default_audit_engine: Noizu.KitchenSink.AuditEngine,
       default_nmid_generator: Noizu.KitchenSink.NmidGenerator,
       domain_object_schema: Noizu.Support.V3.CMS.DomainObject.Schema

config :sendgrid,
       api_key: System.get_env("SENDGRID_KS_KEY"),
       simulate: false,
       email_site_url: "https://github.com/noizu/KitchenSink"



#IO.puts "[[[[[[[[[[[[[[[ #{config_env()}.exs"
import_config "#{config_env()}.exs"
