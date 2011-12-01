require 'test/unit'

class ImagesUsedTest < Test::Unit::TestCase

  def run_script(directory,args="")
    `./images_used.rb -v #{args} #{directory} > out.txt`
    output = File.open("out.txt","r").readlines
    result = {}

    get_section = Proc.new{ |section_text,output| output.drop_while{ |x| !(x.include?(section_text)) }.drop(2).take_while{ |x| !(x.include?("-------")) }.select{|x| x.strip != ""}.map{|x| x.strip } }

    result[:not_used] = get_section.call("Resources not used:",output)
    result[:used] = get_section.call("Resources used",output)
    result[:duplicates] = get_section.call("Duplicate Resources:",output)
    result[:image_files] = get_section.call("Resources:",output)
    result[:code_files] = get_section.call("Code Files:",output)

    `rm out.txt`

    return result
  end

  def test_without_comments
    output = run_script("./Test1")

    assert(output[:used].include?("1.png"))
    assert(output[:used].include?("2.png"))

    assert(output[:not_used].empty?)
    assert(output[:used].count == 2)
  end

def test_with_comments
    output = run_script("./Test1","-c")

    assert(output[:not_used].include?("1.png"))
    assert(output[:used].include?("2.png"))

    assert(output[:not_used].count == 1)
    assert(output[:used].count == 1)
end

end
