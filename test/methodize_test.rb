require 'test/unit'
require 'methodize'

require 'rubygems'
require 'ruby-debug'

class MethodizeTest < Test::Unit::TestCase

  def setup
    @hash = {
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

    @hash.extend(Methodize)
  end

  def test_hash_should_still_work_as_expected
    assert_equal "Article 3", @hash[:article].last[:title]
    assert_equal "Foo Bar"  , @hash[:article][1]["author"]
    assert_equal :text      , @hash["type"]
    assert_equal 3          , @hash[:size]
    assert_nil   @hash[:wrong_key]
    
    assert       @hash.keys.include?(:size)
    assert_equal 3, @hash.article.size
  end

  def test_hash_should_support_read_of_values_as_methods
    assert_equal "Article 3", @hash.article.last.title
    assert_equal "Foo Bar"  , @hash.article[1].author
    assert_equal :sports    , @hash.article.last.info.category.first
    assert_nil   @hash.wrong_key
  end

  def test_should_free_existant_methods_by_default
    assert_equal 3        , @hash.size
    assert_equal :text    , @hash.type
    assert_equal 123456789, @hash.id
  end

  def test_should_be_able_to_call_previously_freed_methods
    assert_equal 4, @hash.__size__
    begin #avoid showing deprecate Object#type warning on test log
      $stderr = StringIO.new
      assert_equal Hash, @hash.__type__
      $stderr.rewind
    ensure
      $stderr = STDERR
    end
    assert_not_equal 123456789, @hash.__id__
  end
  
  def test_should_enable_write_operations
    @hash.article.last.title = "Article 3"
    @hash.article[1].info = {
                              :published => "2010-08-31",
                              :category  => [:sports, :entertainment]
                            }
    @hash.article << {
                       :title  => "A new title",
                       :author => "Marty Mcfly"
                     }
    @hash.shift  = 12
    @hash["inspect"] = false
    @hash.size   = 4
    
    assert_equal "Article 3"  , @hash.article[2].title
    assert_equal "2010-08-31" , @hash.article[1].info.published
    assert_equal "Marty Mcfly", @hash.article.last.author
    assert_equal 12           , @hash.shift
    assert_equal false        , @hash.inspect
    assert_equal String       , @hash.__inspect__.class
    assert_equal 4            , @hash.size
    assert_equal 6            , @hash.__size__
  end
end

