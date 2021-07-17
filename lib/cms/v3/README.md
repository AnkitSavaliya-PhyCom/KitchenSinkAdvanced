CMS 3.0
==============

# What is it?
The Content Management System version 3.0 provides a framework for tracking any user defined elixir scaffolding v3 domain objects
in a general CMS framework. It additionally exposes common json based APIs for editing CMS entries regardless of type although
some custom logic will be needed to provide appropriate client side type editors for various cms types. 

# How does it work
 
The system defines a protocol that entities must implement to enable version tracking, tag lookup etc. and repo behaviour 
hooks that should be invoked to ensure that version records, etc. are injected and removed as expected. 

The CMS 3.0 system additionally provides some basic CMS types to help users get started quickly, Files, Posts, Images.
 
As entities are persisted using the elixir scaffolding framework additional book keeping is tracked to allow the cms system to 
look up records of any type. 
 
# Example 

Let's assume we want to track vehicle records as top level CMS entities.

1. First we define our elixir scaffolding domain_object in the usual mannerm simply replacing
   Noizu.DomainObject with Noizu.CMS.DomainObject. 
    
    ```elixir
    
    defmodule MyProject.Vehicle do 
      use Noizu.Cms.DomainObject
      @vsn 1.0
      @sref "vehicle"
      @persistence_layer :mnesia
      defmodule Entity do
        @universal_identifier true
        Noizu.CMS.DomainObject.noizu_entity do
           identifier :integer
           public_field :name
           public_field :description
           public_field :make
           public_field :model
        end
      end

      defmodule Repo do
         Noizu.Cms.DomainObject.noizu_repo() do
         end
      end
   end
   ```
   
2. Protocol Setup

3. Behavior Call Backs. 

# Behind the scenes. 
As entities are created, updated, and deleted CMS book keeping records are automatically updated. 
These additional book keeping records allow use to access entities using the core CMS repo regardless of type.
And couples with the cms protocol allow us to look up exact versions of tracked entities regardless of type. 
without requiring full duplicate copies to be persisted (for very large user defined types) 
