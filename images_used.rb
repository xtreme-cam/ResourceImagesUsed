#!/usr/bin/ruby

if ARGV.length < 1
  puts "tell me which dir..."
  exit 1
end

unless File.directory?(ARGV[0])
  puts "please provide a valid directory..."
  exit 1
end

class Array
  def only_duplicates
    duplicates = []
    self.each {|each| duplicates << each if self.count(each) > 1}
    duplicates
  end
end

class DirParser
  attr_accessor :code, :imgs

  def initialize(file=".")
    @files = []
    @code = []
    @imgs = []
    @img_exts = ["png","jpg","jpeg"]
    @code_exts = ["m","h","xib","c","cc","cpp","html","xml","erb","rb"]

    @files << file

    get_files
  end

  def process_file(f)
#    print "."
    if "." == f
      #do nothing
    elsif ".." == f
      #do nothing
    elsif File.directory?(f)
      @files = Dir.entries(f).select{|i| i != "." && i != ".." }.map{ |p| "#{f}/#{p}" } + @files
    else
      #is file
      ext = f.split(".").last
      if @img_exts.include?(ext)
        f["@2x."] = "." unless f.index("@2x").nil?
        @imgs << f
      elsif @code_exts.include?(ext)
        @code << f
      end
    end
  end

  def get_files
    while @files.count > 0
      f = @files.pop
      process_file(f)
    end
  end

end

p = DirParser.new(ARGV[0])

def hor_line
  puts "--------------------------------------------------"
end

puts "\n"
#hor_line
#puts "code files:"
#hor_line
#puts p.code.join("\n")
#puts "\n"
#hor_line
#puts "images:"
#hor_line
#puts p.imgs.join("\n")

imgs = p.imgs.map{ |i| i.split("/").last }.uniq
not_used = imgs

usages = {}

p.code.each do |c|
  f = File.open(c,"r")
  contents = f.readlines

  #remove comments

  contents.each do |l|
    words = l.split

    intersect = []
    words.each { |w|
      imgs.each { |i|
        intersect << i unless w.index(i).nil?
      }
    }
    intersect.uniq!

    intersect.each do |image|
      occurence = {:line => l, :resource => image, :line_number => contents.index(l)}
      not_used.delete(image)
      if usages[image].nil?
        usages[image] = [occurence]
      else
        usages[image] << occurence
      end
    end
  end
end

puts "\n"
hor_line
puts "Resources not used:"
hor_line
puts not_used.join("\n")
puts "\n"
#hor_line
#puts "Resources used:"
#hor_line
#puts usages.keys.join("\n")


dup_imgs = p.imgs.map{ |i| i.split("/").last }.only_duplicates.uniq
puts "\n"
hor_line
puts "Duplicate Resources:"
hor_line
puts dup_imgs.join("\n")
puts "\n"
