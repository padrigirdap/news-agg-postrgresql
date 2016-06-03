require 'uri'

class Article
  attr_reader :title, :url, :description, :errors

  def initialize(hash = {})
    @title = hash['title']
    @url = hash['url']
    @description = hash['description']
    @errors = []
  end

  def self.all
    articles_all = db_connection { |conn| conn.exec("SELECT title, url, description FROM articles") }
    articles_all.map do |article|
       Article.new(article)
    end
  end

  def valid?
    form_filled?
    url_nil?
    url_duplicate?
    long_enough?
    if @errors.empty?
      return true
    else
      return false
    end
  end

  def form_filled?
    if title == "" || url == "" || description == ""
      @errors << "Please completely fill out form"
    end
  end

  def url_nil?
    url_test = @url =~ URI::regexp
    if @url == ""
      nil
    elsif url_test.nil?
      @errors << "Invalid URL"
    end
  end

  def url_duplicate?
    all_urls = []
    db_connection do |conn|
      all_urls = conn.exec_params("SELECT url FROM articles").to_a
    end

    all_urls.each do |url|
      if url.has_value?(@url)
        @errors << "Article with same url already submitted"
      end
    end
  end

  def long_enough?
    if @description == ""
      nil
    elsif @description.length < 20
      @errors << "Description must be at least 20 characters long"
    end
  end

  def save
    if valid?
      db_connection do |conn|
        conn.exec_params("INSERT INTO articles (title, url, description) VALUES ($1, $2, $3)", [@title, @url, @description])
      end
      true
    else
      false
    end
  end
end
