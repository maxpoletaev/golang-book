module Jekyll

  module Compressor
    def compress_html(content)
      content.gsub(/(?>[^\S ]\s*|\s{2,})(?=(?:(?:[^<]++|<(?!\/?(?:textarea|pre)\b))*+)(?:<(?>textarea|pre)\b|\z))/ix, '')
    end

    def output_file(dest, content)
      FileUtils.mkdir_p(File.dirname(dest))
      File.open(dest, 'w') do |f|
        f.write(content)
      end
    end

    def output_html(dest, content)
      path = self.destination(dest)
      self.output_file(path, compress_html(content))
    end
  end


  class Post
    include Compressor

    def write(dest)
      self.output_html(dest, self.output)
    end
  end


  class Page
    include Compressor

    def write(dest)
      self.output_html(dest, self.output)
    end
  end

end
