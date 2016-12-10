require 'rails_helper'

describe Contact do
  it 'is valid with a firstname, lastname and email' do
    contact = Contact.new(
      firstname: 'Bruce',
      lastname: 'Wayne',
      email: 'batman@batcave.org'
    )
    expect(contact).to be_valid
  end

  it 'is invalid without a firstname' do
    contact = Contact.new(firstname: nil)
    # contact.valid? # WHY DO THIS?!? IT DOES NOTHING!
    expect(contact).to be_invalid
    expect(contact.errors[:firstname]).to include("can't be blank")
  end

  it 'is invalid without a lastname' do
    contact = Contact.new(lastname: nil)
    expect(contact).to be_invalid
    expect(contact.errors[:lastname]).to include("can't be blank")
  end

  it 'is invalid without an email address' do
    contact = Contact.new(email: nil)
    expect(contact).to be_invalid
    expect(contact.errors[:email]).to include("can't be blank")
  end

  it 'is invalid with a duplicate email address' do
    Contact.create(
      firstname: 'Joe',
      lastname: 'Tester',
      email: 'tester@example.com'
    )
    contact = Contact.new(
      firstname: 'Jane',
      lastname: 'Tester',
      email: 'tester@example.com'
    )
    expect(contact).to be_invalid
    expect(contact.errors[:email]).to include('has already been taken')
  end

  it "returns a contact's full name as a string" do
    contact = Contact.new(
      firstname: 'John',
      lastname: 'Doe',
      email: 'johndoe@example.com'
    )
    expect(contact.name).to eq 'John Doe'
  end

  describe 'filter last name by letter' do
    before :each do
      @smith = Contact.create(
        firstname: 'John',
        lastname: 'Smith',
        email: 'jsmith@example.com'
      )
      @jones = Contact.create(
        firstname: 'Tim',
        lastname: 'Jones',
        email: 'tjones@example.com'
      )
      @johnson = Contact.create(
        firstname: 'John',
        lastname: 'Johnson',
        email: 'jjohnson@example.com'
      )
    end

    context 'matching letters' do
      it 'returns a sorted array of results that match' do
        expect(Contact.by_letter('J')).to eq [@johnson, @jones]
      end
    end

    context 'non-matching letters' do
      it 'ommits results that do not match letter given' do
        expect(Contact.by_letter('J')).to_not include @smith
      end
    end
  end
end
