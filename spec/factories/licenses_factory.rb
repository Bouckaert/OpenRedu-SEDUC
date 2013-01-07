# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :license do
      name "Fulano de Tal"
      sequence(:login) do |n|
        login "fulano#{n}"
      end
      email "fulano@redu.com.br"
      period_start "2012-02-02"
      period_end "2012-02-02"
      role 2 # :member FIXME Aparece número estranho se deixar :member
      association :invoice, :factory => :licensed_invoice
      association :course
    end
end
