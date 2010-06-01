Methodize
---------

Is a module to read from and write to the keys of a ruby Hash using methods. As simple as this:

    require 'methodize/hash'
    hash.methodize!

If you don't want to mess with your Hash class, just do this:

    require 'methodize'
    hash.extend(Methodize)

The advantage of using Methodize is that you can easily access the values of complex or big Hash objects, such as converted JSONs returned from Web Services, RESTful APIs, etc.

Instead of using:

    hash["article"].last["info"][:category].first

You can use:

    hash.article.last.info.category.first

### Interested? Let's see more examples ###

Let's suppose that we have the following hash object:

    hash = {
      :article => [
        {
          :title  => "Article 1",
          :author => "John Doe",
          :url    => "http://a.url.com"
        },{
          "title"  => "Article 2",
          "author" => "Foo Bar",
          "url"    => "http://another.url.com"
        },{
          :title  => "Article 3",
          :author => "Biff Tannen",
          :url    => ["http://yet.another.url.com", "http://localhost"],
          :info => {
            :published => "2010-05-31",
            :category  => [:sports, :entertainment]
          }
        }
      ],
      "type" => :text,
      :size  => 3,
      :id    => 123456789
    }

You can change the **title of the third article** using:

    hash.article[2].title = "New title"
    hash.article[2].title               # => "New title"

Hash public methods that conflicts with keys will be automatically freed:

    hash.type                           # => :text
    hash.size                           # => 3
    hash.id                             # => 123456789

But don't panic, you can still use the Hash methods just as Ruby does for id and send methods by default:

    hash.__type__                       # => Hash
    hash.__size__                       # => 4 (hash keys count)

### Another examples ###

Writing:

    hash.article.last.title = "Article 3"
    hash.article[1].info = {
                              :published => "2010-08-31",
                              :category  => [:sports, :entertainment]
                            }
    hash.article << {
                       :title  => "A new title",
                       :author => "Marty Mcfly"
                     }
    hash.shift  = 12
    hash["inspect"] = false
    hash.size   = 4

Accessing:

    hash.article[2].title               # => "Article 3"
    hash.article[1].info.published      # => "2010-08-31"
    hash.article.last.author            # => "Marty Mcfly"
    hash.shift                          # => 12
    hash.inspect                        # => false
    hash.__inspect__.class              # => String
    hash.size                           # => 4
    hash.__size__                       # => 6

You can access the Hash as usual using [] or []=.

Check the tests for more examples.

*Created by Luis Cipriani*<br/>
*http://blog.talleye.com*
