require 'test/unit'
require 'methodize/hash'

require 'rubygems'
require 'ruby-debug'

class MethodizeHashTest < Test::Unit::TestCase

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
    assert_equal "Article 3", @hash[:article].last[:title]
    assert_equal "Foo Bar"  , @hash[:article][1]["author"]
    assert_equal :text      , @hash["type"]
    assert_equal 3          , @hash[:size]
    assert_nil   @hash[:wrong_key]
    
    assert       @hash.keys.include?(:size)
    assert_equal 3, @hash.article.size
  end

  def test_methodize_should_support_read_of_values_as_methods
    assert_equal "Article 3", @hash.article.last.title
    assert_equal "Foo Bar"  , @hash.article[1].author
    assert_equal :sports    , @hash.article.last.info.category.first
    assert_nil   @hash.wrong_key
    
    assert_equal 3        , @hash.size
    assert_equal :text    , @hash.type
    assert_equal 123456789, @hash.id  
  end

  def test_double_methodize_call_does_not_affect_anything
    assert_equal "Article 3", @hash.methodize!.article.last.title
  end

  def test_iteration_of_array_using_method__each
    map = []
    @hash.article.each do |article|
      map << article.kind_of?(MethodizedHash)
    end
    assert_equal [true, true, true], map
  end

  def test_iteration_of_array_using_method__each_with_index
    map = []
    @hash.article.each_with_index do |article, index|
      map << [article.kind_of?(MethodizedHash), index]
    end
    assert_equal [[true, 0], [true, 1], [true, 2]], map
  end

  def test_iteration_of_array_using_method__map
    map = @hash.article.map do |article|
      article.kind_of?(MethodizedHash)
    end
    assert_equal [true, true, true], map
  end

end
