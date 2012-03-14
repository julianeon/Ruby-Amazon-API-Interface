require 'hpricot'
require 'rubygems'
require 'mechanize'

lines = File.open(ARGV.shift).readlines
lines.map! { |x| x.split(/,/)[0].chomp }

a = Mechanize.new
ft = File.open("newprice.txt",'w')

lines.each do |x|
   word = "http://www.amazon.com/dp/"
   word += x
   word += "/"
   fn = File.open("file.txt",'w')
   a.get(word) do |page|
      fn.write(page.body)
   end

   doc = Hpricot(open("file.txt"))

   hold="0.0"

   doc.search(".qpHeadline").each do |title|
      hold = title.inner_html
      puts hold
   end

   r=/[0-9]+.[0-9]+/
   j = (hold.match r).to_s
   fileline = x + "," + j + "," + "\n"
   ft.write(fileline)
   fn.close
   sleep(3.to_f+rand(100-400).to_f/100)
end

ft.close

