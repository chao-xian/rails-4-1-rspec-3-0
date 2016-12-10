require 'rails_helper'

describe Phone do
  it 'does not allow duplicate phone numbers per contact' do
    contact = Contact.create(
      firstname: 'Joe',
      lastname: 'Tester',
      email: 'joetester@example.com'
    )
    contact.phones.create(
      phone_type: 'home',
      phone: '785-555-1234'
    )
    mobile_phone = contact.phones.build(
      phone_type: 'mobile',
      phone: '785-555-1234'
    )

    # mobile_phone.valid? # This is used to *trigger* the validations. But doing be_valid does and also tests
    expect(mobile_phone).to be_invalid
    expect(mobile_phone.errors[:phone]).to include('has already been taken')
  end

  it 'allows two contacts to share a phone number' do
    create(:phone)
    other_phone = build(:phone)
    expect(other_phone).to be_valid
  end
end
