require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'

get '/' do
  html = %q(
  <html><head><title>Movie Search</title></head><body>
  <h1>Find a Movie!</h1>
  <form accept-charset="UTF-8" action="/result" method="post">
    <label for="movie">Search for:</label>
    <input id="movie" name="movie" type="text" />
    <input name="commit" type="submit" value="Search" />
  </form></body></html>
  )
end

post '/result' do
  search_str = params[:movie]

  # Make a request to the omdb api here!
  response = Typhoeus.get("www.omdbapi.com", :params => {s: search_str})
  movies = JSON.parse(response.body)["Search"].sort_by { |x| x["Year"]}




  # Modify the html output so that a list of movies is provided.
  html_str = "<html><head><title>Movie Search Results</title></head><body><h1>Movie Results</h1>\n<ul>"
  if movies.nil?
    html_str +=  "That movie doesn't exist!"
  else
    movies.each do |x|
      html_str += "<li><a href=poster/#{x['imdbID']}>#{x["Title"]}, #{x["Year"]}</a></li>"
    end
  end

  html_str += "</ul><br /><a href='/'>New Search</a></body></html>"

end

post '/test' do
  search_str = params[:movie]
  response = Typhoeus.get("www.omdbapi.com", :params => {s: search_str})
  movies = JSON.parse(response.body)
end

get '/poster/:imdb' do |imdb_id|
  # Make another api call here to get the url of the poster.
  response = Typhoeus.get("www.omdbapi.com", :params => {i: imdb_id})
  poster = JSON.parse(response.body)

  html_str = "<html><head><title>Movie Poster</title></head><body><h1>Movie Poster</h1>\n"
  html_str += "<h3>#{poster["Title"]}</h3>"
  html_str += "<img src=#{poster["Poster"]} alt = 'Movie Poster Image' >"
  html_str += '<br /><a href="/">New Search</a></body></html>'

end

