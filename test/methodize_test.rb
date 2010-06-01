require 'test/unit'
require 'lib/methodize'

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
    assert_equal @hash[:article].last[:title], "Article 3"
    assert_equal @hash[:article][1]["author"], "Foo Bar"
    assert_equal @hash["type"]               , :text
    assert_equal @hash[:size]                , 3
    assert_nil   @hash[:wrong_key]
    
    assert       @hash.keys.include?(:size)
    assert_equal @hash.article.size, 3
  end

  def test_hash_should_support_read_of_values_as_methods
    assert_equal @hash.article.last.title              , "Article 3"
    assert_equal @hash.article[1].author               , "Foo Bar"
    assert_equal @hash.article.last.info.category.first, :sports
    assert_nil   @hash.wrong_key
  end

  def test_should_free_existant_methods_by_default
    assert_equal @hash.size, 3
    assert_equal @hash.type, :text
    assert_equal @hash.id  , 123456789
  end

  def test_should_be_able_to_call_previously_freed_methods
    assert_equal     @hash.__size__, 4
    begin #avoid showing deprecate Object#type warning on test log
      $stderr = StringIO.new
      assert_equal     @hash.__type__, Hash
      $stderr.rewind
    ensure
      $stderr = STDERR
    end
    assert_not_equal @hash.__id__  , 123456789
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
    
    assert_equal @hash.article[2].title         , "Article 3"
    assert_equal @hash.article[1].info.published, "2010-08-31"
    assert_equal @hash.article.last.author      , "Marty Mcfly"
    assert_equal @hash.shift                    , 12
    assert_equal @hash.inspect                  , false
    assert_equal @hash.__inspect__.class        , String
    assert_equal @hash.size                     , 4
    assert_equal @hash.__size__                 , 6
  end
end

