require 'test/unit'
require 'methodize/hash'

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

    @hash.methodize!
  end

  def test_methodize_should_still_work_as_expected
    assert_equal @hash[:article].last[:title], "Article 3"
    assert_equal @hash[:article][1]["author"], "Foo Bar"
    assert_equal @hash["type"]               , :text
    assert_equal @hash[:size]                , 3
    assert_nil   @hash[:wrong_key]
    
    assert       @hash.keys.include?(:size)
    assert_equal @hash.article.size, 3
  end

  def test_methodize_should_support_read_of_values_as_methods
    assert_equal @hash.article.last.title              , "Article 3"
    assert_equal @hash.article[1].author               , "Foo Bar"
    assert_equal @hash.article.last.info.category.first, :sports
    assert_nil   @hash.wrong_key
    
    assert_equal @hash.size, 3
    assert_equal @hash.type, :text
    assert_equal @hash.id  , 123456789
  end

  def test_double_methodize_call_does_not_affect_anything
    assert_equal @hash.methodize!.article.last.title, "Article 3"
  end

end
