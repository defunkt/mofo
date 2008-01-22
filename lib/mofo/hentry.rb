# => http://microformats.org/wiki/hatom
require 'microformat'
require 'mofo/hcard'
require 'mofo/rel_tag'
require 'mofo/rel_bookmark'
require 'digest/md5'

class HEntry < Microformat
  one :entry_title, :entry_summary, :updated, :published,
      :author => HCard

  many :entry_content => :html, :tags => RelTag 

  after_find do
    @updated ||= @published if @published
  end

  def atom_id
    "<id>tag:#{@base_url.sub('http://','')},#{Date.today.year}:#{Digest::MD5.hexdigest(entry_content)}</id>"
  end

  def atom_link
    %(<link type="text/html" href="#{@base_url}#{@bookmark}" rel="alternate"/>)
  end

  def to_atom(property = nil, value = nil)
    if property
      value ||= instance_variable_get("@#{property}")
      return value ? ("<#{property}>%s</#{property}>" % value) : nil
    end

    entity = <<-atom_entity
  <entry>
    #{atom_id}
    #{atom_link}
    #{to_atom :title, @entry_title}
    <content type="html">#{@entry_content}</content>
    #{to_atom :updated}
    #{to_atom :published}
    <author>
      #{to_atom :name, @author.try(:fn)}
      #{to_atom :email, @author.try(:email)}
    </author>
  </entry>
    atom_entity
  end
end

class Array
  def to_atom(options = {})
    entries = map { |entry| entry.try(:to_atom) }.compact.join("\n")
    <<-end_atom
<?xml version="1.0" encoding="UTF-8"?>
<feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">
  <id>#{first.atom_id}</id>
  <link type="text/html" href="#{first.base_url}" rel="alternate"/>
  <link type="application/atom+xml" href="" rel="self"/>
  <title>#{options[:title]}</title>
  <updated>#{first.updated || first.published}</updated>
  #{entries}
</feed>
    end_atom
  end
end
