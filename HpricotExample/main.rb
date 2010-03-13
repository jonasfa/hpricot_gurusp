require 'BlogExtrator'

blog_extrator = BlogExtrator.new
blog_extrator.extrair

puts blog_extrator.posts.collect{|p| p.inspect}