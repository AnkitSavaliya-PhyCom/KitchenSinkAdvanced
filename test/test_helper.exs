#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

{:ok, _} = Application.ensure_all_started(:semaphore)

Application.load(:tzdata)
{:ok, _} = Application.ensure_all_started(:tzdata)

Noizu.Support.Cms.V2.Database.MnesiaEmulator.start_link()
Noizu.Testing.Mnesia.Emulator.start_link()

# Schema Setup
#Amnesia.Schema.destroy()
Amnesia.Schema.create()

# Start Amnesia
Amnesia.start()

# Support Records
Noizu.KitchenSink.Database.Support.UserTable.create(memory: [node()])

# Email Service
Noizu.EmailService.Database.Email.TemplateTable.create(memory: [node()])
Noizu.EmailService.Database.Email.QueueTable.create(memory: [node()])
Noizu.EmailService.Database.Email.Queue.EventTable.create(memory: [node()])

# Setup Template
%Noizu.EmailService.Email.TemplateEntity{
  identifier: :test_template,
  name: "Test Template",
  description: "Template Description",
  external_template_identifier: {:sendgrid, "ccbe9d68-59ab-4639-87a8-07ab73a8dcc1"}, # todo standardize ref
  binding_defaults: [{:default_field, {:literal,  "default_value"}}],
} |> Noizu.EmailService.Email.TemplateRepo.create!(Noizu.ElixirCore.CallingContext.admin())


%Noizu.EmailService.Email.TemplateEntity{
  identifier: :test_dynamic_template,
  name: "Test Template",
  description: "Template Description",
  external_template_identifier: {:sendgrid, "d-e09ef095b9f641d8a35d862ec8882d9c"}, # todo standardize ref
  binding_defaults: [{:default_field, {:literal,  "default_value"}}],
} |> Noizu.EmailService.Email.TemplateRepo.create!(Noizu.ElixirCore.CallingContext.admin())



# Cms
Noizu.Cms.Database.PostTable.create(memory: [node()])
Noizu.Cms.Database.Post.TagTable.create(memory: [node()])
Noizu.Cms.Database.Post.VersionTable.create(memory: [node()])
Noizu.Cms.Database.Post.VersionHistoryTable.create(memory: [node()])

# V3.CMS
Noizu.V3.CMS.Database.Article.Table.create(memory: [node()])
Noizu.V3.CMS.Database.Article.Index.Table.create(memory: [node()])
Noizu.V3.CMS.Database.Article.Tag.Table.create(memory: [node()])
Noizu.V3.CMS.Database.Article.VersionSequencer.Table.create(memory: [node()])
Noizu.V3.CMS.Database.Article.Version.Table.create(memory: [node()])
Noizu.V3.CMS.Database.Article.Version.Revision.Table.create(memory: [node()])
Noizu.V3.CMS.Database.Article.Active.Version.Table.create(memory: [node()])
Noizu.V3.CMS.Database.Article.Active.Version.Revision.Table.create(memory: [node()])

# Smart Token
Noizu.SmartToken.Database.TokenTable.create(memory: [node()])

ExUnit.start()
