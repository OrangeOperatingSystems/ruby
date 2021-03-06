require "rexml/document"

require "rss-testcase"

require "rss/maker"
require "rss/1.0"
require "rss/2.0"
require "rss/content"
require "rss/dublincore"
require "rss/syndication"
require "rss/trackback"

module RSS
  class TestToS < TestCase
    
    def setup
      @image_url = "http://example.com/foo.png"
      @textinput_link = "http://example.com/search.cgi"
      @item_links = [
        "http://example.com/1",
        "http://example.com/2",
      ]
      
      setup_xml_declaration_info
      setup_xml_stylesheet_infos
      setup_channel_info
      setup_item_infos
      setup_image_info
      setup_textinput_info

      setup_dublin_core_info
      setup_syndication_info
      setup_content_info
      setup_trackback_info
    end

    def test_to_s_10
      rss = RSS::Maker.make("1.0") do |maker|
        setup_full(maker)
      end

      assert_xml_declaration(@version, @encoding, @standalone, rss)
      assert_xml_stylesheets(@xs_infos, rss.xml_stylesheets)
      assert_channel10(@channel_info, rss.channel)
      assert_items10(@item_infos, rss.items)
      rss.items.each do |item|
        assert_trackback(@trackback_info, item)
      end
      assert_image10(@image_info, rss.image)
      assert_textinput10(@textinput_info, rss.textinput)

      rss = RSS::Parser.parse(rss.to_s)

      assert_xml_declaration(@version, @encoding, @standalone, rss)
      assert_xml_stylesheets(@xs_infos, rss.xml_stylesheets)
      assert_channel10(@channel_info, rss.channel)
      assert_items10(@item_infos, rss.items)
      assert_image10(@image_info, rss.image)
      assert_textinput10(@textinput_info, rss.textinput)
    end
    
    def test_to_s_09
      rss = RSS::Maker.make("0.91") do |maker|
        setup_full(maker)
      end

      assert_xml_declaration(@version, @encoding, @standalone, rss)
      assert_xml_stylesheets(@xs_infos, rss.xml_stylesheets)
      assert_channel09(@channel_info, rss.channel)
      assert_items09(@item_infos, rss.items)
      assert_image09(@image_info, rss.image)
      assert_textinput09(@textinput_info, rss.textinput)

      rss = RSS::Parser.parse(rss.to_s)

      assert_xml_declaration(@version, @encoding, @standalone, rss)
      assert_xml_stylesheets(@xs_infos, rss.xml_stylesheets)
      assert_channel09(@channel_info, rss.channel)
      assert_items09(@item_infos, rss.items)
      assert_image09(@image_info, rss.image)
      assert_textinput09(@textinput_info, rss.textinput)
    end
    
    def test_to_s_20
      rss = RSS::Maker.make("2.0") do |maker|
        setup_full(maker)
      end

      assert_xml_declaration(@version, @encoding, @standalone, rss)
      assert_xml_stylesheets(@xs_infos, rss.xml_stylesheets)
      assert_channel20(@channel_info, rss.channel)
      assert_items20(@item_infos, rss.items)
      assert_image20(@image_info, rss.image)
      assert_textinput20(@textinput_info, rss.textinput)

      rss = RSS::Parser.parse(rss.to_s)

      assert_xml_declaration(@version, @encoding, @standalone, rss)
      assert_xml_stylesheets(@xs_infos, rss.xml_stylesheets)
      assert_channel20(@channel_info, rss.channel)
      assert_items20(@item_infos, rss.items)
      assert_image20(@image_info, rss.image)
      assert_textinput20(@textinput_info, rss.textinput)
    end
    
    private
    def setup_xml_declaration_info
      @version = "1.0"
      @encoding = "UTF-8"
      @standalone = false
    end

    def setup_xml_stylesheet_infos
      @xs_infos = [
        {
          "href" => "XXX.xsl",
          "type" => "text/xsl",
          "title" => "XXX",
          "media" => "print",
          "alternate" => "no",
        },
        {
          "href" => "YYY.css",
          "type" => "text/css",
          "title" => "YYY",
          "media" => "all",
          "alternate" => "no",
        },
      ]
    end

    def setup_channel_info
      @channel_info = {
        "about" => "http://example.com/index.rdf",
        "title" => "Sample RSS",
        "link" => "http://example.com/",
        "description" => "Sample\n\n\n\n\nSite",
        "language" => "en",
        "copyright" => "FDL",
        "managingEditor" => "foo@example.com",
        "webMaster" => "webmaster@example.com",
        "rating" => '(PICS-1.1 "http://www.rsac.org/ratingsv01.html" l gen true comment "RSACi North America Server" for "http://www.rsac.org" on "1996.04.16T08:15-0500" r (n 0 s 0 v 0 l 0))',
        "docs" => "http://backend.userland.com/rss091",
        "skipDays" => [
          "Monday",
          "Friday",
        ],
        "skipHours" => [
          12,
          23,
        ],
        "date" => Time.now,
        "lastBuildDate" => Time.now - 3600,
        "generator" => "RSS Maker",
        "ttl" => 60,
        "cloud" => {
          "domain" => "rpc.sys.com",
          "port" => "80",
          "path" => "/RPC2",
          "registerProcedure" => "myCloud.rssPleaseNotify",
          "protocol" => "xml-rpc",
        },
        "category" => {
          "domain" => "http://example.com/misc/",
          "content" => "misc",
        },

        "image" => {
          "resource" => @image_url,
        },

        "textinput" => {
          "resource" => @textinput_link,
        },

        "items" => @item_links.collect{|link| {"resource" => link}},
      }
    end

    def setup_item_infos
      @item_infos = [
        {
          "title" => "Sample item1",
          "link" => @item_links[0],
          "description" => "Sample description1",
          "date" => Time.now - 3600,
          "author" => "foo@example.com",
          "comments" => "http://example.com/1/comments",
          "guid" => {
            "isPermaLink" => "ture",
            "content" => "http://example.com/1",
          },
          "enclosure" => {
            "url" => "http://example.com/1.mp3",
            "length" => "100",
            "type" => "audio/mpeg",
          },
          "source" => {
            "url" => "http:/example.com/",
            "content" => "Sample site",
          },
          "category" => {
            "domain" => "http://example.com/misc/",
            "content" => "misc",
          },
        },

        {
          "title" => "Sample item2",
          "link" => @item_links[1],
          "description" => "Sample description2",
          "date" => Time.now - 7200,
          "author" => "foo@example.com",
          "comments" => "http://example.com/2/comments",
          "guid" => {
            "isPermaLink" => "false",
            "content" => "http://example.com/2",
          },
          "enclosure" => {
            "url" => "http://example.com/2.mp3",
            "length" => "200",
            "type" => "audio/mpeg",
          },
          "source" => {
            "url" => "http:/example.com/",
            "content" => "Sample site",
          },
          "category" => {
            "domain" => "http://example.com/misc/",
            "content" => "misc",
          },
        },
      ]
    end

    def setup_image_info
      @image_info = {
        "title" => "Sample image",
        "url" => @image_url,
        "width" => "88",
        "height" => "31",
        "description" => "Sample",
      }
    end

    def setup_textinput_info
      @textinput_info = {
        "title" => "Sample textinput",
        "description" => "Search",
        "name" => "key",
        "link" => @textinput_link,
      }
    end

    def setup_dublin_core_info
      @dc_info = {
        "title" => "DC title",
        "description" => "DC desc",
        "creator" => "DC creator",
        "subject" => "DC subject",
        "publisher" => "DC publisher",
        "contributor" => "DC contributor",
        "type" => "DC type",
        "format" => "DC format",
        "identifier" => "DC identifier",
        "source" => "DC source",
        "language" => "ja",
        "relation" => "DC relation",
        "coverage" => "DC coverage",
        "rights" => "DC rights",
        "date" => Time.now - 60,
      }
    end

    def setup_syndication_info
      @sy_info = {
        "updatePeriod" => "hourly",
        "updateFrequency" => 2,
        "updateBase" => Time.now - 3600,
      }
    end
    
    def setup_content_info
      @content_info = {
        "encoded" => "<p>p</p>",
      }
    end
    
    def setup_trackback_info
      @trackback_info = {
        "ping" => "http://example.com/tb.cgi?tb_id=XXX",
        "abouts" => [
          "http://example.net/tb.cgi?tb_id=YYY",
          "http://example.org/tb.cgi?tb_id=ZZZ",
        ]
      }
    end


    def setup_full(maker)
      setup_xml_declaration(maker)
      setup_xml_stylesheets(maker)
      setup_channel(maker)
      setup_image(maker)
      setup_items(maker)
      setup_textinput(maker)
    end

    def setup_xml_declaration(maker)
      %w(version encoding standalone).each do |name|
        maker.__send__("#{name}=", instance_eval("@#{name}"))
      end
    end

    def setup_xml_stylesheets(maker)
      @xs_infos.each do |info|
        xs = maker.xml_stylesheets.new_xml_stylesheet
        info.each do |name, value|
          xs.__send__("#{name}=", value)
        end
      end
    end

    def setup_channel(maker)
      channel = maker.channel
      info = @channel_info
      
      %w(about title link description language copyright
         managingEditor webMaster rating docs date
         lastBuildDate generator ttl).each do |name|
        channel.__send__("#{name}=", info[name])
      end

      skipDays = channel.skipDays
      info["skipDays"].each do |day|
        new_day = skipDays.new_day
        new_day.content = day
      end

      skipHours = channel.skipHours
      info["skipHours"].each do |hour|
        new_hour = skipHours.new_hour
        new_hour.content = hour
      end
      
      cloud = channel.cloud
      %w(domain port path registerProcedure protocol).each do |name|
        cloud.__send__("#{name}=", info["cloud"][name])
      end

      category = channel.categories.new_category
      %w(domain content).each do |name|
        category.__send__("#{name}=", info["category"][name])
      end
    end
    
    def setup_image(maker)
      image = maker.image
      info = @image_info

      %w(title url width height description).each do |name|
        image.__send__("#{name}=", info[name])
      end
    end
    
    def setup_items(maker)
      items = maker.items

      @item_infos.each do |info|
        item = items.new_item
        %w(title link description date author comments).each do |name|
          item.__send__("#{name}=", info[name])
        end
        
        guid = item.guid
        %w(isPermaLink content).each do |name|
          guid.__send__("#{name}=", info["guid"][name])
        end

        enclosure = item.enclosure
        %w(url length type).each do |name|
          enclosure.__send__("#{name}=", info["enclosure"][name])
        end

        source = item.source
        %w(url content).each do |name|
          source.__send__("#{name}=", info["source"][name])
        end

        category = item.categories.new_category
        %w(domain content).each do |name|
          category.__send__("#{name}=", info["category"][name])
        end

        setup_trackback(item)
      end
    end

    def setup_textinput(maker)
      textinput = maker.textinput
      info = @textinput_info

      %w(title description name link).each do |name|
        textinput.__send__("#{name}=", info[name])
      end
    end

    def setup_content(target)
      prefix = "content"
      %w(encoded).each do |name|
        target.__send__("#{prefix}_#{name}=", @content_info[name])
      end
    end
    
    def setup_dublin_core(target)
      prefix = "dc"
      %w(title description creator subject publisher
        contributor type format identifier source language
        relation coverage rights).each do |name|
        target.__send__("#{prefix}_#{name}=", @dc_info[name])
      end
    end
    
    def setup_syndicate(target)
      prefix = "sy"
      %w(updatePeriod updateFrequency updateBase).each do |name|
        target.__send__("#{prefix}_#{name}=", @sy_info[name])
      end
    end
    
    def setup_trackback(target)
      target.trackback_ping = @trackback_info["ping"]
      @trackback_info["abouts"].each do |about|
        new_about = target.trackback_abouts.new_about
        new_about.value = about
      end
    end
    
  end
end
