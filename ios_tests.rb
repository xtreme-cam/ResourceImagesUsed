require 'test/unit'

class ImagesUsedTest < Test::Unit::TestCase

  def run_script(directory,args="")
    `./images_used.rb -v #{args} #{directory} > out.txt`
    output = File.open("out.txt","r").readlines
    result = {}
    result[:not_used] = output.drop_while{ |x| !(x.include?("Resources not used:")) }.drop(2).take_while{ |x| !(x.include?("-------")) }.select{|x| x.strip != ""}.map{|x| x.strip }
    result[:used] = output.drop_while{ |x| !(x.include?("Resources used:")) }.drop(2).take_while{ |x| !(x.include?("-------")) }.select{|x| x.strip != ""}.map{|x| x.strip }
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
