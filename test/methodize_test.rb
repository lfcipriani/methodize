require 'rubygems'
require 'test/unit'
require 'lib/methodize'
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
          :url    => ["http://yet.another.url.com", "http://localhost"]
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
  end

  def test_hash_should_support_read_of_values_as_methods
    assert_equal @hash.article.last.title, "Article 3"
    assert_equal @hash.article[1].author , "Foo Bar"
    assert_nil   @hash.wrong_key
  end

  def test_hash_should_eval_existent_methods_as_usual
    assert_equal @hash.size, 4
  end

  def test_should_free_id_and_type_methods_by_default
    assert_equal @hash.type, :text
    assert_equal @hash.id  , 123456789
  end

  def test_should_be_able_to_free_methods
    assert_equal @hash.__free_method__(:size).size, 3
  end
end

