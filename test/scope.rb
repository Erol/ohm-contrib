# encoding: UTF-8

require File.expand_path("../helper", __FILE__)

class Post < Ohm::Model
  set :comments, :Comment
end

module Finders
  def rejected
    find(:status => "rejected")
  end
end

class Comment < Ohm::Model
  include Ohm::Scope

  attribute :status
  index :status

  scope do
    def approved
      find(:status => "approved")
    end
  end

  scope Finders
end

test "has a predefined scope" do
  assert defined?(Comment::DefinedScopes)
end

test "allows custom methods for the defined scopes" do
  post = Post.create
  comment = Comment.create(:status => "approved")
  Post.redis.call("SADD", post.comments.key, comment.id)

  assert post.comments.approved.is_a?(Ohm::MultiSet)
  assert post.comments.approved.include?(comment)
end

test "allows custom methods to be included from a module" do
  post = Post.create
  comment = Comment.create(:status => "rejected")
  Post.redis.call("SADD", post.comments.key, comment.id)

  assert post.comments.rejected.is_a?(Ohm::MultiSet)
  assert post.comments.rejected.include?(comment)
end

test "works with the main Comment.all collection as well" do
  approved = Comment.create(:status => "approved")
  rejected = Comment.create(:status => "rejected")


  assert Comment.all.approved.include?(approved)
  assert Comment.all.rejected.include?(rejected)
end
