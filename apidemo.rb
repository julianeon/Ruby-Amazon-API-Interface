require "rubygems"
require "amazon_product"

req = AmazonProduct["us"]

req.configure do |c|
  c.key    = "intentionally_left_blank"
  c.secret = "intentionally_left_blank"
  c.tag    = "intentionally_left_blank"
end

a = File.open(ARGV.first).readlines
a.map! { |x| x.chomp }

asin = Array.new
cardvalue = Array.new

a.each do |x| 
   y = x.split(",")
   y.each { |z| z.to_i > 1000 ? asin.push(z) : cardvalue.push(z) }
end

h = Hash.new
a.each_index { |x| h[asin[x]]= cardvalue[x]}

fn = File.open(ARGV.first.sub(/\./, 'low.'),'w')

top=0
while top<asin.length
   req << { 
         'Operation'                       => 'ItemLookup',
         'ItemLookup.Shared.IdType'        => 'ASIN',
         'ItemLookup.Shared.Condition'     => 'All',
         'ItemLookup.Shared.MerchantId'    => 'All',
         'ItemLookup.Shared.ResponseGroup' => 'OfferFull',
         'ItemLookup.1.ItemId'             => asin[top, 10],
         'ItemLookup.2.ItemId'             => asin[top+10, 10] }
    resp = req.get
    top+=20

    #puts(resp.to_hash)

    resp.each('Item') do |item|
       #puts item
       isbn=item['ASIN']
       card = h[isbn]
       #puts isbn
       if (item['OfferSummary']['LowestUsedPrice'] != nil)
          price = item['OfferSummary']['LowestUsedPrice']['Amount'].to_f/100 
       else
          price = item['OfferSummary']['LowestNewPrice']['Amount'].to_f/100
       end
       word = isbn + "," + price.to_s + "," + card + "\n"
       (card.to_f*0.65) > (price+3.99) ? fn.write(word) : word
    end  

   puts (top*100/asin.length)
    
end

print Time.now.hour.modulo(12),":",Time.now.min,"\n"

