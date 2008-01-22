# => http://microformats.org/wiki/hatom
require 'microformat'
require 'mofo/hcard'
require 'mofo/rel_tag'
require 'mofo/rel_bookmark'
require 'digest/md5'

class HEntry < Microformat
  one :entry_title, :entry_summary, :updated, :published,
      :author => HCard

  many :entry_content, :tags => RelTag 

  after_find do
    @updated = @published unless @updated if @published
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

    <<-atom_entity
    <entry>
      #{atom_id}
      #{atom_link}
      #{to_atom :title, @entry_title}
      <content type="html">#{Array(@entry_content).join("\n")}</content>
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
