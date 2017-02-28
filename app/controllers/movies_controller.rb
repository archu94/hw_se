class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

@all_ratings = Movie.distinct.pluck(:rating)


redirect = false
logger.debug(session.inspect)

if params[:sort]
  @column_to_sort = params[:sort]
  session[:sort] = params[:sort]
  elsif session[:sort]
  @column_to_sort = session[:sort]
  redirect = true
else
  @column_to_sort = nil
end

if params[:commit] == 'Refresh' and params[:ratings] == nil
  @set_ratings = nil
  session[:ratings] = nil
  elsif params[:ratings]
  @set_ratings = params[:ratings]
  session[:ratings] = params[:ratings]
  elsif session[:ratings]
  @set_ratings = session[:ratings]
  redirect = true
else
  @set_ratings = nil
end

if redirect
  flash.keep
  redirect_to movies_path :sort => @column_to_sort, :ratings => @set_ratings
end
@column_to_sort = params[:sort]
@set_ratings = params[:ratings]

if @set_ratings and @column_to_sort
  @get_keys = params[:ratings].keys
  @movies = Movie.where(:rating => @get_keys).order(params[:sort])
  elsif @set_ratings
  @get_keys = params[:ratings].keys
  @movies = Movie.where(:rating => @get_keys)
  elsif @column_to_sort
  @movies = Movie.order(@column_to_sort)
else
  @movies = Movie.all
end
if @set_ratings == nil
  @set_ratings = Hash.new
end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
