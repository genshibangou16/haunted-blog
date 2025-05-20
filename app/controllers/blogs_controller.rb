# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :check_user_ownership, only: %i[edit update destroy]
  before_action :check_user_ownership_for_secret, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    elsif @blog.errors[:random_eyecatch].any?
      render :new, status: :found
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    elsif @blog.errors[:random_eyecatch].any?
      render :edit, status: :found
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end

  def check_user_ownership
    raise ActiveRecord::RecordNotFound unless @blog.owned_by?(current_user)
  end

  def check_user_ownership_for_secret
    raise ActiveRecord::RecordNotFound if @blog.secret && !@blog.owned_by?(current_user)
  end
end
