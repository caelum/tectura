require 'md5'
require File.expand_path(File.dirname(__FILE__) + "/../../config/banners")

module ApplicationHelper
  #def forum_posts_path(forum, options = {})
  #	super(Forum.first, options)
  #end
  
  def random_banner
    BANNERS[rand(BANNERS.size)]
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed-icon.png', :size => '14x14', :alt => "Assine o feed do #{title}"), url
  end

  def pagination(collection)
    if collection.total_entries > 1
      "<p class='pages'>" + I18n.t('txt.pages', :default => 'Pages') + ": <strong>" +
      will_paginate(collection, :inner_window => 10, :next_label => I18n.t('txt.page_next', :default => 'next'), :prev_label => I18n.t('txt.page_prev', :default => 'previous')) +
      "</strong></p>"
    end
  end

  def next_page(collection)
    unless collection.current_page == collection.total_entries or collection.total_entries == 0
      "<p style='float:right;'>" + link_to(I18n.t('txt.next_page', :default => 'next page'), { :page => collection.current_page.next }.merge(params.reject{|k,v| k=="page"})) + "</p>"
    end
  end

  def search_posts_title
    returning(params[:q].blank? ? I18n.t('txt.recent_posts', :default => 'Recent Posts') : I18n.t('txt.searching_for', :default => 'Searching for') + " '#{h params[:q]}'") do |title|
      title << " " + I18n.t('txt.by_user', :default => 'by %{user}', :user => h(@user.display_name)) if @user
      title << " " + I18n.t('txt.in_forum', :default => 'in %{forum}', :forum => h(@forum.name)) if @forum
    end
  end

  def topic_title_link(topic, options)
    if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
      "<span class='flag'>#{$1}</span>" +
      link_to(h($2.strip), forum_topic_path(@forum, topic), options)
    else
      link_to(h(topic.title), forum_topic_path(@forum, topic), options)
    end
  end

  def ajax_spinner_for(id, spinner="spinner.gif")
    "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
  end

  def avatar_for(user, size=32)
    image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.md5(user.email)}&rating=PG&size=#{size}", :size => "#{size}x#{size}", :class => 'photo'
  end

  def for_moderators_of(record, &block)
    moderator_of?(record) && concat(capture(&block))
  end

  def display_linked_tags(topic)
    topic.tag_list.map{|t| link_to("##{t}", tag_path(t),:class => "tag-link")}.join(" ")
  end

  def display_tags_as_keywords(topic)
    topic.tag_list.map{|t| "#{t}"}.join(", ")
  end
  
  def add_links(str)
    rules = {
      "//registration//" => link_to(I18n.t("txt.registration", :default => "registration"), settings_path)
    }
    rules.each do |from, to|
      str = str.gsub(from, to)
    end
    str
  end

  # i18n do will_paginate

  include WillPaginate::ViewHelpers

  def will_paginate_with_i18n(collection, options = {})
    will_paginate_without_i18n(collection, options.merge(:previous_label => I18n.t(:previous), :next_label => I18n.t(:next)))
  end

  alias_method_chain :will_paginate, :i18n

  # /i18n

  # INCLUDES

  include PathHelper
  include MonitorshipsHelper
  include ReCaptcha::ViewHelper

  # /INCLUDES

  def show_all_link
    if session[:show_all] == true
      link_to I18n.t("txt.hide_downvoted"), hide_downvoted_path, :id => "show_control_link"
    else
      link_to I18n.t("txt.show_all"), show_all_path, :id => "show_control_link"
    end
  end
end
