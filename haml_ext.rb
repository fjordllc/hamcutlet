class Hpricot::Comment
  def to_haml(tabs, options)
    content = self.content
    if content =~ /\A(\[[^\]]+\])>(.*)<!\[endif\]\z/m
      condition = $1
      content = $2
    end
    if content.include?("\n")
      "#{tabulate(tabs)}/#{condition}\n#{parse_text(content, tabs + 1)}"
    else
      "#{tabulate(tabs)}/#{condition} #{content.strip}\n"
    end
  end
end

class Hpricot::Elem
  def to_haml_filter(filter, tabs, options)
    content =
      if children.first.is_a?(::Hpricot::CData)
        children.first.content
      elsif children.first.is_a?(::Hpricot::Comment)
        children.first.content.gsub(/\/\/$/, '')
      else
        CGI.unescapeHTML(self.innerText)
      end

    content = erb_to_interpolation(content, options)
    content.gsub!(/\A\s*\n(\s*)/, '\1')
    original_indent = content[/\A(\s*)/, 1]
    if content.split("\n").all? {|l| l.strip.empty? || l =~ /^#{original_indent}/}
      content.gsub!(/^#{original_indent}/, tabulate(tabs + 1))
    end

    "#{tabulate(tabs)}:#{filter}\n#{content}"
  end
end
