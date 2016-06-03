class Article
  attr_reader :title, :url, :description, :errors

  def initialize(hash = {})
    @title = hash['title']
    @url = hash['url']
    @description = hash['description']
    @errors = []
  end

  def self.all
    salami_array = []
    articles_all = db_connection { |conn| conn.exec("SELECT title, url, description FROM articles") }
    articles_all.each do |article|
      salami_array << Article.new(article)
    end
    salami_array
  end

  def valid?
    if title == "" || url == "" || description == ""
      @errors << "Please completely fill out form"
      false
    else
      true
    end
  end
end
