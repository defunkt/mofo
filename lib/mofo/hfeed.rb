# => http://microformats.org/wiki/hatom
require 'mofo/hentry'

class HFeed < Microformat
  many :hentry => HEntry

  def initialize(entries)
    @hentry = entries
  end

  def to_atom
    <<-end_atom
    <?xml version="1.0" encoding="UTF-8"?>
    <feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">
      <id>#{@hentry.first.atom_id}</id>
      <link type="text/html" href="#{@base_url}" rel="alternate"/>
      <link type="application/atom+xml" href="FUCK" rel="self"/>
      <title>#{@hentry.first.entry_title}</title>
      <updated>#{@hentry.first.updated || @hentry.first.published}</updated>
      #{@hentry.map { |entry| entry.to_atom }.join("\n")}
    </feed>
    end_atom
  end
end
