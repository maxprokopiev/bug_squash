# Item   Unit      Special
#         Price     Price
#  --------------------------
#    A     50       3 for 130
#    B     30       2 for 45
#    C     20
#    D     15

class CheckOut

  def initialize(rules)
    @rules = rules
    @products = []
  end

  def scan(product)
    @products << product
  end

  def total
    calculate!
    @total
  end

  private
  def calculate!
    @total = 0
    qtd_product = {}
    @rules.keys.each do |k|
      qtd_product[k] = @products.select { |p| p == k}.count
    end

    qtd_product.each_pair do |prod, quantity|
      if @rules[prod].key? :promotion
        qtt_prod_normal_price = qtt_normal_price_for(quantity, @rules[prod][:promotion][:qtt])
        qtt_prod_special_price = qtt_special_price_for(quantity, @rules[prod][:promotion][:qtt])

        special_price = (qtt_prod_special_price * @rules[prod][:promotion][:special_price])
        normal_price = (qtt_prod_normal_price * @rules[prod][:price])

        @total += (special_price + normal_price)
      else
        @total += @rules[prod][:price] * quantity
      end
    end
  end

  def qtt_normal_price_for(prod_qtt, promotion_qtt)
    prod_qtt % promotion_qtt
  end

  def qtt_special_price_for(prod_qtt, promotion_qtt)
    prod_qtt / promotion_qtt
  end
end

RSpec.describe CheckOut do
  RULES = {
    'A' => { price: 50, promotion: { qtt: 3, special_price: 130 } },
    'B' => { price: 30, promotion: { qtt: 2, special_price: 45 } },
    'C' => { price: 20 },
    'D' => { price: 15 }
  }

  subject(:checkout) { described_class.new(RULES) }

  it 'incremential scanning on the same bill' do
    expect(checkout.total).to eq(0)

    checkout.scan('A')
    expect(checkout.total).to eq(50)

    checkout.scan('B')
    expect(checkout.total).to eq(80)

    checkout.scan('A')
    expect(checkout.total).to eq(130)

    checkout.scan('A')
    expect(checkout.total).to eq(160)

    checkout.scan('B')
    expect(checkout.total).to eq(175)
  end

  def total_of(items)
    checkout = described_class.new(RULES)
    items.each do |item|
      checkout.scan(item)
    end
    checkout.total
  end

  it 'checking total of separate bills' do
    expect(total_of([])).to eq(0)
    expect(total_of(%w(A))).to eq(50)
    expect(total_of(%w(A B))).to eq(80)
    expect(total_of(%w(C D B A))).to eq(115)

    expect(total_of(%w(A A))).to eq(100)
    expect(total_of(%w(A A A))).to eq(130)
    expect(total_of(%w(A A A A))).to eq(180)
    expect(total_of(%w(A A A A A))).to eq(230)
    expect(total_of(%w(A A A A A A))).to eq(260)

    expect(total_of(%w(A A A B))).to eq(160)
    expect(total_of(%w(A A A B B))).to eq(175)
    expect(total_of(%w(A A A B B D))).to eq(190)
    expect(total_of(%w(D A B A B A))).to eq(190)
  end
end
