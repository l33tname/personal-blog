xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Primärquelle"
    xml.description "Ein Blog für seriösliche Nachrichten!"
    xml.link "http://blog.l33t.name/"

    @posts.each do |post|
      xml.item do
        xml.title post.text.slice(0, 30) + "..."
        xml.link "http://blog.l33t.name/#{post.id}"
        xml.description Md.render(post.text).gsub("</p>", "").gsub("<p>", "")
        xml.pubDate Time.parse(post.created_at.to_s).rfc822()
        xml.guid "http://blog.l33t.name/#{post.id}"
      end
    end
  end
end