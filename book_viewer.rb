require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @contents = File.readlines "data/toc.txt"
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |paragraph, idx|
      "<p id = #{idx + 1}>#{paragraph}</p>"
    end.join
  end

  def each_chapter
    @contents.each_with_index do |title, num|
      num += 1
      chapter = File.read "data/chp#{num}.txt"
      yield title, num, chapter
    end
  end

  def search_chapters(query)
    results = []

    return results if !query || query.empty?

    each_chapter do |title, num, content|
      paragraphs = []

      content.split("\n\n").each_with_index do |paragraph, idx|
        paragraphs << { :num => idx + 1, :content => paragraph } if paragraph.include? query
      end
      
      results << { :title => title, :number => num, :paragraphs => paragraphs } if paragraphs.any?
    end

    results
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_title = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_title}"
  @chapter = File.read "data/chp#{number}.txt"

  erb :chapter
end

get "/chapters/:number/" do
  number = params[:number].to_i
  chapter_title = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_title}"
  @chapter = File.read "data/chp#{number}.txt"

  erb :chapter
end

get "/search" do
  @title = "Search"
  @results = search_chapters(params[:query])

  erb :search
end