class BooksController < ApplicationController
  
  before_filter :login_required
  
  def index
    @books = Book.published.by_title
  end
  
  def proposed
    @books = Book.proposed.by_category
  end
  
  def contracted
    @books = Book.under_contract.by_category
  end


  def show
    @book = Book.find(params[:id])
  end


  def new
    @book = Book.new
  end


  def edit
    @book = Book.find(params[:id])
  end


  def create
    @book = Book.new(params[:book])

    if @book.save
      redirect_to @book, notice: "#{@book.title} was added to the system."
    else
      render action: "new"
    end
  end


  def update
    @book = Book.find(params[:id])

    if @book.update_attributes(params[:book])
      redirect_to @book, notice: "#{@book.title} was revised in the system."
    else
      render action: "edit"
    end
  end


  def destroy
    @book = Book.find(params[:id])
    @book.destroy
  end
end
