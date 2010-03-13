require 'rubygems'
require 'hpricot'
require 'open-uri'

class BlogExtrator
  attr_accessor :posts
  
  def initialize
    @posts = []
  end
  
  def extrair
    doc = Hpricot(open('http://localhost/wordpress'))
    extrair_posts(doc)
  end
  
  private
  
  def extrair_posts(doc)
    doc.search('#content .post').each do |post_div|
      post_page = Hpricot(open( post_div.at('h2 > a')[:href] ))
      post_page.search('.entry > p.postmetadata').remove
      
      @posts << {
        :title => post_page.at('#content .post h2').inner_text.strip,
        :body => post_page.at('#content .post .entry').inner_text.strip,
        :date => post_div.at('small').inner_text.strip,
        :comments => extrair_comentarios(post_page.search('ol.commentlist li.comment'))
      }
    end
    
    if link_pag_anterior = doc.at(".alignleft a[@href^='http://localhost/wordpress/?paged=']")
      extrair_posts Hpricot(open(link_pag_anterior[:href]))
    end
  end
  
  def extrair_comentarios(doc)
    doc.collect do |comment|
      {
        :author => comment.at('.comment-author cite').inner_text,
        :date => comment.at('.comment-meta').inner_text,
        :body => comment.at('.comment-body > p').inner_text
      }
    end
  end
end