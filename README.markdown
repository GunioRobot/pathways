Pathways
========

Pathways allows you to see the pathways that users are using within your application. When we can see the flows through the app then we can pave the cowpaths and validate the features that we build.

Pathways uses your default Rails logger to store the information from a successful response so it doesn't slow our request/response cycle. We can then parse the logfile and store the results in a MongoDB database at a later date.

### Another set of Metrics?

Pathways was created so that we can understand the impact of our development on the behaviour of our users. Metrics shouldn't just be about page view counters it should understand where the user has been within that viewing session. By using a non relational database like MongoDB we can map_reduce all the pages that a user visits in a session so that we can truly analyse what is going on within our applications.


The Blog Post
-------------

For the backstory, philosophy, and history of why we created Pathways,
please see [the blog post][0].


Overview
--------

Pathways allows you to track the flow users take within your application. Each successful request is logged into your Rails.logger which can then be asynchronously parsed and stored in a MongoDB table later.

Tracker
-------

To start tracking the paths your users are taking all you need to do is add this to your controllers.

``` ruby
class ApplicationController
  include Pathways::Tracker
  after_filter :log_visit
end
```

This will create an entry in your default logfile that is later collected and parsed by Pathways.

### Iteration

You can also track the iteration/deployment that is currently running so that we can easily track the impact of each deployment.

``` ruby
class ApplicationController
  include Pathways::Tracker
  after_filter :log_visit
  Pathways::Tracker.iteration  = "iteration-001"
end
```

Parser
------

Now that we're tracking the paths our users take we need to parse these so that we can mine this like a mofo.

    Pathways::Parser.execute

This will run ever 5 seconds and create records for Pathways::Session and Pathways::Visits. By default this will look at the development.log using Rails.root.

If you want to specify the name of the logfile then you can pass it as the first parameter.

    Pathways::Parser.execute("production")

You can also control the interval (in seconds) that parser will check your logfile, the default is set to 60 seconds.

    Pathways::Tracker.iteration("production",10)

The Front End
-------------

Pathways has a huge crush on Resque, so like Resque it comes with a Sinatra-based front end for seeing the sessions users are creating in your app.

### Standalone

If you've installed Pathways as a gem running the front end standalone is easy:

    $ pathways-web

It's a thin layer around `rackup` so it's configurable as well:

    $ pathways-web -p 8282

### Passenger

Using Passenger? Resque ships with a `config.ru` you can use. See
Phusion's guide:

Apache: <http://www.modrails.com/documentation/Users%20guide%20Apache.html#_deploying_a_rack_based_ruby_application>
Nginx: <http://www.modrails.com/documentation/Users%20guide%20Nginx.html#deploying_a_rack_app>

### Rack::URLMap

If you want to load Resque on a subpath, possibly alongside other
apps, it's easy to do with Rack's `URLMap`:

``` ruby
require 'pathways/server'

run Rack::URLMap.new \
  "/"       => Your::App.new,
  "/pathways" => Pathways::Server.new
```

### Rails 3

You can also easily mount Resque on a subpath in your existing Rails 3 app by adding this to your `routes.rb`:

``` ruby
mount Pathways::Server.new, :at => "/pathways"
```


Installing MongoDB
------------------

Pathways requires MongoDB.


#### Homebrew

If you're on OS X, Homebrew is the simplest way to install MongoDB:

    $ brew install mongodb
    $ mongod run --config /usr/local/Cellar/mongodb/1.8.1-x86_64/mongod.conf

You now have a MongoDB instance running on 27017.


Pathways Dependencies
---------------------

    $ gem install bundler
    $ bundle install


Installing Pathways
-----------------

### In a Rails 2.x app, as a gem

First install the gem.

    $ gem install resque

Next include it in your application.

    $ cat config/initializers/load_pathways.rb
    require 'resque'

Now start your application:

    $ ./script/server

Ta da! Your application is now logging the pathways your users make.

### In a Rails 3 app, as a gem

First include it in your Gemfile.

    $ cat Gemfile
    ...
    gem 'pathways'
    ...

Next install it with Bundler.

    $ bundle install

Now start your application:

    $ rails server

Ta da! Your application is now logging the pathways your users make.


Contributing
------------

Once you've made your great commits:

1. [Fork][1] Pathways
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch
5. That's it!

Meta
----

* Code: `git clone git://github.com/simonreed/pathways.git`
* Bugs: <http://github.com/simonreed/pathways/issues>

Author
------

Simon Reed :: simon@mintdigital.com :: @simonreed

[0]: http://logicalfriday.com/2011/08/25/dont-build-that-feature/