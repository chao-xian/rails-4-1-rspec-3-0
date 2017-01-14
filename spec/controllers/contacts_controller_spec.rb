require 'rails_helper'

describe ContactsController do
  describe "administrator access" do
    before :each do
      user = create(:admin)
      session[:user_id] = user.id
    end

    describe 'GET #index' do
      context 'with params[:letter]' do
        it 'populates an array of contacts starting with the letter' do
          smith = create(:contact, lastname: 'Smith')
          create(:contact, lastname: 'Jones')
          get :index, letter: 'S'
          expect(assigns(:contacts)).to match_array([smith])
        end

        it 'renders the :index template' do
          get :index, letter: 'S'
          expect(response).to render_template :index
        end
      end

      context 'without params[:letter]' do
        it 'populates an array of all contacts' do
          smith = create(:contact, lastname: 'Smith')
          jones = create(:contact, lastname: 'Jones')
          get :index
          expect(assigns(:contacts)).to match_array([smith, jones])
        end

        it 'renders the :index template' do
          get :index
          expect(response).to render_template :index
        end
      end
    end

    describe 'GET #show' do
      it 'assigns the requested contact to @contact' do
        contact = create(:contact)
        get :show, id: contact
        expect(assigns(:contact)).to eq contact
      end

      it 'renders the :show template' do
        contact = create(:contact)
        get :show, id: contact
        expect(response).to render_template :show
      end
    end

    describe 'GET #new' do
      it 'assigns a new Contact to @contact' do
        get :new
        expect(assigns(:contact)).to be_a_new(Contact)
      end

      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested contact to @contact' do
        contact = create(:contact)
        get :edit, id: contact
        expect(assigns(:contact)).to eq contact
      end

      it 'renders the :edit template' do
        contact = create(:contact)
        get :edit, id: contact
        expect(response).to render_template :edit
      end
    end

    describe 'POST #create' do
      before :each do
        @phones = [
          attributes_for(:phone),
          attributes_for(:phone),
          attributes_for(:phone),
        ]
      end

      context 'with valid attributes' do
        it 'saves the new contact in the database' do
          post_attributes = Proc.new do
            post(:create, contact: attributes_for(:contact,
            phones_attributes: @phones))
          end
          expect(post_attributes).to change(Contact, :count).by 1
        end

        it 'redirects to contact#show' do
          post(:create, contact: attributes_for(:contact,
            phones_attributes: @phones))
          expect(response).to redirect_to contact_path(assigns[:contact])
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new contact in the database' do
          post_attributes = Proc.new do
            post :create,
              contact: attributes_for(:invalid_contact)
          end
          expect(post_attributes).not_to change(Contact, :count)
        end

        it 're-renders the :new template' do
          post(:create, contact: attributes_for(:invalid_contact))
          expect(response).to render_template :new
        end
      end
    end

    describe 'PATCH #update' do
      before :each do
        @contact = create(
          :contact,
          firstname: 'Lawrence',
          lastname: 'Smith',
        )
      end

      context 'with valid attributes' do
        it 'locates the requested @contact' do
          patch :update, id: @contact, contact: attributes_for(:contact)
          expect(assigns(:contact)).to eq(@contact)
        end

        it "changes @contact's attributes" do
          patch :update, id: @contact, contact: attributes_for(
            :contact,
            firstname: 'Larry',
            lastname: 'Smithers',
          )
          @contact.reload
          expect(@contact.firstname).to eq('Larry')
          expect(@contact.lastname).to eq('Smithers')
        end

        it 'redirects to the updated contact' do
          patch :update, id: @contact, contact: attributes_for(:contact)
          expect(response).to redirect_to @contact
        end
      end

      context 'with invalid attributes' do
        it "does not change the contact's attributes" do
          patch :update, id: @contact,
            contact: attributes_for(
              :contact,
              firstname: 'Larry',
              lastname: nil
            )
          @contact.reload
          expect(@contact.firstname).not_to eq('Larry')
          expect(@contact.lastname).to eq('Smith')
        end

        it 're-renders the :edit template' do
          patch :update, id: @contact,
            contact: attributes_for(:invalid_contact)
          expect(response).to render_template :edit
        end
      end
    end

    describe 'DELETE #destroy' do
      before :each do
        @contact = create(:contact)
      end

      it 'deletes the contect from the database' do
        expect { delete :destroy, id: @contact }.to change(Contact, :count).by(-1)
      end

      it 'redirects to users#index' do
        delete :destroy, id: @contact
        expect(response).to redirect_to contacts_url
      end
    end

    describe "PATCH hide_contact" do
      before :each do
        @contact = create(:contact)
      end

      it "marks the contact as hidden" do
        patch :hide_contact, id: @contact
        expect(@contact.reload.hidden?).to be true
      end

      it "redirects to the contacts#index" do
        patch :hide_contact, id: @contact
        expect(response).to redirect_to contacts_url
      end
    end
  end

  describe "guest access" do
    describe 'GET #new' do
      it "requires login" do
        get :new
        expect(response).to redirect_to login_url
      end
    end

    describe 'GET #edit' do
      it "requires login" do
        contact = create(:contact)
        get :edit, id: contact
        expect(response).to redirect_to login_url
      end
    end

    describe 'POST #create' do
      it "requires login" do
        post :create, id: create(:contact),
          contact: attributes_for(:contact)
        expect(response).to redirect_to login_url
      end
    end

    describe 'PATCH #update' do
      it "requires login" do
        put :update, id: create(:contact),
          contact: attributes_for(:contact)
        expect(response).to redirect_to login_url
      end
    end

    describe 'DELETE #destroy' do
      it "requires login" do
        delete :destroy, id: create(:contact)
        expect(response).to redirect_to login_url
      end
    end
  end
end
